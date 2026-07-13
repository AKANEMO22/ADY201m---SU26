-- 1. NDVI trung bình theo cây trồng
SELECT 
    [Crop Name] AS Crop_Name,
    ROUND(AVG([NDVI_Season_Mean]), 3) AS Avg_NDVI,
    COUNT(*) AS Total_Records
FROM [Data]
GROUP BY [Crop Name]
ORDER BY Avg_NDVI DESC;


-- 2. So sánh sức khỏe cây trồng giữa các mùa
SELECT 
    [Season],
    ROUND(AVG([NDVI_Season_Mean]), 3) AS Avg_NDVI,
    ROUND(AVG([Rainfall]), 2) AS Avg_Rainfall,
    ROUND(AVG([Avg Temp]), 2) AS Avg_Temperature
FROM [Data]
GROUP BY [Season]
ORDER BY Avg_NDVI DESC;


-- 3. Tìm khu vực có NDVI thấp và độ mặn cao
SELECT 
    [District],
    [Crop Name] AS Crop_Name,
    [Season],
    ROUND([NDVI_Season_Mean], 3) AS NDVI_Season_Mean,
    ROUND([Avg_Salinity_Index], 2) AS Avg_Salinity_Index
FROM [Data]
WHERE [NDVI_Season_Mean] < 0.45
  AND [Avg_Salinity_Index] > 500
ORDER BY [Avg_Salinity_Index] DESC;


-- 4. Thống kê NDVI theo cây trồng và mùa vụ
SELECT 
    [Crop Name] AS Crop_Name,
    [Season],
    ROUND(AVG([NDVI_Season_Mean]), 3) AS Avg_NDVI,
    ROUND(AVG([Rainfall]), 2) AS Avg_Rainfall,
    ROUND(AVG([Soil_Moisture_mm]), 2) AS Avg_Soil_Moisture
FROM [Data]
GROUP BY 
    [Crop Name],
    [Season]
ORDER BY 
    [Crop Name],
    Avg_NDVI DESC;


-- 5. Xếp hạng cây trồng theo NDVI trong từng mùa
SELECT 
    [Crop Name] AS Crop_Name,
    [Season],
    ROUND(AVG([NDVI_Season_Mean]), 3) AS Avg_NDVI,

    RANK() OVER (
        PARTITION BY [Season]
        ORDER BY AVG([NDVI_Season_Mean]) DESC
    ) AS NDVI_Rank

FROM [Data]
GROUP BY 
    [Crop Name],
    [Season]
ORDER BY 
    [Season],
    NDVI_Rank;