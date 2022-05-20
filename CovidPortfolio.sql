-- Looking at the coviddeaths data

SELECT *
FROM PortfolioProject.dbo.coviddeaths
WHERE continent is not null
ORDER BY 3,4;


-- Looking at the covidvac data

SELECT *
FROM PortfolioProject.dbo.covidvac
ORDER BY 3,4;


-- Select the data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.coviddeaths
WHERE continent is not null
ORDER BY 1,2


-- Looking at total cases vs total deaths
-- Shows the liklihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM PortfolioProject.dbo.coviddeaths
WHERE location like '%canada%'
AND continent is not null
ORDER BY 1,2


-- Looking at the total cases vs population
-- Shows what percentage of population got covid

SELECT location, date, population, total_cases,(total_deaths/population)*100 as percent_population_death
FROM PortfolioProject.dbo.coviddeaths
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to population

SELECT location, population, max(total_cases) as highest_infection,max((total_cases/population))*100 as percent_population_infected
FROM PortfolioProject.dbo.coviddeaths
GROUP BY location, population
ORDER BY percent_population_infected Desc


-- Showing the countries with the highest death count per population

SELECT location, max(cast(total_deaths as int)) as Total_deaths
FROM PortfolioProject.dbo.coviddeaths
WHERE continent is not null
GROUP BY location
ORDER BY Total_deaths Desc


-- Showing the continents with the highest deaths count per population

SELECT continent, max(cast(total_deaths as int)) as Total_deaths
FROM PortfolioProject.dbo.coviddeaths
WHERE continent is not null
GROUP BY continent
ORDER BY Total_deaths Desc


-- Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
FROM PortfolioProject.dbo.coviddeaths
--where location like '%canada%'
where continent is not null
order by 1,2


-- Looking at total population vs total vaccination
-- CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvac vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Temp Table 

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
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvac vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..coviddeaths dea
Join PortfolioProject..covidvac vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
