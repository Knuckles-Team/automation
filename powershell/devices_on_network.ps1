Write-Host "Discovering devices..."
#$FileOut = ".\Computers.csv"
### Ping subnet
#$Subnet = "192.168.1."
#1..254|ForEach-Object{
#    Start-Process -WindowStyle Hidden ping.exe -Argumentlist "-n 1 -l 0 -f -i 2 -w 1 -4 $SubNet$_"
#}
#$Computers = (arp.exe -a | Select-String "$SubNet.*dynam") -replace ' +',','|
#  ConvertFrom-Csv -Header Computername,IPv4,MAC,x,Vendor|
#                   Select-Object Computername,IPv4,MAC
#
#ForEach ($Computer in $Computers){
#  nslookup $Computer.IPv4|Select-String -Pattern "^Name:\s+([^\.]+).*$"|
#    ForEach-Object{
#      $Computer.Computername = $_.Matches.Groups[1].Value
#    }
#}
#$Computers
##$Computers | Export-Csv $FileOut -NotypeInformation
#$Computers | Out-Gridview

### Create the pscredential object to pass to Invoke-Command
#$credential = Get-Credential
#
### Run the command on the remote computer
#Invoke-Command -ComputerName 192.168.1.134 -ScriptBlock { [System.Net.Dns]::GetHostName() } -Credential $credential