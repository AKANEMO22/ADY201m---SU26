/*
    BUOC 2 - GHEP DU LIEU BANG SQL SERVER

    1. GEE-enriched crop data (10.000 dong) lam bang goc.
    2. LEFT JOIN Soil theo District.
    3. LEFT JOIN Weather theo District + Season + Year.
    4. Giu nguyen 10.000 dong, khong sampling va khong SampleMap.
*/

USE ADY201_Agriculture;
GO

IF (SELECT COUNT(*) FROM dbo.GeeRaw) <> 10000
    THROW 50001, 'GEE phai co dung 10.000 dong.', 1;

DROP TABLE IF EXISTS dbo.BangladeshFinalMerged;
GO

WITH BaseMerged AS (
    SELECT
        g.SourceRowId,
        g.APRatio AS [AP Ratio],
        g.District,
        g.Season,
        g.AvgHumidity AS [Avg Humidity],
        g.CropName AS [Crop Name],
        g.Transplant,
        g.Growth,
        g.NDVI,
        g.EVI,
        g.LAI,
        g.FPAR,
        g.LSTKelvin AS LST_Kelvin,
        g.SoilMoistureMm AS Soil_Moisture_mm,
        g.AvgSalinityIndex AS Avg_Salinity_Index,
        s.pH,
        s.OrganicCarbon AS Organic_Carbon,
        s.Nitrogen,
        s.Clay,
        s.Silt,
        s.CNRatio AS CN_Ratio,
        s.DominantSoilTexture AS Dominant_Soil_Texture,
        w.Rainfall,
        w.TempMean AS Temp_Mean,
        w.TempMax AS Temp_Max,
        w.TempMin AS Temp_Min,
        w.HeatStressDays AS Heat_Stress_Days,
        w.WindMean AS Wind_Mean,
        w.WindMax AS Wind_Max,
        w.RainTempRatio AS Rain_Temp_Ratio
    FROM dbo.GeeRaw AS g
    LEFT JOIN dbo.SoilData AS s
      ON TRIM(g.District) = TRIM(s.District)
    LEFT JOIN dbo.WeatherData AS w
      ON TRIM(g.District) = TRIM(w.District)
     AND TRIM(g.Season) = TRIM(w.Season)
     AND TRY_CONVERT(INT, g.[Year]) = TRY_CONVERT(INT, w.[Year])
)
SELECT
    SourceRowId AS OutputOrder,
    [AP Ratio], District, Season, [Avg Humidity], [Crop Name],
    Transplant, Growth, NDVI, EVI, LAI, FPAR, LST_Kelvin,
    Soil_Moisture_mm, Avg_Salinity_Index, pH, Organic_Carbon,
    Nitrogen, Clay, Silt, CN_Ratio, Dominant_Soil_Texture,
    Rainfall, Temp_Mean, Temp_Max, Temp_Min, Heat_Stress_Days,
    Wind_Mean, Wind_Max, Rain_Temp_Ratio
INTO dbo.BangladeshFinalMerged
FROM BaseMerged;
GO

ALTER TABLE dbo.BangladeshFinalMerged
ADD CONSTRAINT PK_BangladeshFinalMerged PRIMARY KEY (OutputOrder);
GO

IF (SELECT COUNT(*) FROM dbo.BangladeshFinalMerged) <> 10000
    THROW 50002, 'Ket qua khong co dung 10.000 dong.', 1;

SELECT COUNT(*) AS FinalRows, 29 AS ExportColumns
FROM dbo.BangladeshFinalMerged;
GO
