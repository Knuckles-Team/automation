# Create a self-signed cert with a long expiry and enable secure remote powershell with this cert:
#https://www.reddit.com/r/sysadmin/comments/67h8qn/what_is_the_most_useful_powershell_script_you/dgqqv15/
##
##    THIS SCRIPT MUST BE RUN AS ADMINISTRATOR ##
##

$downloadlink = "https://iisnetblogs.blob.core.windows.net/media/thomad/Media/SelfSSL7.zip"
$hostname = $env:computername

#Adding a function to unzip
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}


#Remove existing cert(s)
Write-Host "Existing certs"
Get-ChildItem -path cert:"LocalMachine\My" -dnsname $hostname
write-host "Is it ok to delete the above?"
pause

Get-ChildItem -path cert:"LocalMachine\My" -dnsname $hostname | remove-item

Write-Host "Remaining certs"
Get-ChildItem -path cert:"LocalMachine\My" -dnsname $hostname




#download and unzip SelfSSL7.exe
mkdir c:\temp
Invoke-WebRequest -uri $downloadlink -outfile c:\temp\selfssl7.zip
Unzip "c:\temp\selfssl7.zip" "c:\temp"

#create the new cert with 3000 days expiry
c:\temp\selfssl7 /Q /T /V 3000 /X /F c:\temp\$hostname.PFX

#cleanup
del  c:\temp\selfssl7.exe

#This script has to be run as Administrator, so we can't use the existing X: mapping and instead have to create one anew
#This is obv going to fail on DMZ machines that don't have access to the fileshare in which case we need to manually copy the cert
net use /y x: \\[fileshare]
move c:\temp\$hostname.PFX x:



#remove all powershell listeners
Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse

#Get the new cert
$cert = dir cert:\LocalMachine\My\ | ? { $_.subject -like "CN=$hostname" }

#create the new listener with the new cert, don't ask for permission
New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint -Force

#Show the listener, this should only be HTTPS
write-host "ONLY HTTPS SHOULD BE LISTED HERE:"
dir wsman:\localhost\listener | select Keys