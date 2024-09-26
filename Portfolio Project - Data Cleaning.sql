-- SQL PROJECT DATA CLEANING
-- Source: https://www.kaggle.com/datasets/swaptr/layoffs-2022

-- Display the raw layoffs table to understand the data structure
SELECT *
FROM layoffs;

-- Step 1: Creating a staging table to work with, to keep the raw data untouched
CREATE TABLE layoffs_staging LIKE layoffs;

-- Check the structure of the staging table
SELECT *
FROM layoffs_staging;

-- Insert the data from the original table into the staging table for cleaning
INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

-- Data Cleaning Steps:
-- 1. Check and remove duplicates
-- 2. Standardize the data (e.g., trimming spaces)
-- 3. Handle null or blank values
-- 4. Remove unnecessary columns and rows

-- Step 1: Removing duplicates

-- Identify potential duplicates by generating row numbers based on specific columns
SELECT *,
    ROW_NUMBER() OVER (
        PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`
        ORDER BY company
    ) AS row_num
FROM layoffs_staging;

-- Use a CTE (Common Table Expression) to find duplicates based on a broader set of columns
WITH duplicate_cte AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised
            ORDER BY company
        ) AS row_num
    FROM layoffs_staging
)
-- Select rows where row numbers indicate duplicates (row_num > 1)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Query to fetch records for the company 'Beyond Meat' for deeper inspection
SELECT *
FROM layoffs_staging
WHERE company = 'Beyond Meat';

-- Query to fetch records for the company 'Cazoo' for further investigation
SELECT *
FROM layoffs_staging
WHERE company = 'Cazoo';

-- Step 2: Creating a second staging table to apply transformations more efficiently
CREATE TABLE layoffs_staging2 (
  company TEXT,
  location TEXT,
  industry TEXT,
  total_laid_off TEXT,
  percentage_laid_off TEXT,
  `date` TEXT,
  stage TEXT,
  country TEXT,
  funds_raised TEXT,
  row_num INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Check for duplicates in the second staging table
SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

-- Insert data into the new staging table, generating row numbers for duplicates
INSERT INTO layoffs_staging2
SELECT *,
    ROW_NUMBER() OVER(
        PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised
        ORDER BY company
    ) AS row_num
FROM layoffs_staging;

-- Remove duplicates where row numbers indicate duplicate rows (row_num > 1)
DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

-- Inspect the data after removing duplicates
SELECT *
FROM layoffs_staging2;

-- Step 3: Standardizing data by trimming spaces and correcting values

-- Identify and trim spaces from the company column
SELECT DISTINCT company, TRIM(company)
FROM layoffs_staging2;

-- Apply trimming to the company column
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Inspect distinct values in the industry column
SELECT DISTINCT industry
FROM layoffs_staging2;

-- Update incorrect industry entries (e.g., where industry is mistakenly set as a URL)
UPDATE layoffs_staging2
SET industry = 'Retail'
WHERE industry LIKE '%www%';

-- Inspect distinct values in the country column to check for anomalies
SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- Step 4: Handling date column

-- Check the format of the 'date' column
SELECT `date`
FROM layoffs_staging2;

-- Modify the 'date' column to store values as actual DATE type
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Final review of the data after date modification
SELECT *
FROM layoffs_staging2;

-- Step 5: Handling NULLs & blank values

-- Identify rows where industry is NULL or blank
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
   OR industry = '';

-- Correct missing industry values for specific companies
UPDATE layoffs_staging2
SET industry = 'Data'
WHERE company = 'Appsmith';

-- Set total_laid_off and percentage_laid_off to NULL where they are blank
UPDATE layoffs_staging2
SET total_laid_off = NULL
WHERE total_laid_off = '';

UPDATE layoffs_staging2
SET percentage_laid_off = NULL
WHERE percentage_laid_off = '';

UPDATE layoffs_staging2
SET funds_raised = NULL
WHERE funds_raised = '';

-- Modify columns to appropriate data types (e.g., convert to INT)
ALTER TABLE layoffs_staging2
MODIFY COLUMN total_laid_off INT;

ALTER TABLE layoffs_staging2
MODIFY COLUMN funds_raised INT;

-- Final inspection of data
SELECT *
FROM layoffs_staging2;

-- Identify rows where both total_laid_off and percentage_laid_off are NULL
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Step 6: Deleting rows with null key metrics (total_laid_off and percentage_laid_off)
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Final review of data after deletion
SELECT *
FROM layoffs_staging2;

-- Drop the row_num column as it's no longer needed
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;