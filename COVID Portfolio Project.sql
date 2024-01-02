SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--Order by 3,4

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--Looking at Total cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%states%'
and continent is not null
Order by 1,2

--Looking at total cases vs Population
--Shows what percentage of population got covid

SELECT Location, date,  population,total_cases, (total_cases/population)*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Order by 1,2


-- Looking at countries with highest infection rate compared to population

 SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location,Population
Order by PercentagePopulationInfected desc

-- Showing Countries with highest Death count per Population

  SELECT Location,  MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--Let's break things down by continent

 

-- Showing the Continent with Highest Death count

SELECT continent,  MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global Numbers


SELECT  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths ,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null
--Group by date
Order by 1,2


--Joining 2 tables

SELECT *
FROM portfolioProject..CovidDeaths dea
Join portfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date



--Looking at total population vs Vaccination




	 -- USE CTE

	 with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
	 as(
	 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
  From PortfolioProject..CovidDeaths dea
   Join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	-- order by 2,3
	)
	SELECT *, (RollingPeopleVaccinated/Population)*100
	From PopvsVac


	--TEMP TABLE

	DROP Table if exists  #PercentPopulationVaccinated 
	Create Table #PercentPopulationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)

	Insert into	#PercentPopulationVaccinated
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
  From PortfolioProject..CovidDeaths dea
   Join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
	--here dea.continent is not null
	-- order by 2,3


	SELECT *, (RollingPeopleVaccinated/Population)*100
	From #PercentPopulationVaccinated

	--Creating view to store data for later visualizations
	
	Create View PercentPopulationVaccinated as
	
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
  From PortfolioProject..CovidDeaths dea
   Join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date
    where dea.continent is not null
   --order by 2,3

   SELECT *
   FROM PercentPopulationVaccinated
