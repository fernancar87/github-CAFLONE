#Copy\Mirror OU structure from one domain to another domain

#This is one of the regular task that we have to perform during Domain migration activities. So, today we will learn how to Copy\Mirror OU structure from one domain to another domain.

#For my case, I used “LDIFDE” command to export and import the OU’s from one domain to another domain. Login to the Source Domain domain controller with sufficient privileges (Domain admin).Execute below command on Elevated command prompt

ldifde -f c:\Temp\OUs.ldf -r “(objectClass=organizationalUnit)” -l objectClass,description

#This command will export all OU’s from the source domain and create a LDF file with the name “Ous.LDF” in the directory C:\Temp Copy this file on Destination domain domain controller and edit with notepad as we need to modify the Distinguish domain name based on Target domain name. Replace Distinguish name for all OU’s with the new domain distinguish Domain name.

#Ex : dc=testenv,dc=local entries with the new domain’s DN dc=testcorp,dc=local

#Remove the Domain controller OU information from the LDF file as it will come by default on all domains and it is not required to import again in target domain.

#Now file is ready and run below command with elevated command prompt on Target Domain domain controller.

ldifde -i -f c:\Temp\OUs.ldf