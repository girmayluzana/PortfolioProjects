Select *
From Portfolio..CovidDeaths
where continent is not NULL
order by 3, 4

Select *
From Portfolio..CovidVaccinations


--Looking at total cases vs total deaths
--Shows what percentage of people who got infected died
Select location, total_cases, total_deaths, Round ((total_deaths/total_cases) * 100, 2) AS DeathPercentage
From Portfolio..CovidDeaths
where continent is not NULL
Order by location


--Looking at Total cases vs Population
--Shows what percentage of population got infected
Select Location, date, total_cases, Population, Round((total_cases/Population) * 100, 2) AS InfectionPercentage
From Portfolio..CovidDeaths
where continent is not NULL
Order by Location

--Looking at countries with highest infection rate compared to population
Select Location, Population, MAX(total_cases) AS HighestInfectionCount, Round((MAX(total_cases)/Population) * 100, 4) AS InfectionPercentage
From Portfolio..CovidDeaths
where continent is not NULL
Group by Location, Population
Order by InfectionPercentage desc

--Looking at countries with highest death count
Select Location, MAX(total_deaths) AS HighestDeathCount
From Portfolio..CovidDeaths
where continent is not NULL
Group by Location
Order by HighestDeathCount desc


-- Showing the continents with the highest death counts per population
Select continent, MAX(total_deaths) AS HighestDeathCount
From Portfolio..CovidDeaths
where continent is not NULL
Group by continent
Order by HighestDeathCount desc

--Death Percentage per continent
Select Continent, SUM(new_cases) AS TotalCases, SUM(new_deaths) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases)) * 100 AS DeathPercentage
From Portfolio..CovidDeaths
Where continent is NOT NULL
Group by continent
order by 1,2


-- Total Population vs Vaccinations
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by death.location 
	Order by death.location, death.date) AS RollingPeopleVaccinated
From Portfolio..CovidDeaths death
Join Portfolio..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
Where death.continent is NOT NULL
Order by 2,3


-- USE CTE
With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by death.location 
	Order by death.location, death.date) AS RollingPeopleVaccinated
From Portfolio..CovidDeaths death
Join Portfolio..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
Where death.continent is NOT NULL
)

Select * , (RollingPeopleVaccinated/Population) * 100
From PopVsVac
Order by location, date

/*
Some rows have the continent as Null and have the continent listed in the location field.
*/

--populate the NULL values in the continent field from the location field 
	
Update a 
SET continent = ISNULL(a.continent, b.location)
from CovidVaccinations a
	join CovidVaccinations b 
	on a.iso_code = b.iso_code
where a.continent is null

Update a 
SET continent = ISNULL(a.continent, b.location)
from CovidDeaths a
	join CovidDeaths b 
	on a.iso_code = b.iso_code
where a.continent is null

-- Temp Table
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
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by death.location 
	Order by death.location, death.date) AS RollingPeopleVaccinated
From Portfolio..CovidDeaths death
Join Portfolio..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
Where death.continent is NOT NULL

Select * , (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated
Order by location, date

-- Creating view to store data for later visualizations
Create View PercentPopulationVaccinatedView as 
Select death.continent, death.location, death.date, death.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as float)) OVER (Partition by death.location 
	Order by death.location, death.date) AS RollingPeopleVaccinated
From Portfolio..CovidDeaths death
Join Portfolio..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
Where death.continent is NOT NULL

