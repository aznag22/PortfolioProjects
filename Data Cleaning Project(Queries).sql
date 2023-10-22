/*
Cleaning Data in SQL Queries
*/



--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


update Portfolio1.dbo.NashvelleHousing set SaleDate =CONVERT(date,SaleDate)
select SaleDate from Portfolio1..NashvelleHousing


-- If it doesn't Update properly


ALTER TABLE Portfolio1.dbo.NashvelleHousing ADD SaleDateConverted Date

update Portfolio1.dbo.NashvelleHousing set SaleDateConverted =CONVERT(date,SaleDate)

select SaleDateConverted from Portfolio1.dbo.NashvelleHousing

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select nn.ParcelID, nn.PropertyAddress, n.ParcelID, ISNULL(n.PropertyAddress,nn.PropertyAddress) 
from Portfolio1..NashvelleHousing nn JOIN Portfolio1..NashvelleHousing n 
ON nn.ParcelID = n.ParcelID where n.PropertyAddress is null and nn.PropertyAddress is not null


UPDATE n SET n.PropertyAddress =nn.PropertyAddress
from Portfolio1..NashvelleHousing nn JOIN Portfolio1..NashvelleHousing n 
ON nn.ParcelID = n.ParcelID and nn.[UniqueID ] <> n.[UniqueID ] where n.PropertyAddress is null 

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- PROPERTY ADDRESS

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as State
from Portfolio1..NashvelleHousing

-- creating a splited address column called PropertySplitAddress

ALTER TABLE Portfolio1..NashvelleHousing ADD PropertySplitAddress nvarchar(255)

UPDATE Portfolio1..NashvelleHousing SET PropertySplitAddress =SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

-- creating a splited City column called PropertySplitCity

ALTER TABLE Portfolio1..NashvelleHousing ADD PropertySplitCity nvarchar(255)

UPDATE Portfolio1..NashvelleHousing SET PropertySPLITCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

--OWNER ADDRESS

select PARSENAME(REPLACE(OwnerAddress, ',','.'),3),PARSENAME(REPLACE(OwnerAddress, ',','.'),2),PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
from Portfolio1..NashvelleHousing 
--where OwnerAddress is not null

ALTER TABLE Portfolio1..NashvelleHousing ADD OwnerSplitAddress nvarchar(255)

UPDATE  Portfolio1..NashvelleHousing SET OwnerSplitAddress =PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE Portfolio1..NashvelleHousing ADD OwnerSplitCity nvarchar(255)

UPDATE  Portfolio1..NashvelleHousing SET OwnerSplitCity =PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE Portfolio1..NashvelleHousing ADD OwnerSplitState nvarchar(255)

UPDATE  Portfolio1..NashvelleHousing SET OwnerSplitState =PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select SoldAsVacant  ,CASE 
                         WHEN SoldAsVacant ='N' THEN 'No'
                         WHEN SoldAsVacant ='Y' THEN 'Yes'
                         ELSE SoldAsVacant
                         END
from Portfolio1..NashvelleHousing 

UPDATE  Portfolio1..NashvelleHousing 
SET SoldAsVacant  = CASE 
                    WHEN SoldAsVacant ='N' THEN 'No'
                    WHEN SoldAsVacant ='Y' THEN 'Yes'
                    ELSE SoldAsVacant
	    END

select DISTINCT SoldAsVacant, COUNT(SoldAsVacant) as number
from  Portfolio1..NashvelleHousing 
group by SoldAsVacant
order by number desc


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE as (
SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID,LandUse,PropertyAddress, SaleDate, SalePrice 
                            ORDER BY UniqueID) as row_num
FROM Portfolio1..NashvelleHousing
)

SELECT * FROM RowNumCTE WHERE row_num >1



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


ALTER TABLE Portfolio1..NashvelleHousing
DROP COlUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate









