#https://oofhours.com/2020/05/13/the-most-useful-powershell-cmdlet-i-didnt-know-existed/
#https://www.educba.com/useful-powershell-scripts/
Get-ComputerInfo

Write-Host "Welcome to the script of fetching computer Information"
Write-host "The BIOS Details are as follows"
Get-CimInstance -ClassName Win32_BIOS

Write-Host "The systems processor is"
Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -Property SystemType

Write-Host "The computer Manufacture and physical memory details are as follows"
Get-CimInstance -ClassName Win32_ComputerSystem

Write-Host "The installed hotfixes are"
Get-CimInstance -ClassName Win32_QuickFixEngineering

Write-Host "The OS details are below"
Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -Property Build*,OSType,ServicePack*

Write-Host "The following are the users and the owners"
Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -Property *user*

Write-Host "The disk space details are as follows"
Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" |Measure-Object -Property FreeSpace,Size -Sum |Select-Object -Property Property,Sum

Write-Host "Current user logged in to the system"
Get-CimInstance -ClassName Win32_ComputerSystem -Property UserName

Write-Host "Status of the running services are as follows"
Get-CimInstance -ClassName Win32_Service | Format-Table -Property Status,Name,DisplayName -AutoSize -Wrap

function add_user_adgroup(){
    try
    {
        Import-Csv “C:\test\test.csv” | ForEach-Object {
        $Name = $_.Name + “test.com”
        New-ADUser `
        -DisplayName $_.”Dname” `
        -Name $_.”Name” `
        -GivenName $_.”GName” `
        -Surname $_.”Sname” `
        -SamAccountName $_.”Name” `
        -UserPrincipalName $UPName `
        -Office $_.”off” `
        -EmailAddress $_.”EAddress” `
        -Description $_.”Desc” `
        -AccountPassword (ConvertTo-SecureString “vig@123” -AsPlainText -force) `
        -ChangePasswordAtLogon $true `
        -Enabled $true `
        Add-ADGroupMember “OrgUsers” $_.”Name”;
        Write-Host "User created and added in the AD group"
    }
    }
    catch
    {
        $msge=$_.Exception.Message
        Write-Host "Exception is" $msge
    }

}

function delete_files_older_30days() {
    Write-Host "Welcome to the archive example"
    $csv = Import-Csv "C:\Vignesh\test.csv"
    foreach($row in $csv)
    {
        $Path=$row.Path
        write-host "The path to be archived is" $row.Path
        $DaysTOBeArchived = "-30"
        $CurrentDate = Get-Date
        $DatetoBeDeleted = $CurrentDate.AddDays($DaysTOBeArchived)
        Get-ChildItem $Path -Recurse  | Where-Object { $_.CreationTime  -lt $DatetoBeDeleted } | Remove-Item
        Write-Host "Cleared the files is the path "$row.path
    }
}

function send_email_disk_space_low(){
    $cname="Mycomputer"
    ForEach ($c in $cname)
    {
    $disk=Get-WmiObject win32_logicaldisk -ComputerName $c -Filter "Drivetype=3" -ErrorAction SilentlyContinue | Where-Object {($_.freespace/$_.size) -le '0.05'}
    If ($disk)
    {
    $EmailToAdd = "test@test.com"
    $EmailFromAdd = "test@test.com"
    $userdet = 'testuser'
    $passworddet = "testpwd"
    $Subjectdet = "Disk space alert"
    $Bodydet = "low space in the system"
    $SMTPServerdet = "testswer"
    $SMTPMessagedet = New-Object System.Net.Mail.MailMessage($EmailFromAdd,$EmailToAdd,$Subjectdet,$Bodydet)
    $SMTPClientdet = New-Object Net.Mail.SmtpClient($SMTPServerdet, 587)
    $ SMTPClientdet.EnableSsl = $true
    $ SMTPClientdet.Credentials = New-Object System.Net.NetworkCredential($userdet, $passworddet)
    $ SMTPClientdet.Send($SMTPMessagedet)
    }
    }
}










