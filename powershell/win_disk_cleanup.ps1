# Perform Disk Clean Up

$VerbosePreference="Continue"

#more info here:
#http://support.microsoft.com/kb/253597

#ensure we're running on windows 10.X.XXXX first
if ((Get-CimInstance win32_operatingsystem).version.substring(0, 2) -eq '10') {
  # Set all the CLEANMGR registry entries for Group #64
  $GroupNo="StateFlags0013"
  $RootKey="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
  #Capture current free disk space on Drive C
  $FreespaceBefore = (Get-WmiObject win32_logicaldisk -filter "DeviceID='C:'" | Select-Object Freespace).FreeSpace/1GB

  #Set StateFlags0012 setting for each item in Windows 10 disk cleanup utility
  if(-not (Get-ItemProperty -path "$RootKey\Active Setup Temp Folders" -name $GroupNo -ErrorAction SilentlyContinue)) {
    # Active Setup Temp Folders
    try{
      "Setting Active Setup Temp Folders to Registry..."
      Set-ItemProperty -path "$RootKey\Active Setup Temp Folders" -name $GroupNo -type DWORD -Value 2
      "Set Active Setup Temp Folders to Registry Successfully"
    }
    catch{
      "Could not Find Registry Value: Adding Active Setup Temp Folders to Registry"
      REG ADD "$RootKey\Active Setup Temp Folders" /v $GroupNo /t REG_DWORD /d 00000002 /f
      "Successfully Added Registry Value"
    }
    # Branch Cache (WAN bandwidth optimization)
    try{
      "Setting Branch Cache to Registry"
      Set-ItemProperty -path "$RootKey\BranchCache" -name $GroupNo -type DWORD -Value 2
    }
    catch{
      "Adding Branch Cache to Registry"
      REG ADD "$RootKey\Branch Cache" /v $GroupNo /t REG_DWORD /d 00000002 /f
    }
    try{
      Set-ItemProperty -path "$RootKey\Content Indexer Cleaner" -name $GroupNo -type DWORD -Value 2
    }
    catch{
      # Catalog Files for the Content Indexer (deletes all files in the folder c:\catalog.wci)
      REG ADD "$RootKey\Content Indexer Cleaner" /v $GroupNo /t REG_DWORD /d 00000002 /f
    }
    try{
      Set-ItemProperty -path "$RootKey\D3D Shader Cache" -name $GroupNo -type DWORD -Value 2
    }
    catch{
    # Direct X Shader cache (graphics cache, clearing this can can speed up application load time.)
      REG ADD "$RootKey\D3D Shader Cache" /v $GroupNo /t REG_DWORD /d 00000002 /f
    }
    try{
      Set-ItemProperty -path "$RootKey\Delivery Optimization Files" -name $GroupNo -type DWORD -Value 2
    }
    catch{
    # Delivery Optimization Files (service to share bandwidth for uploading Windows updates)
    #   REG ADD "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Delivery Optimization Files" /v StateFlags0012 /t REG_DWORD /d 00000002 /f
      REG ADD "$RootKey\Delivery Optimization Files" /v $GroupNo /t REG_DWORD /d 00000002 /f
    }
    try{
      Set-ItemProperty -path "$RootKey\Device Driver Packages" -name $GroupNo -type DWORD -Value 2
    }
    catch{
      REG ADD "$RootKey\Device Driver Packages" /v $GroupNo /t REG_DWORD /d 00000002
    }
    try{
      Set-ItemProperty -path "$RootKey\Diagnostic Data Viewer database files" -name $GroupNo -type DWORD -Value 2
    }
    catch{
    # Diagnostic data viewer database files (Windows app that sends data to Microsoft)
      REG ADD "$RootKey\Diagnostic Data Viewer database Files" /v $GroupNo /t REG_DWORD /d 00000002 /f
    }
    try{
      Set-ItemProperty -path "$RootKey\Downloaded Program Files" -name $GroupNo -type DWORD -Value 2
    }
    catch{
    # Downloaded Program Files (ActiveX controls and Java applets downloaded from the Internet)
      REG ADD "$RootKey\Downloaded Program Files" /v $GroupNo /t REG_DWORD /d 00000002 /f
    }
    try{
      Set-ItemProperty -path "$RootKey\DownloadsFolder" -name $GroupNo -type DWORD -Value 2
    }
    catch{
    # Downloads Folder (Automatically emptying this is probably a bad idea.)
      REG ADD "$RootKey\Downloads Folder" /v $GroupNo /t REG_DWORD /d 00000002
    }
    try{
      Set-ItemProperty -path "$RootKey\Internet Cache Files" -name $GroupNo -type DWORD -Value 2
    }
    catch{
    # Temporary Internet Files
      REG ADD "$RootKey\Internet Cache Files" /v $GroupNo /t REG_DWORD /d 00000003 /f
    }
    #  try{
    #    #  Set-ItemProperty -path "$RootKey\Language Pack" -name $GroupNo -type DWORD -Value 2
    #  }
    #  catch{
    #    # Language resources Files (unused languages and keyboard layouts)
    #    #  REG ADD "$RootKey\Language Pack" /v $GroupNo /t REG_DWORD /d 00000002
    #  }
    try{
      Set-ItemProperty -path "$RootKey\Offline Pages Files" -name $GroupNo -type DWORD -Value 2
    }
    catch{
    # Offline Files (Web pages)
      REG ADD "$RootKey\Offline Pages Files" /v $GroupNo /t REG_DWORD /d 00000002 /f
    }
    try{
      Set-ItemProperty -path "$RootKey\Old ChkDsk Files" -name $GroupNo -type DWORD -Value 2
    }
    catch{
    # Old ChkDsk Files
      REG ADD "$RootKey\Old ChkDsk Files" /v $GroupNo /t REG_DWORD /d 00000002 /f
    }
    try{
      Set-ItemProperty -path "$RootKey\Previous Installations" -name $GroupNo -type DWORD -Value 2
    }
    catch{
      REG ADD "$RootKey\Previous Installations" /v $GroupNo /t REG_DWORD /d 00000002
    }
    try{
      Set-ItemProperty -path "$RootKey\Recycle Bin" -name $GroupNo -type DWORD -Value 2
    }
    catch{
    # Recycle Bin
      REG ADD "$RootKey\Recycle Bin" /v $GroupNo /t REG_DWORD /d 00000002 /f
    }
    try{
      Set-ItemProperty -path "$RootKey\RetailDemo Offline Content" -name $GroupNo -type DWORD -Value 2
    }
    catch{
    # Retail Demo
      REG ADD "$RootKey\RetailDemo Offline Content" /v $GroupNo /t REG_DWORD /d 00000002 /f
    }
    #  try{
    #      Set-ItemProperty -path "$RootKey\Service Pack Cleanup" -name $GroupNo -type DWORD -Value 2
    #  }
    #  catch{
    #    # Update package Backup Files (old versions)
    #      REG ADD "$RootKey\ServicePack Cleanup" /v $GroupNo /t REG_DWORD /d 00000002 /f
    #  }
    try{
      Set-ItemProperty -path "$RootKey\Setup Log Files" -name $GroupNo -type DWORD -Value 2
    }
    catch{
    # Setup Log files (software install logs)
      REG ADD "$RootKey\Setup Log Files" /v $GroupNo /t REG_DWORD /d 00000002 /f
    }
    try{
      Set-ItemProperty -path "$RootKey\System error memory dump files" -name $GroupNo -type DWORD -Value 2
    }
    catch{
    # System Error memory dump files (These can be very large if the system has crashed)
      REG ADD "$RootKey\System error memory dump files" /v $GroupNo /t REG_DWORD /d 00000002 /f
    }
    try{
      Set-ItemProperty -path "$RootKey\System error minidump files" -name $GroupNo -type DWORD -Value 2
    }
    catch{
    # System Error minidump files (smaller memory crash dumps)
      REG ADD "$RootKey\System error minidump files" /v $GroupNo /t REG_DWORD /d 00000002 /f
    }
    try{
      Set-ItemProperty -path "$RootKey\Temporary Files" -name $GroupNo -type DWORD -Value 2
    }
    catch{
    # Temporary Files (%Windir%\Temp and %Windir%\Logs)
      REG ADD "$RootKey\Temporary Files" /v $GroupNo /t REG_DWORD /d 00000002 /f
    }
    try{
      Set-ItemProperty -path "$RootKey\Temporary Setup Files" -name $GroupNo -type DWORD -Value 2
    }
    catch{
      REG ADD "$RootKey\Temporary Setup Files" /v $GroupNo /t REG_DWORD /d 00000002
    }
    try{
      Set-ItemProperty -path "$RootKey\Temporary Sync Files" -name $GroupNo -type DWORD -Value 2
    }
    catch{
      REG ADD "$RootKey\Temporary Sync Files" /v $GroupNo /t REG_DWORD /d 00000002
    }
    try{
      Set-ItemProperty -path "$RootKey\Thumbnail Cache" -name $GroupNo -type DWORD -Value 2
    }
    catch{
    # Thumbnails (Explorer will recreate thumbnails as each folder is viewed.)
      REG ADD "$RootKey\Thumbnail Cache" /v $GroupNo /t REG_DWORD /d 00000002 /f
    }
    try{
      Set-ItemProperty -path "$RootKey\Update Cleanup" -name $GroupNo -type DWORD -Value 2
    }
    catch{
    # Windows Update Cleanup (old system files not migrated during a Windows Upgrade)
      REG ADD "$RootKey\Update Cleanup" /v $GroupNo /t REG_DWORD /d 00000002 /f
    }
    try{
      Set-ItemProperty -path "$RootKey\Upgrade Discarded Files" -name $GroupNo -type DWORD -Value 2
    }
    catch{
      REG ADD "$RootKey\Upgrade Discard Files" /v $GroupNo /t REG_DWORD /d 00000002
    }
    try{
      Set-ItemProperty -path "$RootKey\User file versions" -name $GroupNo -type DWORD -Value 2
    }
    catch{
    # User file history (Settings > Update & Security > Backup.)
      REG ADD "$RootKey\User file versions" /v $GroupNo /t REG_DWORD /d 00000002 /f
    }
    try{
      Set-ItemProperty -path "$RootKey\Windows Defender" -name $GroupNo -type DWORD -Value 2
    }
    catch{
    # Windows Defender Antivirus
      REG ADD "$RootKey\Windows Defender" /v $GroupNo /d 2 /t REG_DWORD /f
    }
    try{
      Set-ItemProperty -path "$RootKey\Windows Error Reporting Files" -name $GroupNo -type DWORD -Value 2
    }
    catch{
    # Windows error reports and feedback diagnostics
      REG ADD "$RootKey\Windows Error Reporting Files" /v $GroupNo /t REG_DWORD /d 00000002 /f
    }
    #  try{
    #      Set-ItemProperty -path "$RootKey\Windows ESD installation files" -name $GroupNo -type DWORD -Value 2
    #  }
    #  catch{
    #    #Don"t clean up this unless you are prepared to Download & re-activate Windows if it crashes.
    #    ##  REG ADD "$RootKey\Windows ESD installation files" /v $GroupNo /t REG_DWORD /d 00000002 /f
    #  }
    try{
      Set-ItemProperty -path "$RootKey\Windows Upgrade Log Files" -name $GroupNo -type DWORD -Value 2
    }
    catch{
      # Windows Upgrade log files
      REG ADD "$RootKey\Windows Upgrade Log Files" /v $GroupNo /t REG_DWORD /d 00000002 /f
    }
  }
  $sagerun = ($GroupNo).substring($GroupNo.get_Length()-2)
  "SAGE RUN: $sagerun "
  cleanmgr /sagerun:$sagerun
  #Start-Process cleanmgr -ArgumentList “/sagerun:$sagerun” -Wait -NoNewWindow -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

  #Get-Process -Name cleanmgr,dismhost -ErrorAction SilentlyContinue | Wait-Process
  do {
    "waiting for cleanmgr to complete..."
    Start-Sleep 5
  } while ((get-wmiobject win32_process | Where-Object {$_.processname -eq "cleanmgr.exe"} | Measure-Object).count)

  $FreespaceAfter = (Get-WmiObject win32_logicaldisk -filter "DeviceID='C:'" | Select-Object Freespace).FreeSpace/1GB

  "Free Space Before: {0}" -f $FreespaceBefore
  "Free Space After: {0}" -f $FreespaceAfter

}