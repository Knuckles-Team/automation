# https://www.reddit.com/r/PowerShell/comments/gibag9/i_wrote_a_script_and_converted_it_to_an_exe_file/fqdwodg/
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$formHome                        = New-Object system.Windows.Forms.Form
$formHome.ClientSize             = '650,300'
$formHome.text                   = "STL Printers"
$formHome.TopMost                = $false

$items                           = New-Object system.Windows.Forms.ListBox
$items.text                      = "listBox"
$items.width                     = 175
$items.height                    = 150
$items.location                  = New-Object System.Drawing.Point(20,46)
$items.Sorted                    = $true
$items.ScrollAlwaysVisible       = $true
$items.SelectionMode             = [System.Windows.Forms.SelectionMode]::MultiExtended;

$items2                          = New-Object system.Windows.Forms.ListBox
$items2.text                     = "listBox"
$items2.width                    = 175
$items2.height                   = 150
$items2.location                 = New-Object System.Drawing.Point(220,46)
$items2.Sorted                   = $true
$items2.ScrollAlwaysVisible      = $true
$items2.SelectionMode            = [System.Windows.Forms.SelectionMode]::MultiExtended;

$items3                          = New-Object system.Windows.Forms.ListBox
$items3.text                     = "listBox"
$items3.width                    = 175
$items3.height                   = 150
$items3.location                 = New-Object System.Drawing.Point(430,46)
$items3.Sorted                   = $true
$items3.ScrollAlwaysVisible      = $true
$items3.SelectionMode            = [System.Windows.Forms.SelectionMode]::MultiExtended;

$btnGetItem                      = New-Object system.Windows.Forms.Button
$btnGetItem.text                 = "OK"
$btnGetItem.width                = 100
$btnGetItem.height               = 30
$btnGetItem.location             = New-Object System.Drawing.Point(200,250)
$btnGetItem.Font                 = 'Microsoft Sans Serif,10'

$btntwoGetItem                   = New-Object system.Windows.Forms.Button
$btntwoGetItem.text              = "CANCEL"
$btntwoGetItem.DialogResult      = [System.Windows.Forms.DialogResult]::Cancel
$btntwoGetItem.width             = 100
$btntwoGetItem.height            = 30
$btntwoGetItem.location          = New-Object System.Drawing.Point(330,250)
$btntwoGetItem.Font              = 'Microsoft Sans Serif,10'

$btnMap1GetItem                   = New-Object system.Windows.Forms.Button
$btnMap1GetItem.text              = "1st Floor Locations"
$btnMap1GetItem.width             = 175
$btnMap1GetItem.height            = 30
$btnMap1GetItem.location          = New-Object System.Drawing.Point(20,200)
$btnMap1GetItem.Font              = 'Microsoft Sans Serif,10'

$btnMap2GetItem                   = New-Object system.Windows.Forms.Button
$btnMap2GetItem.text              = "2nd Floor Locations"
$btnMap2GetItem.width             = 175
$btnMap2GetItem.height            = 30
$btnMap2GetItem.location          = New-Object System.Drawing.Point(220,200)
$btnMap2GetItem.Font              = 'Microsoft Sans Serif,10'

$btnMap3GetItem                   = New-Object system.Windows.Forms.Button
$btnMap3GetItem.text              = "3rd Floor Locations"
$btnMap3GetItem.width             = 175
$btnMap3GetItem.height            = 30
$btnMap3GetItem.location          = New-Object System.Drawing.Point(430,200)
$btnMap3GetItem.Font              = 'Microsoft Sans Serif,10'

$People                          = New-Object system.Windows.Forms.Label
$People.text                     = "First Floor Printers:"
$People.AutoSize                 = $true
$People.width                    = 25
$People.height                   = 10
$People.location                 = New-Object System.Drawing.Point(25,19)
$People.Font                     = 'Microsoft Sans Serif,10'

$People2                         = New-Object system.Windows.Forms.Label
$People2.text                    = "Second Floor Printers:"
$People2.AutoSize                = $true
$People2.width                   = 25
$People2.height                  = 10
$People2.location                = New-Object System.Drawing.Point(225,19)
$People2.Font                    = 'Microsoft Sans Serif,10'

$People3                         = New-Object system.Windows.Forms.Label
$People3.text                    = "Third Floor Printers:"
$People3.AutoSize                = $true
$People3.width                   = 25
$People3.height                  = 10
$People3.location                = New-Object System.Drawing.Point(435,19)
$People3.Font                    = 'Microsoft Sans Serif,10'

$formHome.Controls.AddRange(@($items,$items2,$items3,$People2,$People3,$btnGetItem,$btntwoGetItem,$btnMap1GetItem,$btnMap2GetItem,$btnMap3GetItem,$People))

$formHome.Add_Load({
    $items.Items.Add("STL127")
    $items2.Items.Add("STL101")
    $items3.Items.Add("STL102")
})

do {
$btnMap1GetItem.Add_Click({Invoke-Expression -command "start-process '\\network location for first floor picture'"})

$btnMap2GetItem.Add_Click({Invoke-Expression -command "start-process '\\network location for second floor picture'"})

$btnMap3GetItem.Add_Click({Invoke-Expression -command "start-process '\\network location for third floor picture'"})
} until ([System.Windows.Forms.DialogResult]::CANCEL)

$btnGetItem.Add_Click({
    foreach ($item in $items.SelectedItems)
    {
        if ($item -eq "STL127")
        {
             Invoke-Expression -Command "cmd.exe /c start\\network printer"

            msg /time:1 $env:UserName 'Success!'
        }}})

    $btnGetItem.Add_Click({
    foreach ($item in $items2.SelectedItems)
    {
        if ($item -eq "STL101")
        {
             Invoke-Expression -Command "cmd.exe /c start\\network printer"

            msg /time:1 $env:UserName 'Success!'
        }}})

    $btnGetItem.Add_Click({
    foreach ($item in $items3.SelectedItems)
    {
        if ($item -eq "STL102")
        {
            Invoke-Expression -Command "cmd.exe /c start\\network printer"

            msg /time:1 $env:UserName 'Success!'
        }
}
})

Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'
$consolePtr = [Console.Window]::GetConsoleWindow()
[Console.Window]::ShowWindow($consolePtr, 0)
msg /time:9 $env:UserName 'ATTN: To add a printer, click on the one you want followed by OK. To see where a printer is, click the location button under each list of printers. When you are finished adding printers, click CANCEL to exit.'
Start-Sleep 10

do {
$formHome.ShowDialog()
} until ([System.Windows.Forms.DialogResult]::CANCEL)