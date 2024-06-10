-- SELECT * FROM coviddeaths WHERE continent IS NOT NULL ORDER BY 3,4;

-- SELECT location, date, total_cases, new_cases, total_deaths, population FROM coviddeaths 
-- ORDER BY location, date;


### Total cases vs Total deaths
# Likelihood of dying if you contract COVID in your country
-- SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentage FROM coviddeaths 
-- WHERE location LIKE '%states%' ORDER BY location, date;


### Total Cases vs Population
# Shows percentage of population contracted COVID
-- SELECT location, date, total_cases, population, (total_cases/population)*100 AS populpercentage FROM coviddeaths 
-- WHERE location LIKE '%states%' ORDER BY 1, 2;


### Countries with Highest Infection Rate compared to Population
-- SELECT location, population, MAX(total_cases) AS highestinfectioncount, MAX((total_cases/population))*100 AS populpercentage FROM coviddeaths 
-- GROUP BY location, population ORDER BY populpercentage DESC;


### Countries with Highest Death Count per Population
-- SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS totaldeathcount FROM coviddeaths 
-- WHERE continent IS NOT NULL GROUP BY location ORDER BY totaldeathcount DESC;


# Breakdown by Continent
-- SELECT continent, MAX(CAST(total_deaths AS UNSIGNED)) AS totaldeathcount FROM coviddeaths 
-- WHERE continent IS NOT NULL GROUP BY continent ORDER BY totaldeathcount DESC;



### GLOBAL NUMBERS
-- SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS UNSIGNED)) AS total_deaths, 
-- SUM(CAST(new_deaths AS UNSIGNED))/SUM(new_cases)*100 AS deathpercentage FROM coviddeaths 
-- WHERE continent IS NOT NULL GROUP BY date ORDER BY 1, 2;



### Total Population vs Vaccinations
-- SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
-- SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS peoplevaccinated
-- FROM coviddeaths AS dea JOIN covidvaccinations AS vac ON dea.location = vac.location AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL ORDER BY 2, 3;


## CTE
-- WITH PopvsVac (continent, location, date, population, new_vaccinations, peoplevaccinated) AS (
-- SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
-- SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS peoplevaccinated
-- FROM coviddeaths AS dea JOIN covidvaccinations AS vac ON dea.location = vac.location AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL
-- );

-- SELECT * FROM PopvsVac;


## Temp Table
-- DROP TABLE IF EXISTS percentpopvaccinated;
-- CREATE TEMPORARY TABLE percentpopvaccinated (
--     continent VARCHAR(255),
--     location VARCHAR(255),
--     date DATETIME,
--     population INT,
--     new_vaccinations INT,
--     peoplevaccinated INT
-- );

-- INSERT INTO percentpopvaccinated 
-- SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
-- SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS peoplevaccinated
-- FROM coviddeaths AS dea JOIN covidvaccinations AS vac ON dea.location = vac.location AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL;

-- SELECT *, (peoplevaccinated/population)*100 FROM percentpopvaccinated;



### Create View to store data for visualizations
CREATE VIEW percentpopvaccinated AS SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS peoplevaccinated
FROM coviddeaths AS dea JOIN covidvaccinations AS vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;



