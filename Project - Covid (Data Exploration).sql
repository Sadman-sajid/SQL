--looking at the entire table sorted by location and date

select location, date, total_cases, new_cases, total_deaths, population 
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--swapping of total_deaths and total_cases as one or two rows have deaths greater than cases

update PortfolioProject..CovidDeaths set total_deaths=total_cases, 
total_cases=total_deaths where total_deaths>total_cases

--looking at total_deaths vs total_cases
--likelihood of deaths in my country

Select Location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like 'Bangladesh'
and continent is not null
order by 1,2

--looking at total cases vs population
--shows what percent of population is effected by covid


Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--looking at countries with highest infection rate compared to population

Select Location, population, max(total_cases) as highestinfectioncount, max(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by PercentPopulationInfected desc

--death count in a continent

Select continent, max(total_deaths) as totaldeathcount
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by totaldeathcount desc

--death rate(total_deaths vs total_cases) per day

Select date, sum(total_deaths), sum(total_cases), (sum(total_deaths)/sum(total_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

--global death rate (total_deaths vs total_cases)

Select sum(total_deaths), sum(total_cases), (sum(total_deaths)/sum(total_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2

--looking at total people vaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.date)
as PeopleVaccinatedTillDate
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--using CTE and looking at vaccinations vs population 

with popvsvac (continent, location, date, population, new_vaccinations, PeopleVaccinatedTillDate) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.date)
as PeopleVaccinatedTillDate
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select * , (PeopleVaccinatedTillDate/population)*100 from popvsvac

--temp table and looking at vaccinations vs population 

drop table if exists #percentpopulationvaccinated

create table #percentpopulationvaccinated (
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinatedTillDate numeric
)

insert into #percentpopulationvaccinated 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.date)
as PeopleVaccinatedTillDate
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (PeopleVaccinatedTillDate/population)*100 from #percentpopulationvaccinated 

--creating view to store data for future visualization
drop view if exists percentpopulationvaccinated

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.date)
as PeopleVaccinatedTillDate
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * from percentpopulationvaccinated




