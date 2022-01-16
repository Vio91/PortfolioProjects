/*

Cleaning data in SQL queries


*/

Select * 
From Portfolio_Project.dbo.NashvilleHousing
---------------------------------------------

--Standardize Date format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From Portfolio_Project.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

Alter Table NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)

---------------------------------------------------
--Populate Property Address Data

Select *
From Portfolio_Project.dbo.NashvilleHousing
--Where PropertyAddress is null
Order By ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio_Project.dbo.NashvilleHousing a
Join Portfolio_Project.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
And a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

Update a 
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio_Project.dbo.NashvilleHousing a
Join Portfolio_Project.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
And a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking out address into individual columns(address, city, state)

Select *
From Portfolio_Project.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order By ParcelID

Select
Substring(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as Address
, Substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
From Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))







SELECT OwnerAddress
FROM Portfolio_Project.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM Portfolio_Project.dbo.NashvilleHousing



ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)


ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)



--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct (SoldAsVacant), Count(SoldAsVacant)
From Portfolio_Project.dbo.NashvilleHousing
Group By (SoldAsVacant)
Order By 2

SELECT SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM Portfolio_Project.dbo.NashvilleHousing

UPDATE Portfolio_Project.dbo.NashvilleHousing
SET SoldAsVacant = CASE 
When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END




--Remove Duplicates
WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY 
			   UniqueID ) row_num

FROM Portfolio_Project.dbo.NashvilleHousing
--Order By ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1 
Order By PropertyAddress


-----------------------------------------------------------------

--Delete unused columns

Select * 
From Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
DROP COLUMN SaleDate
