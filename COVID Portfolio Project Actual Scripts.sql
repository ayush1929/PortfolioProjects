SELECT * 
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent is not null
ORDER  BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

-- Select Data that we are going to be Using

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1, 2


-- Looking at the Total Cases vs Total Deaths by Country
-- Shows likelihood of Dying if you track covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
Where location like '%india%'
ORDER BY 1, 2


-- Looking at Total Cases vs Population
-- Shows what percentage of Population got Covid
Select location, date,population, total_cases, (total_cases/population)*100 as CasePercentage -- PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths$
--Where location like '%india%'
ORDER BY 1, 2

-- Finding the Country with the Highest Infection Rates compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as 
	PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths$
-- Where location like '%india%'
Group By location, population
ORDER BY PercentOfPopulationInfected DESC


-- Showing Countries with Highest Death count per population

Select location, MAX(cast(total_deaths as int))  as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
-- Where location like '%india%'
where continent is not null
Group By location
ORDER BY TotalDeathCount DESC



-- LET'S BREAK THINGS DOWN BY CONTINENT




-- SHOWING the Continents with the highest deathcounts per population

Select continent, MAX(cast(total_deaths as int))  as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
-- Where location like '%india%'
where continent is not null
Group By continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--Where location like '%india%'
where continent is not null
group by date
ORDER BY 1, 2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--Where location like '%india%'
where continent is not null
--group by date
ORDER BY 1, 2



-- Looking at total population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
ORDER BY 2,3


--USE CTE
WITH Popvsvac (continent, location, date, population ,New_Vaccinations, RollingPoepleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
-- ORDER BY 2,3
)
Select * , (RollingPoepleVaccinated/population)*100
From Popvsvac

-- TEMP TABLE
DROP TABLE If EXISTS #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
--where dea.continent is not null
-- ORDER BY 2,3

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- CREATE VIEW to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
	dea.date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2,3


Select * 
from PercentPopulationVaccinated



























