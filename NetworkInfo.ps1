write-output "Subnet Computers" >> $outfile
for ($i=1;$i -le 254; $i++){
    $strQuery = "select * from win32_PingStatus where address = '" +
    $intNetwork + $i + "'";
    $wmi = Get-WmiObject -query $strQuery
    echo "Pinging $intNetwork$i ... "
    if ($wmi.statuscode -eq 0){
        write-host "Computer $intNetwork$i is still powered on" -b DarkBlue -f Green
        $Computers += "$intNetwork$i "
    }
}
write-output $Computers >> $outfile
write-output " " >> $outfile
write-output " " >> $outfile
write-host "Connecting to remote computer"
write-output " " >> $outfile
write-output " " >> $outfile
write-output "Computer: $computername" >> $outfile
enable-psremoting -force
$MySecureCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username,$SecureString
invoke-command -ComputerName $computername -Credential $MySecureCreds -FilePath C:\Scripts\RemoteInfo.ps1 >> $outfile
#Restart-Computer -ComputerName $computername -Credential $MySecureCreds -Force



