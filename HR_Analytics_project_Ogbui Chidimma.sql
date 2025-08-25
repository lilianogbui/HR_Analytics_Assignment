-- Clean and structure the HR dataset
WITH EmpClean AS (
    SELECT
        id,
        first_name,
        last_name,
        TRY_CAST(birthdate AS DATE) AS birthdate,
        gender,
        race,
        department,
        jobtitle,
        location,
        TRY_CAST(hire_date AS DATE) AS hire_date,
        TRY_CAST(termdate AS DATE) AS termdate,
        location_city,
        location_state,

        -- Assign official-style salaries based on job role
        CASE 
            WHEN jobtitle LIKE '%Manager%'  THEN 80000
            WHEN jobtitle LIKE '%Director%' THEN 100000
            WHEN jobtitle LIKE '%Engineer%' THEN 75000
            WHEN jobtitle LIKE '%Analyst%'  THEN 60000
            WHEN jobtitle LIKE '%Sales%'    THEN 55000
            ELSE 50000
        END AS salary,

        -- Assign simple performance categories
        CASE 
            WHEN jobtitle LIKE '%Manager%'  THEN 'Exceeds Expectations'
            WHEN jobtitle LIKE '%Director%' THEN 'Outstanding'
            WHEN jobtitle LIKE '%Engineer%' THEN 'Meets Expectations'
            WHEN jobtitle LIKE '%Analyst%'  THEN 'Needs Improvement'
            ELSE 'Meets Expectations'
        END AS performance_score
    FROM [HR Data]
),

EmpSnap AS (
    SELECT
        *,
        -- Calculate age in years
        DATEDIFF(YEAR, birthdate, GETDATE()) AS age_years,

        -- Calculate tenure in years (till today if active)
        DATEDIFF(DAY, hire_date, ISNULL(termdate, GETDATE())) / 365.0 AS tenure_years,

        -- Employment status
        CASE 
            WHEN termdate IS NULL THEN 'Active' 
            ELSE 'Terminated' 
        END AS employment_status
    FROM EmpClean
)

-- Final cleaned dataset
SELECT *
FROM EmpSnap;
