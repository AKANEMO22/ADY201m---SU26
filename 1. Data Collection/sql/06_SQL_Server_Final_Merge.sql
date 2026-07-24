/*
    BUOC 2 - GHÉP DỮ LIỆU GIỐNG HỆT NOTEBOOK CŨ

    1. GEE (4.608 dong) lam bang goc.
    2. LEFT JOIN soil theo District.
    3. LEFT JOIN weather theo District + Season + Year.
    4. SampleMap dua ket qua len 10.000 dong dung seed 42.
*/

USE ADY201_Agriculture;
GO

IF (SELECT COUNT(*) FROM dbo.GeeRaw) <> 4608
    THROW 50001, 'GEE phai co dung 4.608 dong.', 1;

IF (SELECT COUNT(*) FROM dbo.SampleMap) <> 10000
    THROW 50002, 'SampleMap phai co dung 10.000 dong.', 1;

DROP TABLE IF EXISTS dbo.BangladeshFinalMerged;
GO

WITH BaseMerged AS (
    SELECT
        g.SourceRowId,
        g.APRatio AS [AP Ratio],
        CASE
            WHEN LOWER(REPLACE(TRIM(g.District), ' ', '')) = 'coxsbazar'
                THEN 'Coxsbazar'
            ELSE g.District
        END AS District,
        g.Season,
        g.AvgHumidity AS [Avg Humidity],
        g.CropName AS [Crop Name],
        g.Transplant,
        g.Growth,
        g.NDVI, g.EVI, g.LAI, g.FPAR,
        g.LSTKelvin AS LST_Kelvin,
        g.SoilMoistureMm AS Soil_Moisture_mm,
        g.AvgSalinityIndex AS Avg_Salinity_Index,
        s.pH, s.OrganicCarbon AS Organic_Carbon, s.Nitrogen,
        s.Clay, s.Silt, s.CNRatio AS CN_Ratio,
        s.DominantSoilTexture AS Dominant_Soil_Texture,
        w.Rainfall, w.TempMean AS Temp_Mean, w.TempMax AS Temp_Max,
        w.TempMin AS Temp_Min, w.HeatStressDays AS Heat_Stress_Days,
        w.WindMean AS Wind_Mean, w.WindMax AS Wind_Max,
        w.RainTempRatio AS Rain_Temp_Ratio
    FROM dbo.GeeRaw g
    LEFT JOIN dbo.SoilData s
      ON TRIM(g.District) = TRIM(s.District)
    LEFT JOIN dbo.WeatherData w
      ON TRIM(g.District) = TRIM(w.District)
     AND TRIM(g.Season) = TRIM(w.Season)
     AND TRY_CONVERT(INT, g.[Year]) = TRY_CONVERT(INT, w.[Year])
)
SELECT sm.OutputOrder,
       b.[AP Ratio], b.District, b.Season, b.[Avg Humidity], b.[Crop Name],
       b.Transplant, b.Growth, b.NDVI, b.EVI, b.LAI, b.FPAR, b.LST_Kelvin,
       b.Soil_Moisture_mm, b.Avg_Salinity_Index, b.pH, b.Organic_Carbon,
       b.Nitrogen, b.Clay, b.Silt, b.CN_Ratio, b.Dominant_Soil_Texture,
       b.Rainfall, b.Temp_Mean, b.Temp_Max, b.Temp_Min, b.Heat_Stress_Days,
       b.Wind_Mean, b.Wind_Max, b.Rain_Temp_Ratio
INTO dbo.BangladeshFinalMerged
FROM dbo.SampleMap sm
JOIN BaseMerged b ON b.SourceRowId = sm.SourceRowId;
GO

CREATE UNIQUE CLUSTERED INDEX IX_Final_OutputOrder
ON dbo.BangladeshFinalMerged(OutputOrder);
GO

IF (SELECT COUNT(*) FROM dbo.BangladeshFinalMerged) <> 10000
    THROW 50003, 'Ket qua khong co dung 10.000 dong.', 1;

SELECT COUNT(*) AS FinalRows, 29 AS ExportColumns
FROM dbo.BangladeshFinalMerged;
GO
