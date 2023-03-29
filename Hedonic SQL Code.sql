--Loading Data 
Select * 
From Nashville.dbo.Nash

--Standardizing Date Format 
Select SaleDate, CONVERT(Date,SaleDate)
From Nashville.dbo.Nash
Alter table Nash
Add SaleDateConverted Date; 
Update Nash
Set SaleDateConverted = Convert(Date,SaleDate)

--Checking if Conversion Worked 
Select SaleDateConverted, Convert(Date,SaleDate)
From Nashville.dbo.Nash

--It Worked 

--Checking Property Address Null Values 
Select PropertyAddress
From Nashville.dbo.Nash
Where PropertyAddress is null

--29 Nulls

--Checking for Same ParcelID's
Select *
From Nashville.dbo.Nash
Order By ParcelID 

--ParcelID's same as property address 

--Need to join ParcelID's & Addresses 
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
From Nashville.dbo.Nash a
JOIN Nashville.dbo.Nash b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--successful join but still need to update info into right column 
Update a
Set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
From Nashville.dbo.Nash a
JOIN Nashville.dbo.Nash b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out property info into address, city, and state into three seperate columns instead of one

--comma is delimiter in this case

--viewing basic data 
Select PropertyAddress 
From Nashville.dbo.Nash  

--seperating out cities from property address
Select
Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1 ) as Address
, Substring(PropertyAddress, Charindex(',', PropertyAddress) + 1 , Len(PropertyAddress)) as Address
From Nashville.dbo.Nash

--seperated city from address 

--creating new columns to add values in 
Alter table Nash
Add PropertySplitAddress nvarchar(255); 
Update Nash
Set PropertySplitAddress = Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1 )

Alter table Nash
Add PropertySplitCity nvarchar(255); 
Update Nash
Set PropertySplitCity = Substring(PropertyAddress, Charindex(',', PropertyAddress) + 1 , Len(PropertyAddress))

--Checking to see if things worked out correctly 
Select *
From Nashville.dbo.Nash  

--splitting address and city worked out, two new columns created

--need to do same for owner address now
Select OwnerAddress
From Nashville.dbo.Nash

--trying same thing from before but different way, 123 was backwards so attempt to fix
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From Nashville.dbo.Nash  

--creating new columns to add values in 
Alter table Nash
Add OwnerSplitAddress nvarchar(255); 
Update Nash
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

Alter table Nash
Add OwnerSplitCity nvarchar(255); 
Update Nash
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

Alter table Nash
Add OwnerSplitState nvarchar(255); 
Update Nash
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--Checking to see if things worked out correctly 
Select *
From Nashville.dbo.Nash  

--sold as vacant column has issues, has Yes/No & Y/N, confirming issue
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Nashville.dbo.Nash  
Group by SoldAsVacant
order by 2

--Yes/No format more popular, so attempting to change all values to that format in that column
Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From Nashville.dbo.Nash 

--putting correct information into column
Update Nash
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End

--checking to see if things turned out alright 
Select *
From Nashville.dbo.Nash  

--looks good 

--attempt to remove duplicate information from database 
With RowNumCTE as(
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					) row_num
From Nashville.dbo.Nash
) 
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

--104 duplicates 

--attempt to delete dupes
With RowNumCTE as(
Select *,
	ROW_NUMBER() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					) row_num
From Nashville.dbo.Nash
) 
Delete 
From RowNumCTE
Where row_num > 1

--104 rows deleted, seems to check out

--checking to see if things turned out alright 
Select *
From Nashville.dbo.Nash  

--now that i have deleted dupes, i plan on deleting useless columns from dataset

--loading data
Select *
From Nashville.dbo.Nash  

--dropping columns
Alter Table  Nashville.dbo.Nash 
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

--checking to see if things turned out alright 
Select *
From Nashville.dbo.Nash  

--Looks good, data finally cleaned!