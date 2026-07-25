/*
    BUOC 1 - TAO DATABASE VA BANG NHAP DU LIEU

    GEE la bang goc 10.000 dong da khop voi MainData.
    SQL chi can LEFT JOIN Soil va Weather, khong can SampleMap.
*/

IF DB_ID(N'ADY201_Agriculture') IS NULL
    CREATE DATABASE ADY201_Agriculture;
GO

USE ADY201_Agriculture;
GO

DROP VIEW IF EXISTS dbo.GeeRawImport;
DROP TABLE IF EXISTS dbo.BangladeshFinalMerged;
/* Xoa bang cu neu database tung dung phien ban SampleMap. */
DROP TABLE IF EXISTS dbo.SampleMap;
DROP TABLE IF EXISTS dbo.GeeRaw;
DROP TABLE IF EXISTS dbo.SoilData;
DROP TABLE IF EXISTS dbo.WeatherData;
/* Xoa bang MainData cu: GeeRaw 10.000 dong da chua cac cot can dung. */
DROP TABLE IF EXISTS dbo.MainData;
GO

CREATE TABLE dbo.SoilData (
    District NVARCHAR(100) NOT NULL, pH NVARCHAR(255), OrganicCarbon NVARCHAR(255),
    Nitrogen NVARCHAR(255), Clay NVARCHAR(255), Silt NVARCHAR(255),
    CNRatio NVARCHAR(255), DominantSoilTexture NVARCHAR(255),
    CONSTRAINT PK_SoilData PRIMARY KEY (District)
);

CREATE TABLE dbo.WeatherData (
    Season NVARCHAR(50) NOT NULL, Rainfall NVARCHAR(255), TempMean NVARCHAR(255),
    TempMax NVARCHAR(255), TempMin NVARCHAR(255), HeatStressDays NVARCHAR(255),
    WindMean NVARCHAR(255), WindMax NVARCHAR(255),
    District NVARCHAR(100) NOT NULL, [Year] NVARCHAR(4) NOT NULL,
    RainTempRatio NVARCHAR(255),
    CONSTRAINT PK_WeatherData PRIMARY KEY (District, Season, [Year])
);

CREATE TABLE dbo.GeeRaw (
    SourceRowId INT IDENTITY(0,1) NOT NULL,
    Area NVARCHAR(255), APRatio NVARCHAR(255), District NVARCHAR(100) NOT NULL,
    Season NVARCHAR(50) NOT NULL, AvgTemp NVARCHAR(255), AvgHumidity NVARCHAR(255),
    CropName NVARCHAR(255), Transplant NVARCHAR(255), Growth NVARCHAR(255),
    Harvest NVARCHAR(255), Production NVARCHAR(255), MaxTemp NVARCHAR(255),
    MinTemp NVARCHAR(255), MaxRelativeHumidity NVARCHAR(255),
    MinRelativeHumidity NVARCHAR(255), NDVI NVARCHAR(255),
    [Year] NVARCHAR(4) NOT NULL,
    EVI NVARCHAR(255), LAI NVARCHAR(255), FPAR NVARCHAR(255),
    LSTKelvin NVARCHAR(255), SoilMoistureMm NVARCHAR(255),
    AvgSalinityIndex NVARCHAR(255),
    CONSTRAINT PK_GeeRaw PRIMARY KEY (SourceRowId)
);
GO

/* BCP nap vao view nay de SQL Server tu sinh SourceRowId theo thu tu CSV. */
CREATE VIEW dbo.GeeRawImport AS
SELECT Area, APRatio, District, Season, AvgTemp, AvgHumidity, CropName,
       Transplant, Growth, Harvest, Production, MaxTemp, MinTemp,
       MaxRelativeHumidity, MinRelativeHumidity, NDVI, [Year], EVI, LAI,
       FPAR, LSTKelvin, SoilMoistureMm, AvgSalinityIndex
FROM dbo.GeeRaw;
GO

/*
    Quan he vat ly de SSMS Database Diagram tu ve duong noi:
    GeeRaw.District -> SoilData.District
    GeeRaw.(District, Season, Year) -> WeatherData
*/
ALTER TABLE dbo.GeeRaw ADD CONSTRAINT FK_GeeRaw_SoilData
    FOREIGN KEY (District) REFERENCES dbo.SoilData(District);

ALTER TABLE dbo.GeeRaw ADD CONSTRAINT FK_GeeRaw_WeatherData
    FOREIGN KEY (District, Season, [Year])
    REFERENCES dbo.WeatherData(District, Season, [Year]);
GO
