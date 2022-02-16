set global local_infile=1;

use portfolioproject;
load data local infile 'C:/Users/user/Desktop/BUSINESS ANALYTICS/PROJECTS/Alex Freeberg/CovidDeaths.csv' into table coviddeaths FIELDS terminated by ',' lines terminated by '\n'
ignore 1 lines;
select * 
from portfolioproject.coviddeaths
where continent is not null;

use portfolioproject;
load data local infile 'C:/Users/user/Desktop/BUSINESS ANALYTICS/PROJECTS/Alex Freeberg/CovidVaccinations.csv' into table covidvaccinations FIELDS terminated by ',' lines terminated by '\n'
ignore 1 lines;
select * from portfolioproject.covidvaccinations;

select location,date,population, total_cases, new_cases, total_deaths
from portfolioproject.coviddeaths
order by location;

# total cases vs total deaths 
select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject.coviddeaths
order by location;

# Death percentage in India - shows the likelihood of dying if one contracts covid 19
select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from portfolioproject.coviddeaths
where location like '%India%'
order by location;

# Total cases vs population in India
select location,date, population, total_cases, (total_cases/population)*100 as PercentCases
from portfolioproject.coviddeaths
where location ='India'
order by location;
# 3 % of population has been infected in India by 11-02-2022

#Countries with Highest Infection Rate with population greater than 5M
# max(total cases) shows the highest number of the infection count for the country
#Group by because we want the max under country count
select location,population, max(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
from portfolioproject.coviddeaths
where population > 5000000
group by population, location
order by location;

#Countries with the highest Death count per population
#Converting the datatype of total deaths from text to int
set sql_mode=' ';
alter table portfolioproject.coviddeaths change column total_deaths total_deaths int;
select continent, Max(total_deaths) as TotalDeathCount
from portfolioproject.coviddeaths
where continent is not null
group by continent
order by TotalDeathCount desc;

# Global numbers - this shows the Death percentage over the world is approx 1.4%
set sql_mode=' ';
alter table portfolioproject.coviddeaths change column new_deaths new_deaths int;
select sum(new_cases), sum(new_deaths), (sum(new_deaths)/sum(new_cases))*100 as NewDeathPercentage
from portfolioproject.coviddeaths
where population > 5000000
order by NewDeathPercentage desc;

#Looking at total population vs total vaccinations
# Vaccinations in India Started in 16-01-2021
select cd.continent,cd.location, cd.date, cd.population, cv.new_vaccinations
from portfolioproject.coviddeaths as cd
join portfolioproject.covidvaccinations cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null and cd.location='India'
order by cd.location;

# using CTE- Number of columns in CTE and columnsin the select statement must be equal
with PopvsVac (Continent, Location, date, population, new_vaccinations,RollingPeopleVaccinated) as 
(
select cd.continent,cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cv.new_vaccinations) 
over (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated 
from portfolioproject.coviddeaths as cd
join portfolioproject.covidvaccinations cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null 
order by cd.location
)
select * , (RollingPeopleVaccinated/population)*100
from PopvsVac;

#Temp Table
drop table if exists PercentPopulationVaccinated;
Create table PercentPopulationVaccinated
(
continent varchar(255),
location varchar(255),
date datetime ,
population int,
new_vaccinations int,
RollingPeopleVaccinated int
);
insert into PercentPopulationVaccinated
select cd.continent,cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cv.new_vaccinations) 
over (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated 
from portfolioproject.coviddeaths as cd
join portfolioproject.covidvaccinations cv
on cd.location=cv.location and cd.date=cv.date
#where cd.continent is not null 
order by cd.location;

select * , (RollingPeopleVaccinated/population)*100
from PercentPopulationVaccinated;

#Creating view to store data for Tableau Visualization
Create View PopulationVaccinated as 
select cd.continent,cd.location, cd.date, cd.population, cv.new_vaccinations, sum(cv.new_vaccinations) 
over (Partition by cd.location order by cd.location, cd.date) as RollingPeopleVaccinated 
from portfolioproject.coviddeaths as cd
join portfolioproject.covidvaccinations cv
on cd.location=cv.location and cd.date=cv.date
where cd.continent is not null 
order by cd.location;

select * from portfolioproject.populationvaccinated order by date, location;


