-- Selecting all data from CovidDeaths$ table
select * from CovidDeaths$
order by 3, 4;


-- Selecting all data from CovidVaccinations$ table
select * from CovidVaccinations$
order by 3, 4;


-- Selecting data that we are going to be using
select 
location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
order by 1, 2;


--                                Looking at total_cases vs total_deaths
-- Shows likelihood of dying in Uzbekistan
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100, 2) as persentage_deaths 
from CovidDeaths$
where location like 'uzbekistan'
order by 1,2;


--                                Looking at total_cases vs population 
-- Shows how many persentage of population got COVID-19 in uzbekistan
select location, date, total_cases, population, round((total_cases/population)*100, 2) as persentage_population 
from CovidDeaths$
where location like 'uzbekistan'
order by 1,2;


-- Looking at Countries with highest infection rate compared to population
select location, population, max(total_cases) as highest_infection, max(round((total_cases/population)*100, 2)) as persentage_population 
from CovidDeaths$
group by location, population
order by persentage_population desc;


--                    Showing countries with highest death count per population
-- Showing all countries from highest death count per population to lowest
select location, max(cast(total_deaths as int)) as total_deaths_count
from CovidDeaths$
where continent is not null
group by location
order by total_deaths_count desc;


-- Showing death counts with group by continents
select continent, max(cast(total_deaths as int)) as total_deaths_count
from CovidDeaths$
where continent is not null
group by continent
order by total_deaths_count desc;


-- Showing global number of deaths count grouping by time
select date, sum(cast(total_deaths as int)) as total_deaths_count from CovidDeaths$
group by date
order by date desc;


-- Looking at total population vs vacinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location) as total_vacination_per_locations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_vacination_with_rolling_vaccinations
from Covid_analysis_project..CovidDeaths$ as dea
join Covid_analysis_project..CovidVaccinations$ as vac
on vac.location=dea.location and dea.date=vac.date
where (dea.continent is not null) and (vac.new_vaccinations is not null)
order by 2, 3;


-- Creating table to store vaccinations of populations
create table PercentPopulationVaccinated
(
Continent nvarchar(266),
Location nvarchar(266),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalOfNewVaccinations numeric,
RollingPeopleVaccinated numeric
);

 
 -- Inserting data into percentPopulationVaccinated table
 insert into PercentPopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location) as total_vacination_per_locations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_vacination_with_rolling_vaccinations
from Covid_analysis_project..CovidDeaths$ as dea
join Covid_analysis_project..CovidVaccinations$ as vac
on vac.location=dea.location and dea.date=vac.date
where (dea.continent is not null) and (vac.new_vaccinations is not null);


-- Getting all data from created table
select * from PercentPopulationVaccinated;


-- Creating view to store data for later
create view PercentagePopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location) as total_vacination_per_locations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as total_vacination_with_rolling_vaccinations
from Covid_analysis_project..CovidDeaths$ as dea
join Covid_analysis_project..CovidVaccinations$ as vac
on vac.location=dea.location and dea.date=vac.date
where (dea.continent is not null) and (vac.new_vaccinations is not null);


-- Getting data from created view table
select * from PercentagePopulationVaccinated;

