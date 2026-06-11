SELECT 
    Crop_Name,
    AVG(NDVI_Season_Mean) AS Avg_NDVI,
    COUNT(*) AS Total_Records
FROM [Data]
GROUP BY Crop_Name
ORDER BY Avg_NDVI DESC;

SELECT 
    Season,
    AVG(NDVI_Season_Mean) AS Avg_NDVI,
    AVG(Rainfall) AS Avg_Rainfall,
    AVG(Temp_Mean) AS Avg_Temperature
FROM [Data]
GROUP BY Season
ORDER BY Avg_NDVI DESC;

SELECT 
    District,
    Crop_Name,
    Season,
    NDVI_Season_Mean,
    Avg_Salinity_Index
FROM [Data]
WHERE NDVI_Season_Mean < 0.45
  AND Avg_Salinity_Index > 500
ORDER BY Avg_Salinity_Index DESC;

SELECT 
    Crop_Name,
    Season,
    AVG(NDVI_Season_Mean) AS Avg_NDVI,
    AVG(Rainfall) AS Avg_Rainfall,
    AVG(Soil_Moisture_mm) AS Avg_Soil_Moisture
FROM [Data]
GROUP BY Crop_Name, Season
ORDER BY Crop_Name, Avg_NDVI DESC;

SELECT 
    Crop_Name,
    Season,
    AVG(NDVI_Season_Mean) AS Avg_NDVI,
    RANK() OVER (
        PARTITION BY Season 
        ORDER BY AVG(NDVI_Season_Mean) DESC
    ) AS NDVI_Rank
FROM [Data]
GROUP BY Crop_Name, Season
ORDER BY Season, NDVI_Rank;

SELECT 
    Crop_Name,
    AVG(NDVI_Season_Mean) AS Avg_NDVI
FROM [Data]
GROUP BY Crop_Name
HAVING AVG(NDVI_Season_Mean) > (
    SELECT AVG(NDVI_Season_Mean)
    FROM [Data]
)
ORDER BY Avg_NDVI DESC;

WITH CropSeason AS (
    SELECT 
        Crop_Name,
        Season,
        AVG(NDVI_Season_Mean) AS Crop_Season_NDVI
    FROM [Data]
    GROUP BY Crop_Name, Season
),
SeasonAvg AS (
    SELECT 
        Season,
        AVG(NDVI_Season_Mean) AS Season_Avg_NDVI
    FROM [Data]
    GROUP BY Season
)
SELECT 
    cs.Crop_Name,
    cs.Season,
    cs.Crop_Season_NDVI,
    sa.Season_Avg_NDVI,
    cs.Crop_Season_NDVI - sa.Season_Avg_NDVI AS Difference
FROM CropSeason cs
JOIN SeasonAvg sa
    ON cs.Season = sa.Season
ORDER BY cs.Season, Difference DESC;