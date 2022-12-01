SELECT LOCATION, DATE, TOTAL_CASES,NEW_CASES, TOTAL_DEATHS, POPULATION
FROM c_deaths
ORDER BY 1,2;


SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, (SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100) AS death_percentage
FROM c_deaths
WHERE continent IS NOT NULL;


SELECT location, SUM(new_deaths) AS totaldeathcount
FROM c_deaths
WHERE continent IS NULL
AND location NOT IN ('%income%', 'World', 'European Union', 'International')
AND location NOT LIKE '%income%'
GROUP BY 1
ORDER BY 2 DESC;


-- Comparing the max number of total_cases vs population and calculating the percent of population that has been infected.
SELECT location, population, MAX(total_cases) AS MaxInfectedCount, (MAX(total_cases)/population)*100 AS Percent_of_population_Infected
FROM c_deaths
GROUP BY 1, 2
ORDER BY 4 DESC;



SELECT location, population, date, MAX(total_cases) AS MaxInfectedCount, (MAX(total_cases)/population)*100 AS Percent_of_population_Infected
FROM c_deaths
GROUP BY 1, 2, 3
ORDER BY 1, 5 DESC;


-- Comparing the total_cases vs total_deaths and calculating percentage of deaths per case.
-- -- The calculation would show the chance of dying (%) if infected with COVID-19 in the specified country below. 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Deaths_per_Cases
FROM c_deaths
WHERE location like 'United States'
ORDER BY 1,2;


-- Here we are finding the countries' highest infection rate of COVID-19 compared to their population.
SELECT location, MAX(total_cases) AS MaxCases, population, MAX((total_cases/population))*100 AS case_per_population
FROM c_deaths
GROUP BY 1,3
ORDER BY 4 DESC;


-- Here we are finding the countries' highest ratio of death to population while showing the highest death count per country.
SELECT location, MAX(total_deaths) AS HighestDeathCount, population, MAX(total_deaths/population)*100 AS DeathRatePercentage
FROM c_deaths
WHERE continent IS NOT NULL
AND total_deaths IS NOT NULL
GROUP BY 1,3
ORDER BY 2 DESC;


-- Now we are looking at the total deaths per continent and per the world.
SELECT location, MAX(total_deaths) AS HighestDeathCount, population
FROM c_deaths
WHERE continent IS NULL
AND population IS NOT NULL
AND location NOT LIKE 'European Union' 
AND location NOT LIKE '%income%'
GROUP BY 1,3
ORDER BY 2 DESC;


-- Finding the number of new cases and deaths for the entire world per day then calculating the new deaths per new cases, DailyDeathPercentage.
SELECT date, SUM(new_cases) AS DailyCases, SUM(new_deaths) AS DailyDeaths, SUM(new_deaths)/SUM(new_cases)*100 AS DailyDeathPercentage
FROM c_deaths
WHERE continent IS NOT NULL
AND new_deaths IS NOT NULL
AND new_cases > 0
GROUP BY 1
ORDER BY 1;


---Joining two tables together based on the shared dates. This will allow for the comparison of columns from different tables.
---Using a common table expression, cte.
WITH DailyVaccinations (location, date, population, new_vaccinations, DailyVacc) AS
( 
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS DailyVacc
FROM c_deaths as dea
FULL JOIN c_vacc as vac
ON dea.date = vac.date
AND dea.location = vac.location
WHERE dea.location LIKE 'Canada'
AND vac.new_vaccinations > 0
OR dea.location LIKE 'United States'
AND vac.new_vaccinations > 0
-- GROUP BY 1,2,3
-- ORDER BY 1,2
)
SELECT *, (DailyVacc/population)*100 AS Percent_of_Population_Vaccinated
FROM DailyVaccinations
GROUP BY date, dailyvaccinations.location, dailyvaccinations.population, dailyvaccinations.new_vaccinations, dailyvaccinations.dailyvacc
ORDER BY location;


---Created a temp table. Had to include semicolons so that drop and create can be ran one at a time.
DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TABLE PercentPopulationVaccinated
(
Location varchar(50),
Date date,
Population numeric,
New_Vaccinations numeric,
DailyVacc numeric
);
INSERT INTO PercentPopulationVaccinated
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS DailyVacc
FROM c_deaths as dea
FULL JOIN c_vacc as vac
ON dea.date = vac.date
AND dea.location = vac.location
WHERE dea.location LIKE 'Canada'
AND vac.new_vaccinations > 0
OR dea.location LIKE 'United States'
AND vac.new_vaccinations > 0
-- GROUP BY 1,2,3
-- ORDER BY 1,2
;
SELECT *, (DailyVacc/population)*100 AS Percent_of_Population_Vaccinated
FROM PercentPopulationVaccinated
GROUP BY date, location, population, new_vaccinations, dailyvacc
ORDER BY location;


-- Creating a view
DROP VIEW IF EXISTS maxvacc;
CREATE VIEW maxvacc AS
SELECT continent, MAX(total_deaths) AS total_deaths
FROM c_deaths
WHERE continent IS NOT NULL
GROUP BY 1;

SELECT *
FROM maxvacc;
