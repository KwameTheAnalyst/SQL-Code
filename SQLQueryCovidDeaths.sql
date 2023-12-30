/*
In this project, we perform calculations to extablish the min, max, use partitions, joins, CTE's, temp tables
group, order and like to make basic queries about the COVID dataset in SQL. 
We check new cases, deaths, infection rate of countries, Total Population vs Vaccination rates and more, 
To conclude, we create views to store for latter visualization
*/
--Select Data that we are going to be using
Select *
From PortfolioProject.dbo.CovidDeaths

Select *
From PortfolioProject.dbo.CovidVaccinations

-- New cases of deaths
Select location, date, total_cases, new_cases,
total_deaths,population
From PortfolioProject.dbo.CovidDeaths
ORDER BY 1, 2

--- Total Cases vs Total Deaths
-- What is the likely of dying if you contract Covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/Nullif(total_cases, 0))*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where location like '%hana%'
Order By 1,2

-- Total Cases vs Population
-- What percentage of population has COVID

Select location, date, total_cases, total_deaths, (total_deaths/Nullif(population, 0))*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where location like '%hana%'
Order By 1,2

-- Countries with highest infection rate
-- What percentage of your population has COVID?

Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/Nullif(population, 0)))*100 as PercentofPopulationInfected
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
Group by location, population
Order By PercentofPopulationInfected desc


Select * 
from PortfolioProject.dbo.CovidDeaths
where continent is not null

--showing countries with the highest Death Count

Select location, max(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by location
Order By TotalDeathCount desc


--- Break down by Continents

Select location, max(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject.dbo.CovidDeaths
where continent = ''
Group by location
Order By TotalDeathCount desc

Select continent, max(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
Order By TotalDeathCount desc


--Showing continent with the highest death count per population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent
Order By TotalDeathCount desc 

-- Global Numbers

Select SUM(new_cases) as total_cases, Sum(cast(new_deaths as int)) as total_deaths, 
Sum(cast(new_deaths as int))/SUM(Nullif(new_cases, 0)) *100 as DeathPercent 
From PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by date
Order By 1,2

--- Looking at Total Population vs Vaccination

Select * 
from PortfolioProject.dbo.CovidVaccinations

-- Apply join on Vaccination and Deaths

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--- USE CTE
-- Vaccination Rate
WITH PopvsVac (continent, location, Date, Population, new_vaccinations, RollingPeopleVaccinated) 
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location,
	dea.Date) AS RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/Nullif(Population,0))*100 as VaccinationRate
From PopvsVac


-- TEMP TABLE
DROP Table if exists #Percent_PopulationVaccinated
DROP Table if exists #PercentPopulation_Vaccinated

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations int,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location,
	dea.Date) AS RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Nullif(Population,0))*100
From #PercentPopulationVaccinated


--Creating views to Store Data for Latter Visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition By dea.location ORDER BY dea.location,
	dea.Date) AS RollingPeopleVaccinated
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Create View ContinentBreakdown as 
Select location, max(cast(total_deaths as int)) as TotalDeathCount 
From PortfolioProject.dbo.CovidDeaths
where continent = ''
Group by location

Create View RegionalInfectionRate as
Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/Nullif(population, 0)))*100 as PercentofPopulationInfected
From PortfolioProject.dbo.CovidDeaths
--where location like '%states%'
Group by location, population

-- Call a view
select *
From PortfolioProject.dbo.RegionalInfectionRate
