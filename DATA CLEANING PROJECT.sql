# Data Cleaning 

-- Cuba buat semakan terhadap table yang telah diimport dari wworld_layoffs
SELECT *
FROM layoffs;

-- Objektif
-- 1) Semakan terhadap data yang sama atau duplicate - jika temui maka padamnya
-- 2) Piawaikan atau standadize data dan betulkan segala ralat
-- 3) Permerhatian terhadap data NUll
-- 4) Padam column dan baris yang tidak diperlukan

# PERMULAAN SEKALI INGAT
# JIKA HENDAK MENJALANKAN EDA ATAU CLEANING PADA DATA PASTIKAN LAKUKAN PADA TABLE YANG BAHARU ATAU BACKUP TABLE
# DATA DAN TABLE ASAL JANGAN DIKACAU UNTUK MENGELAKKAN SEBARANG KESILAPAN YANG BERSIFAT PERMENANT

# STAGING TABLE --- duplicate data dari table asal kepada table baru untuk digunakan dalam proses edit dan sebagainya

CREATE TABLE world_layoffs.layoffs_staging
LIKE world_layoffs.layoffs;

INSERT layoffs_staging
SELECT * FROM layoffs;

SELECT *
FROM layoffs_staging;

# DUPLICATE CHECKING

SELECT *,
ROW_NUMBER() OVER( PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS Row_Num
FROM layoffs_staging
ORDER BY company
;

WITH CTE_Layoffs as
	(SELECT *,
	ROW_NUMBER() OVER( PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS Row_Num
	FROM layoffs_staging
	ORDER BY company)
SELECT *
FROM CTE_Layoffs
WHERE Row_Num > 1;

# Disyaki data dari company Casper, Cazoo, Hibob, Wildlife Studios dan yahoo mempunyai duplicate data
# jadi Check dulu untuk pastikan ia duplicate jika tidak biarkan dan jika ya, padam

SELECT *
FROM layoffs_staging
WHERE company LIKE 'wildlife%'; # ada 1 duplicate

SELECT *
FROM layoffs_staging
WHERE company = 'yahoo'; # ada 1 duplicate

# Dapat dipastikan data dari company Casper, Cazoo, Hibob, Wildlife Studios dan yahoo mempunyai masing-masing 1 duplicate
# Jadi kita perlu delete
# Dicadangkan bagi memudahkan kerja, Create Table baru yang turut mempunyai Row_Num dan pastu delete duplictate data dari table baru tersebut

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `Row_Num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2;

INSERT INTO layoffs_staging2 (
  `company`,
  `location`,
  `industry`,
  `total_laid_off`,
  `percentage_laid_off`,
  `date`,
  `stage`,
  `country`,
  `funds_raised_millions`,
  `Row_Num`)
  SELECT
  `company`,
  `location`,
  `industry`,
  `total_laid_off`,
  `percentage_laid_off`,
  `date`,
  `stage`,
  `country`,
  `funds_raised_millions`,
  ROW_NUMBER() 
  OVER( PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as  Row_Num
  FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE Row_Num > 1;

DELETE 
FROM layoffs_staging2
WHERE Row_Num > 1;

# Piawaian Data (Standadize)

SELECT company, TRIM(company)
FROM layoffs_staging2
ORDER BY company;

UPDATE layoffs_staging2
SET company = TRIM(company);  # Ini dibuat untuk pastikan yang ruang char data tiada sebarag ruang kosong Contoh: NPK_ _ kepada NPK ----> _ sebagai ruang kosong yang divisualisasikan

SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY industry; # Lihat column terdapat kejanggalan ----> ada ' ', NULL dan Konsep industrinya sama tapi namanya berbeza ---> Crypto, CryptoCurrency dan Crypto Currency

SELECT industry
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%' # Mari fokuskan terhadap industry Crypto
ORDER BY industry;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT industry
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT location
FROM layoffs_staging2  
ORDER BY location;       #Tiada Masalah

SELECT DISTINCT country
FROM layoffs_staging2 
ORDER BY country;   # Terdapat Kejanggalan pada US

SELECT DISTINCT country
FROM layoffs_staging2
WHERE country LIKE '%State%'
ORDER BY country;

UPDATE layoffs_staging2
SET country = 'United State'
WHERE country LIKE '%State%';
# atau guna 
-- UPDATE layoffs_staging2
-- SET country = TRIM( TRAILING '.' FROM country)
-- WHERE country LIKE '%State%';

SELECT DISTINCT stage
FROM layoffs_staging2 
ORDER BY stage;       # Tiada Masalah 

SELECT `date`,  # Sekarang kita hendak menukarkan date daripada type text kepada type date 
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date`= STR_TO_DATE(`date`, '%m/%d/%Y'); #Ubah Penulisan format kepada format tarikh terlebih dahulu

SELECT `date` FROM layoffs_staging2;

ALTER TABLE layoffs_staging2 # Gunakan Allter Table untuk ubah type `date` kepada DATE
MODIFY COLUMN `date` DATE;

SELECT `date` FROM layoffs_staging2
ORDER BY `date`;

SELECT * FROM layoffs_staging2;

# Seterusnya akan diteruskan dengan proses standadize untuk deal dengan NULL dan '' data ----> '' maksudnya kotaknya kosong
# Pertama NULL dan '' dari industri

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = '';

# Sekarang dapat dilihat insutry untuk company Airbnb, Carvana dan Juul adalah '' manakala industri bagi Bally adalah NULL
# Jika dapat dijangkan isi kotak tersebut, just masukkan sahaja data contohnya airbnb yang merupakan industri berkaitan penginapan atau perlancongan
# Pemilihan data untuk mengisi kotak kosong atau NULL perlulah berpandukan data sedia ada atau sumber yang boleh dipercayai

SELECT company, industry
FROM layoffs_staging2
WHERE company = 'airbnb' ; # ada data lain yang menunjukkan ia industry Travel, so boleh masukkan secara manual dalam kotak
# Manual Boleh dibuat dengan menggunakan UPDATE dan SET
# atau guna kaedah populate so tak perlu masukkan data satu-satu

SELECT T1.company, T2.company, T1.industry, T2.industry
FROM layoffs_staging2 as T1
JOIN layoffs_staging2 as T2
	ON T1.company = T2.company
WHERE (T1.industry = '' OR T1.industry IS NULL)
AND (T2.industry != '' OR T2.industry IS NOT NULL);

UPDATE layoffs_staging2
SET industry = NULL 
WHERE industry = '';

UPDATE layoffs_staging2 as T1
JOIN layoffs_staging2 as T2
	ON T1.company = T2.company
SET T1.industry = T2.industry
WHERE T1.industry IS NULL
AND T2.industry IS NOT NULL;

SELECT company, industry
FROM layoffs_staging2
WHERE company LIKE 'Bally%'
ORDER BY company;

# Uruskan data NUll dan '' dalam total_laid_off dan percentage_laid_off
# NULL dalam kedua-duanya boleh diganti dengan nilai jika salah satu daripada datanya, ditambah dengan kehadiran total worker
# tapi jika jika dua data penting ini tiada maka pengiraan tidak boleh dibuat
# formula ----> total_laid_off = percentage_laid_off/100 * Total_worker

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2
WHERE funds_raised_millions IS NULL 
OR funds_raised_millions = '';

# Buang Column yang tidak digunakan lagi 

ALTER TABLE layoffs_staging2
DROP COLUMN Row_Num;

SELECT *
FROM layoffs_staging2;

# NULL mungkin menunjukkan data yang belum dimasukkan dan akan diupdate nanti
# '' dalam funds_raised_millions akan ditukar kepada 0 disebabkan oleh type nya yang merupakan INT