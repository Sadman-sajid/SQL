--CLEANING DATA IN SQL

select * from PortfolioProject.dbo.NashvilleHousing

--Standardize date format

select Saledate, CONVERT(date, Saledate) from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
add Saledateupdated date;

update PortfolioProject.dbo.NashvilleHousing
set Saledateupdated = CONVERT(date, Saledate)

select SaleDate, Saledateupdated from PortfolioProject.dbo.NashvilleHousing

--populate the null property address 

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

select PropertyAddress from PortfolioProject.dbo.NashvilleHousing
where PropertyAddress = null 

--breaking property address into two columns (address and city)

select PropertyAddress from PortfolioProject.dbo.NashvilleHousing

select PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as City
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitAddress nvarchar(255);
alter table PortfolioProject.dbo.NashvilleHousing
add PropertySplitCity nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing set
PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))

select PropertySplitAddress, PropertySplitCity  from PortfolioProject.dbo.NashvilleHousing

--breaking owner address into three columns (address, city and state)

select OwnerAddress from PortfolioProject.dbo.NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) as address,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) as city,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) as state
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitAddress nvarchar(255);
alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitCity nvarchar(255);
alter table PortfolioProject.dbo.NashvilleHousing
add OwnerSplitState nvarchar(255);

update PortfolioProject.dbo.NashvilleHousing set 
OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) ;

select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState from PortfolioProject.dbo.NashvilleHousing

--change Y and N to Yes and No in sold as vacant field 

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes' 
	 when SoldAsVacant = 'N' then 'No' 
	 else SoldAsVacant
	 end
from PortfolioProject.dbo.NashvilleHousing

update PortfolioProject.dbo.NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes' 
	 when SoldAsVacant = 'N' then 'No' 
	 else SoldAsVacant
	 end

-- remove duplicates

with RowNumCTE as ( 

select *, ROW_NUMBER() 
over(partition by
	parcelID, PropertyAddress,
	SalePrice, SaleDate,
	LegalReference
	order by uniqueID
	) row_num
	from PortfolioProject.dbo.NashvilleHousing
	--order by ParcelID
	)
	
select * from RowNumCTE
where row_num > 1
order by [UniqueID ]

delete from RowNumCTE
where row_num > 1
--order by [UniqueID ]


--deleting unused columns

select * from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column PropertyAddress, SaleDate, OwnerAddress, TaxDistrict