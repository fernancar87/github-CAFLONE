#How to Import and Export AD Security groups

https://community.spiceworks.com/topic/2119765-import-ad-security-groups


Import-Module ActiveDirectory 
Get-ADgroup -Filter * -Properties groupscope,description| select name,samaccountname,groupscope,description | Sort-Object -Property Name| Export-csv -path C:\ADGroups.csv -NoTypeInformation

##import
$groups=Import-csv c:\adgroups.csv
ForEach($group In $groups){
New-ADGroup -Name $group.Name -GroupScope $group.Groupscope -Path 'OU=groups,dc=domain,dc=com' -description $group.description 

      Write-Host "Group $($Group.Name) created!"

