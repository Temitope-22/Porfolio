SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4 DESC;

SELECT *
FROM CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3,4 DESC;

--Usable Data

SELECT
	location, 
	date, 
	total_cases, 
	new_cases,
	total_deaths, 
	population	
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs. Total Dates

-- Showing likihood of dying after contracting COVID in your countries
SELECT
	location, 
	date, 
	total_cases,
	total_deaths,
	(total_deaths/total_cases) * 100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY DeathPercentage desc, 1,2

-- Showing likihood of dying after contracting COVID IN THE United States
SELECT
	location, 
	date, 
	total_cases,
	total_deaths,
	(total_deaths/total_cases) * 100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%'
AND continent is not null
ORDER BY DeathPercentage desc, 1,2

SELECT
	location, 
	date, 
	total_cases,
	total_deaths,
	(total_deaths/total_cases) * 100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states%' and total_deaths is not null
AND continent is not null
ORDER BY 1,2 desc


-- Looking at Total Cases vs. Population
-- Percentag of Population that has contracted COVID

--	U.S.
SELECT
	location, 
	date, 
	total_cases,
	population,
	(total_cases/population) * 100 as ContractionPercentage
FROM CovidDeaths
WHERE location like '%states%' 
and continent is not null
ORDER BY ContractionPercentage desc, 1,2

-- WorldWide
SELECT
	location, 
	date, 
	total_cases,
	population,
	(total_cases/population) * 100 as ContractionPercentage
FROM CovidDeaths
ORDER BY 1,2

-- Looking at countries with Highest Infection Rate Compared to Population
SELECT
	location, 
	population, 
	MAX(total_cases) as HighestInfectionCount,
	MAX((total_cases/population)) * 100 as ContractionPercentage
FROM CovidDeaths
GROUP BY location, population
ORDER BY ContractionPercentage desc

-- Looking at Countries with Highest Death Count per Population
SELECT
	location, 
	MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


--  By Continent
--SELECT
--	continent, 
--	MAX(cast(total_deaths as int)) as TotalDeathCount
--FROM CovidDeaths
--WHERE continent is not null
--GROUP BY continent
--ORDER BY TotalDeathCount desc

SELECT
	location, 
	MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is null 
-- removing categories I do not need
and location != 'Upper middle income'
and location != 'High income'
and location != 'Lower middle income'
and location != 'Low income'
GROUP BY location
ORDER BY TotalDeathCount desc



-- Global Numbers
SELECT 
	date, 
	SUM(new_cases) as total_cases,
	SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT  
	SUM(new_cases) as total_cases,
	SUM(cast(new_deaths as int)) as total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
-- GROUP BY date
ORDER BY 1,2



-- Total Population vs Vaccinations

SELECT 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations,
	-- limiting it by countries 
	SUM(CONVERT(bigint, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date ) NewVaccinationsPerDay_Additive 
	--(NewVaccinationsPerDay_Additive/population)*100
FROM CovidDeaths d
JOIN CovidVaccinations v
ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not null
--and new_vaccinations is not null
ORDER BY 2,3


-- With CTE's

WITH PopVsVacc (Continent, Location, Date, Population, New_Vaccinations, NewVaccinationsPerDay_Additive)
	as
(
SELECT 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations,
	-- limiting it by countries 
	SUM(CONVERT(bigint, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date ) NewVaccinationsPerDay_Additive 
	--(NewVaccinationsPerDay_Additive/population)*100
FROM CovidDeaths d
JOIN CovidVaccinations v
ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not null
--and new_vaccinations is not null
-- ORDER BY 2,3
)
SELECT *,
	(NewVaccinationsPerDay_Additive/Population)*100
FROM PopVsVacc


-- Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
NewVaccinationsPerDay_Additive numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations,
	-- limiting it by countries 
	SUM(CONVERT(bigint, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date ) NewVaccinationsPerDay_Additive 
	--(NewVaccinationsPerDay_Additive/population)*100
FROM CovidDeaths d
JOIN CovidVaccinations v
ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not null
--and new_vaccinations is not null
-- ORDER BY 2,3

SELECT *,
	(NewVaccinationsPerDay_Additive/Population)*100
FROM #PercentPopulationVaccinated

-- Creating Views for Tableau Visulalizations

CREATE VIEW 
PercentPopulationVaccinated AS

SELECT 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations,
	-- limiting it by countries 
	SUM(CONVERT(bigint, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date ) NewVaccinationsPerDay_Additive 
	--(NewVaccinationsPerDay_Additive/population)*100
FROM CovidDeaths d
JOIN CovidVaccinations v
ON d.location = v.location
	and d.date = v.date
WHERE d.continent is not null
and new_vaccinations is not null

SELECT *
FROM PercentPopulationVaccinated

CREATE VIEW 
DeathCountPerCountry AS

SELECT
	location, 
	MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location

CREATE VIEW 
DeathCountPerContinent AS

SELECT
	location, 
	MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent is null 
-- removing categories I do not need
and location not in ('Upper middle income', 'High income', 'Lower middle income', 'Low income', 'World', 'European Union', 'International')
GROUP BY location

CREATE VIEW 
CountryContractionRatePercentage AS

SELECT
	location, 
	population, 
	MAX(total_cases) as HighestInfectionCount,
	MAX((total_cases/population)) * 100 as ContractionPercentage
FROM CovidDeaths
GROUP BY location, population
