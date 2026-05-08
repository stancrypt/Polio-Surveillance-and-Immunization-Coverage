--- View Your Tables (inspect the data)
SELECT TOP (10) * 
FROM [Polio_data].[dbo].[Coverage Estimates];

SELECT TOP (10) * 
FROM [Polio_data].[dbo].[Polio Cases];

SELECT * 
FROM [Polio_data].[dbo].[Vaccinated Stats];

SELECT TOP (10) * 
FROM [Polio_data].[dbo].[Vaccine Info];

--- Check Column Names & Data Types

EXEC sp_help [Coverage Estimates];
EXEC sp_help [Polio Cases];
EXEC sp_help [Vaccinated Stats];
EXEC sp_help [Vaccine Info];

--- Basic Cleaning
SELECT *
FROM [Polio_data].[dbo].[Coverage Estimates]
WHERE coverage Is Not Null;

--- CLEAN TABLE
SELECT *
Into who_unicef_coverage_clean
FROM [Polio_data].[dbo].[Coverage Estimates]
WHERE coverage Is Not Null;


SELECT *
FROM who_unicef_coverage_clean;

---Standardize Country Names

SELECT DISTINCT Entity
FROM [Polio_data].[dbo].[Polio Cases]
ORDER BY Entity;

SELECT DISTINCT surveyNameEnglish
FROM who_unicef_coverage_clean
ORDER BY surveyNameEnglish;

--- Global Polio Trend


SELECT Year, 
	SUM(CONVERT(INT, Total_estimated_polio_cases)) AS total_cases
INTO Total_Polio_cases
FROM [Polio_data].[dbo].[Polio Cases]
GROUP BY Year
ORDER BY Year;

SELECT *
FROM Total_Polio_cases

--- Average Vaccine Coverage by Year

SELECT
    cohortYear,
    AVG(coverage) AS avg_coverage
FROM who_unicef_coverage_clean
GROUP BY cohortYear
ORDER BY cohortYear;

--- Coverage by Vaccine
SELECT DISTINCT vaccine
FROM who_unicef_coverage_clean
ORDER BY vaccine;

SELECT
    vaccine,
    AVG(coverage) AS avg_coverage
FROM who_unicef_coverage_clean
GROUP BY vaccine
ORDER BY avg_coverage DESC;


SELECT region,
    year, 
    unvaccinated
INTO vaccinated_stats
FROM [Polio_data].[dbo].[Vaccinated Stats]
where region like 'wcar';

-- Vaccination Performance
SELECT
    region,
    vaccine,
    year,
    coverage,
    vaccinated,
    target,
    
    ROUND(
        (CAST(vaccinated AS FLOAT) / target) * 100,
        2
    ) AS performance_rate

FROM [Polio_data].[dbo].[Vaccinated Stats];

--- Risk Classification

SELECT
    region,
    vaccine,
    year,
    coverage,
    unvaccinated,

    CASE
        WHEN coverage < 70 THEN 'High Risk'
        WHEN coverage BETWEEN 70 AND 89 THEN 'Medium Risk'
        ELSE 'Low Risk'
    END AS risk_level

FROM [Polio_data].[dbo].[Vaccinated Stats];

-- Duplicate Records
SELECT
    vaccine,
    cohortYear,
    COUNT(*) AS duplicate_count
FROM who_unicef_coverage_clean
GROUP BY vaccine, cohortYear
HAVING COUNT(*) > 1;