/*
    BUOC 1 - TAO DATABASE VA BANG NHAP DU LIEU

    GEE la bang goc 4.608 dong, dung dung thu tu trong file CSV.
    SampleMap luu san thu tu lay mau seed 42 cua notebook cu.
*/

IF DB_ID(N'ADY201_Agriculture') IS NULL
    CREATE DATABASE ADY201_Agriculture;
GO

USE ADY201_Agriculture;
GO

DROP VIEW IF EXISTS dbo.GeeRawImport;
DROP TABLE IF EXISTS dbo.BangladeshFinalMerged;
DROP TABLE IF EXISTS dbo.SampleMap;
DROP TABLE IF EXISTS dbo.SoilData;
DROP TABLE IF EXISTS dbo.WeatherData;
DROP TABLE IF EXISTS dbo.GeeRaw;
GO

CREATE TABLE dbo.SoilData (
    District NVARCHAR(255), pH NVARCHAR(255), OrganicCarbon NVARCHAR(255),
    Nitrogen NVARCHAR(255), Clay NVARCHAR(255), Silt NVARCHAR(255),
    CNRatio NVARCHAR(255), DominantSoilTexture NVARCHAR(255)
);

CREATE TABLE dbo.WeatherData (
    Season NVARCHAR(255), Rainfall NVARCHAR(255), TempMean NVARCHAR(255),
    TempMax NVARCHAR(255), TempMin NVARCHAR(255), HeatStressDays NVARCHAR(255),
    WindMean NVARCHAR(255), WindMax NVARCHAR(255), District NVARCHAR(255),
    [Year] NVARCHAR(255), RainTempRatio NVARCHAR(255)
);

CREATE TABLE dbo.GeeRaw (
    SourceRowId INT IDENTITY(0,1) NOT NULL PRIMARY KEY,
    Area NVARCHAR(255), APRatio NVARCHAR(255), District NVARCHAR(255),
    Season NVARCHAR(255), AvgTemp NVARCHAR(255), AvgHumidity NVARCHAR(255),
    CropName NVARCHAR(255), Transplant NVARCHAR(255), Growth NVARCHAR(255),
    Harvest NVARCHAR(255), Production NVARCHAR(255), MaxTemp NVARCHAR(255),
    MinTemp NVARCHAR(255), MaxRelativeHumidity NVARCHAR(255),
    MinRelativeHumidity NVARCHAR(255), NDVI NVARCHAR(255), [Year] NVARCHAR(255),
    EVI NVARCHAR(255), LAI NVARCHAR(255), FPAR NVARCHAR(255),
    LSTKelvin NVARCHAR(255), SoilMoistureMm NVARCHAR(255),
    AvgSalinityIndex NVARCHAR(255)
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

CREATE TABLE dbo.SampleMap (
    OutputOrder INT NOT NULL PRIMARY KEY,
    SourceRowId INT NOT NULL
);
GO
