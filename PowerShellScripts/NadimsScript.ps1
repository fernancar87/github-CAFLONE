#EF - Domain Discovery Script v1.0 - By Nadim Janjua
#10/09/2021

$comma = ","
$tab = "`t"

#Get Domain Controllers
$DCs = Get-ADDomainController -Filter * | Select-Object Name, Domain, Hostname, IPv4Address, IsGlobalCatalog, IsReadOnly, OperatingSystem, Site `
| Export-Csv -Path C:\temp\DCExport.csv -NoTypeInformation

#Get All AD Sites and their subnets
$sites = Get-ADReplicationSite -Filter * -Properties * | Select-Object Name, Description, whenCreated, location, subnets
("Name"  + $comma + "Description" + $comma + "Location" + $comma + "whenCreated" + $comma + "All subnets") | Out-File c:\temp\Sites_SubnetsExport.txt

ForEach ($site in $sites)
{      
    $allSubnetsForThisSite = ""

    ForEach ($subnet in $site.subnets)
    {
       $value = $subnet.Split(',')[0]
       $value = $value.Replace("CN=","")
       $allSubnetsForThisSite += $value + ";"
    }  

    ($site.Name  + $comma + $site.Description + $comma + $site.Location + $comma + $site.whenCreated + $comma + $allSubnetsForThisSite) | Out-File c:\temp\Sites_SubnetsExport.txt -Append
}


#Get user accounts in AD
$ADUsers = Get-ADUser -Filter * -Properties * | Select-Object sAMAccountName, GivenName, sn, Description, UserPrincipalName, DisplayName, EmailAddress, Telephone, Title, Department, Manager, `
ScriptPath, HomeDirectory, HomeDrive, PasswordNeverExpires, AccountExpirationDate, whenCreated, whenChanged, userAccountControl, `
                                                 
@{n='LastLogonTimeStamp';e={[DateTime]::FromFileTime($_.LastLogonTimeStamp)}}, 
@{n='LastLogon';e={[DateTime]::FromFileTime($_.LastLogon)}}, 
@{n='pwdLastSet';e={[DateTime]::FromFileTime($_.pwdLastSet)}}, distinguishedName | Export-Csv -Path C:\temp\UserExport.csv -NoTypeInformation

Write-Host "AD User export complete" -BackgroundColor DarkGreen

#Get computer accounts in AD
$ADComputers = Get-ADComputer -Filter * -Properties * | Select-Object name, description,

@{n='LastLogonTimeStamp';e={[DateTime]::FromFileTime($_.LastLogonTimeStamp)}}, 
@{n='LastLogon';e={[DateTime]::FromFileTime($_.LastLogon)}}, 
@{n='pwdLastSet';e={[DateTime]::FromFileTime($_.pwdLastSet)}}, 
userAccountControl, operatingSystem, operatingSystemVersion, distinguishedName | Export-Csv -Path C:\temp\ComputerExport.csv -NoTypeInformation

Write-Host "AD Computer export complete" -BackgroundColor DarkGreen

#Get AD groups
$ADGroups = Get-ADGroup -Filter * | Select-Object samAccountName
ForEach ($group in $ADGroups)
{
    $groupName = Get-ADGroup $group.samAccountName
    $groupName | Out-File -FilePath ("C:\Temp\GroupsExport.txt") -Append
}

Write-Host "AD Group export complete" -BackgroundColor DarkGreen

#Get DNS zone info
Get-DnsServerZone | Export-Csv -Path C:\temp\DNSzoneExport.csv -NoTypeInformation

Write-Host "DNS Zone settings export complete" -BackgroundColor DarkGreen

#Get DHCP scope info
$DHCPServers = Get-DhcpServerInDC
foreach ($computername in $DHCPServers)
{
    ##Export List of DHCP Servers
    $computername | Export-Csv C:\temp\DHCPServer.csv -Append -NoTypeInformation
    $scopes = Get-DHCPServerv4Scope -ComputerName $computername.DnsName |
    Select-Object "Name","SubnetMask","StartRange","EndRange","ScopeID","State"


    $serveroptions = Get-DHCPServerv4OptionValue -ComputerName $computername.DnsName | 
    Select-Object OptionID,Name,Value,VendorClass,UserClass,PolicyName

    ForEach ($scope in $scopes) 
    {
        $DHCPServer = $computername.DnsName

        ##Export List of scopes on each server
        $scope | Export-Csv "C:\temp\$DHCPServer-Scopes.csv" -Append -NoTypeInformation

        ForEach ($option in $serveroptions) 
        {
            $lines = @()
            $Serverproperties = @{
            Name = $scope.Name
            SubnetMask = $scope.SubnetMask
            StartRange = $scope.StartRange
            EndRange = $scope.EndRange
            ScopeId = $scope.ScopeId
            OptionID = $option.OptionID
            OptionName = $option.name
            OptionValue =$option.Value
            OptionVendorClass = $option.VendorClass
            OptionUserClass = $option.UserClass }

            $lines += New-Object psobject -Property $Serverproperties
            $lines | select Name,SubnetMask,StartRange,EndRange,ScopeId,OptionID,OptionName,{OptionValue},OptionVendorClass,OptionUserClass | Export-Csv C:\temp\$dhcpserver-ServerOption.csv -Append -NoTypeInformation
        }

        $scopeoptions = Get-DhcpServerv4OptionValue -ComputerName $computername.DnsName -ScopeId "$($scope.ScopeId)" -All | 
        Select-Object OptionID,Name,Value,VendorClass,UserClass,PolicyName

        ForEach ($option2 in $scopeoptions) 
        {
            $lines2 = @()
            $Scopeproperties = @{
            Name = $scope.Name
            SubnetMask = $scope.SubnetMask
            StartRange = $scope.StartRange
            EndRange = $scope.EndRange
            ScopeId = $scope.ScopeId
            OptionID = $option2.OptionID
            OptionName = $option2.name
            OptionValue =$option2.Value
            OptionVendorClass = $option2.VendorClass
            OptionUserClass = $option2.UserClass }


            $lines2 += New-Object psobject -Property $Scopeproperties
            $lines2 | select Name,SubnetMask,StartRange,EndRange,ScopeId,OptionID,OptionName,{OptionValue},OptionVendorClass,OptionUserClass |Export-Csv C:\temp\$dhcpserver-ScopeOption.csv -Append -NoTypeInformation
        }
    }
 }

Write-Host "DHCP config export complete" -BackgroundColor DarkGreen


Read-Host "Press any key to exit"            