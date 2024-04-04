SELECT * FROM portfolio.coviddeaths
where continent is not null
order by 3,4;

-- SELECT * FROM portfolio.covidvaccinations
-- order by 3,4;

-- select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population 
FROM portfolio.coviddeaths
where continent is not null
order by 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, round(( total_deaths/total_cases)*100,2) as Death_percentage
FROM portfolio.coviddeaths
where location like '%states%'
order by 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid
select location, date, population, total_cases, round(( total_cases/population)*100,2) as percent_population_infected
FROM portfolio.coviddeaths
-- where location like '%states%'
order by 1,2;

-- Looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, round(max(( total_cases/population))*100,2) as Highest_percent_population_infected
FROM portfolio.coviddeaths
-- where location like '%states%'
where continent is not null
group by location, population
order by Highest_percent_population_infected desc;

-- Showing countries with highest death count per population

select location, max(cast(total_deaths as unsigned) )  as Total_Death_Count
FROM portfolio.coviddeaths
-- where location like '%states%'
where continent is not null
group by location
order by Total_Death_Count desc;

-- Let's break thing down by continent
-- Showing continets with the highest death count per population 

select continent, max(cast(total_deaths as unsigned))  as TotalDeathCount
FROM portfolio.coviddeaths
-- where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc;

-- Global Numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as unsigned)) as total_deaths, round(sum(cast(new_deaths as unsigned)) / sum(new_cases)*100,2) as Death_percentage
FROM portfolio.coviddeaths
-- where location like '%states%'
where continent is not null
order by 1,2;

-- Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT( vac.new_vaccinations, unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From Portfolio.CovidDeaths dea
Join Portfolio.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(vac.new_vaccinations, unsigned)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100
From Portfolio.CovidDeaths dea
Join Portfolio.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(vac.new_vaccinations, UNSIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated,
    (SUM(CONVERT(vac.new_vaccinations, UNSIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) / dea.population) * 100 AS PercentVaccinated
FROM
    Portfolio.CovidDeaths dea
JOIN
    Portfolio.CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;

select * from PercentPopulationVaccinated;



