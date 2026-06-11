-- NDVI trung bình theo cây trồng
SELECT 
    Crop_Name,
    AVG(NDVI_Season_Mean) AS Avg_NDVI,
    COUNT(*) AS Total_Records
FROM [Data]
GROUP BY Crop_Name
ORDER BY Avg_NDVI DESC;
-- So sánh sức khỏe cây trồng giữa các mùa
SELECT 
    Season,
    AVG(NDVI_Season_Mean) AS Avg_NDVI,
    AVG(Rainfall) AS Avg_Rainfall,
    AVG(Temp_Mean) AS Avg_Temperature
FROM [Data]
GROUP BY Season
ORDER BY Avg_NDVI DESC;
-- So sánh sức khỏe cây trồng giữa các mùa
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
--Thống kê NDVI theo cây trồng và mùa vụ 
SELECT 
    Crop_Name,
    Season,
    AVG(NDVI_Season_Mean) AS Avg_NDVI,
    AVG(Rainfall) AS Avg_Rainfall,
    AVG(Soil_Moisture_mm) AS Avg_Soil_Moisture
FROM [Data]
GROUP BY Crop_Name, Season
ORDER BY Crop_Name, Avg_NDVI DESC;
-- Xếp hạng cây trồng theo NDVI trong từng mùa
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
