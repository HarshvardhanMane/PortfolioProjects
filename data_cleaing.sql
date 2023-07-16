--Cleaing Data IN SQL Queries


select *
from Project.dbo.nashvillehousing

--Standardize data format

select SaleDateConverted, CONVERT(Date,SaleDate)
from Project.dbo.nashvillehousing

update Project.dbo.nashvillehousing
SET SaleDate=CONVERT(Date,SaleDate)

ALTER TABLE Project.dbo.nashvillehousing
add SaleDateConverted Date;

update Project.dbo.nashvillehousing
SET SaleDateConverted=CONVERT(Date,SaleDate)

--Populate Property Address Date
select *
from Project.dbo.nashvillehousing
where PropertyAddress is null

select *
from Project.dbo.nashvillehousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from Project.dbo.nashvillehousing a
JOIN Project.dbo.nashvillehousing b
ON a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from Project.dbo.nashvillehousing a
JOIN Project.dbo.nashvillehousing b
ON a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null



--Breaking Out Address into Individual Columns (Address, City, State )


select PropertyAddress
from Project.dbo.nashvillehousing
--where PropertyAddress is null
--order by ParcelID

select 
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1 ) as Address
,SUBSTRING(PropertyAddress ,CHARINDEX(',',PropertyAddress)+1 ,len(PropertyAddress)) as Address
FROM Project..nashvillehousing

ALTER TABLE Project.dbo.nashvillehousing
add PropertySplitAddress nvarchar(255);

update Project.dbo.nashvillehousing
SET PropertySplitAddress=SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1 )

ALTER TABLE Project.dbo.nashvillehousing
add PropertySplitCity nvarchar(255);

update Project.dbo.nashvillehousing
SET PropertySplitCity=SUBSTRING(PropertyAddress ,CHARINDEX(',',PropertyAddress)+1 ,len(PropertyAddress))

select*
from Project..nashvillehousing

select OwnerAddress
from Project..nashvillehousing

select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) 
,PARSENAME(REPLACE(OwnerAddress,',','.'),2) 
,PARSENAME(REPLACE(OwnerAddress,',','.'),1) 
from Project..nashvillehousing



ALTER TABLE Project.dbo.nashvillehousing
add OwnerSpiltAddress nvarchar(255);

update Project.dbo.nashvillehousing
SET OwnerSpiltAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

ALTER TABLE Project.dbo.nashvillehousing
add OwnerSplitCity nvarchar(255);

update Project.dbo.nashvillehousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Project.dbo.nashvillehousing
add OwnerSplitState nvarchar(255);

update Project.dbo.nashvillehousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1) 

select*
from Project.dbo.nashvillehousing



--Change Y and N To Yes and No is "Sold as Vacant" field
select distinct(SoldAsVacant),COUNT(SoldAsVacant)
from Project.dbo.nashvillehousing
group by SoldAsVacant
order by 2


select SoldAsVacant
,CASE when SoldAsVacant='Y' THEN 'YES'
WHEN SoldAsVacant='N' THEN 'NO'
ELSE SoldAsVacant
END
from Project.dbo.nashvillehousing

update nashvillehousing
set SoldAsVacant=CASE when SoldAsVacant='Y' THEN 'YES'
WHEN SoldAsVacant='N' THEN 'NO'
ELSE SoldAsVacant
END




--Remove Duplicates
with RowNumCTE AS(
select*,
 ROW_NUMBER()OVER(
 PARTITION BY ParcelID,
              PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  ORDER BY 
			   UniqueID
			  ) row_num

from Project..nashvillehousing)
--ORDER BY ParcelID)
DELETE
FROM RowNumCTE
where row_num > 1
--order by PropertyAddress




--Delete Unused Columns

select*
from Project..nashvillehousing

ALTER TABLE Project..nashvillehousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE Project..nashvillehousing
DROP COLUMN SaleDate