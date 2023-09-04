Select *  --imp
From [Covid deaths and vaccinations]..CovidDeaths
order by 3,4

--Select *
--From [Covid deaths and vaccinations]..CovidVaccinations
--order by 3,4

-- selecting the desired Data for visualization with Tableau
select location, date,total_cases, new_cases, total_deaths, population
From [Covid deaths and vaccinations]..CovidDeaths
order by 1,2


-- checking how many of cases led to deaths
select location, date,total_cases, total_deaths
From [Covid deaths and vaccinations]..CovidDeaths
order by 1,2

select location, date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Covid deaths and vaccinations]..CovidDeaths
order by 1,2

--need to change the data type
Select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage  --imp
From [Covid deaths and vaccinations]..CovidDeaths
order by 1,2

--checking the same percentage for united states
--we can see the likelihood of dying if you contract covid in the USA
Select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage  
From [Covid deaths and vaccinations]..CovidDeaths
Where location like '%States%' --imp
order by 1,2

--now checking what percentage of the population have gotten COVID in the USA
Select location, date, Population, total_cases, (CONVERT(float, total_cases) / NULLIF(CONVERT(float,population), 0))*100 as InfectedPercentage  
From [Covid deaths and vaccinations]..CovidDeaths
Where location like '%States%' --imp
order by 1,2
--results shows as of Aug 30th 2023 around 30% of the population were infected by COVID

--Now we can check what country has the highest infection rate compared to the population
Select location, Population, MAX(CONVERT(float, total_cases)) as HighestInfectionCount, (MAX(CONVERT(float, total_cases)) / NULLIF(CONVERT(float,population), 0))*100 as InfectedPercentage  --imp
From [Covid deaths and vaccinations]..CovidDeaths
--Where location like '%States%' --imp
Group by location, population --imp
order by InfectedPercentage desc
--results shows that Cyprus (73% so far) and San Marino have the highest percentage of infection, Austria 4th, South Korea 5th (66% so far)


--now we're intersted to spot the contries with the highest total deaths per population
Select location , Max(cast(total_deaths as int)) as TotalDeathCount
From [Covid deaths and vaccinations]..CovidDeaths
--Where location like '%States%' --imp
Group by location 
order by TotalDeathCount desc
--we see locations like world, Asia, Europe which are continents and need to be removed
--by checking the data whenever location has a continent name in it, the continent column is null
Select * 
From [Covid deaths and vaccinations]..CovidDeaths
Where continent is not null
order by 3,4

--now I update the above query to find the highest total deaths per population
Select location , Max(cast(total_deaths as int)) as TotalDeathCount
From [Covid deaths and vaccinations]..CovidDeaths
Where continent is not null
Group by location 
order by TotalDeathCount desc
--the results shows that USA with 1127152 total deaths has the highest numbers!

--now the same data per continent
Select continent , Max(cast(total_deaths as int)) as TotalDeathCount
From [Covid deaths and vaccinations]..CovidDeaths
Where continent is not null
Group by continent 
order by TotalDeathCount desc
--results show North America with 1127152 is the highest then South America with 704659 TotalDeath Counts!


--Let's check Global numbers
--here we see by each day how total cases (SUM(new_cases)), total deaths (SUM(cast(new_deaths as int))) and are increasing globally! 
Select date, SUM(new_cases) as TatalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int)) / NULLIF(SUM(new_cases),0)*100 as DeathPercentage  
From [Covid deaths and vaccinations]..CovidDeaths
--Where location like '%States%' --imp
Where continent is not null
Group by date
order by 1,2

--by removing the date, we can see the overal numbers across the world
Select SUM(new_cases) as TatalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int)) / NULLIF(SUM(new_cases),0)*100 as DeathPercentage  
From [Covid deaths and vaccinations]..CovidDeaths
--Where location like '%States%' --imp
Where continent is not null
--Group by date
order by 1,2
-- result shows TatalCases 770166399, TotalDeaths 6962719, DeathPercentage 0.904053852393527

--2nd Stage: working on CovidVaccination table
--here I join two tables on data and location
Select *
From [Covid deaths and vaccinations]..CovidDeaths death
join [Covid deaths and vaccinations]..CovidVaccinations vac
    On death.location=vac.location
	and death.date= vac.date

--total vaccinations in the world
Select death.continent,death.location,death.date,death.population, vac.new_vaccinations
From [Covid deaths and vaccinations]..CovidDeaths death
join [Covid deaths and vaccinations]..CovidVaccinations vac
    On death.location=vac.location
	and death.date= vac.date
where death.continent is not null
order by 2,3 --so that location starts with Afghanistan

--now I want to find the total vaccinations (sum(vac.new_vaccinations)) per country (reset when country name is changed using partition by) over this joined tables
Select death.continent,death.location,death.date,death.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by death.location) as TotalVaccinationsPerCountry
From [Covid deaths and vaccinations]..CovidDeaths death
join [Covid deaths and vaccinations]..CovidVaccinations vac
    On death.location=vac.location
	and death.date= vac.date
where death.continent is not null
order by 2,3

--now I would like to see the total vaccinations in a cumulative way, so partition by should be ordered by date so we can see how total number increases day by day
Select death.continent,death.location,death.date,death.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by death.location order by death.date) as CumulativeTotalVaccinationsPerCountry
From [Covid deaths and vaccinations]..CovidDeaths death
join [Covid deaths and vaccinations]..CovidVaccinations vac
    On death.location=vac.location
	and death.date= vac.date
where death.continent is not null
order by 2,3

--USING CTE
--now I make CumulativeTotalVaccinations name acceptable to be used in the select command using CTE
With PopvsVac (Continent,Location,Date,Population,New_Vaccinations,CumulativeTotalVaccinations)
as
(
Select death.continent,death.location,death.date,death.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by death.location order by death.location, death.date) as CumulativeTotalVaccinations
From [Covid deaths and vaccinations]..CovidDeaths death
join [Covid deaths and vaccinations]..CovidVaccinations vac
    On death.location=vac.location
	and death.date= vac.date
where death.continent is not null
--order by 2,3
)
Select *, (CumulativeTotalVaccinations/Population)*100 as CumulativeTotalVaccinationsPercentage
From PopvsVac


--TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated --in case of changing the query the new temp table overwrites the previous one
Create Table #PercentPopulationVaccinated
(
--specifying the data type
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
CumulativeTotalVaccinations numeric,
)
insert into #PercentPopulationVaccinated
Select death.continent,death.location,death.date,death.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by death.location order by death.location, death.date) as CumulativeTotalVaccinations
From [Covid deaths and vaccinations]..CovidDeaths death
join [Covid deaths and vaccinations]..CovidVaccinations vac
    On death.location=vac.location
	and death.date= vac.date
where death.continent is not null
--order by 2,3
Select *, (CumulativeTotalVaccinations/Population)*100 as CumulativeTotalVaccinationsPercentage
From #PercentPopulationVaccinated