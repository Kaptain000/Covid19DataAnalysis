select *
from PopulationAnalysis..populationDistribution

select *
from PopulationAnalysis..uscities


----------------------------------------------------------------------------------------------------------------------


-- creating pivot table for table populationDistribution


Select *
FROM PopulationAnalysis..PopulationDistribution as SourceTable  
PIVOT (
  SUM([Count])
  FOR Race
  IN (
    [American Indian and Alaska Native],[Asian],[Black or African-American],[Hispanic or Latino],[White]
  )
) AS Pivot_SalesRegionMonth
Order by State, City


-- use City to join pivot table and uscities together


Drop Table if exists Combined
Create Table Combined
(
state_id nvarchar(255),
state nvarchar(255),
city nvarchar(255),
lat Float,
lng Float,
timezone nvarchar(255),
medianAge Float,
malePopulation numeric,
femalePopulation numeric,
totalPopulation numeric,
veteranPopulation numeric,
foreignBornPopulation numeric,
Native_American numeric,
Asian numeric,
African_American numeric,
Hispanic_Lantio numeric,
White numeric,
averageHouseHoldSize Float,
)

Insert into Combined
Select u.state_id,u.state_name,u.city, lat, lng, timezone, p.[Median Age], p.[Male Population], p.[Female Population], p.[Total Population], p.[Number of Veterans],p.[Foreign-born], p.[American Indian and Alaska Native], p.Asian,p.[Black or African-American], p.[Hispanic or Latino],p.White, p.[Average Household Size]
from PopulationAnalysis..uscities u
join (Select *
	FROM PopulationAnalysis..PopulationDistribution as SourceTable  
	PIVOT (
	  SUM([Count])
	  FOR Race
	  IN (
		[American Indian and Alaska Native],[Asian],[Black or African-American],[Hispanic or Latino],[White]
	  )
	) AS Pivot_SalesRegionMonth) p
on u.City=p.City


Create View USAStatePopulation as
Select state_id, state, max(timezone) as timezone, Round(Avg(medianAge),2) as medianAge, 
	Sum(malePopulation) as malePopulation, Sum(femalePopulation) as femalePopulation, 
	Sum(totalPopulation) as totalPopulation, Sum(veteranPopulation) as veteranPopulation, 
	Sum(foreignBornPopulation) as foreignBornPopulation, Sum(Native_American) as Native_American, 
	Sum(African_American) as African_American, Sum(Hispanic_Lantio) as Hispanic_Lantio, Sum(White) as White, 
	Round(Avg(averageHouseHoldSize),2) as averageHouseHoldSize
From Combined
Group by state_id, state
