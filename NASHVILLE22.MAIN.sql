/****** Nashville Housing Data Cleaning Using SQL  ******/

  SELECT *
  FROM CALC.dbo.NashvilleHousingData



/*Standerdised Date format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM [Portfolio_SQL-Project].[dbo].[Nashville-Housing]


ALTER TABLE Nashville-Housing
ADD SaleDateConverted Date;

UPDATE Nashville-Housing
SET SaleDateConverted =  CONVERT(Date, SaleDate)
*/

--- Populate Property address Data
--- Let take a look at the column

SELECT PropertyAddress
FROM CALC.dbo.NashvilleHousingData

--- Let check for null value

SELECT PropertyAddress
 FROM CALC.dbo.NashvilleHousingData
WHERE PropertyAddress is null

SELECT *
FROM CALC.dbo.NashvilleHousingData
WHERE PropertyAddress is null

SELECT *
FROM CALC.dbo.NashvilleHousingData
ORDER BY ParcelID
 
--- From the query above we notice that the PercelID correspond with the PropertyAddress so we can use it to replace it.
--- To Populate PercelID to PropertyAddress we need to do a selfjoin i.e joining a table to itself.

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM CALC.dbo.NashvilleHousingData a
JOIN CALC.dbo.NashvilleHousingData b
ON a.ParcelID = b. ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

--- Now let populate the propertyAddree to replace the null value

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM CALC.dbo.NashvilleHousingData a
JOIN CALC.dbo.NashvilleHousingData b
ON a.ParcelID = b. ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null


--- Let update the table

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM CALC.dbo.NashvilleHousingData a
JOIN CALC.dbo.NashvilleHousingData b
ON a.ParcelID = b. ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is null

--- Breaking out address or delimeter into individual column, (Address, City)

SELECT PropertyAddress
FROM CALC.dbo.NashvilleHousingData

--- Let separate the delimiters
--- We are going to use CHARINDEX to look for specific value, for this is the comma which is the separator.

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM CALC.dbo.NashvilleHousingData

SELECT PropertyAddress
FROM CALC.dbo.NashvilleHousingData

--- To seperate two value from one column we have to create two other column

ALTER TABLE NashvilleHousingData
ADD PropertySplitAddress nvarchar(100);

UPDATE NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousingData
ADD PropertySplitCity nvarchar(100);

UPDATE NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM CALC.dbo.NashvilleHousingData


--- Let do the same separation for the OwnerAddress

SELECT OwnerAddress
FROM CALC.dbo.NashvilleHousingData

--- Let split the Address, City and State using PARSENAME function

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM CALC.dbo.NashvilleHousingData

--- Let add this separated column to our table


ALTER TABLE NashvilleHousingData
ADD OwnerSplitAddress nvarchar(100);

UPDATE NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousingData
ADD OwnerSplitCity nvarchar(100);

UPDATE NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousingData
ADD OwnerSplitState nvarchar(100)

UPDATE NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM CALC.dbo.NashvilleHousingData

--- Change Y and N to Yes and No "Sold as Vacant" field
--- Let take a look at the SoldVacant column

SELECT DISTINCT(SoldAsVacant)
FROM CALC.dbo.NashvilleHousingData

--- Let count the values

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM CALC.dbo.NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2

--- Let set the 1 to 'Yes' and 0 to 'NO' for more clearity


SELECT SoldAsVacant,
CASE when SoldAsVacant = '1' THEN  'Yes'
     when SoldAsVacant = '0' THEN 'No'
     ELSE SoldAsVacant 
	 END
FROM CALC.dbo.NashvilleHousingData


UPDATE NashvilleHousingData
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN  'Yes'
    when SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
	END


--- Remove duplicate

SELECT *
FROM CALC.dbo.NashvilleHousingData

--- Let us identify the duplicates in our table using RowNumCTE

WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				    UniqueID
					)row_num
FROM CALC.dbo.NashvilleHousingData
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--- Delete the duplicate 

WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				    UniqueID
					)row_num
FROM CALC.dbo.NashvilleHousingData
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

--- Let check if we still have duplicate

WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				    UniqueID
					)row_num
FROM CALC.dbo.NashvilleHousingData
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


--- Delete unused columns

SELECT *
FROM CALC.dbo.NashvilleHousingData

ALTER TABLE CALC.dbo.NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress, SaleDate
