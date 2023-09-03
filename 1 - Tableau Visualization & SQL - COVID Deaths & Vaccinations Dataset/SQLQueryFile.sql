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
Where location like '%States%' --imp
Group by location, population --imp
order by 1,2




