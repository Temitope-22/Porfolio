-- CLEANING DATASETS WITH SQL QUERYING

SELECT *
FROM [Nashville Housing].dbo.Housing

--Standardizing Date Format
SELECT 
	SaleDate,
	CONVERT(Date, SaleDate)
FROM [Nashville Housing].dbo.Housing

UPDATE [Nashville Housing].dbo.Housing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE [Nashville Housing].dbo.Housing
ADD SaleDateConverted Date

UPDATE [Nashville Housing].dbo.Housing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT 
	SaleDateConverted
FROM [Nashville Housing].dbo.Housing

-- Populating Property Address 
--SELECT 
--	*
--FROM [Nashville Housing].dbo.Housing
--WHERE PropertyAddress is null

SELECT 
	*
FROM [Nashville Housing].dbo.Housing
ORDER BY ParcelID

SELECT 
	a.ParcelID, 
	a.PropertyAddress,
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Nashville Housing].dbo.Housing a
JOIN [Nashville Housing].dbo.Housing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET PropertyAddress	= ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Nashville Housing].dbo.Housing a
JOIN [Nashville Housing].dbo.Housing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]

-- Property Address no longer NULL	
SELECT 
	*
FROM [Nashville Housing].dbo.Housing
ORDER BY ParcelID


-- BREAKING ADDRESSES INTO INDIVIDUAL COLUMNS
SELECT 
	*
FROM [Nashville Housing].dbo.Housing
ORDER BY ParcelID

SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address, -- -1 to get rid of comma delimeter [CHARINDEX(',', PropertyAddress)-1)]
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address --LEN() fcn is selecting the City so there's always a gaurentee we're getting all of it 
FROM Housing


ALTER TABLE Housing
ADD PropertySplitAddress Nvarchar(255)

UPDATE Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 


ALTER TABLE Housing
ADD PropertySplitCity Nvarchar(255)

UPDATE Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 





SELECT 
	OwnerAddress
FROM [Nashville Housing].dbo.Housing
ORDER BY ParcelID

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Housing



ALTER TABLE Housing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)



ALTER TABLE Housing
ADD OwnerSplitCity Nvarchar(255)

UPDATE Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)



ALTER TABLE Housing
ADD OwnerSplitState Nvarchar(255)

UPDATE Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT 
	*
FROM [Nashville Housing].dbo.Housing
ORDER BY ParcelID


-- Changing Y's and N's to Yes and No

SELECT 
	DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant)
FROM Housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT 
	SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y'
			THEN 'Yes'
		WHEN SoldAsVacant = 'N'
			THEN 'No'
		ELSE SoldAsVacant
		END
FROM Housing


UPDATE Housing
SET SoldAsVacant =
	CASE 
		WHEN SoldAsVacant = 'Y'
			THEN 'Yes'
		WHEN SoldAsVacant = 'N'
			THEN 'No'
		ELSE SoldAsVacant
		END

SELECT 
	DISTINCT(SoldAsVacant),
	COUNT(SoldAsVacant)
FROM Housing
GROUP BY SoldAsVacant
ORDER BY 2



-- Handling Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) row_num
				
FROM Housing
)

--SELECT *
--FROM RowNumCTE
--WHERE row_num > 1
--ORDER BY PropertyAddress

--DELETE
--FROM RowNumCTE
--WHERE row_num > 1




-- Removing Certain Columns

SELECT *
FROM Housing


ALTER TABLE Housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

