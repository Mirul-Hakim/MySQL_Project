
# Sumber : https://www.kaggle.com/datasets/irakozekelly/fertilizer-prediction

-- 1) Sediakan table baru untuk digunakan dalam data cleaning dan EDA

SELECT *
FROM fertilizer_prediction;

CREATE TABLE Agriculture
LIKE agriculture_sector.fertilizer_prediction;

INSERT agriculture
SELECT * FROM fertilizer_prediction;

SELECT *
FROM agriculture;

-- 2) Periksa Jumlah Baris data yang akan terlibat dan penetapan nilai unik

WITH CTE_Row as (
SELECT *, 
ROW_Number() OVER( PARTITION BY Temparature, Humidity, Moisture, Soil_Type, Crop_Type, Nitrogen, Potassium, Phosphorous, Fertilizer_Name) as Num_of_Row
FROM agriculture)
SELECT *
FROM CTE_Row
WHERE Num_of_Row > 1;  #Semua data bersifat unik

SELECT *,
ROW_Number() OVER() as Num_of_Row
FROM agriculture;

CREATE TABLE `agriculture_2` (
  `Temparature` int DEFAULT NULL,
  `Humidity` int DEFAULT NULL,
  `Moisture` int DEFAULT NULL,
  `Soil_Type` text,
  `Crop_Type` text,
  `Nitrogen` int DEFAULT NULL,
  `Potassium` int DEFAULT NULL,
  `Phosphorous` int DEFAULT NULL,
  `Fertilizer_Name` text,
  `Num_of_Row` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM agriculture_2;

INSERT INTO `agriculture_2` (
  `Temparature`,
  `Humidity`,
  `Moisture`,
  `Soil_Type`,
  `Crop_Type`,
  `Nitrogen`,
  `Potassium`,
  `Phosphorous`,
  `Fertilizer_Name`,
  `Num_of_Row`)
SELECT `Temparature`,
  `Humidity`,
  `Moisture`,
  `Soil_Type`,
  `Crop_Type`,
  `Nitrogen`,
  `Potassium`,
  `Phosphorous`,
  `Fertilizer_Name`,
  ROW_Number() OVER() as Num_of_Row
FROM agriculture;

SELECT *
FROM agriculture_2
ORDER BY Num_of_Row DESC; #Data mempunyai 100,000 baris

-- 3) Piawaikan setiap data

SELECT Soil_Type, Crop_Type, Fertilizer_Name, 
TRIM(Soil_Type), TRIM(Crop_Type), TRIM(Fertilizer_Name)
FROM agriculture_2;

UPDATE agriculture_2
SET Soil_Type = TRIM(Soil_Type),
 Crop_Type = TRIM(Crop_Type),
 Fertilizer_Name = TRIM(Fertilizer_Name);
 
 SELECT DISTINCT Soil_Type
 FROM agriculture_2
 ORDER BY Soil_Type ASC; #ada terdapat 5 Soil_Type : Black, Clayey, Loamy, Red & Sandy ----> Tiada masalah
 
 SELECT DISTINCT Crop_Type
 FROM agriculture_2
 ORDER BY Crop_Type ASC; # ada terdapat 11 Crop_Type ----> Tiada masalah
 
 SELECT DISTINCT Fertilizer_Name
 FROM agriculture_2
 ORDER BY Fertilizer_Name ASC; # ada terdapat 7 Fertilizer_Name -----> Tiada masalah
 
 -- 4) Periksa sama ada terdapat ruangan yang kosong atau NULL
 
  SELECT Temparature, Humidity, Moisture, Nitrogen, Potassium, Phosphorous, Fertilizer_Name,
	 ROW_NUMBER() OVER() as Count_Row
	 FROM agriculture_2
	 WHERE Temparature = '' OR Temparature IS NULL
     ORDER BY Count_Row DESC;

 SELECT Temparature, Humidity, Moisture, Nitrogen, Potassium, Phosphorous, Fertilizer_Name,
	 ROW_NUMBER() OVER() as Count_Row
	 FROM agriculture_2
	 WHERE Potassium = '' OR Potassium IS NULL
     ORDER BY Count_Row DESC;

 SELECT Temparature, Humidity, Moisture, Nitrogen, Potassium, Phosphorous, Fertilizer_Name,           #Tiada Nilai NULL ditemui
	 ROW_NUMBER() OVER() as Count_Row                                                                 # Nilai 0 pada N P K adalah logik kerana kandungan setiap baja adalah berbeza
	 FROM agriculture_2
	 WHERE  Phosphorous = '' OR Phosphorous IS NULL
     ORDER BY Count_Row DESC;
     
