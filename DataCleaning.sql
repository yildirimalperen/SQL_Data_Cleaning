/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [Project].[dbo].[NashvilleHousing]

  /*
  Data Cleaning Exercises 
  */


  -- Standardize Date Format

  select SaleDate --CONVERT(Date,SaleDate) as SaleDate1
  from Project..NashvilleHousing

  update NashvilleHousing
  set SaleDate = CONVERT(Date,SaleDate)
  

  alter table NashvilleHousing
  add SaleDateConverted Date;

  update NashvilleHousing
  set SaleDateConverted = CONVERT(Date,SaleDate)

  select saledateconverted
  from Project..NashvilleHousing

  -- Populating Property Address Column

  select a.ParcelID, a.PropertyAddress, b.ParcelID , b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
  from Project..NashvilleHousing a
  join Project..NashvilleHousing b 
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress is null

  update a
  set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
  from Project..NashvilleHousing a 
  join Project..NashvilleHousing b
  on a.ParcelID = b.ParcelID
  and a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress is null;
  
  
  select 
  substring(PropertyAddress, 1, Charindex(',', PropertyAddress)-1) as Address,
  SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as address
  from Project..NashvilleHousing
  

  alter table NashvilleHousing
  add PropertySplitAddress nvarchar(255);

  update NashvilleHousing
  set PropertySplitAddress = substring(PropertyAddress, 1, Charindex(',', PropertyAddress)-1)

  alter table NashvilleHousing
  add PropertySplitCity nvarchar(255);

  update NashvilleHousing
  set PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

 
 select *
 from Project..NashvilleHousing

 -- Breaking out Address into Individual Columns(Address,City,State)

 select 
 PARSENAME(REPLACE(OwnerAddress,',','.'),3),
 PARSENAME(REPLACE(OwnerAddress,',','.'),2),
 PARSENAME(REPLACE(OwnerAddress,',','.'),1)
 from Project..NashvilleHousing
  where OwnerAddress is not null


  
  alter table project..NashvilleHousing
  add OwnerSplitAddress nvarchar(255);

  update project..NashvilleHousing
  set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

  alter table project..NashvilleHousing
  add OwnerSplitCity nvarchar(255);

  update project..NashvilleHousing
  set OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress,',','.'),2)

  alter table project..NashvilleHousing
  add OwnerSplitState nvarchar(255);

  update project..NashvilleHousing
  set OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress,',','.'),1)


   select *
 from Project..NashvilleHousing
 where OwnerAddress is not null

 -- Change Y and N to Yes and No in 'SoldAsVacant' field

 select distinct(soldasvacant), count(SoldAsVacant) as Vacantcount
 from Project..NashvilleHousing
 group by SoldAsVacant
 order by 2 desc

 select soldasvacant,
 case when soldasvacant = 'Y' then 'Yes'
 when soldasvacant = 'N' then 'No'
 else soldasvacant
 end
 from Project..NashvilleHousing

 update Project..NashvilleHousing
 set SoldAsVacant = case when soldasvacant = 'Y' then 'Yes'
 when soldasvacant = 'N' then 'No'
 else soldasvacant
 end

 -- remove duplicates

 WITH RowNumCTE AS(
 select *,
 ROW_NUMBER() OVER(
 Partition by ParcelID,
 PropertyAddress,
 SalePrice,
 SaleDate,
 LegalReference
 Order by
 uniqueID) row_num
 
 from Project..NashvilleHousing
 )

 select *
 from RowNumCTE
 where row_num > 1
 order by PropertyAddress

 -- Delete Unused Columns

 Select* 
 From Project..NashvilleHousing

 Alter table Project..NashvilleHousing
 Drop column OwnerAddress, TaxDistrict, PropertyAddress,SaleDate
