# Create Temp Dir if not existing
if (!(Test-Path C:\Temp)) {
	md C:\Temp
}

## Turning off IE Enhanced Security for Prerequisties to be able to download files:
Write-Host "Disabling IE Enhanced Security Configuration (ESC)..."
$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
Stop-Process -Name Explorer

Start-Sleep -Seconds 30


$SP_img = "C:\Temp\officeserver.img"

# Installation log files
$errorOutputFile = "C:\Temp\ErrorOutput.txt"
$standardOutputFile = "C:\Temp\StandardOutput.txt"
#Removing old log files
Remove-Item -Path $errorOutputFile -Force -ErrorAction SilentlyContinue
Remove-Item -Path $standardOutputFile -Force -ErrorAction SilentlyContinue

Write-Host "Standard Output: $standardOutputFile"
Write-Host "Error Output: $errorOutputFile"

Write-Host "Mounting DiskImage and extracting Drive Letter..."

$MountedDriveLetter = Mount-DiskImage -ImagePath $SP_img -PassThru | 
						Get-Volume | 
						% {Get-PSDrive -Name $_.DriveLetter} | 
						% {$_.Root}

Write-Host "Mount Drive letter: $MountedDriveLetter"
Write-Host "Starting the installation of SharePoint Prerequisites...  "-ForegroundColor Green


Start-Process "$MountedDriveLetter\PrerequisiteInstaller.exe" `
			-ArgumentList "/continue /unattended" `
			-Wait `
			-RedirectStandardOutput $standardOutputFile `
			-RedirectStandardError $errorOutputFile

Start-Process "$MountedDriveLetter\setup.exe" -ArgumentList "/config C:\tmp\config_single.xml"

Dismount-DiskImage -ImagePath $SP_img

Write-Host "SharePoint Prerequisites are installed!, Please checks logs!"

