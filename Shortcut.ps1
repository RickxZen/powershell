param (
 [system.string]$ShortcutName     = "Title",
 [system.string]$ShortcutUrl      = "https://url",
 [system.string]$IconURL          = "https://url/icon.ico",
 [system.string]$Desktop          = [Environment]::GetFolderPath("Desktop"),
 [system.string]$IntuneProgramDir = "$env:APPDATA\Intune",
 [System.String]$TempIcon         = "$IntuneProgramDir\icon.ico",
 [bool]$ShortcutOnDesktop         = $True,
 [bool]$ShortcutInStartMenu       = $True
)

#Test if icon is currently present, if so delete it so we can update it
$IconPresent = Get-ChildItem -Path $Desktop | Where-Object {$_.Name -eq "$ShortcutName.lnk"}
If ($null -ne $IconPresent)
{
 Remove-Item $IconPresent.VersionInfo.FileName -Force -Confirm:$False
}

$WScriptShell = New-Object -ComObject WScript.Shell

If ((Test-Path -Path $IntuneProgramDir) -eq $False)
{
    New-Item -ItemType Directory $IntuneProgramDir -Force -Confirm:$False
}

#Start download of the icon in blob storage
Start-BitsTransfer -Source $IconURL -Destination $TempIcon

if ($ShortcutOnDesktop)
{
 $Shortcut = $WScriptShell.CreateShortcut("$Desktop\$ShortcutName.lnk")
 $Shortcut.TargetPath = $ShortcutUrl
 $Shortcut.IconLocation = $TempIcon
 $Shortcut.Save()
}

if ($ShortCutInStartMenu)
{
 $Shortcut = $WScriptShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\$ShortcutName.lnk")
 $Shortcut.TargetPath = $ShortcutUrl
 $Shortcut.IconLocation = $TempIcon
 $Shortcut.Save()
}