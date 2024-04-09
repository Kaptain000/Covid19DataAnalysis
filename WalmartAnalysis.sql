Select *
From WalmartStoreLocation..PopulationDistribution
Order by State, City

---------------------------------------------------------------------------------------------------------------


--- creating pivot table without PIVOT fuction


Drop Table if exists #RaceDistribution
Create Table #RaceDistribution
(
StateCode nvarchar(255),
State nvarchar(255),
City nvarchar(255),
MedianAge numeric,
MalePopulation numeric,
FemalePopulation numeric,
TotalPopulation numeric,
NumberofVeterans numeric,
ForeignBorn numeric,
AverageHouseholdSize numeric,
AmericanIndianAndAlaskaNative numeric,
Asian numeric,
BlackOrAfricanAmerican numeric,
HispanicOrLatino numeric,
White numeric,
)


Insert into #RaceDistribution
Select 	Max("State Code"),
		State, 
		City, 
		Max("Median Age"),
		Max("Male Population"),
		Max("Female Population"),
		Max("Total Population"),
		Max("Number of Veterans"),
		Max("Foreign-born"),
		Max("Average Household Size"),
		Max(Case when Race='American Indian and Alaska Native' then Count else 0 end),
		Max(Case when Race='Asian' then Count else 0 end),
		Max(Case when Race='Black or African-American' then Count else 0 end),
		Max(Case when Race='Hispanic or Latino' then Count else 0 end),
		Max(Case when Race='White' then Count else 0 end)
From WalmartStoreLocation..PopulationDistribution
Group by State, City


Select *
From #RaceDistribution
Order by State, City


--- creating pivot table with PIVOT fuction


Select *
FROM WalmartStoreLocation..PopulationDistribution as SourceTable  
PIVOT (
  SUM([Count])
  FOR Race
  IN (
    [American Indian and Alaska Native],[Asian],[Black or African-American],[Hispanic or Latino],[White]
  )
) AS Pivot_SalesRegionMonth
Order by State, City


------------------------------------------------------------------------------------------------------------


-- Ceating view for Tableau


Create view RaceDistribution as
Select *
FROM WalmartStoreLocation..PopulationDistribution as SourceTable  
PIVOT (
  SUM([Count])
  FOR Race
  IN (
    [American Indian and Alaska Native],[Asian],[Black or African-American],[Hispanic or Latino],[White]
  )
) AS Pivot_SalesRegionMonth


Select *
From RaceDistribution
Order by State, City


-----------------------------------Walmart Analysis----------------------------------------


Select *
From WalmartStoreLocation..WalmartDistribution
Where [Avg# Walmart Wage] is null


Update WalmartDistribution
Set [Avg# Walmart Wage] = (
	Select Round(Avg([Avg# Walmart Wage]),2)
	From WalmartStoreLocation..WalmartDistribution
	Where [Avg# Walmart Wage] is not null)
Where [Avg# Walmart Wage] is null


Update WalmartDistribution
Set State = Case when State='DC' then 'Washington' else State end


Update WalmartDistribution
Set State = Case when State like '%Virginia' then 'Virginia' else State end


Select cast(Population/[Quantity of Walmarts] as int) as PopulationPerWalmart 
From WalmartStoreLocation..WalmartDistribution


ALTER TABLE WalmartDistribution
Add WalmartPer10000People Float


Update WalmartDistribution
Set WalmartPer10000People = Round([Quantity of Walmarts]*10000/Population, 3)
From WalmartStoreLocation..WalmartDistribution


Select *
From WalmartStoreLocation..WalmartDistribution


ALTER TABLE WalmartDistribution
Add SmallBusinessPerWalmart Numeric


Update WalmartDistribution
Set SmallBusinessPerWalmart = [# of SMALL BUSINESSES]/[Quantity of Walmarts]
From WalmartStoreLocation..WalmartDistribution


Select *
From WalmartStoreLocation..WalmartDistribution


ALTER TABLE WalmartDistribution
Add PopulationPerSmallBusiness Numeric


Update WalmartDistribution
Set PopulationPerSmallBusiness = Population/[# of SMALL BUSINESSES]
From WalmartStoreLocation..WalmartDistribution


Select *
From WalmartStoreLocation..WalmartDistribution
where * is null


ALTER TABLE WalmartDistribution
Add EmployeesPerWalmart Numeric


Update WalmartDistribution
Set EmployeesPerWalmart = [# of Walmart Employees]/[Quantity of Walmarts]
From WalmartStoreLocation..WalmartDistribution


--------------------------------combine table and create view for tableau---------------------------------------


Create view WalmartVsLocationAndPopulation as
Select w.*, r.AverageHouseholdSize, r.AmericanIndianAndAlaskaNative, r.Asian, r.BlackOrAfricanAmerican, r.HispanicOrLatino, r.White
From WalmartStoreLocation..WalmartDistribution w
left join (Select State,
				Avg([Average Household Size]) as AverageHouseholdSize, 
				Sum([American Indian and Alaska Native]) as AmericanIndianAndAlaskaNative,
				Sum([Asian]) as Asian,
				Sum([Black or African-American]) as BlackOrAfricanAmerican,
				Sum([Hispanic or Latino]) as HispanicOrLatino,
				Sum([White]) as White
			From RaceDistribution
			Group by State) r
on w.State = r.State





