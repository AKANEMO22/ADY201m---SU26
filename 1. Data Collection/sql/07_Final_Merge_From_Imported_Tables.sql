USE Agri_bangladesh;
GO



DROP TABLE IF EXISTS dbo.Bangladesh_Final_Database;
GO

SELECT 

    G.*,
    

    S.pH, 
    S.Organic_Carbon, 
    S.Nitrogen, 
    S.Clay, 
    S.Silt, 
    S.CN_Ratio, 
    S.Dominant_Soil_Texture,
    

    W.Rainfall, 
    W.Temp_Mean, 
    W.Temp_Max, 
    W.Temp_Min, 
    W.Heat_Stress_Days, 
    W.Wind_Mean, 
    W.Wind_Max
    
INTO dbo.Bangladesh_Final_Database

FROM dbo.Process_Bangladesh_GEE_Indices_Merge AS G


LEFT JOIN dbo.Process_Bangladesh_soil_data_Merge AS S
    ON TRIM(G.District) = TRIM(S.District)

LEFT JOIN dbo.Process_Bangladesh_weather_data_Merge AS W
    ON TRIM(G.District) = TRIM(W.District) 
   AND TRIM(G.Season) = TRIM(W.Season) 
   AND TRY_CONVERT(INT, G.[Year]) = TRY_CONVERT(INT, W.[Year]);
GO

SELECT * FROM dbo.Bangladesh_Final_Database;
GO
