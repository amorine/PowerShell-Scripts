<#
.DESCRIPTION
	This script gathers user members of group specified in @Groups
	and emails to recipients.

.AUTHOR
	Name: Andrew Morine
	Date: 08-May-2020
	Version: 1.1

#>

# Email configuration details
$EmailFrom = "IT Support <support@testdomain.com.au>"
$EmailTo = "Andrew Morine <andrew.morine@testdomain.com.au>"
$EmailSubject = "O365 User List Licensing Audit."
$EmailSMTP = "webmail.testdomain.com.au"

# Add groups here. Use the group name in AD.
$Groups = "MS_Office_365_F1", "MS_Office_365_E3", "MS_Visio_Online_P2", "MS_Intune_EMS_E3"

# Initialise empty array
$Files = New-Object System.Collections.ArrayList

$Result = Foreach ($Group in $Groups) {
	$GetGroup = Get-ADGroupMember -Identity $Group
	$GetUsers = Foreach ($User in $GetGroup) {
		$username = $User.SamAccountName
		# For each user, get the details I want
		Get-ADUser -Identity $username -Properties * | Select-Object -Property SamAccountName, DisplayName, City, State, OfficePhone
	}
	$FileName = ".\" + $Group + ".csv"
	# Sort the users by the State property and export to CSV file
	$GetUsers | sort -Property "State" | Export-Csv -Path $FileName -NoTypeInformation
	# Add the file name to the array 
	$Files.Add($FileName)
}

# Send an email and attach the files listed in the array
Send-MailMessage -From $EmailFrom -To $EmailTo -Subject $EmailSubject -Attachments $Files -SmtpServer $EmailSMTP

# Clean up
Remove-Item -Path * -include *.csv