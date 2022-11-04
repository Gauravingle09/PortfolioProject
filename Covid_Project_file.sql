
select * from PortfolioProject..coviddeaths where continent is not null order by 3,4
select * from PortfolioProject..covidvaccinations where continent is not null order by 3,4
select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..coviddeaths 
where continent is not null
order by 1,2 


--looking at total cases vs total deaths
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as Percent_Population_infected
from PortfolioProject..coviddeaths 
where location like '%india%' 
where continent is not null
order by 1,2


--{looking at total cases vs population}--{shows what % of population got covid}
select location,date, population, total_cases,(total_cases/population)*100 as Percent_Population_infected
from PortfolioProject..coviddeaths 
where location like '%india%' 
where continent is not null
order by 1,2


--{looking at countries with highest infection rate compared to population}
select location, population, Max(total_cases) as Highest_infection_count, Max((total_cases/population))*100 as Percent_Population_infected
from PortfolioProject..coviddeaths where continent is not null
group by location, population
order by Percent_Population_infected desc


--{showing countries with highest death count per population}
select location,max(cast(total_deaths as int)) as Total_Death_count
from PortfolioProject..coviddeaths 
where continent is not null
group by location
order by Total_Death_count desc


--{breaking down with continents}
--showing continent with highest death count
select continent,max(cast(total_deaths as int)) as Total_Death_count
from PortfolioProject..coviddeaths 
where continent is not null
group by continent
order by Total_Death_count desc 

--{Global Numbers}
select SUM(new_cases) as Total_Cases,SUM(cast(new_deaths as int)) as Total_Deaths,SUM(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from PortfolioProject..coviddeaths 
--where location like '%india%' 
where continent is not null
--group by date
order by 1,2


--{joining tables}
select *
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date

--{total population vs total vaccinations}
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date 
where dea.continent is not null
  order by 2,3


--{Use CTE}

with Population_vs_Vaccination (Continent,Location,Date,Population,New_vaccinations,Rolling_People_Vaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
-- (Rolling_People_Vaccinated/Population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (Rolling_People_Vaccinated/Population)*100
from Population_vs_Vaccination

--{TEMP table}
Drop table if exists #Percent_Population_Vaccinated
Create table #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)


Insert into #Percent_Population_Vaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
-- (Rolling_People_Vaccinated/Population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
   on dea.location=vac.location
   and dea.date=vac.date
--where dea.continent is not null
--order by 2,3
Select *, (Rolling_People_Vaccinated/Population)*100
from #Percent_Population_Vaccinated

--{creating views for visualization}
Create view Percent_Population_Vaccinated as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,dea.date) as Rolling_People_Vaccinated
-- (Rolling_People_Vaccinated/Population)*100
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
   on dea.location=vac.location
   and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select * from Percent_Population_Vaccinated