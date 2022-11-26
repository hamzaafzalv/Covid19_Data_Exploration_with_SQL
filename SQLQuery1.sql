SELECT * FROM PortfolioProject..Covid_Vacc order by 3,4;

SELECT * FROM PortfolioProject..Covid_deaths order by 3,4;

USE PortfolioProject;
-- Selecting Data required

Select location,date,total_cases,new_cases,total_deaths,population FROM PortfolioProject..Covid_deaths order by 1,2;

--Total Cases vs Total Deaths 
-- Percentage of Chance for someone dying from covid in the UK
Select location,date,total_cases,total_deaths, 
(total_deaths/total_cases) *100 as Death_percentage
FROM Covid_deaths WHERE location = 'United Kingdom'

-- Total Cases vs Population in the UK
Select location,date,total_cases,population, 
(total_cases/population) *100 as Population_percentage
FROM Covid_deaths WHERE location = 'United Kingdom'

-- Percentage of Population infected in every country with highest at the top
Select location,MAX(total_cases) as Highest_Cases,population, 
MAX((total_cases)/population) *100 as Infection_Perct FROM Covid_deaths
GROUP BY location,population
ORDER BY Infection_Perct DESC

-- Countries with highest death percentage per Populaition
Select location,MAX(cast(total_deaths as int)) as Highest_Deaths,population, 
MAX((total_deaths)/population) *100 as Death_Perct FROM Covid_deaths WHERE continent is not null
GROUP BY location,population
ORDER BY Highest_Deaths DESC


-- Continents with most deaths 
Select location,MAX(cast(total_deaths as int)) as Highest_Deaths
FROM Covid_deaths WHERE continent is null
GROUP BY location
ORDER BY Highest_Deaths DESC

--Global Numbers
Select date, SUM(new_cases) as Cases , SUM(cast(new_deaths as float)) as Deaths, SUM(cast(new_deaths as float))/SUM(new_cases) *100 as Death_Ratio
FROM Covid_deaths
where continent is not null 
group by date  
order by 1,2


-- Applying an Inner Join and using OVER Partition
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations 
, SUM(convert(float,vac.new_vaccinations)) 
OVER(Partition by dea.location order by dea.location,dea.date)	as RollingVaccinationCount
from Covid_deaths dea 
JOIN Covid_Vacc vac
ON dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
ORDER BY 1,2,3

-- USE CTE 

With PopvsVac(Continent, location,date,population,RollingVaccinationCount,new_vaccinations)
as
(
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations 
, SUM(convert(float,vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location,dea.date)as RollingVaccinationCount
from Covid_deaths dea 
JOIN Covid_Vacc vac
ON dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--ORDER BY 1,2,3
)
SELECT * from PopvsVac


--Creating Views
CREATE View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations 
, SUM(convert(float,vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location,dea.date)as RollingVaccinationCount
from Covid_deaths dea 
JOIN Covid_Vacc vac
ON dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--ORDER BY 1,2,3