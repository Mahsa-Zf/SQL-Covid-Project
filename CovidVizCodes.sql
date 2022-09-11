--1st Visualization

--Using Cntrl+Shift+C we copy rows and headers 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidProject..CovidDeath
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--2nd Visualization

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeath
Where continent is null 
and location not in ('World', 'European Union', 'International','High income','Upper middle income','Lower middle income','Low income')
Group by location
order by TotalDeathCount desc

--3rd Visualization

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProject..CovidDeath
Group by Location, Population
order by PercentPopulationInfected desc

--4th Visualization

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProject..CovidDeath
Group by Location, Population, date
order by PercentPopulationInfected desc