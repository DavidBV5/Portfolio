Select*
From Project1..CovidDeaths
Order by 3,4;

Select*
From Project1..CovidVaccinations
Order by 3,4;

Select Location, Date, total_cases, new_cases, total_deaths, Population
From Project1..CovidDeaths
Order by 1,2;

--shows percentage that have died to covid
Select Location, Date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Project1..CovidDeaths
Where location like '%states%'
Order by 1,2;

--%shows the pop that got covid
Select Location, Date, total_cases, Population, (total_cases/population)*100 as PercentPopInfected
From Project1..CovidDeaths
Where location like '%states%'
Order by 1,2;

--infected of total population
Select Location, Population, Max(total_cases) as HighestInfectionCount, Population, (Max(total_cases)/population)*100 as PercentPopInfected
From Project1..CovidDeaths
--Where location like '%states%'
Group by Location, Population
Order by PercentPopInfected desc;


--highest infection at a time
Select Location, Population, Max(new_cases) as HighestInfectionCount, Population, (Max(new_cases)/population)*100 as PercentPopInfected
From Project1..CovidDeaths
--Where location like '%states%'
Group by Location, Population
Order by PercentPopInfected desc;

--showing countries with highest death count per pop
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From Project1..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc;

--showing continents with highest death count
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
From Project1..CovidDeaths
--Where location like '%states%'
Where continent is null
Group by Location
Order by TotalDeathCount desc;

-- GLOBAL NUMBERS

Select sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From Project1..CovidDeaths
Where continent is not null
--Group by date
Order by 1,2;

--total pop vs vacc
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RPeopleVaccinated
--,(RPeopleVaccinated/population*100)
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
Order by 2,3;

--useCTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RPeopleVaccinated
--,(RPeopleVaccinated/population*100)
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
--Order by 2,3
)
Select*, (RPeopleVaccinated/Population)*100
From PopvsVAC;

--TEMPtable

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RPeopleVaccinated
--,(RPeopleVaccinated/population*100)
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null
Order by 2,3;

Select*, (RPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated;


--Creating view to store data for later visual
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RPeopleVaccinated
--,(RPeopleVaccinated/population*100)
From Project1..CovidDeaths dea
Join Project1..CovidVaccinations vac
	on dea.location=vac.location
	and dea.date=vac.date
Where dea.continent is not null