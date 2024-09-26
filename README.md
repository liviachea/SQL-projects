# SQL-projects
## Data Cleaning Preview

```sql
Data Cleaning
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
```

## Exploratory Data Analysis Preview

```sql
Exploratory Data Analysis

-- Fetch all records from the cleaned layoffs table
SELECT * FROM layoffs_staging2;

-- Get the maximum total_laid_off and maximum percentage_laid_off
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Companies that laid off 100% of their workforce, sorted by funds raised
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised DESC;

-- Total layoffs per company
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Get the earliest and latest dates in the data
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Total layoffs per industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;
```

