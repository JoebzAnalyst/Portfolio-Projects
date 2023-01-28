--SELECT *
--FROM Portfolio_Project..CovidVaccinations

--SELECT *
--FROM Portfolio_Project..CovidDeaths 



--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM Portfolio_Project..CovidDeaths 
--ORDER BY 1,2


/*  Looking at Total Deaths vs Total Cases  
    This result shows the Death Percentage if you contract Covid in your country  */
--SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
--FROM Portfolio_Project..CovidDeaths 
--WHERE location LIKE '%state%'
--ORDER BY 1, 2


/*  Looking at Total Case (count & %) vs Total Death (count & %) vs Total Population per Country 
	This result in showing the trend in total Covid, Total Death in count & percentage over time across population per country  */
--SELECT location, date, population, total_cases, total_deaths, ROUND((total_cases/population)*100,2) AS CovidPercentage, ROUND((total_deaths/total_cases)*100,2) AS DeathPercentage
--FROM Portfolio_Project..CovidDeaths 
----WHERE location LIKE '%states'
--ORDER BY 1, 2


/*  Looking at Total Case vs Total Population per Country 
	This result in showing the total Covid percentage across population per country  */
--SELECT location, MAX(population) AS tot_population, MAX(total_cases) AS tot_cases, ROUND(MAX(total_cases)/MAX(population)*100, 2) AS '%Covid'
--FROM Portfolio_Project..CovidDeaths 
--GROUP BY location
--ORDER BY '%Covid' DESC


/*  Looking at Total Case vs Total Population in your country    
	This result in showing the Total Covid Percentage across population in your country  */
--SELECT location, MAX(population) AS tot_population, MAX(total_cases) AS tot_cases, ROUND(MAX(total_cases)/MAX(population)*100.00, 2) AS '%PopulationInfected' 
--FROM Portfolio_Project..CovidDeaths 
----WHERE location LIKE '%states'
--GROUP BY location
--ORDER BY '%PopulationInfected' DESC


/*  Looking at Total Case (count & %) vs Total Death (count & %) vs Total Population per Country 
	This result in showing the total Covid, Total Death in count & percentage per country  */
--SELECT location, MAX(population) AS Population, MAX(total_cases) AS Total_Cases, MAX(CAST(total_deaths AS INT)) AS Total_Deaths, 
--		ROUND((MAX(total_cases)/MAX(population))*100,2) AS CovidPercentage, ROUND((MAX(total_deaths)/MAX(total_cases))*100,2) AS DeathPercentage
--FROM Portfolio_Project..CovidDeaths 
--WHERE continent IS NOT NULL
----WHERE location LIKE '%states'
--GROUP BY location
--ORDER BY 4 DESC


/*  Looking at Total Case (count & %) vs Total Death (count & %) vs Total Population per continent
	This result in showing the total Covid, Total Death in count & percentage per country  */
--SELECT continent, MAX(population) AS Population, MAX(total_cases) AS Total_Cases, MAX(CAST(total_deaths AS INT)) AS Total_Deaths, 
--		ROUND((MAX(total_cases)/MAX(population))*100,2) AS CovidPercentage, ROUND((MAX(total_deaths)/MAX(total_cases))*100,2) AS DeathPercentage
--FROM Portfolio_Project..CovidDeaths 
--WHERE continent IS NOT NULL
----WHERE location LIKE '%states'
--GROUP BY continent
--ORDER BY Total_Deaths DESC

/* Global Numbers  */
--SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, 
--	SUM(CAST(new_deaths AS INT))/SUM(new_cases) AS 'Death %'
--FROM Portfolio_Project..CovidDeaths 
----WHERE location LIKE '%states%'
--WHERE continent IS NOT NULL
----GROUP BY date
--ORDER BY Total_Cases, Total_Deaths


/*  Total Population vs Vaccinations  */
/*  Using CTE  */

--WITH PopvcVac (continent, location, date, population, new_vaccinations, CummPeopleVaccinated)
--AS
--(
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--	, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CummPeopleVaccinated
--FROM Portfolio_Project..CovidDeaths AS dea
--JOIN Portfolio_Project..CovidVaccinations AS vac
--	ON dea.location = vac.location
--	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
----ORDER BY 2, 3
--)
--SELECT *, (CummPeopleVaccinated/population)*100 AS NewVacc_vs_Population
--FROM PopvcVac



/*  Temp Table  */

--DROP TABLE IF EXISTS #PercentPopulationVaccinated
--CREATE TABLE #PercentPopulationVaccinated
--(
--continent nvarchar(255),
--location nvarchar(255),
--date datetime,
--population numeric,
--new_vaccinations numeric,
--CummPeopleVaccinated numeric
--)

--INSERT INTO #PercentPopulationVaccinated
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--	, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CummPeopleVaccinated
--FROM Portfolio_Project..CovidDeaths AS dea
--JOIN Portfolio_Project..CovidVaccinations AS vac
--	ON dea.location = vac.location
--	AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
----ORDER BY 2, 3

--SELECT *, (CummPeopleVaccinated/population)*100 AS NewVacc_vs_Population
--FROM #PercentPopulationVaccinated


/* Create view to store data for later visualizations  */

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS CummPeopleVaccinated
FROM Portfolio_Project..CovidDeaths AS dea
JOIN Portfolio_Project..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3


SELECT *
FROM PercentPopulationVaccinated