### CLEANING DATA IN SQL
SELECT * FROM nashville;


### Standardize Date Format
SELECT saledate, CONVERT(DATE, saledate) FROM nashville;

UPDATE nashville SET saledate = CONVERT(DATE, saledate);

ALTER TABLE nashville ADD saledateconverted DATE;
UPDATE nashville SET saledateconverted = CONVERT(DATE, saledate);


### Populate Property Address
SELECT propertyaddress FROM nashville WHERE propertyaddress IS NULL ORDER BY parcelID;

SELECT a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, 
ISNULL(a.propertyaddress, b.propertyaddress) FROM nashville 
AS a JOIN nashville AS b ON a.parcelID = b.parcelID AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.propertyaddress IS NULL;

UPDATE a
SET propertyaddress = ISNULL(a.propertyaddress, b.propertyaddress)
FROM nashville AS a JOIN nashville AS b 
ON a.parcelID = b.parcelID AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.propertyaddress IS NULL;


### Dividing Address into Individual Columns
SELECT SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) - 1) AS address, 
SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1, LENGTH(propertyaddress)) AS city
FROM nashville;


ALTER TABLE nashville ADD propertysplitaddress VARCHAR(255);
UPDATE nashville SET propertysplitaddress = 
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) - 1);

ALTER TABLE nashville ADD propertysplitcity VARCHAR(255);
UPDATE nashville SET propertysplitcity = 
SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1, LENGTH(propertyaddress));



SELECT PARSENAME(REPLACE(owneraddress, ',', '.'), 3),
PARSENAME(REPLACE(owneraddress, ',', '.'), 2),
PARSENAME(REPLACE(owneraddress, ',', '.'), 1) FROM nashville;


ALTER TABLE nashville ADD ownersplitaddress VARCHAR(255);
UPDATE nashville SET ownersplitaddress = PARSENAME(REPLACE(owneraddress, ',', '.'), 3);

ALTER TABLE nashville ADD ownersplitcity VARCHAR(255);
UPDATE nashville SET ownersplitcity = PARSENAME(REPLACE(owneraddress, ',', '.'), 2);

ALTER TABLE nashville ADD ownersplitstate VARCHAR(255);
UPDATE nashville SET ownersplitstate = PARSENAME(REPLACE(owneraddress, ',', '.'), 1);


### Change Y/N to Yes/No
SELECT DISTINCT(soldasvacant), COUNT(soldasvacant) FROM nashville
GROUP BY soldasvacant ORDER BY 2;

UPDATE nashville SET soldasvacant = CASE
    WHEN soldasvacant = 'Y' THEN 'Yes'
    WHEN soldasvacant = 'N' THEN 'No'
    ELSE soldasvacant
END


### Remove Duplicates
WITH rownumCTE AS (
SELECT *, ROW_NUMBER() OVER 
(PARTITION BY parcelID, propertyaddress, saleprice, saledate, legalreference
ORDER BY uniqueID) AS row_num FROM nashville ORDER BY parcelID);

DELETE FROM rownumCTE WHERE row_num > 1;


### Delete Unused Columns
ALTER TABLE nashville
DROP COLUMN owneraddress, taxdistrict, propertyaddress, saledate;