SELECT *
FROM agriculture_2
ORDER BY Num_of_Row DESC;

-- TUGASAN ------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- 1) Apakah 5 jenis baja yang paling kerap digunakan berdasarkan rekod fertilizer_name?

WITH CTE_Count as (
	SELECT Fertilizer_Name, COUNT(Fertilizer_Name) as Count_Fer
	FROM agriculture_2
	GROUP BY Fertilizer_Name
	),
Percent as (
SELECT *,
SUM(Count_Fer) OVER(ORDER BY Count_Fer DESC) as Total_Rolling, 
DENSE_RANK() OVER( ORDER BY Count_Fer DESC) as Ranking,
ROUND(Count_Fer * 100.0 / SUM(Count_Fer) OVER(), 2) AS Percent_of_Total
FROM CTE_Count)
SELECT *,
SUM(Percent_of_Total) OVER(ORDER BY Percent_of_Total DESC) as Total_Rolling_Percentage
FROM Percent
LIMIT 5;
# Jawapan : Baja paling kerap digunakan adalah 14-35-14 diikuti oleh 10-26-26, Urea, 28-28 dan DAP

-- 2) Tanaman manakah yang memerlukan purata kandungan nitrogen tertinggi?

SELECT  Crop_Type, AVG(Nitrogen) as Average_Nitrogen
FROM agriculture_2
GROUP BY Crop_Type
ORDER BY AVG(Nitrogen) DESC;
# Jawapan : Tanaman yang memerlukan kandungan nitrogen yang paling tinggi adalah Crop_Type = Tobacco
# Dapat dilihat, purata keperluan Nitrogen oleh setiap tanaman tiada perbezaan yang ketara 

-- 3) Senaraikan kombinasi jenis tanah dan jenis tanaman yang paling banyak muncul (top 3).

WITH CTE_Com as (
SELECT Soil_Type, Crop_Type,
COUNT(Soil_Type AND Crop_Type) as Total_Com
FROM agriculture_2
GROUP BY Soil_Type, Crop_Type
)
SELECT *,
SUM(Total_Com) OVER (ORDER BY Total_Com DESC) as Rolling_Total,
DENSE_RANK () OVER (ORDER BY Total_Com DESC) as Ranking,
ROUND(Total_Com * 100.0 / SUM(Total_Com) OVER(), 2) AS Percent_of_Total
FROM CTE_Com
ORDER BY Total_Com DESC
LIMIT 3;
# Jawapan : Kombinasi antara Soil_Type = Black dan Crop_Type = Sugarcane adalah paling banyak muncul Diikuti Sandy-Cotton dan Black-Paddy

-- 4) Untuk setiap crop_type, kira: purata suhu (temperature), purata kelembapan udara (humidity), purata kelembapan tanah (moisture)

SELECT Crop_Type, AVG(Temparature) as Average_Temperature ,
AVG(Humidity) as Average_Humidity, 
AVG(Moisture) as Average_Moisture
FROM agriculture_2
GROUP BY Crop_Type
ORDER BY Average_Temperature DESC;

-- 5) Untuk setiap crop_type, apakah jenis baja paling kerap digunakan?

WITH CTE_Crop as (
SELECT Crop_Type, Fertilizer_Name,
COUNT(Crop_Type AND Fertilizer_Name) as Total_Crop_Fer
FROM agriculture_2
GROUP BY Crop_Type, Fertilizer_Name
ORDER BY Total_Crop_Fer DESC),
Top_Fer as (SELECT *, 
DENSE_RANK() OVER( PARTITION BY Crop_Type ORDER BY Total_Crop_Fer DESC) as Ranking
FROM CTE_Crop)
SELECT *
FROM Top_Fer
WHERE Ranking = 1
ORDER BY Total_Crop_Fer DESC;

