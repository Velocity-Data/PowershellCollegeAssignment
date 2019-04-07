write-output " "
write-output "Basic Information" 
Get-CimInstance Win32_OperatingSystem | Select-Object Name, CSName, RegisteredUser, NumberOfUsers, Caption, Version, OSArchitecture, MUILanguages, OSLanguage, BuildNumber, SerialNumber, BootDevice, SystemDevice, SystemDrive, WindowsDirectory, SystemDirectory, DataExecutionPrevention_32BitApplications, DataExecutionPrevention_Available, DataExecutionPrevention_Drivers, DataExecutionPrevention_SupportPolicy, EncryptionLevel, PortableOperatingSystem, BuildType, FreePhysicalMemory, FreeSpaceInPagingFiles, FreeVirtualMemory, TotalVirtualMemorySize, TotalVisibleMemorySize, MaxProcessMemorySize, MaxNumberOfProcesses, NumberOfProcesses, LastBootUpTime, LocalDateTime, InstallDate | FL 
write-host "Collecting Anti-Virus and other Security Information."
write-output "Anti-Virus Information"
write-output " "
$computername=$env:computername
$AntiVirusProduct = Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct  -ComputerName $computername
switch ($AntiVirusProduct.productState) { 
    "262144" {$defstatus = "Up to date" ;$rtstatus = "Disabled"} 
    "262160" {$defstatus = "Out of date" ;$rtstatus = "Disabled"} 
    "266240" {$defstatus = "Up to date" ;$rtstatus = "Enabled"} 
    "266256" {$defstatus = "Out of date" ;$rtstatus = "Enabled"} 
    "393216" {$defstatus = "Up to date" ;$rtstatus = "Disabled"} 
    "393232" {$defstatus = "Out of date" ;$rtstatus = "Disabled"} 
    "393488" {$defstatus = "Out of date" ;$rtstatus = "Disabled"} 
    "397312" {$defstatus = "Up to date" ;$rtstatus = "Enabled"} 
    "397328" {$defstatus = "Out of date" ;$rtstatus = "Enabled"} 
    "397584" {$defstatus = "Out of date" ;$rtstatus = "Enabled"} 
    "397568" {$defstatus = "Up to date"; $rtstatus = "Enabled"}
    "393472" {$defstatus = "Up to date" ;$rtstatus = "Disabled"}
default {$defstatus = "Unknown" ;$rtstatus = "Unknown"} 
}
write-output $computername
write-output $AntiVirusProduct.displayName
write-output $AntiVirusProduct.pathToSignedProductExe 
write-output "Definition status:  $defstatus" 
write-output "Real-time protection status: $rtstatus"
write-output " "
write-output " "
write-Output "Network Information"
test-netconnection
write-output " "

if ($IsIp -ne $true) {
    $Computer = "192.168.0.22"
    Write-Output 'Trying a DNS lookup.'
    $ErrorActionPreference = 'SilentlyContinue'
    $Ips = [System.Net.Dns]::GetHostAddresses($Computer) | Foreach { $_.IPAddressToString }
    if ($?) {
        Write-Output 'IP address(es) from DNS:' ($Ips -join ', ') >> $outfile
    }
    else {
        if ($IgnoreDNS) {
            Write-Output "WARNING: Could not resolve DNS name, but -IgnoreDNS was specified. Proceeding."
        }
        else {
            Write-Output "Could not resolve DNS name and -IgnoreDNS not specified. Exiting with code 1."
            exit 1
        }  
    }
    $ErrorActionPreference = 'Continue'   
}
if ($ping) {
    if (Test-Connection -Count 1 -ErrorAction SilentlyContinue $Computer) {   
        Write-Output "$Computer responded to ICMP ping" >> $outfile   
    } 
    else {  
        Write-Output "$Computer did not respond to ICMP ping" >> $outfile  
    }    
}
foreach ($Port in $Ports) {    
    $private:socket = New-Object Net.Sockets.TcpClient
    $ErrorActionPreference = 'SilentlyContinue'
    $private:socket.Connect($Computer, $Port)
    $ErrorActionPreference = 'Continue'    
    if ($private:socket.Connected) {        
        Write-Output "${Computer}: Port $port is open" >> $outfile
        $private:socket.Close()        
    }     
    else {        
        Write-Output "${Computer}: Port $port is closed or filtered" >> $outfile     
    }    
    $private:socket = $null 
}

write-output " "
write-output "Network Adapter" 
Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName . | Select-Object -Property PSComputerName, Caption, MACAddress, IPEnabled, IPFilterSecurityEnabled, IPAddress, IPSubnet, DefaultIPGateway, DHCPEnabled, DHCPLeaseObtained, DHCPLeaseExpires, DHCPServer, DNSDomain, DNSHostName
