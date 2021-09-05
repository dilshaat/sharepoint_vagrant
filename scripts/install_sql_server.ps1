# Create Temp Dir if not existing
if (!(Test-Path C:\Temp)) {
	md C:\Temp
}

############################
# Installing SQL Server 2019
############################

$SQLServer_ISO_Path = "C:\Temp\SQLServe2019.iso"
# Silent Install Configuratin File
$ConfigurationINI = "$env:HOMEDRIVE$env:HOMEPATH\Downloads\Configuration.ini"
# Installation log files
$errorOutputFile = "C:\Temp\ErrorOutput.txt"
$standardOutputFile = "C:\Temp\StandardOutput.txt"
#Removing old log files
Remove-Item -Path $errorOutputFile -Force -ErrorAction SilentlyContinue
Remove-Item -Path $standardOutputFile -Force -ErrorAction SilentlyContinue

Write-Host "Configuration File: $ConfigurationINI"
Write-Host "Standard Output: $standardOutputFile"
Write-Host "Error Output: $errorOutputFile"

Write-Host "Mounting DiskImage and extracting Drive Letter..."

$MountedDriveLetter = Mount-DiskImage -ImagePath $SQLServer_ISO_Path -PassThru | 
						Get-Volume | 
						% {Get-PSDrive -Name $_.DriveLetter} | 
						% {$_.Root}
Write-Host "Mount Drive letter: $MountedDriveLetter"
Write-Host "Starting the installation of SQL Server..." -ForegroundColor Green
Start-Process "$MountedDriveLetter\setup.exe" `
			 -ArgumentList "/ConfigurationFile=$ConfigurationINI" `
			 -Wait `
			 -RedirectStandardOutput $standardOutputFile `
			 -RedirectStandardError $errorOutputFile

Write-Host "Dismounting the drive."
Dismount-DiskImage -ImagePath $SQLServer_ISO_Path

Write-Host "Standard Installing log is here: $standardOutputFile"
Write-Host "Standard Error log is here: $errorOutputFile"

Get-Service *sql*

$env:Path += ";C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn"

& SQLCMD.EXE -S $env:COMPUTERNAME -Q "SELECT @@VERSION"

Write-Host "If no red text then SQL Server Successfully Installed!"