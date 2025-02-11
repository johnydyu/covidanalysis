--SELECT *
--FROM PortfolioProject..[CovidDeaths(CovidDeaths)]
--WHERE continent IS NOT NULL
--ORDER BY 3,4



--SELECT location, date,  population, total_cases,(CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100 AS contractPercentage
--FROM PortfolioProject..[CovidDeaths(CovidDeaths)]
--WHERE location like '%states%'
--ORDER BY 1, 2


-- looking at countries with highest infection rate compared to population

--SELECT location,  population, MAX(total_cases) AS highestinfectioncount,  CASE WHEN CAST(population AS FLOAT) = 0 OR population IS NULL THEN 0
																		-- ELSE (MAX(CAST(total_cases AS FLOAT)) / CAST(population AS FLOAT)) * 100 
																		-- END AS contractPercentage
--FROM PortfolioProject..[CovidDeaths(CovidDeaths)]
--GROUP BY location, population
--ORDER BY contractPercentage DESC


--break things down by continent

--SELECT continent, MAX(CAST(total_deaths AS bigint)) AS TotalDeathCount -- CASE WHEN CAST(population AS FLOAT) = 0 OR population IS NULL THEN 0
																		 --ELSE (MAX(CAST(total_deaths AS FLOAT)) / CAST(population AS FLOAT)) * 100 
																		-- END AS DeathPercentage
--FROM PortfolioProject..[CovidDeaths(CovidDeaths)]
--WHERE continent IS NOT NULL
--GROUP BY continent
--ORDER BY TotalDeathCount DESC	



-- GLOBAL NUMBERS

--SELECT   date,   SUM(cast(new_cases AS BIGINT)) AS total_cases,     SUM(cast(new_deaths AS BIGINT)) AS total_deaths,   CASE WHEN CAST(new_cases AS INT) = 0 OR new_cases IS NULL THEN 0
																		--   ELSE SUM(CAST(new_deaths AS INT)) / SUM(CAST(new_cases AS INT)) * 100  END AS DeathPercentage
--FROM PortfolioProject..[CovidDeaths(CovidDeaths)]
--WHERE continent IS NOT NULL
--GROUP BY date, new_cases
--ORDER BY date DESC



-- looking at total population vs vaccinations



--WITH popvsvac (continent, location, date, population, new_vaccinations, rollingPeopleVaccinated)
--AS (
  

--SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(cast(v.new_vaccinations AS bigint)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rollingPeopleVaccinated
--FROM PortfolioProject..[CovidDeaths(CovidDeaths)] AS d
--JOIN PortfolioProject..[CovidVaccinations(CovidVaccinations)] AS v
--ON d.location = v.location AND d.date =  v.date
--WHERE d.continent IS NOT NULL
--ORDER BY 2, 3
--)
--SELECT *, CASE WHEN CAST(population AS BIGINT) = 0 OR population IS NULL THEN 0
		--	ELSE (rollingPeopleVaccinated / CAST (population AS bigint)) * 100  END AS DeathPercentage
--FROM popvsvac


-- WITH CTE



-- temp table


DROP table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255), location nvarchar(255), date datetime, population numeric, New_vaccinations numeric, rollingPeopleVaccinated numeric )

INSERT into #PercentPopulationVaccinated
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(cast(v.new_vaccinations AS bigint)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rollingPeopleVaccinated
FROM PortfolioProject..[CovidDeaths(CovidDeaths)] AS d
JOIN PortfolioProject..[CovidVaccinations(CovidVaccinations)] AS v
ON d.location = v.location AND d.date =  v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2, 3


SELECT *, CASE WHEN CAST(population AS BIGINT) = 0 OR population IS NULL THEN 0
			ELSE (rollingPeopleVaccinated / CAST (population AS bigint)) * 100  END AS DeathPercentage
FROM #PercentPopulationVaccinated




-- creating view to store data for later viz

CREATE View PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(cast(v.new_vaccinations AS bigint)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS rollingPeopleVaccinated
FROM PortfolioProject..[CovidDeaths(CovidDeaths)] AS d
JOIN PortfolioProject..[CovidVaccinations(CovidVaccinations)] AS v
ON d.location = v.location AND d.date =  v.date
WHERE d.continent IS NOT NULL
--ORDER BY 2, 3