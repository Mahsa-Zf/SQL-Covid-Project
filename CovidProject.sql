--Calculating Death Percentage, It's a rough estimate of likelihood of dying of covid
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidProject..CovidDeath
WHERE location like 'iran' 
ORDER BY 1,2

--Total confirmed cases vs population
SELECT location, date, total_cases,population, (total_cases/population)*100 AS SickPercentage
FROM CovidProject..CovidDeath
WHERE location like 'iran' 
ORDER BY 1,2
-- Countries based on sick percentage (infection rate) and total infection count
SELECT location,population,Max(total_cases)AS TotalInfectedCount,Max((total_cases/population)*100) AS SickPercentage
FROM CovidProject..CovidDeath
GROUP BY location,population
ORDER BY 4 Desc

-- Countries with the highest death counts per population
SELECT location,Max(cast(total_deaths as int)) AS TotalDeathCount 
FROM CovidProject..CovidDeath
WHERE continent is not null
GROUP BY location
ORDER BY 2 Desc

--Continents with the highest death counts per population
SELECT continent,Max(cast(total_deaths as int)) AS TotalDeathCount 
FROM CovidProject..CovidDeath
WHERE continent is not null
GROUP BY continent
ORDER BY 2 Desc

-- Daily new cases and deaths
SELECT  date, SUM(new_cases) AS total_cases,SUM(CAST(new_deaths as int)) AS total_deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases) )*100 AS DeathPercentage
FROM CovidProject..CovidDeath
WHERE continent is not null
GROUP BY date
ORDER BY 1,2
-- Total cases and deaths
SELECT  SUM(new_cases) AS total_cases,SUM(CAST(new_deaths as int)) AS total_deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases) )*100 AS DeathPercentage
FROM CovidProject..CovidDeath
WHERE continent is not null
ORDER BY 1,2

--Looking at total Population VS vaccination

--CTE METHOD
with PopvsVax (continent, location, date, population, new_vaccinations, total_vaccination)
as
(
SELECT dth.continent,dth.location,dth.date,dth.population,vax.new_vaccinations,
SUM(CONVERT (bigint,vax.new_vaccinations)) OVER (PARTITION BY dth.location ORDER BY dth.location,dth.date) AS total_vaccination
FROM CovidProject..CovidDeath dth
JOIN CovidProject..CovidVaccination vax
   ON dth.iso_code= vax.iso_code
   AND dth.date=vax.date
WHERE dth.continent is not null
--ORDER BY 2,3
)
SELECT *,(total_vaccination/population) AS vaccination_population_rate
FROM PopvsVax

--We can do the above total Population Vs vaccination using a temp table too
--TEMP TABLE METHOD
DROP TABLE IF EXISTS PopulationVaccinationRate;
Create Table PopulationVaccinationRate
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
Total_vaccination numeric
)
set ansi_warnings off --this is to turn off the warning issued in case of NULL values existing in agg function results.
INSERT INTO PopulationVaccinationRate
SELECT dth.continent,dth.location,dth.date,dth.population,vax.new_vaccinations,
SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (PARTITION BY dth.location ORDER BY dth.location,dth.date) AS total_vaccination
FROM CovidProject..CovidDeath dth
JOIN CovidProject..CovidVaccination vax
   ON dth.iso_code= vax.iso_code
   AND dth.date=vax.date
WHERE dth.continent is not null

SELECT *,(total_vaccination/population) AS vaccination_population_rate
FROM PopulationVaccinationRate
WHERE Location='France'


--Creating view to store data in the views file of SSMS, for later use. It'll be saved in Views section of database in SSMS

--GO will execute the related sql commands n times OR is used for separating batches of query.https://bertwagner.com/posts/what-does-the-go-command-do/
GO
DROP VIEW IF EXISTS Vaccinated_Population;
GO 
CREATE VIEW Vaccinated_Population AS 
SELECT dth.continent,dth.location,dth.date,dth.population,vax.new_vaccinations,
SUM(CONVERT (int,vax.new_vaccinations)) OVER (PARTITION BY dth.location ORDER BY dth.location,dth.date) AS total_vaccination
FROM CovidProject..CovidDeath dth
JOIN CovidProject..CovidVaccination vax
   ON dth.iso_code= vax.iso_code
   AND dth.date=vax.date
WHERE dth.continent is not null



--Difference between CTE and view: The key thing to remember about SQL views is that, in contrast to a CTE,
--a view is a physical object in a database and is stored on a disk. 
--However, views store the query only, not the data returned by the query. 
--The data is computed each time you reference the view in your query.


--Difference between CTE and Temp tables: Temp Tables are physically created in the tempdb database. These tables act as the normal table
--and also can have constraints, an index like normal tables.
--CTE is a named temporary result set which is used to manipulate the complex sub-queries data.
--This exists for the scope of a statement.

--CTE: A Common Table Expression, also called as CTE in short form,
--is a temporary named result set that you can reference within a
--SELECT, INSERT, UPDATE, or DELETE statement. The CTE can also be used in a View. 
--The CTE query starts with a “With” and is followed by the Expression Name.