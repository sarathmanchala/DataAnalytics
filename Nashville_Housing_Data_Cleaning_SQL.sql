select *
from portfolioproject.nashville_housing_data;
/* Standardize Date Format  */

set sql_safe_updates = 0;

UPDATE nashville_housing_data
SET SaleDate = STR_TO_DATE(SaleDate, '%M %d, %Y');

select SaleDate 
from nashville_housing_data;

/* Populate Property Address data */
select PropertyAddress
from nashville_housing_data;

/* Breaking out Address into Individual Colums */
SELECT SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1) AS Address, substring(PropertyAddress, INSTR(PropertyAddress, ',') + 1, length(PropertyAddress)) as Address
FROM nashville_housing_data;

alter table nashville_housing_data
add PropertySplitAddress nvarchar(255);

update nashville_housing_data
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, INSTR(PropertyAddress, ',') - 1);

alter table nashville_housing_data
add PropertySplitCity nvarchar(255);

update nashville_housing_data
set PropertySplitCity = substring(PropertyAddress, INSTR(PropertyAddress, ',') + 1, length(PropertyAddress));


select OwnerAddress from
nashville_housing_data;

SELECT 
  SUBSTRING_INDEX(replace(OwnerAddress, ',', '.'), '.', 1) AS AddressPart1,
  SUBSTRING_INDEX(SUBSTRING_INDEX(replace(OwnerAddress, ',', '.'), '.', 2), '.', -1) AS AddressPart2,
  SUBSTRING_INDEX(SUBSTRING_INDEX(replace(OwnerAddress, ',', '.'), '.', 3), '.', -1) AS AddressPart3
FROM nashville_housing_data;

alter table nashville_housing_data
add OwnerSplitAddress nvarchar(255);

update nashville_housing_data
set OwnerSplitAddress = SUBSTRING_INDEX(replace(OwnerAddress, ',', '.'), '.', 1);

alter table nashville_housing_data
add OwnerSplitCity nvarchar(255);

update nashville_housing_data
set OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(replace(OwnerAddress, ',', '.'), '.', 2), '.', -1);

alter table nashville_housing_data
add OwnerSplitState nvarchar(255);

update nashville_housing_data
set OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(replace(OwnerAddress, ',', '.'), '.', 3), '.', -1);

select * from 
nashville_housing_data;


/* Change Y and N to Yes and No in "Sold as Vacant" field */
select distinct(SoldAsVacant), count(SoldAsVacant)
from nashville_housing_data
group by SoldAsVacant
order by 2;

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant =  'N' then 'No'
     else SoldAsVacant
     end
from nashville_housing_data;

UPDATE nashville_housing_data
SET SoldAsVacant = CASE 
                        WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
                        ELSE SoldAsVacant
                    END;


/* Remove Duplicates */

WITH RowNumCTE AS (
    SELECT *, 
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
               ORDER BY UniqueID
           ) AS row_num 
    FROM nashville_housing_data
)

DELETE FROM nashville_housing_data
WHERE UniqueID IN (
    SELECT UniqueID
    FROM (
        SELECT UniqueID,
               ROW_NUMBER() OVER (
                   PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
                   ORDER BY UniqueID
               ) AS row_num 
        FROM nashville_housing_data
    ) AS RowNumCTE
    WHERE row_num > 1
);

/* Delete unused Columns */

alter table nashville_housing_data
drop column OwnerAddress;

alter table nashville_housing_data
drop column TaxDistrict;

alter table nashville_housing_data
drop column PropertyAddress;

alter table nashville_housing_data
drop column SaleDate;

select * from 
nashville_housing_data;



























