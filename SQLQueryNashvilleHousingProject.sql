
--- The Nashville Housing Data Cleansing Project

-- Data Cleaning
---------------------------------------------------------

-- Clearing Data in the SQL queries


Select SaleDate, convert(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ALTER COLUMN SaleDate date

--------------------------------------------------------------------------
--- Populate Property Address date : Fill up Property Address with data from duplicate rows 

Select * 
From PortfolioProject.dbo.Nashvillehousing
--where PropertyAddress is null
order by ParcelID

	-- duplicate rows with same data
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.Nashvillehousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	And a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is Null

-----------------------------------------------------------------------------
-- SPLIT: Breaking out address into individual columns(Address, City, State)

Select PropertyAddress 
From PortfolioProject.dbo.Nashvillehousing
--where PropertyAddress is null
--order by ParcelID

--- SPLIT METHOD 1: Split into new columns
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address

--CHARINDEX(',',PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)


Alter Table NashvilleHousing
Add PropertySplitCity NVARCHAR(255)

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select * 
From NashvilleHousing

------------------------------------------------------------------------
-- SPLIT Owner Address into new columns

Select OwnerAddress 
From NashvilleHousing

	-- SPLIT METHOD 2
Select
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity NVARCHAR(255)

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState NVARCHAR(255)

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

--------------------------------------------------------------------------------
-- Original idea: change Y and N to Yes and No in Sold as Vacant
--- Eventually, we changed 0 = No, 1 = Yes

Select SoldAsVacant
From NashvilleHousing

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select Cast(SoldAsVacant as nvarchar(10)),
Case when Cast(SoldAsVacant as nvarchar(10)) = 1 then 'Yes'
	when Cast(SoldAsVacant as nvarchar(10)) = 0 then 'No'
	Else Cast(SoldAsVacant as nvarchar(10))
End
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
ALTER COLUMN SoldAsVacant NVARCHAR(10)

Update NashvilleHousing
SET SoldAsVacant = Case when SoldAsVacant = 1 then 'Yes'
	when SoldAsVacant = 0 then 'No'
	Else SoldAsVacant
End
From PortfolioProject.dbo.NashvilleHousing

Select SoldAsVacant
From NashvilleHousing

---------------------------------------------------------
-- Remove Duplicates

WITH RandomCTE as
(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		ORDER BY
			UNIQUEID
			) row_num
From PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RandomCTE
WHERE row_num>1
--Order by PropertyAddress


--WITH RandomCTE as
--(
--Select *,
--	ROW_NUMBER() OVER(
--	PARTITION BY ParcelID,
--		PropertyAddress,
--		SalePrice,
--		SaleDate,
--		LegalReference
--		ORDER BY
--			UNIQUEID
--			) row_num
--From PortfolioProject.dbo.NashvilleHousing
----ORDER BY ParcelID
--)
--Delete
--FROM RandomCTE
--WHERE row_num>1
----Order by PropertyAddress


-- Delete Unused Columns

Select *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

