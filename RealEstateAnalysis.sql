
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
From RealEstate
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From RealEstate a
JOIN RealEstate b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From RealEstate a
JOIN RealEstate b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------


-- Extract Address, City, State From PropertyAddress


Select PropertyAddress
From RealEstate


-- CHARINDEX(',', PropertyAddress) could find the index of the char value


SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
	, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From RealEstate


ALTER TABLE RealEstate
Add PropertySplitAddress Nvarchar(255);

Update RealEstate
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE RealEstate
Add PropertySplitCity Nvarchar(255);

Update RealEstate
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From RealEstate


ALTER TABLE RealEstate
DROP COLUMN PropertyAddress


Select OwnerAddress
From RealEstate


-- PARSENAME(columnName, index) could split string by '.'


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From RealEstate


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
From RealEstate

ALTER TABLE RealEstate
DROP COLUMN OwnerAddress


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From RealEstate
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From RealEstate


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
						 PropertySplitAddress,
						 PropertySplitCity,
						 SalePrice,
						 SaleDateConverted,
						 LegalReference
						ORDER BY UniqueID
						) row_num

From RealEstate
)
Select *
From RowNumCTE
Where row_num = 1
Order by PropertySplitCity, PropertySplitAddress


Create View FormatedRealEstate as
Select *
From (
	Select *,
		ROW_NUMBER() OVER (PARTITION BY ParcelID,
							 PropertySplitAddress,
							 PropertySplitCity,
							 SalePrice,
							 SaleDateConverted,
							 LegalReference
							ORDER BY UniqueID
							) row_num

	From RealEstate) b
Where row_num = 1

---------------------------------------------------------------------------------------------------------


-- Delete Unused Columns


Select *
From RealEstate


ALTER TABLE RealEstateAnalysis..RealEstate
DROP COLUMN TaxDistrict