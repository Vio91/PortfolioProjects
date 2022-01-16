Select * 
From Portfolio_Project..CovidDeaths1$
Where continent is not NULL
Order By 3,4

--Select *
--From Portfolio_Project..CovidVaccinations$
--Order By 3,4

Select Location, date, total_cases, new_cases, total_deaths,population
From Portfolio_Project..CovidDeaths1$
Order By 1,2


--Looking at total cases vs total deaths
--Shows the likelehood of dying if you have covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
From Portfolio_Project..CovidDeaths1$
Where Location like '%states%'
Order By 1,2


--Looking at Total Cases vs Population

Select Location, date, total_cases, population, (total_cases/population)*100 as Total_cases_percentage
From Portfolio_Project..CovidDeaths1$
Where Location like '%states%'
Order by 1,2 

--Looking at countries with highest infection rates compared to population
Select Location, Max(total_cases) as HighestInfectionCount,MAX(total_cases/population)*100 as Total_cases_percentage
From Portfolio_Project..CovidDeaths1$
--Where Location like '%states%'
Group By Location, Population 
Order by  Total_cases_percentage DESC
 
 --Total Death Count 
 --Select Location, SUM(cast(new_deaths as int)) as TotalDeathCount
-- From Portfolio_Project..CovidDeaths1$
 --Where location like '%state%'
 --Where continent is not null 
 --and location not in ('World','European Union', 'International')
 --Group By Location
 --order by TotalDeathCount DESC

 --Percent Population infected by location
 Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
 From Portfolio_Project..CovidDeaths1$
 Group By Location, population
 Order By PercentPopulationInfected desc
 
 
 --Percent Population Infected by location and date 

 Select Location,Population, Date, Max(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
 FROM Portfolio_Project..CovidDeaths1$
 Group By Location,population,date 
 order by PercentPopulationInfected DESC

--Showing countries with highest dead count per population
Select Location, MAX(cast(total_deaths AS int)) as Total_death_count
From Portfolio_Project..CovidDeaths1$
--Where Location like '%states%'
Where continent is not NULL
Group By Location
Order by  Total_death_count DESC

-- Lets Break things down by Continent


--Showing contintents with the highest death count

Select continent, MAX(cast(total_deaths AS int)) as Total_death_count
From Portfolio_Project..CovidDeaths1$
--Where Location like '%states%'
Where continent is not NULL
Group By continent
Order by  Total_death_count DESC


--GLOBAL NUMBERS PER DATE
Select date,SUM(new_cases) AS NewCasesByDate, SUM(cast(new_deaths as int)) AS NewDeathsByDate, SUM(cast(new_deaths as int)) /SUM(new_cases)*100 AS Death_Percentage
From Portfolio_Project..CovidDeaths1$
--Where Location like '%states%'
Where continent is not null
Group By date 
Order By 1,2

--GlOBAL NUMBERS TOTAL
Select SUM(new_cases) AS Total_cases, SUM(cast(new_deaths as int)) AS NewDeathsTotal, SUM(cast(new_deaths as int)) /SUM(new_cases)*100 AS Death_Percentage
From Portfolio_Project..CovidDeaths1$
--Where Location like '%states%'
Where continent is not null
--Group By date 
Order By 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location,dea.date ) as RollingPeopleVaccinated
From Portfolio_Project..CovidDeaths1$ dea
Join Portfolio_Project..CovidVaccinations$  vac
ON dea.location = vac.location
AND dea.date = vac.date
Where dea.continent is not null
Order By 2,3


--USE CTE 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location,dea.date ) as RollingPeopleVaccinated
From Portfolio_Project..CovidDeaths1$ dea
Join Portfolio_Project..CovidVaccinations$  vac
ON dea.location = vac.location
AND dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 AS PercentPPLVac
From PopvsVac


--TEMP Table
DROP Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric 
)
INSERT INTO #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location,dea.date ) as RollingPeopleVaccinated
From Portfolio_Project..CovidDeaths1$ dea
Join Portfolio_Project..CovidVaccinations$  vac
ON dea.location = vac.location
AND dea.date = vac.date
--Where dea.continent is not null
--Order By 2,3

Select *, (RollingPeopleVaccinated/Population)*100 AS PercentPPLVac
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location,dea.date ) as RollingPeopleVaccinated
From Portfolio_Project..CovidDeaths1$ dea
Join Portfolio_Project..CovidVaccinations$  vac
ON dea.location = vac.location
AND dea.date = vac.date
Where dea.continent is not null
--Order By 2,3


Select *
FROM PercentPopulationVaccinated


