/*
============================================================
 SQL ANALYSIS FILE
 Topic: Predict crop health index (NDVI_Season_Mean)
 Dataset table name: Data
 DBMS: SQL Server
============================================================

Main target variable:
- NDVI_Season_Mean: average vegetation health index during the crop season.

Main idea:
- Use SQL to explore how environment, soil, crop type, season,
  rainfall, temperature, heat stress, and salinity relate to NDVI.
- After running each query in SSMS / DBMS, take a screenshot of the output table
  and paste it into the report.
*/

/* ============================================================
 1. DATASET OVERVIEW
 Business inquiry:
 - How large is the dataset?
 - How many crops, districts, and seasons are available?
 Meaning:
 - This gives a basic understanding of the data size before modeling NDVI.
============================================================ */
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT Crop_Name) AS total_crops,
    COUNT(DISTINCT District) AS total_districts,
    COUNT(DISTINCT Season) AS total_seasons
FROM Data;


/* ============================================================
 2. TARGET VARIABLE SUMMARY: NDVI
 Business inquiry:
 - What is the general distribution of NDVI_Season_Mean?
 Meaning:
 - Min, max, average, and standard deviation show whether crop health
   is generally low, medium, or high in the dataset.
============================================================ */
SELECT
    MIN(NDVI_Season_Mean) AS min_ndvi,
    MAX(NDVI_Season_Mean) AS max_ndvi,
    AVG(NDVI_Season_Mean) AS avg_ndvi,
    STDEV(NDVI_Season_Mean) AS std_ndvi
FROM Data;


/* ============================================================
 3. NDVI BY CROP NAME
 Business inquiry:
 - Which crop types have higher average NDVI?
 SQL skills:
 - GROUP BY, aggregation, ORDER BY.
 Meaning:
 - Crop types with higher average NDVI may be healthier or more suitable
   under the observed environmental conditions.
============================================================ */
SELECT
    Crop_Name,
    COUNT(*) AS total_samples,
    AVG(NDVI_Season_Mean) AS avg_ndvi,
    MIN(NDVI_Season_Mean) AS min_ndvi,
    MAX(NDVI_Season_Mean) AS max_ndvi
FROM Data
GROUP BY Crop_Name
ORDER BY avg_ndvi DESC;


/* ============================================================
 4. NDVI BY SEASON
 Business inquiry:
 - Does crop health change across seasons?
 SQL skills:
 - GROUP BY, aggregation.
 Meaning:
 - If one season has higher NDVI, season may be an important feature
   for predicting crop health.
============================================================ */
SELECT
    Season,
    COUNT(*) AS total_samples,
    AVG(NDVI_Season_Mean) AS avg_ndvi,
    AVG(Rainfall) AS avg_rainfall,
    AVG(Temp_Mean) AS avg_temp,
    AVG(Soil_Moisture_mm) AS avg_soil_moisture
FROM Data
GROUP BY Season
ORDER BY avg_ndvi DESC;


/* ============================================================
 5. NDVI BY DISTRICT
 Business inquiry:
 - Which districts have better crop health on average?
 SQL skills:
 - GROUP BY, aggregation.
 Meaning:
 - District can represent local environmental differences such as soil,
   weather, irrigation, or farming condition.
============================================================ */
SELECT
    District,
    COUNT(*) AS total_samples,
    AVG(NDVI_Season_Mean) AS avg_ndvi,
    AVG(Rainfall) AS avg_rainfall,
    AVG(Avg_Salinity_Index) AS avg_salinity,
    AVG(Soil_Moisture_mm) AS avg_soil_moisture
FROM Data
GROUP BY District
ORDER BY avg_ndvi DESC;


/* ============================================================
 6. FILTERING: LOW NDVI / POSSIBLE STRESS CASES
 Business inquiry:
 - Which records show weak crop health and stressful conditions?
 SQL skills:
 - Filtering with WHERE.
 Meaning:
 - Low NDVI combined with high heat stress, high salinity, or low soil moisture
   may indicate environmental stress affecting crop health.
============================================================ */
SELECT TOP 30
    District,
    Crop_Name,
    Season,
    NDVI_Season_Mean,
    Heat_Stress_Days,
    Avg_Salinity_Index,
    Soil_Moisture_mm,
    Rainfall,
    Temp_Mean,
    LST_C
FROM Data
WHERE NDVI_Season_Mean < 0.40
   OR Heat_Stress_Days > 5
   OR Soil_Moisture_mm < 10
ORDER BY NDVI_Season_Mean ASC;


