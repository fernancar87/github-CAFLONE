# Get a list of all Computer Objects and OS

Get-ADComputer -Filter * -Properties * | Format-Table Name, OperatingSystem -wrap -AutoSize


# Backup all GPO and order them by date, This is very important before doing any changes 
# if you do a ricght click in Group Policy Object you can also make a backup of all GPO's
$date = Get-Date -Format yyyyMMdd
New-Item C:\GPO_Backup -ItemType Directory
New-Item C:\GPO_Backup\$date -ItemType Directory
$GPOS = Get-GPO -All | Select DisplayName
foreach ($GPO in $GPOS) {
    New-Item C:\GPO_Backup\$date\$GPO -ItemType Directory
    Backup-GPO -Name $GPO.Displayname -Path C:\GPO_Backup\$date\$GPO
}


#Example 1: Import the settings from the latest backup to another directory in the same domain


PS C:\> import-gpo -BackupGpoName TestGPO -TargetName TestGPO -path c:\backups 


###################################################################################

#   You can try the following to backup your GPO: -


Backup-GPO -All -Path "C:\Backup\GroupPolicy" -Comment "Backup" -Domain YourDomain.Net -Server ADDC01


# Then the following to restore them : -
 


Restore-GPO -All -Domain YourDomain.Net -path "C:\Backup\GroupPolicy"

