SELECT
    COUNT(*) AS Total_Rows,
    COUNT(DISTINCT CONCAT(
        District, '|',
        Crop_Name, '|',
        Season, '|',
        NDVI, '|',
        Avg_Salinity_Index
    )) AS Unique_Rows
FROM dbo.[Data];
-- 1. NDVI trung bình theo cây trồng
SELECT 
    Crop_Name,
    ROUND(AVG(NDVI), 3) AS Avg_NDVI,
    COUNT(*) AS Total_Records
FROM dbo.[Data]
GROUP BY Crop_Name
ORDER BY Avg_NDVI DESC;


-- 2. So sánh sức khỏe cây trồng giữa các mùa
SELECT 
    Season,
    ROUND(AVG(NDVI), 3) AS Avg_NDVI,
    ROUND(AVG(Rainfall), 2) AS Avg_Rainfall,
    ROUND(AVG(Temp_Mean), 2) AS Avg_Temperature
FROM dbo.[Data]
GROUP BY Season
ORDER BY Avg_NDVI DESC;


-- 3. Tìm khu vực có NDVI thấp và độ mặn cao
SELECT 
    District,
    Crop_Name,
    Season,
    NDVI,
    Avg_Salinity_Index
FROM dbo.[Data]
WHERE NDVI < 0.45
  AND Avg_Salinity_Index > 500
ORDER BY Avg_Salinity_Index DESC;


-- 4. Thống kê NDVI theo cây trồng và mùa vụ
SELECT 
    Crop_Name,
    Season,
    ROUND(AVG(NDVI), 3) AS Avg_NDVI,
    ROUND(AVG(Rainfall), 2) AS Avg_Rainfall,
    ROUND(AVG(Soil_Moisture_mm), 2) AS Avg_Soil_Moisture
FROM dbo.[Data]
GROUP BY Crop_Name, Season
ORDER BY Crop_Name, Avg_NDVI DESC;


-- 5. Xếp hạng cây trồng theo NDVI trong từng mùa
SELECT 
    Crop_Name,
    Season,
    ROUND(AVG(NDVI), 3) AS Avg_NDVI,
    RANK() OVER (
        PARTITION BY Season
        ORDER BY AVG(NDVI) DESC
    ) AS NDVI_Rank
FROM dbo.[Data]
GROUP BY Crop_Name, Season
ORDER BY Season, NDVI_Rank;
