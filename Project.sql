select *
from Project..coviddeaths
where continent is not null
order by 3,4

--select *
--from Project..covidvaccination
--order by 3,4

select location,date,total_cases_per_million,new_cases,total_deaths,population
from Project..coviddeaths
order by 1,2

select location,date,total_deaths,total_cases_per_million,(total_deaths/total_cases_per_million)*100 as deathper
from Project..coviddeaths
where location like '%states%'
order by 1,2

select location,date,population,total_cases_per_million ,(total_cases_per_million/population)*100 as polulationinfe
from Project..coviddeaths
where location like '%states%'
order by 1,2

select location,population, max(total_cases_per_million) as HighestInfectionCount ,max(total_cases_per_million/population)*100 as percentagepopulation
from Project..coviddeaths
--where location like '%states%'
group by location,population
order by percentagepopulation desc

select continent, max(cast(total_deaths as int)) as Totaldeathcount
from Project..coviddeaths
--where location like '%states%'
where continent is not null
group by continent
order by Totaldeathcount desc

select sum(new_cases) as tota_cases,sum(new_deaths),(sum(cast(new_deaths as int))/sum(new_cases)) * 100 as deathpercentage --,total_deaths,(total_deaths/total_cases_per_million)*100 as deathpercentage
from Project..coviddeaths
--where location like '%states%'
where continent is not null
order by 1,2

--Looking ata total population vs vaccinations
select cd.continent,cd.location,cd.date,population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations))over (partition by cd.location order by cd.location ,cd.date) as rolling_peoplevaccinated
--,(rolling_peoplevaccinated/population)*100 
from Project..coviddeaths cd
join Project..covidvaccination cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null
order by 2,3

--using cte
with popvsvacc (continent,location,date, population,new_vaccinations, rolling_peoplevaccinated)
as
(
select cd.continent,cd.location,cd.date,population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations))over (partition by cd.location order by cd.location ,cd.date) as rolling_peoplevaccinated
--,(rolling_peoplevaccinated/population)*100 
from Project..coviddeaths cd
join Project..covidvaccination cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null
--order by 2,3
)
select *,(rolling_peoplevaccinated/population)*100
from popvsvacc

--temp table
drop table if exists #percentpopulationvacc
create table #percentpopulationvacc
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_peoplevaccinated numeric
)
insert into #percentpopulationvacc
select cd.continent,cd.location,cd.date,population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as rolling_peoplevaccinated
--,(rolling_peoplevaccinated/population)*100 
from Project..coviddeaths cd
join Project..covidvaccination cv
on cd.location=cv.location
and cd.date=cv.date
--where cd.continent is not null
--order by 2,3
select *, (rolling_peoplevaccinated/population)*100
from #percentpopulationvacc


create view percentpopulationvacc as
select cd.continent,cd.location,cd.date,population,cv.new_vaccinations,
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as rolling_peoplevaccinated
--,(rolling_peoplevaccinated/population)*100 
from Project..coviddeaths cd
join Project..covidvaccination cv
on cd.location=cv.location
and cd.date=cv.date
where cd.continent is not null
--order by 2,3

select *
from percentpopulationvacc