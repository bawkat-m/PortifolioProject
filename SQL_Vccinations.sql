
--select * from [dbo].[CovidVaccsenations]
--order by 3,4

--select * from [dbo].[CovidDeaths]
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
from [dbo].[CovidDeaths] 
order by 1,2

--looking at total cases vs total deaths
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_pct
from [dbo].[CovidDeaths] 
where location like '%Israel%'
order by 1,2

--Looking at total cases vs population
select location,date,population,total_cases, (total_cases/population)*100 as cases_pct
from [dbo].[CovidDeaths] 
--where location like '%Israel%'
order by 1,2

--the cuntry with hieghst rate of total cases
select location,population,max(total_cases) max_cases, max((total_cases/population))*100 as Infected_Rate_Pop
from [dbo].[CovidDeaths] 
--where location like '%Israel%'
group by location,population
order by Infected_Rate_Pop desc


--the cuntry with hieghst rate of death count for pop
select location,population,max(cast(total_deaths as int)) total_deaths_count
from [dbo].[CovidDeaths] 
--where location like '%Israel%'
where continent is null
group by location,population
order by total_deaths_count desc



-- by continent
select location,max(cast(total_deaths as int)) total_deaths_count
from [dbo].[CovidDeaths]
where  continent is null
group by location
order by total_deaths_count desc


-- global numbers
select sum(new_cases)as total_cases,sum(cast(new_deaths as int)) as total_death,
sum(cast(new_deaths as int))/sum(new_cases)*100 as death_pct
from [dbo].[CovidDeaths] 
--where location like '%Israel%'
--group by date
order by 1,2


--looking at total Population vs vaccinations
select 
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations
from [dbo].[CovidDeaths] dea
join [dbo].[CovidVaccsenations] vac
	on dea.date = vac.date
	and dea.location = vac.location
where dea.continent is not null
order by 2,3


-- Vaccinations peer day
select 
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over
(partition by dea.location order by dea.location,dea.date) as sum_comulative_vac
from [dbo].[CovidDeaths] dea
join [dbo].[CovidVaccsenations] vac
	on dea.date = vac.date
	and dea.location = vac.location
where dea.continent is not null
order by 2,3

-- Use CTE
with Pop_VS_Vac(continent,location,date,population,new_vaccinations,sum_comulative_vac)
as
(
select 
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over
(partition by dea.location order by dea.location,dea.date) as sum_comulative_vac
from [dbo].[CovidDeaths] dea
join [dbo].[CovidVaccsenations] vac
	on dea.date = vac.date
	and dea.location = vac.location
where dea.continent is not null)
--order by 2,3)

select *, (sum_comulative_vac/Population)*100   from Pop_VS_Vac

--View
create view Pop_Vaccinations
as
(
select 
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over
(partition by dea.location order by dea.location,dea.date) as sum_comulative_vac
from [dbo].[CovidDeaths] dea
join [dbo].[CovidVaccsenations] vac
	on dea.date = vac.date
	and dea.location = vac.location
where dea.continent is not null)

select * from Pop_Vaccinations
