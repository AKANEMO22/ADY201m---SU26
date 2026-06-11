-- =================================================================================
-- TRUY VẤN XUẤT DỮ LIỆU TƯƠNG ĐƯƠNG VỚI FINAL_MERGE.PY
-- Hướng dẫn:
-- 1. Chạy toàn bộ câu lệnh SELECT bên dưới trong SSMS.
-- 2. Click chuột phải vào ô kết quả (Results Grid) ở dưới cùng.
-- 3. Chọn "Save Results As..." và lưu thành "Bangladesh_database_Final_Merged.csv".
-- =================================================================================

SELECT 
    -- 1. Ba cột khóa chính (đẩy lên đầu giống code Python)
    g.[AP Ratio] AS [AP Ratio], 
    g.District, 
    g.Season,

    -- 2. Các cột còn lại từ GEE Indices (đã loại bỏ Avg Temp, Max Temp, Min Temp, 
    -- Max Relative Humidity, Min Relative Humidity, Year, Harvest, Area, Production)
    g.[Avg Humidity],
    g.[Crop Name],
    g.Transplant,
    g.Growth,
    g.NDVI_Season_Mean,
    g.EVI,
    g.LAI,
    g.FPAR,
    g.LST_Kelvin,
    g.Soil_Moisture_mm,
    g.Avg_Salinity_Index,

    -- 3. Toàn bộ các cột từ Soil Data
    s.pH,
    s.Organic_Carbon,
    s.Nitrogen,
    s.Clay,
    s.Silt,
    s.CN_Ratio,
    s.Dominant_Soil_Texture,

    -- 4. Toàn bộ các cột từ Weather Data
    w.Rainfall,
    w.Temp_Mean,
    w.Temp_Max,
    w.Temp_Min,
    w.Heat_Stress_Days,
    w.Wind_Mean,
    w.Wind_Max,
    w.Rain_Temp_Ratio

FROM 
    Process_Bangladesh_GEE_Indices_Merge g
LEFT JOIN 
    Process_Bangladesh_soil_data_Merge s 
    ON g.District = s.District
LEFT JOIN 
    Process_Bangladesh_weather_data_Merge w 
    ON g.District = w.District 
    AND g.Season = w.Season 
    AND g.Year = w.Year;
