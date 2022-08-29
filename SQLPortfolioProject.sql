--DATA EXPLORATION

SELECT*
FROM PortfolioProject..CovidDeaths
order by 3,4


SELECT*
FROM PortfolioProject..CovidVaccinations
order by 3,4


/*Select data to be used*/
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

/*Looking at Total Cases vs Total Deaths
Shows likelihood of death after contracting COVID in respective countries
*/
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%Africa%' and continent is not null
order by 1,2


/*Looking at Total_cases vs Population
Shows % of population infected with COVID*/

SELECT Location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
FROM PortfolioProject..CovidDeaths
--Where location like '%Africa%'
order by 1,2


/*Showing countries with highest infection rate compared to population*/
SELECT Location, MAX(total_cases) as HighestInfectionRate, population, MAX((total_cases/population))*100 as InfectedPopulationPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%Africa%'
Group by location,population
order by InfectedPopulationPercentage DESC

/* Showing countries with highest death count per population*/
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is not null
Group by location,population
order by TotalDeathCount DESC


/*Breaking the data down by continent*/
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount DESC


/*Breaking the data down per location in continent*/
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
Where continent='Africa' and continent is NOT null
Group by location
order by TotalDeathCount DESC


/*Global Numbers*/
--Breaks down the global data into total_cases per day, total_deaths per day and DeathPercentage per day
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%Africa%'
Where continent is not null
Group by date
order by 1,2

--Breaks down the data to global_total_cases, global_total_deaths and GlobalDeathPercentage
SELECT SUM(new_cases) as global_total_cases, SUM(cast(new_deaths as int)) as global_total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as GlobalDeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%Africa%'
Where continent is not null
--Group by date
order by 1,2


/*JOINING 2 TABLES*/
Select *
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

--Looking at Total population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


/* Use CTE*/

With PopulationvsVaccination (continent,location,date,population,new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population*100)
From PopulationvsVaccination


/*TEMP TABLE*/

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
Select *, (RollingPeopleVaccinated/population*100)
From #PercentPopulationVaccinated


/*Creating Views to store data for later visualizations*/

Create View Percent_PopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3




