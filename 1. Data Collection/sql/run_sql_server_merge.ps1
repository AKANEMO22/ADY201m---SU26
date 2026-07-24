$ErrorActionPreference = "Stop"

# Cau hinh SQL Server.
$server = "localhost"
$database = "ADY201_Agriculture"

$sqlDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$dataDir = Split-Path -Parent $sqlDir

$sqlcmd = "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\SQLCMD.EXE"
$bcp = "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\BCP.EXE"

$setupSql = Join-Path $sqlDir "05_SQL_Server_Setup.sql"
$mergeSql = Join-Path $sqlDir "06_SQL_Server_Final_Merge.sql"

$soilCsv = Join-Path $dataDir "Process_Bangladesh_soil_data_Merge.csv"
$weatherCsv = Join-Path $dataDir "Process_Bangladesh_weather_data_Merge.csv"
$geeCsv = Join-Path $dataDir "Process_Bangladesh_GEE_Indices_Merge.csv"
$sampleCsv = Join-Path $sqlDir "sample_map_seed42.csv"

# Xuat file moi de so sanh, khong ghi de file Final cu.
$outputCsv = Join-Path $dataDir "Bangladesh_database_Final_Merged_SQLServer.csv"

function Check-File {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Khong tim thay file: $Path"
    }
}

function Run-SqlFile {
    param([string]$Path)

    & $sqlcmd `
        -S $server `
        -E `
        -b `
        -i $Path

    if ($LASTEXITCODE -ne 0) {
        throw "SQL Server chay that bai: $Path"
    }
}

function Import-CsvToTable {
    param(
        [string]$CsvPath,
        [string]$TableName
    )

    Write-Host "Nap $TableName tu $([IO.Path]::GetFileName($CsvPath))..."

    & $bcp `
        "$database.dbo.$TableName" `
        in $CsvPath `
        -S $server `
        -T `
        -c `
        -C 65001 `
        -t "," `
        -F 2

    if ($LASTEXITCODE -ne 0) {
        throw "Khong nap duoc bang $TableName."
    }
}

Check-File $sqlcmd
Check-File $bcp
Check-File $setupSql
Check-File $mergeSql
Check-File $soilCsv
Check-File $weatherCsv
Check-File $geeCsv
Check-File $sampleCsv

Write-Host "1. Tao database va cac bang staging..."
Run-SqlFile $setupSql

Write-Host "`n2. Nap CSV vao SQL Server..."
Import-CsvToTable $soilCsv "SoilData"
Import-CsvToTable $weatherCsv "WeatherData"
Import-CsvToTable $geeCsv "GeeRawImport"
Import-CsvToTable $sampleCsv "SampleMap"

Write-Host "`n3. Chay LEFT JOIN bang T-SQL..."
Run-SqlFile $mergeSql

Write-Host "`n4. Xuat bang SQL Server ve CSV..."

$connectionString = (
    "Server=$server;" +
    "Database=$database;" +
    "Integrated Security=True;" +
    "TrustServerCertificate=True;"
)

$query = @"
SELECT [AP Ratio], District, Season, [Avg Humidity], [Crop Name],
       Transplant, Growth, NDVI, EVI, LAI, FPAR, LST_Kelvin,
       Soil_Moisture_mm, Avg_Salinity_Index, pH, Organic_Carbon,
       Nitrogen, Clay, Silt, CN_Ratio, Dominant_Soil_Texture,
       Rainfall, Temp_Mean, Temp_Max, Temp_Min, Heat_Stress_Days,
       Wind_Mean, Wind_Max, Rain_Temp_Ratio
FROM dbo.BangladeshFinalMerged
ORDER BY OutputOrder;
"@

$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
$command = New-Object System.Data.SqlClient.SqlCommand($query, $connection)
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
$dataTable = New-Object System.Data.DataTable

try {
    $connection.Open()
    [void]$adapter.Fill($dataTable)
}
finally {
    $connection.Close()
}

$dataTable |
    Export-Csv `
        -LiteralPath $outputCsv `
        -NoTypeInformation `
        -Encoding utf8

Write-Host (
    "Hoan tat: {0:N0} dong x {1} cot" -f
    $dataTable.Rows.Count,
    $dataTable.Columns.Count
)
Write-Host "File moi: $outputCsv"
Write-Host "File Final cu chua bi ghi de."
