# Perform Disk Clean Up
# https://winaero.com/cleanmgr-exe-command-line-arguments-in-windows-10/
# https://www.theservergeeks.com/how-todisk-cleanup-using-powershell/

$HKLM = [UInt32] "0x80000002"
$strKeyPath = "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
$strValueName = "StateFlags0065"

#gci -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches -Name
$subkeys = gci -Path HKLM:\$strKeyPath -Name
$subkeys = $subkeys[0]

#Start-Process cleanmgr -ArgumentList “/VERYLOWDISK” -Wait -NoNewWindow -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

$subkeys = gci -Path HKLM:\$strKeyPath -Name
ForEach ($subkey in $subkeys) {
Try {
New-ItemProperty -Path HKLM:\$strKeyPath\$subkey -Name $strValueName -PropertyType DWord -Value 2 -ErrorAction SilentlyContinue| Out-Null
}
Catch {
}
try {
Start-Process cleanmgr -ArgumentList “/sagerun:65” -Wait -NoNewWindow -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
}
catch {
}
}
ForEach ($subkey in $subkeys) {
Try {
Remove-ItemProperty -Path HKLM:\$strKeyPath\$subkey -Name $strValueName | Out-Null
}
Catch {
}
}