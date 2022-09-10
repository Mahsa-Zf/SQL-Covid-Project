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
with PopvsVax (continent, location, date, population, new_vaccinations, total_vaccination)
as
(
SELECT dth.continent,dth.location,dth.date,dth.population,vax.new_vaccinations,
SUM(CONVERT (int,vax.new_vaccinations)) OVER (PARTITION BY dth.location ORDER BY dth.location,dth.date) AS total_vaccination
FROM CovidProject..CovidDeath dth
JOIN CovidProject..CovidVaccination vax
   ON dth.iso_code= vax.iso_code
   AND dth.date=vax.date
WHERE dth.continent is not null
--ORDER BY 2,3
)
SELECT *,(total_vaccination/population) AS vaccination_population_rate
FROM PopvsVax


--Creating view to store data for later visualizations (common table expression, or CTE)
GO
CREATE VIEW Vaccinated_Population AS 
SELECT dth.continent,dth.location,dth.date,dth.population,vax.new_vaccinations,
SUM(CONVERT (int,vax.new_vaccinations)) OVER (PARTITION BY dth.location ORDER BY dth.location,dth.date) AS total_vaccination
FROM CovidProject..CovidDeath dth
JOIN CovidProject..CovidVaccination vax
   ON dth.iso_code= vax.iso_code
   AND dth.date=vax.date
WHERE dth.continent is not null

