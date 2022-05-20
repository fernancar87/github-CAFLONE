#-------------------------------------------------------------------------------------
# Author      : Carlos Fernandez                                                      #
# FileName    : New-OU.ps1                                                            #
# Version     : 1.0                                                                   #
# Created     : 16/02/2022                                                            #
# Description : Powershell script creates OUs for non-integrated sites                #
# Remarks     : To run the script just change domain name in $Privileged_Objects and  #
# $PathTierPrivileged according to the site                                           #
#                                                                                     #
#-------------------------------------------------------------------------------------

# Import active directory module for running AD cmdlets
Import-Module ActiveDirectory

# Setting up Disntinguished Name for OU creation
# The 

Write-Host "Welcome, we will create all OU's for non-integrated sites" -ForegroundColor Green
Start-Sleep -s 2

$DC1= Read-Host -Prompt "Enter Distinguished Name, e.g. DC=Mitoxandmetodos,DC=local where the first value for DC is = First DC Name " 
$DC2= Read-Host -Prompt "Enter Distinguished Name, e.g. DC=Mitoxandmetodos,DC=local where the second value for DC is = Second DC Name"


# Create Tier Levels OU in Privileged Objects by identifying the path
$Privileged_Objects = "DC=$DC1 ,DC=$DC2"
$PathTierPrivileged = "OU=Privileged_Objects ,DC=$DC1,DC=$DC2"
$Tier0 =  $PathTierPrivileged
$Tier1 =  $PathTierPrivileged
$Tier2 =  $PathTierPrivileged


# Create Tier Levels OU in root domain based on Delegation Model

$Tier1 = "$Privileged_Objects"
$Tier2 = "$Privileged_Objects"

#Variables for SubOU based on Tier Model
$Tier1SubOU = "OU=Tier1,$Privileged_Objects"
$Tier2SubOU = "OU=Tier2,$Privileged_Objects"
 

#Create OU under Privileged_Objects Model 
New-ADOrganizationalUnit -Name "Privileged_Objects" -Path "$Privileged_Objects" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Tier0" -Path "$PathTierPrivileged" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Tier1" -Path "$PathTierPrivileged" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Tier2" -Path "$PathTierPrivileged" -ProtectedFromAccidentalDeletion $true

#Create OU Delegation Model 
New-ADOrganizationalUnit -Name "Tier1" -Path "$Privileged_Objects" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit -Name "Tier2" -Path "$Privileged_Objects" -ProtectedFromAccidentalDeletion $true

#Create Sub OU at Tier1 level 
New-ADOrganizationalUnit "Tier1 Resource Access Groups" -Path "$Tier1SubOU" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit "Server Administration Group" -Path "$Tier1SubOU" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit "Tier1 Servers" -Path "$Tier1SubOU" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit "Shared Printers" -Path "$Tier1SubOU" -ProtectedFromAccidentalDeletion $true


#Create Sub OU at Tier2 level 
New-ADOrganizationalUnit "Tier2 Computer Administration Groups" -Path "$Tier2SubOU" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit "Tier2 Computers" -Path "$Tier2SubOU" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit "Tier2 Groups" -Path "$Tier2SubOU" -ProtectedFromAccidentalDeletion $true
New-ADOrganizationalUnit "User Accounts" -Path "$Tier2SubOU" -ProtectedFromAccidentalDeletion $true


#Display confirmation
Start-Sleep -s 2
Get-ADOrganizationalUnit -Filter 'Name -like "Tier*"' | Format-Table Name 

If ($Privileged_Objects,$PathTierPrivileged -icontains $Privileged_Objects ) {

Write-Host -ForegroundColor Green "All OUs were created successfully" }
 Else {
Write-Host -Foregr