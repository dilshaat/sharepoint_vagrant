
# Create Temp Dir if not existing
if (!(Test-Path C:\Temp)) {
	md C:\Temp
}

##########################
# Download SQL Server 2019
##########################

$url = 'https://download.microsoft.com/download/0/0/4/004EE264-7043-45BF-99E3-3F74ECAE13E5/officeserver.img'
$SP_img = "C:\Temp\officeserver.img"
$start_time = Get-Date
Write-host  "Starting download at $start_time ... "
(New-Object System.Net.WebClient).DownloadFile($url, $SP_img)
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"