select location,date, total_cases, total_deaths, (CONVERT(float, total_deaths)/NULLIF(CONVERT(float, total_cases),0))*100 as deathPercentage
from Portfolio..CovidDeaths where location ='morocco' order by 1,2

--percentage of population got covid
select location, date, population, total_cases, (total_cases/ population)*100 as effectedPercentage
from Portfolio..CovidDeaths where location ='morocco' order by 1,2

--looking at countries with the heighest infection rate compared to population
select location, population, MAX(total_cases), MAX(total_cases/population) *100 as infectionRate
from Portfolio..CovidDeaths group by location, population order by infectionRate desc

--looking at countries with the highest death percentage compared to population
select location, population, MAX(CONVERT(float, total_deaths)) as TotalDeath, MAX(CONVERT(float, total_deaths)/population)*100 as Death_percentage
from Portfolio..CovidDeaths group by location, population order by Death_percentage desc

--showing countries with the highest death count
select  location, MAX(CONVERT(int,total_deaths)) as TotalDeath 
from Portfolio..CovidDeaths where continent is not null group by location order by TotalDeath desc

-- **********GLOBAL NUMBERS *********

--showing continents with highest death count
select  location, MAX(CONVERT(int,total_deaths)) as TotalDeath 
from Portfolio..CovidDeaths where continent is null and location not in ('World','High income','Upper middle income','Lower middle income','European Union','Low income') 
group by location order by TotalDeath desc

--selecting days with the highest death rate in the world
select date, SUM(CONVERT(float,total_cases)) as TotalCases, SUM(CONVERT(float, total_deaths)) as TotalDeaths,
(SUM(CONVERT(float, total_deaths))/SUM(CONVERT(float,total_cases)))*100 DeathPercentage
from Portfolio..CovidDeaths where continent is not null
group by date order by DeathPercentage desc


--looking at total population vs total vaccinations
with popVSvac (continent, location, date, population, new_vaccinations,RollingPeopleVaccinated) 
as 
(
select cd.continent, cd.location, cd.date, cd.population,vac.new_vaccinations ,
SUM(CONVERT(float,vac.new_vaccinations )) OVER (partition by cd.location order by cd.location, cd.date ) as RollingPeopleVaccinated 
from Portfolio..CovidVaccinations vac Join Portfolio..CovidDeaths cd on vac.location =cd.location and vac.date =cd.date 
where cd.continent is not null 
--order by 2,3 
)
select *,(RollingPeopleVaccinated/population)*100 as percentageVaccinated 
from popVSvac order by percentageVaccinated desc

-- Temp table

Drop Table if exists #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)


Insert into #PercentagePopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population,vac.new_vaccinations ,
SUM(CONVERT(float,vac.new_vaccinations )) OVER (partition by cd.location order by cd.location, cd.date ) as RollingPeopleVaccinated 
from Portfolio..CovidVaccinations vac Join Portfolio..CovidDeaths cd on vac.location =cd.location and vac.date =cd.date 
--where cd.continent is not null 
--order by 2,3 
select *,(Rollingpeoplevaccinated/population)*100 as percentageVaccinated 
from #PercentagePopulationVaccinated

--Creating View
Create View PercentagePopulationVaccinated as 
select cd.continent, cd.location, cd.date, cd.population,vac.new_vaccinations ,
SUM(CONVERT(float,vac.new_vaccinations )) OVER (partition by cd.location order by cd.location, cd.date ) as RollingPeopleVaccinated 
from Portfolio..CovidVaccinations vac Join Portfolio..CovidDeaths cd on vac.location =cd.location and vac.date =cd.date 
where cd.continent is not null 
--order by 2,3 
select * from PercentagePopulationVaccinated