-- 6) Kenal pasti baris data di mana kandungan nitrogen jauh lebih tinggi (>1.5x) berbanding phosphorous dan potassium.

SELECT Num_of_Row, Soil_Type, Crop_Type, Temparature, Humidity, Moisture, 
Nitrogen, Potassium, Phosphorous, Fertilizer_Name,
  ROUND(Nitrogen / Phosphorous, 2) AS N_to_P_Ratio,
  ROUND(Nitrogen / Potassium, 2) AS N_to_K_Ratio
FROM agriculture_2
WHERE 
  Nitrogen > 1.5 * Phosphorous
  AND
  Nitrogen > 1.5 * Potassium
ORDER BY Num_of_Row;

-- 7) Untuk setiap soil_type, apakah fertilizer_name yang paling kerap digunakan?

WITH CTE_Soil as (
SELECT Soil_Type, Fertilizer_Name,
COUNT(Soil_Type AND Fertilizer_Name) as Total_Soil_Fer
FROM agriculture_2
GROUP BY Soil_Type, Fertilizer_Name
ORDER BY Total_Soil_Fer DESC),
Top_Fer as (SELECT *, 
DENSE_RANK() OVER( PARTITION BY Soil_Type ORDER BY Total_Soil_Fer DESC) as Ranking
FROM CTE_Soil)
SELECT *
FROM Top_Fer
WHERE Ranking = 1
ORDER BY Total_Soil_Fer DESC;

-- 8) Kira satu metrik total_nutrient = nitrogen + phosphorous + potassium. Senaraikan 10 tanaman yang memerlukan total_nutrient tertinggi.

WITH CTE_Nutrient as (
SELECT Crop_Type, Fertilizer_Name, Nitrogen, Potassium, Phosphorous,
Nitrogen + Potassium + Phosphorous as Total_Nutrient
FROM agriculture_2)
SELECT *,
DENSE_RANK() OVER( ORDER BY Total_Nutrient DESC) as Ranking,
ROW_NUMBER() OVER( ORDER BY Total_Nutrient DESC) as Numbering
FROM CTE_Nutrient
LIMIT 10;

-- 9) Untuk setiap Crop_Type, kira purata jumlah nutrient (N + P + K) yang diperlukan. Kemudian, tentukan jenis baja paling ekonomik (yakni paling kerap digunakan dengan total nutrient tertinggi).

WITH CTE_Nutrient AS (
  SELECT 
    Crop_Type, 
    Fertilizer_Name,
    Nitrogen, Phosphorous, Potassium,
    Nitrogen + Phosphorous + Potassium AS Total_Nutrient
  FROM agriculture_2
)
, Avg_Nutrient AS (
  SELECT 
    Crop_Type,
    ROUND(AVG(Total_Nutrient), 2) AS Avg_Total_Nutrient
  FROM CTE_Nutrient
  GROUP BY Crop_Type
)
, Fert_Stats AS (
  SELECT 
    Crop_Type,
    Fertilizer_Name,
    COUNT(*) AS Freq,
    ROUND(AVG(Total_Nutrient), 2) AS Avg_Nutrient_Per_Fert,
    DENSE_RANK() OVER (
      PARTITION BY Crop_Type ORDER BY COUNT(*) DESC, AVG(Total_Nutrient) DESC
    ) AS Ranking
  FROM CTE_Nutrient
  GROUP BY Crop_Type, Fertilizer_Name
)
SELECT 
  f.Crop_Type,
  a.Avg_Total_Nutrient,
  f.Fertilizer_Name,
  f.Freq,
  f.Avg_Nutrient_Per_Fert
FROM Fert_Stats f
JOIN Avg_Nutrient a ON f.Crop_Type = a.Crop_Type
WHERE f.Ranking = 1
ORDER BY a.Avg_Total_Nutrient DESC;