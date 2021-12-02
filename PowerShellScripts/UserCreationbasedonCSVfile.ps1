

#********************************************************************************************************************************************

#Create a new password
$SecurePassword = ConvertTo-SecureString "Venezuela198" -AsPlainText -Force


# Prompt user for CSV file path

$filepath = Read-Host -Prompt "Please enter your CSV file path"

# Import the file into a variable
    
$users = Import-Csv $filepath

#Loop item by item and gather info

foreach ($i in $users) {

#gather user info
$username =$i.'User Name'
$firstname = $i.'First Name'
$lastname = $i.'Last Name'
$jobtitle = $i.'Job Title'
$username = $i.'User Name'
$displayname = $i.'Display Name'
$email = $i.'Email Address'
$department = $i.Department
$officephone = $i.'Office Phone'
$address = $i.Address
$city = $i.City
$country = $i.'Country or Region'
$OU = $i.'Organizational Unit'


#Create new AD users for each user in CSV file

New-ADUser -Name $firstname -GivenName $firstname -Surname $lastname -UserPrincipalName "$firstname.$lastname" -AccountPassword $SecurePassword -ChangePasswordAtLogon $true -OfficePhone $officephone -EmailAddress $email -City $city -Enabled $true -Path $OU

echo "Account created for $firstname $lastname in $OU"

}