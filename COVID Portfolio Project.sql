Select *
From [Portfolio Project]..CovidDeaths
Where continent is not null
Order by 3,4

--Select *
--From [Portfolio Project]..CovidVaccinations
--Order by 3,4

--Select data that we are going to be using 

Select Location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
Where continent is not null
Order by 1,2


-- Looking at the total cases vs Total Deaths 
-- Shows the likelihood of dying after contraction

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location like '%Ghana%'
and continent is not null
Order by 1,2


-- Looking at total cases vs Population
-- Shows the percentage that got COVID

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like '%Ghana%'
Where continent is not null
Order by 1,2


-- Looking at Countries with Highest infection rates compared to population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
--Where location like '%Ghana%'
Where continent is not null
Group by Location, Population
Order by PercentPopulationInfected desc


-- Showing Countries with the highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%Ghana%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc


-- Now to break things down by CONTINENT

-- Showing the continents with the highest death count

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
--Where location like '%Ghana%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%Ghana%'
Where continent is not null
--Group by date
Order by 1,2


--Joining both tables
--Looking at total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.Date) as PeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- USING CTE...

With PopulationvsVaccination (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.Date) as PeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (PeopleVaccinated/Population)*100
From PopulationvsVaccination





-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated  --for alterations
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.Date) as PeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (PeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




--Creating View to store data for later Visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.Date) as PeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
   On dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select *
From PercentPopulationVaccinated

 
 
 
 --View 2

 Create View GlobalNumbers as 
 Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%Ghana%'
Where continent is not null
--Group by date
--Order by 1,2

Select *
From GlobalNumbers
