
-- exploring the World Covid dataset provided by CDC. 
-- Date: 05/02/2021

select * FROM coviddeaths
where continent is not NULL
order BY 3,4


-- select columns needed for initial data exploration


SELECT location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
WHERE continent is NOT NULL
--order by 1,2 


-- Total cases vs Total death
-- shows the probability of dying if a person contracts covid in their respective country

SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    CONCAT(ROUND((total_deaths / total_cases) * 100, 2), '%') AS Death_Percentage
FROM coviddeaths
WHERE continent IS NOT NULL
  AND location LIKE '%states%' -- enter country name to see a SPECIFIC country


--Total cases vs population
-- shows the probability of contracting covid in each country

SELECT 
    location, 
    date, 
    total_cases, 
    population, 
    CONCAT(ROUND((total_cases / population) * 100, 2), '%') AS PercentPopulationInfected
FROM coviddeaths


-- Countries with Highest Infection Rate compared to Population
SELECT 
    location, 
    population, 
    MAX(total_cases) AS HighestInfectionCount, 
    ROUND(MAX(total_cases) / population * 100, 2) AS PercentPopulationInfected
FROM coviddeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- countries with highest death perentage

SELECT 
    location, 
    population, 
    MAX(total_deaths) AS HighestDeathCount, 
    ROUND(MAX(total_deaths) / population * 100, 2) AS PercentPopulationInfected
FROM coviddeaths
where location is not NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- totla death count per continent

SELECT 
    continent, 
    SUM(new_deaths) AS TotalDeathCount
FROM 
    coviddeaths
WHERE 
    continent IS NOT NULL
GROUP BY 
    continent
ORDER BY 
    TotalDeathCount DESC;



-- countries with highest death count

SELECT location, 
       MAX(CAST(total_deaths AS SIGNED)) AS TotalDeathCount
FROM coviddeaths
where continent is NOT NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- Global numbers

select sum(new_cases) as total_cases, sum(CAST(new_deaths as signed)) as total_deaths, sum(CAST(new_deaths as SIGNED))/sum(new_cases)*100 as deathpercentage
from coviddeaths
where continent is not NULL 
ORDER BY 1,2

-- percentage by date
select date, sum(new_cases) as total_cases, sum(CAST(new_deaths as signed)) as total_deaths, sum(CAST(new_deaths as SIGNED))/sum(new_cases)*100 as deathpercentage
from coviddeaths
where continent is not NULL 
GROUP BY date 
ORDER BY 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.location, dea.continent, dea.population, dea.date, vac.new_vaccinations, sum(cast(vac.new_vaccinations as SIGNED)) OVER(PARTITION BY dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
    from coviddeaths dea 
    JOIN covidvaccinations vac 
    on dea.location = vac.location
    and dea.date = vac.date
    where dea.continent is NOT NULL
    -- and dea.continent = 'Europe'
    -- and dea.location = 'Moldova'
    order by 1,2,3  

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(

SELECT dea.location, dea.continent, dea.population, dea.date, vac.new_vaccinations, sum(cast(vac.new_vaccinations as SIGNED)) OVER(PARTITION BY dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
    from coviddeaths dea 
    JOIN covidvaccinations vac 
    on dea.location = vac.location
    and dea.date = vac.date
    where dea.continent is NOT NULL
    -- -- and dea.continent = 'Europe'
    -- -- and dea.location = 'Moldova'
    -- order by 1,2,3 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- temptable

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as SIGNED)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as SIGNED)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated

From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 







