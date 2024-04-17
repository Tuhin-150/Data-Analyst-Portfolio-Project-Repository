-- Cleaning Data in SQL Queries

Select *
From practice.NashvilleHousing;

SELECT DATE_FORMAT(STR_TO_DATE(saledate, '%M %e, %Y'), '%Y-%m-%d') AS formatted_date
FROM practice.nashvillehousing;

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

set sql_safe_updates=0;
Update NashvilleHousing
SET SaleDateConverted = DATE_FORMAT(STR_TO_DATE(saledate, '%M %e, %Y'), '%Y-%m-%d');

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From Practice.NashvilleHousing;
-- Where PropertyAddress is null
-- order by ParcelID

SELECT 
    SUBSTRING_INDEX(PropertyAddress, ',', 1) AS Address,
    SUBSTRING(PropertyAddress, LENGTH(SUBSTRING_INDEX(PropertyAddress, ',', 1)) + 2) AS Remainder
FROM Practice.NashvilleHousing;

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1) ;


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, LENGTH(SUBSTRING_INDEX(PropertyAddress, ',', 1)) + 2) ;

Select *
From Practice.NashvilleHousing;

Select OwnerAddress
From Practice.NashvilleHousing;


SELECT 
    SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 3), '.', -1),
    SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 2), '.', -1),
    SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1), '.', -1)
FROM Practice.NashvilleHousing;


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 3), '.', -1);


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 2), '.', -1);

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', 1), '.', -1);

Select *
From Practice.NashvilleHousing;

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Practice.NashvilleHousing
Group by SoldAsVacant
order by 2;

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Practice.NashvilleHousing;

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;

-- Identify Duplicates
 
set sql_safe_updates=0; 
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Practice.NashvilleHousing
-- order by ParcelID
)
select *
From RowNumCTE
Where row_num > 1;
-- Order by PropertyAddress;

-- Remove Duplicates

DELETE FROM Practice.NashvilleHousing
WHERE UniqueID IN (
    SELECT UniqueID
    FROM (
        SELECT *,
            ROW_NUMBER() OVER (
                PARTITION BY ParcelID,
                             PropertyAddress,
                             SalePrice,
                             SaleDate,
                             LegalReference
                ORDER BY UniqueID
            ) AS row_num
        FROM Practice.NashvilleHousing
    ) AS RowNumCTE
    WHERE row_num > 1
);

Select *
From Practice.NashvilleHousing;

-- Delete Unused Columns

Select *
From Practice.NashvilleHousing;

ALTER TABLE Practice.NashvilleHousing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;




