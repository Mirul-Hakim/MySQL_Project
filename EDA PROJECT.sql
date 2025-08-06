# EDA - EXPLORATORY DATA ANALYST

SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off), 
MIN(total_laid_off)
FROM world_layoffs.layoffs_staging2;
-- atau --
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL
ORDER BY total_laid_off DESC; # Tukar kepada ASC untuk tau MIN
# Maksimum seramai 12000 pekerja dan minimum 3 orang pekerja yang telah diberhenti dalam sesuatu masa 

SELECT MAX(percentage_laid_off),  MIN(percentage_laid_off)
FROM layoffs_staging2
WHERE percentage_laid_off IS NOT NULL;
# Terdapat beberapa syarikat yang telah memberhentikan kesemua 100% pekerja berkemungkinan kerana ia telah dinyatakan muflis
# Terdapat juga syarikat yang tidak memberhentikan pekerja ditunjukkan oleh percentage_laid_off 0
# Walaubagaimanapun terdapat kejanggalan kerana total_laid_off nya adalah 52 orang

SELECT MAX(`date`) as Latest,  MIN(`date`) as Oldest
FROM layoffs_staging2;
# Data ini mula dikumpulkan bermula pada 11 Mac 2020 hingga 6 Mac 2023

WITH CTE_SUM as 
	(SELECT company, SUM(total_laid_off) as Total_Sum
	FROM layoffs_staging2
	GROUP BY company)
SELECT *
FROM CTE_SUM
WHERE Total_Sum IS NOT NULL
ORDER BY Total_Sum DESC;
# Amazon merupakan syarikat dengan jumlah pemberhentian pekerja paling ramai dengan 18,150 diikuti oleh Google dan Meta yang masing-masing adalah 12,000 dan 11,000

WITH CTE_SUM as 
	(SELECT industry, SUM(total_laid_off) as Total_Sum
	FROM layoffs_staging2
	GROUP BY industry)
SELECT *
FROM CTE_SUM
WHERE Total_Sum IS NOT NULL
ORDER BY Total_Sum ASC;
# Bagi industri pula, pekerja dari sektor pengguna adalah paling ramai diberhentikan iaitu seramai 45,182 diiikuti retail dan other
# Pekerja dari sektor pembuatan paling sedikit diberhentikan iaitu hanya 20 orang sahaja

WITH CTE_SUM as 
	(SELECT country, SUM(total_laid_off) as Total_Sum
	FROM layoffs_staging2
	GROUP BY country)
SELECT *
FROM CTE_SUM
WHERE Total_Sum IS NOT NULL
ORDER BY Total_Sum ASC;
# United State mencatatkan jumlah pemberhentian pekerja paling ramai diikuti India dan Netherlands
# Sebaliknya, Poland mencatatkan jumlah pemberhentian pekerja paling sedikit diikuti Chile dan New Zealand

SELECT `date`, SUM(total_laid_off) as Total_Sum
FROM layoffs_staging2
GROUP BY `date`
ORDER BY `date` DESC;
# Data terkini iaitu bertarikh 6 Mac 2023 menunjukkan jumlah seramai 1,495 pekerja telah diberhentikan 

WITH Data_year as (
SELECT YEAR(`date`) as `Year`, SUM(total_laid_off) as Total_Sum
FROM layoffs_staging2
GROUP BY `Year`)
SELECT *
FROM Data_year
WHERE `Year` IS NOT NULL
ORDER BY Total_Sum DESC;
#  Tahun 2022 mencatatkan jumlah pemberhentian pekerja terbesar iaitu 160,661 diikuti oleh tahun 2023 iaitu 125,677

SELECT SUBSTRING(`date`, 1,7) as `Month`,
SUM(total_laid_off) as Total_Sum
FROM layoffs_staging2
WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY `Month` ;
# Data memaparkan jumlah pekerja yang telah diberhentikan mengikut bulan dari Mac tahun 2020 hingga  Mac 2023
# walaubagaimanapun ia maish lagi kurang jelas untuk diintepretasikan dengan lebih spesifik

WITH Rolling_Total as (
	SELECT SUBSTRING(`date`, 1,7) as `Month`,
	SUM(total_laid_off) as Total_Sum
	FROM layoffs_staging2
	WHERE SUBSTRING(`date`, 1,7) IS NOT NULL
	GROUP BY `Month`
	ORDER BY `Month`)
SELECT `Month`, Total_Sum,
SUM(Total_Sum) OVER(ORDER BY `Month`) as Rolling_Total_Sum
FROM Rolling_Total
WHERE `Month` LIKE '2022%';
# Walaupun kurang jelas tapi dapat dipastikan bahawa terdapat peningkatan yang besar terhadap pemberhentian pekerja pada tahun 2022 berbanding tahun-tahun lain

WITH CTE_NULL as (
SELECT company, Year(`date`), SUM(total_laid_off) as Total_Sum
FROM layoffs_staging2
GROUP BY company, Year(`date`)
ORDER BY Total_Sum DESC)
SELECT *
FROM CTE_NULL
WHERE Total_Sum IS NOT NULL;
# Pada tahun 2023 Google telah mencatat jumlah pemberhentian pekerja yang paling tinggi iaitu 12,000
# Jumlah tersebut juga merupakan jumlah yang paling tinggi bagi tempoh masa 3 tahun dari tahun 2020 hingga 2023 
# Meta pula mencatat jumlah paling tinggi bagi tahun 2022  diikuti oleh Amazon

WITH Company_Years (Company, Years, Total) as (
	SELECT company, Year(`date`), SUM(total_laid_off) as Total_Sum
	FROM layoffs_staging2
	GROUP BY company, Year(`date`)),
Rank_year as (
SELECT *, 
DENSE_RANK () OVER( PARTITION BY Years ORDER BY Total DESC ) as Ranking
FROM Company_Years
WHERE Years IS NOT NULL AND Total IS NOT NULL
ORDER BY Ranking ASC)
SELECT *
FROM Rank_year
WHERE Ranking <= 5; 
# Berikut merupakan senarai syarikat yang telah memberhentikan pekerja paling ramai mengikut tahun
# Tahun 2020 : Uber, Tahun 2021 : Bytedance, Tahun 2022 : Meta dan Tahun 2023 : Google


#Tambahan 

SELECT *
FROM layoffs_staging2;

WITH Sum_Worker as (
SELECT SUBSTRING(`date`,1,7) as Year_Months, Year(`date`) as Years,  SUM(total_laid_off) as Sum_Laid_Off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY Year_Months, Years
ORDER BY Years )
SELECT *,
SUM(Sum_laid_off) OVER (PARTITION BY Years ORDER BY Year_Months )  as Rolling_Total
FROM Sum_Worker;