/* ============================================================
 7. RAINFALL LEVEL VS NDVI
 Business inquiry:
 - Does rainfall level affect average NDVI?
 SQL skills:
 - CASE WHEN, GROUP BY.
 Meaning:
 - Rainfall is converted into simple levels to make the relationship
   easier to interpret for the report.
============================================================ */
WITH rainfall_group AS (
    SELECT
        *,
        CASE
            WHEN Rainfall < 100 THEN 'Low Rainfall'
            WHEN Rainfall BETWEEN 100 AND 300 THEN 'Medium Rainfall'
            ELSE 'High Rainfall'
        END AS rainfall_level
    FROM Data
)
SELECT
    rainfall_level,
    COUNT(*) AS total_samples,
    AVG(NDVI_Season_Mean) AS avg_ndvi,
    AVG(Soil_Moisture_mm) AS avg_soil_moisture,
    AVG(Temp_Mean) AS avg_temp
FROM rainfall_group
GROUP BY rainfall_level
ORDER BY avg_ndvi DESC;


/* ============================================================
 8. SALINITY LEVEL VS NDVI
 Business inquiry:
 - Does soil salinity relate to crop health?
 SQL skills:
 - CASE WHEN, GROUP BY.
 Meaning:
 - High salinity usually makes it harder for crops to absorb water,
   so this query checks whether higher salinity groups have lower NDVI.
============================================================ */
WITH salinity_group AS (
    SELECT
        *,
        CASE
            WHEN Avg_Salinity_Index < 400 THEN 'Low Salinity'
            WHEN Avg_Salinity_Index BETWEEN 400 AND 800 THEN 'Medium Salinity'
            ELSE 'High Salinity'
        END AS salinity_level
    FROM Data
)
SELECT
    salinity_level,
    COUNT(*) AS total_samples,
    AVG(NDVI_Season_Mean) AS avg_ndvi,
    AVG(Rainfall) AS avg_rainfall,
    AVG(Soil_Moisture_mm) AS avg_soil_moisture
FROM salinity_group
GROUP BY salinity_level
ORDER BY avg_ndvi DESC;


/* ============================================================
 9. HEAT STRESS LEVEL VS NDVI
 Business inquiry:
 - How does heat stress affect crop health?
 SQL skills:
 - CASE WHEN, GROUP BY.
 Meaning:
 - This helps show whether many heat stress days are linked with lower NDVI.
============================================================ */
WITH heat_group AS (
    SELECT
        *,
        CASE
            WHEN Heat_Stress_Days = 0 THEN 'No Heat Stress'
            WHEN Heat_Stress_Days BETWEEN 1 AND 5 THEN 'Medium Heat Stress'
            ELSE 'High Heat Stress'
        END AS heat_stress_level
    FROM Data
)
SELECT
    heat_stress_level,
    COUNT(*) AS total_samples,
    AVG(NDVI_Season_Mean) AS avg_ndvi,
    AVG(Temp_Mean) AS avg_temp,
    AVG(LST_C) AS avg_lst_c
FROM heat_group
GROUP BY heat_stress_level
ORDER BY avg_ndvi DESC;


/* ============================================================
 10. MULTI-INDEX GROUPING: CROP + SEASON
 Business inquiry:
 - Which crop performs best in each season?
 SQL skills:
 - Multi-column GROUP BY.
 Meaning:
 - A crop may have high NDVI in one season but lower NDVI in another season.
   This is important because the model should learn crop-season interaction.
============================================================ */
SELECT
    Season,
    Crop_Name,
    COUNT(*) AS total_samples,
    AVG(NDVI_Season_Mean) AS avg_ndvi,
    AVG(Rainfall) AS avg_rainfall,
    AVG(Temp_Mean) AS avg_temp
FROM Data
GROUP BY Season, Crop_Name
ORDER BY Season, avg_ndvi DESC;


/* ============================================================
 11. WINDOW FUNCTION: RANK CROPS BY NDVI WITHIN EACH SEASON
 Business inquiry:
 - In each season, which crops have the highest average NDVI?
 SQL skills:
 - CTE, RANK() window function, PARTITION BY.
 Meaning:
 - This is stronger than a normal GROUP BY because it ranks crop health
   separately inside each season.
============================================================ */
WITH crop_season_ndvi AS (
    SELECT
        Season,
        Crop_Name,
        COUNT(*) AS total_samples,
        AVG(NDVI_Season_Mean) AS avg_ndvi
    FROM Data
    GROUP BY Season, Crop_Name
)
SELECT
    Season,
    Crop_Name,
    total_samples,
    avg_ndvi,
    RANK() OVER (PARTITION BY Season ORDER BY avg_ndvi DESC) AS ndvi_rank_in_season
