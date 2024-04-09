
-- Data Clean


Select *
From RealEstateAnalysis..RealEstate


------------------------------------------------------------------------------------------------------------------


-- Standarize Data Format


Select saleDate, CONVERT(Date,SaleDate)
From RealEstateAnalysis..RealEstate

ALTER TABLE RealEstate
Add SaleDateConverted Date

Update RealEstate
SET SaleDateConverted = CONVERT(Date,SaleDate)

ALTER TABLE RealEstate
Drop Column saleDate


 --------------------------------------------------------------------------------------------------------------------------


-- Populate Property Address data


Select *
From RealEstateAnalysis.dbo.RealEstate
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From RealEstateAnalysis.dbo.RealEstate a
JOIN RealEstateAnalysis.dbo.RealEstate b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From RealEstateAnalysis.dbo.RealEstate a
JOIN RealEstateAnalysis.dbo.RealEstate b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------


-- Extract Address, City, State From PropertyAddress


Select PropertyAddress
From RealEstateAnalysis.dbo.RealEstate


-- CHARINDEX(',', PropertyAddress) could find the index of the char value


SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
	, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From RealEstateAnalysis.dbo.RealEstate


ALTER TABLE RealEstate
Add PropertySplitAddress Nvarchar(255);

Update RealEstate
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE RealEstate
Add PropertySplitCity Nvarchar(255);

Update RealEstate
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From RealEstateAnalysis.dbo.RealEstate



Select OwnerAddress
From RealEstateAnalysis.dbo.RealEstate


-- PARSENAME(columnName, index) could split string by '.'


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From RealEstateAnalysis.dbo.RealEstate


ALTER TABLE RealEstate
Add OwnerSplitAddress Nvarchar(255);

Update RealEstate
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE RealEstate
Add OwnerSplitCity Nvarchar(255);

Update RealEstate
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE RealEstate
Add OwnerSplitState Nvarchar(255);

Update RealEstate
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

Select *
From RealEstateAnalysis.dbo.RealEstate


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From RealEstateAnalysis.dbo.RealEstate
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From RealEstateAnalysis.dbo.RealEstate


Update RealEstate
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-----------------------------------------------------------------------------------------------------------------------------------------------------------


-- Remove Duplicates

-- uee ROW_NUMBER to mark the unique or first duplicated row as 1, the second duplicated row will be 2, and so on
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (PARTITION BY ParcelID,
						 PropertyAddress,
						 SalePrice,
						 SaleDateConverted,
						 LegalReference
						ORDER BY UniqueID
						) row_num

From RealEstateAnalysis..RealEstate
)
Select *
From RowNumCTE
Where row_num = 1
Order by PropertyAddress


---------------------------------------------------------------------------------------------------------


-- Delete Unused Columns


Select *
From RealEstateAnalysis.dbo.RealEstate


ALTER TABLE RealEstateAnalysis..RealEstate
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress