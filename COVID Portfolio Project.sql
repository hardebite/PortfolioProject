select * from PortfolioProject..CovidDeaths
where continent IS NOT NULL
order by 3,4
SELECT * FROM PortfolioProject..coviddeaths
order by 3,4;
--SELECT * FROM PortfolioProject..covidvaccinations
--order by 3,4;
SELECT location ,date,total_cases,new_cases,total_deaths,population 
FROM PortfolioProject..coviddeaths
order by 1,2;

--looking at total cases vs total deaths


--shows the likelyhood of dying from covid
SELECT location ,date,total_cases,total_deaths,(total_deaths/total_cases)* 100 as DeathPercentage
FROM PortfolioProject..coviddeaths
where location like'nigeria'
order by 1,2;

--looking at the total cases vs the Population

--infection rate to show what percentage of population got covid

SELECT location ,date,total_cases,Population,(total_cases/population)* 100 as infectionRate
FROM PortfolioProject..coviddeaths
where location like  'nigeria'
order by 1,2;

--to check for  countries with the highest infection rate
Select location,population ,max(total_cases) as HighestInfectionCount,max((total_cases/population))* 100 as PopulationInfected
FROM PortfolioProject..coviddeaths
Group by location,population
order by PopulationInfected desc; 

--showing countries with the highest deathrate per population

Select location ,max(cast(total_deaths as bigint)) as total_death ,max((total_deaths/population))* 100 as DeathRate
FROM PortfolioProject..coviddeaths
WHERE CONTINENT IS NOT NULL
Group by location
order by total_death desc; 


--Lets break this down by continent

--SHOWING THE CONTINENT WITH THE HIGHEST INFECTION RATE
SELECT continent ,cast(total_cases as bigint) ,(total_cases/population)* 100 as infectionRate
FROM PortfolioProject..coviddeaths
where continent is not null
order by  infectionRate desc;

----to check for  countries with the highest infection rate
Select continent ,max(total_cases ) as HighestInfectionCount,max((total_cases/population))* 100 as PopulationInfected
FROM PortfolioProject..coviddeaths
where continent is not null
Group by continent
order by PopulationInfected desc; 

--Showing continents with the highest death rate per population
Select CONTINENT ,max(cast(total_deaths as bigint)) as total_death ,max((total_deaths/population))* 100 as DeathRate
FROM PortfolioProject..coviddeaths
WHERE CONTINENT IS not NULL
Group by CONTINENT
order by total_death desc; 

--GLOBAL NUMBERS
SELECT  date, sum(new_cases) as Total_cases,sum(cast(new_deaths as bigint )) as Total_deaths,sum(cast(new_deaths as int ))/sum(new_cases) *100 as Deathpercentage
from PortfolioProject..CovidDeaths
--where location like'nigeria'
where continent is not null
group by date
order by 1,2;

SELECT  sum(new_cases) as Total_cases,sum(cast(new_deaths as bigint )) as Total_deaths,sum(cast(new_deaths as int ))/sum(new_cases) *100 as Deathpercentage
from PortfolioProject..CovidDeaths
--where location like'nigeria'
where continent is not null
--group by date
order by 1,2;

--Looking at total population vs vaccinations 

select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations )) over (partition by dea.location order by 
dea.location,dea.date ) as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccination	vac
	 on dea.location=vac.location
	 and dea.date=vac.date
	 where dea.continent is not null
	 order by 2,3;

	 --USE CTE
	 with popvsvac (Continent,location,Date,population,new_vaccinations, RollingPeopleVaccinated)
	 as
(
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations )) over (partition by dea.location order by 
dea.location,dea.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccination	vac
	 on dea.location=vac.location
	 and dea.date=vac.date
	 where dea.continent is not null
	 --order by 2,3;
)
select *, (RollingPeopleVaccinated/population)*100 as percentagevaccinated
from popvsvac




--TEMP TABLE
drop table if exists  PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into  #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations )) over (partition by dea.location order by 
dea.location,dea.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccination	vac
	 on dea.location=vac.location
	 and dea.date=vac.date
	 --where dea.continent is not null
	 --order by 2,3;
 
select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later visualization
create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations )) over (partition by dea.location order by 
dea.location,dea.date ) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccination	vac
	 on dea.location=vac.location
	 and dea.date=vac.date
	 where dea.continent is not null
	 --order by 2,3;


	  select * 
	 from   PercentPopulationVaccinated