FROM crop_season_ndvi
ORDER BY Season, ndvi_rank_in_season;


/* ============================================================
 12. SUBQUERY: CROPS ABOVE OVERALL AVERAGE NDVI
 Business inquiry:
 - Which crops have average NDVI higher than the whole dataset average?
 SQL skills:
 - Subquery in HAVING.
 Meaning:
 - These crops can be interpreted as healthier than the general baseline.
============================================================ */
SELECT
    Crop_Name,
    COUNT(*) AS total_samples,
    AVG(NDVI_Season_Mean) AS avg_ndvi
FROM Data
GROUP BY Crop_Name
HAVING AVG(NDVI_Season_Mean) > (
    SELECT AVG(NDVI_Season_Mean)
    FROM Data
)
ORDER BY avg_ndvi DESC;


/* ============================================================
 13. JOIN USING CTE: COMPARE CROP NDVI TO SEASON AVERAGE
 Business inquiry:
 - Is each crop above or below the average NDVI of its season?
 SQL skills:
 - CTE, INNER JOIN, calculated metric.
 Meaning:
 - This shows whether a crop performs better or worse than the seasonal baseline.
============================================================ */
WITH crop_season AS (
    SELECT
        Season,
        Crop_Name,
        COUNT(*) AS total_samples,
        AVG(NDVI_Season_Mean) AS crop_avg_ndvi
    FROM Data
    GROUP BY Season, Crop_Name
),
season_avg AS (
    SELECT
        Season,
        AVG(NDVI_Season_Mean) AS season_avg_ndvi
    FROM Data
    GROUP BY Season
)
SELECT
    cs.Season,
    cs.Crop_Name,
    cs.total_samples,
    cs.crop_avg_ndvi,
    sa.season_avg_ndvi,
    cs.crop_avg_ndvi - sa.season_avg_ndvi AS ndvi_gap_vs_season
FROM crop_season cs
INNER JOIN season_avg sa
    ON cs.Season = sa.Season
ORDER BY cs.Season, ndvi_gap_vs_season DESC;


/* ============================================================
 14. CORRELATION-LIKE VIEW USING GROUPED NUMERIC BINS
 Business inquiry:
 - How do important numeric features change with NDVI level?
 SQL skills:
 - CASE WHEN, aggregation.
 Meaning:
 - This is a simple SQL-based way to understand which environment groups
   are associated with low, medium, or high crop health.
============================================================ */
WITH ndvi_group AS (
    SELECT
        *,
        CASE
            WHEN NDVI_Season_Mean < 0.40 THEN 'Low NDVI'
            WHEN NDVI_Season_Mean BETWEEN 0.40 AND 0.60 THEN 'Medium NDVI'
            ELSE 'High NDVI'
        END AS ndvi_level
    FROM Data
)
SELECT
    ndvi_level,
    COUNT(*) AS total_samples,
    AVG(Rainfall) AS avg_rainfall,
    AVG(Temp_Mean) AS avg_temp,
    AVG(Avg_Humidity) AS avg_humidity,
    AVG(Soil_Moisture_mm) AS avg_soil_moisture,
    AVG(Avg_Salinity_Index) AS avg_salinity,
    AVG(Heat_Stress_Days) AS avg_heat_stress_days,
    AVG(EVI) AS avg_evi,
    AVG(LAI) AS avg_lai,
    AVG(FPAR) AS avg_fpar,
    AVG(NDVI_Season_Mean) AS avg_ndvi
FROM ndvi_group
GROUP BY ndvi_level
ORDER BY avg_ndvi DESC;


/* ============================================================
 15. TOP DISTRICT-CROP COMBINATIONS WITH HIGH NDVI
 Business inquiry:
 - Which district and crop combinations show the strongest crop health?
 SQL skills:
 - GROUP BY, HAVING, ORDER BY, TOP.
 Meaning:
 - This can reveal good combinations of location and crop for healthy growth.
============================================================ */
SELECT TOP 20
    District,
    Crop_Name,
    COUNT(*) AS total_samples,
    AVG(NDVI_Season_Mean) AS avg_ndvi,
    AVG(Rainfall) AS avg_rainfall,
    AVG(Temp_Mean) AS avg_temp,
    AVG(Soil_Moisture_mm) AS avg_soil_moisture
FROM Data
GROUP BY District, Crop_Name
HAVING COUNT(*) >= 5
ORDER BY avg_ndvi DESC;
