Select *
From PortfolioProject..CovidDeaths
Where continent is not null
order by 3,4


------------------------------------------------------------------------------------------------------------------------


-- Standarize Data Format


Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2


ALTER TABLE PortfolioProject..CovidDeaths ALTER COLUMN total_deaths float
ALTER TABLE PortfolioProject..CovidDeaths ALTER COLUMN total_cases float

-------------------------------------------------------------------------------------------------------------------------


-- death rate of united states


Select location, date, total_cases, total_deaths, Round((total_deaths/total_cases)*100,2) as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states'
order by 1,2


-- infection rate of united states


Select location, date, population, total_cases, (total_cases/population)*100 as infectionRate
From PortfolioProject..CovidDeaths
Where location like '%states'
order by 1,2


-- Countries with highest infection rate


Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases)/population)*100 as HighestInfectionRate
From PortfolioProject..CovidDeaths
Group by location, population
order by 4 desc


-- Countries with highest Death count


Select location, max(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
order by 2 desc


-- Continent with highest Death count


Select continent, sum(MaxDeathCount) as TotalDeathCount
From (
	Select continent, max(total_deaths) as MaxDeathCount
	From PortfolioProject..CovidDeaths
	Where continent is not null
	Group by continent, location) m
group by continent
order by 2 desc

Select location, max(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is null
Group by location
order by 2 desc


-------------------------------------------------------------------------------------------------------------------------


---- Global Numbers


-- Death rate per week


Select date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null and new_cases <> 0
Group by date
order by 1,2


-- total vaccinations count by date


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Vaccine percentage by population


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, Round((RollingPeopleVaccinated/Population)*100,3) as Vaccination_Percentage
From PopvsVac


-- Creating a Temp Table, then calculate Vaccination_Percentage


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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *, (RollingPeopleVaccinated/Population)*100 as Vaccination_Percentage
From #PercentPopulationVaccinated


---------------------------------------------------------------------------------------------------------------------------


-- Creating View for tableau


Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 