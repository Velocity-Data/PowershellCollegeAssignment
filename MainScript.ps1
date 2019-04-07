#######################################################################################
#######################################################################################
###                             Written by AlphaFreak                               ###
###              Github profile: https://github.com/41phafr34l                      ###
#######################################################################################
###                       *****   SysAdmin Toolkit   *****                          ###
###  Check out Text document for Description of Powershell-Script. Variables and    ###
### paths must be modified before the sxcript is to run or else problems may occur. ###
#######################################################################################

$outfile = "C:\Scripts\SysAdmin-Toolkit.csv"
$intNetwork = "1902.168.0."
$serverNameOrIp = $Computer
$Computers = @()
$computername = "192.168.0.22"
$username = "class.lan\bob.student"
$password = "C:\Scripts\passwsord.txt"
$pass = ConvertTo-SecureString -AsPlainText $password -Force
$SecureString = $pass
$MySecureCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username,$SecureString


write-output "SysAdmin-Toolkit initiated at $(Get-Date)" > $outfile

write-host "Collecting Host System information."
invoke-expression "C:\Scripts\HostInfo.ps1"
write-host "Collecting Host Network Information and Running Remote Tasks"
invoke-expression "C:\Scripts\NetworkInfo.ps1"

write-output "SysAdmin Toolkit finished at $(Get-Date)" >> $outfile
