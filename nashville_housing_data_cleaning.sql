/*

Cleaning Data

*/

Select * 
From Portfolio..NashvilleHousing


-- Standardize Date Format
Alter table dbo.NashvilleHousing
Alter column SaleDate Date

/* Populate Property Address data 
		ParcelID is a unique ID for a property. Some rows have the ParcelID but not the property address. 
		We are going to populate the property address based on the Parcel ID from other rows using self-join.
*/

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is NULL


--Breaking out full Addresses into Individual Columns (Street Address, City)
Select 
SUBSTRING(propertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
From Portfolio..NashvilleHousing


-- Create two new columns for the street address and city
Alter table NashvilleHousing
Add propertyStreetAddress nvarchar(255)

Alter table NashvilleHousing
Add propertyCity nvarchar(255)


-- Populate the new columns for propertyAddress
Update NashvilleHousing
SET propertyStreetAddress = SUBSTRING(propertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

Update NashvilleHousing
SET propertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


-- Breaking out Owner Address 

SELECT OwnerAddress
FROM NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From NashvilleHousing


-- Create three new columns for the street address, city and state
ALTER table NashvilleHousing
Add OwnerStreetAddress nvarchar(255)

ALTER table NashvilleHousing
Add OwnerCity nvarchar(255)

ALTER table NashvilleHousing
Add OwnerState nvarchar(255)

-- Populate the new columns
Update NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Update NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Update NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Change Y and N to Yes and No in "Sold as Vacant" field

	-- Using Update and where statements
Update NashvilleHousing
SET SoldAsVacant = 'Yes'
where SoldAsVacant = 'Y'

Update NashvilleHousing
SET SoldAsVacant = 'No'
where SoldAsVacant = 'N'

	-- Using Case statement
Select SoldAsVacant
, Case
	When SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	END
From NashvilleHousing

-- Remove Duplicates

WITH RowNumCTE AS (
Select * ,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  Order By
					UniqueID
					) row_num
From NashvilleHousing
)

DELETE
From RowNumCTE
where row_num > 1

-- Delete PropertyAddress and OwnerAddress Columns (Since we have already split and added them into new columns)

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress










