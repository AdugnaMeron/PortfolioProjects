SELECT * 
FROM CovidProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4 


SELECT * 
FROM CovidProject..CovidVaccinations
WHERE continent is not null
--WHERE location = 'United States'
ORDER BY 3,4 

--Select data that we will be using
SELECT continent, location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 2,3

-- Total Cases vs Total Deaths
-- Shows percentage of dying from covid cases
SELECT continent, location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'United States'
ORDER BY 2,3

-- Total Cases vs Population
-- Shows what percentage ofpopulation got covid
SELECT continent, location, date, population, total_cases, (total_cases/population)*100 AS PercentageOfCases
FROM CovidDeaths
--WHERE location = 'United States'
ORDER BY 2,3


-- Highest infection rates compared to population
-- Shows highest infection rates
SELECT continent, location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentOfPopulationInfected
FROM CovidDeaths
--WHERE location = 'United States'
GROUP BY continent, location, population
ORDER BY PercentOfPopulationInfected DESC


--Showing countries with highest death count per population
SELECT continent, location, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
--WHERE location = 'United States'
WHERE continent is not null
GROUP BY continent, location
ORDER BY TotalDeathCount DESC

--Break it down by continent
--Continents with the highest death counts 
SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM CovidDeaths
--WHERE location = 'United States'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global numbers
SELECT date, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, 
		SUM(new_cases)/SUM(total_deaths)*100 AS DeathPercentage
FROM CovidDeaths
--WHERE location = 'United States'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


--Shows total population vs Vaccinations (X work for me since new_vaccinations is mostly null)
SELECT dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations, 
		SUM(CAST (vac.new_vaccinations AS INT)) 
		OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		--(RollingPeopleVaccinated/population)*100
FROM CovidProject..CovidDeaths	dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.location = 'United States'
--WHERE dea.continent is not null 
ORDER BY 2,3

--USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations, 
		SUM(CAST (vac.new_vaccinations AS INT)) 
		OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		--(RollingPeopleVaccinated/population)*100
FROM CovidProject..CovidDeaths	dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.location = 'United States'
WHERE dea.continent is not null 
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentageVaccinated
FROM PopvsVac

--Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations, 
		SUM(CAST (vac.new_vaccinations AS INT)) 
		OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		--(RollingPeopleVaccinated/population)*100
FROM CovidProject..CovidDeaths	dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.location = 'United States'
WHERE dea.continent is not null 
--ORDER BY 2,3


SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentageVaccinated
FROM #PercentPopulationVaccinated


-- CREATING VIEW to store data for later visualizations

--Population Vaccination
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations, 
		SUM(CAST (vac.new_vaccinations AS INT)) 
		OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
		--(RollingPeopleVaccinated/population)*100
FROM CovidProject..CovidDeaths	dea
JOIN CovidProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.location = 'United States'
WHERE dea.continent is not null 
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated