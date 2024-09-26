-- Exploratory Data Analysis

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

-- Total layoffs by country
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Total layoffs by year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- Total layoffs by company stage (e.g., Acquired, Post-IPO)
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Average layoff percentage per industry
SELECT industry, ROUND(AVG(percentage_laid_off), 2)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Monthly total layoffs
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

-- Running total of layoffs by month
WITH Running_Total AS
(
    SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
    FROM layoffs_staging2
    WHERE SUBSTRING(`date`,1,7) IS NOT NULL
    GROUP BY `MONTH`
    ORDER BY 1 ASC
)
SELECT `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM Running_Total;

-- Total layoffs per company by year
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- Top 5 companies with the highest layoffs per year
WITH Company_Year (Company, `Year`, Total_laid_off) AS
(
    SELECT company, YEAR(`date`), SUM(total_laid_off)
    FROM layoffs_staging2
    GROUP BY company, YEAR(`date`)
),
Company_Year_Rank AS
(
    SELECT *, DENSE_RANK() OVER(PARTITION BY `YEAR` ORDER BY Total_laid_off DESC) AS Ranking
    FROM Company_Year
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;

-- Total layoffs per industry by year
SELECT industry, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry, YEAR(`date`)
ORDER BY 3 DESC;

-- Top 5 industries with the highest layoffs per year
WITH Industry_Year (Industry, `Year`, Total_laid_off) AS
(
    SELECT industry, YEAR(`date`), SUM(total_laid_off)
    FROM layoffs_staging2
    GROUP BY industry, YEAR(`date`)
),
Industry_Year_Rank AS
(
    SELECT *, DENSE_RANK() OVER(PARTITION BY `YEAR` ORDER BY Total_laid_off DESC) AS Ranking
    FROM Industry_Year
)
SELECT *
FROM Industry_Year_Rank
WHERE Ranking <= 5;