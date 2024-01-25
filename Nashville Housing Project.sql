/*
 Cleaning data Project */

SELECT *
 FROM PortfolioProject..NashvilleHousing


 -- Standardize Date Format

 SELECT SaleDate, CONVERT(Date, SaleDate)
  FROM PortfolioProject..NashvilleHousing

 UPDATE NashvilleHousing
  SET SaleDate = CONVERT(Date, SaleDate)

 ALTER TABLE NashvilleHousing
  ADD SaleDateConverted Date; 

 UPDATE NashvilleHousing
  SET SaleDateConverted = CONVERT(Date, SaleDate)


-- Populate Porperty Adress

SELECT N.ParcelID, N.PropertyAddress, NH.ParcelID, NH.PropertyAddress,ISNULL(N.PropertyAddress, NH.PropertyAddress) 
--CASE 
 --WHEN N.PropertyAddress is NULL THEN NH.PropertyAddress
 --WHEN N.PropertyAddress IS NOT NULL THEN N.PropertyAddress
 --END as PropertyPopulate
 FROM PortfolioProject..NashvilleHousing N
 JOIN PortfolioProject..NashvilleHousing NH
  ON N.ParcelID = NH.ParcelID
  AND N.[UniqueID ] <> NH.[UniqueID ]
  WHERE N.PropertyAddress IS NULL

UPDATE N
 SET PropertyAddress = ISNULL(N.PropertyAddress, NH.PropertyAddress)
  FROM PortfolioProject..NashvilleHousing N
  JOIN PortfolioProject..NashvilleHousing NH
  ON N.ParcelID = NH.ParcelID
  AND N.[UniqueID ] <> NH.[UniqueID ]
WHERE N.PropertyAddress IS NULL


-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT 
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address2
FROM PortfolioProject..NashvilleHousing



ALTER TABLE NashvilleHousing
  ADD PropertySplitAddress nvarchar(255); 

 UPDATE NashvilleHousing
  SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

  ALTER TABLE NashvilleHousing
  ADD PropertySplitCity nvarchar(255); 

 UPDATE NashvilleHousing
  SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

  SELECT *
   FROM NashvilleHousing


-- Breaking out OwnerAddress into Individual Columns (Address, City, State)

SELECT OwnerAddress
 FROM NashvilleHousing

 SELECT 
 PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)
 ,PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)
 ,PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
 FROM NashvilleHousing

 

 ALTER TABLE NashvilleHousing
  ADD OwnerSplitAddress nvarchar(255); 

 UPDATE NashvilleHousing
  SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

  ALTER TABLE NashvilleHousing
  ADD OwnerSplitCity nvarchar(255); 

 UPDATE NashvilleHousing
  SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

  ALTER TABLE NashvilleHousing
  ADD OwnerSplitState nvarchar(255); 

 UPDATE NashvilleHousing
  SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)

  SELECT * 
   FROM NashvilleHousing


-- Replace Y and N tp Yes and NO in "Sold as Vacant"

SELECT DISTINCT(SoldasVacant), count(SoldasVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 DESC

SELECT SoldAsVacant,
CASE 
  WHEN SoldAsVacant = 'Y' THEN 'Yes'
  WHEN SoldAsVacant = 'N' THEN 'No'
  ELSE SoldAsVacant
END
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE 
  WHEN SoldAsVacant = 'Y' THEN 'Yes'
  WHEN SoldAsVacant = 'N' THEN 'No'
  ELSE SoldAsVacant
END
FROM NashvilleHousing


-- Remove duplicates

WITH RowNumCTE as
(
SELECT *, 
 ROW_NUMBER() OVER ( PARTITION BY ParcelID,
                                  PropertyAddress,
								  SalePrice,
								  SaleDate,
								  LegalReference
								  ORDER BY 
								    UniqueID
									) row_num
 FROM NashvilleHousing
 )
 DELETE
  FROM RowNumCTE
  WHERE row_num > 1
 

 -- DELETE UNUSED Columns

 SELECT *
  FROM PortfolioProject..NashvilleHousing

  ALTER TABLE PortfolioProject..NashvilleHousing
  DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

  ALTER TABLE PortfolioProject..NashvilleHousing
  DROP COLUMN SaleDate