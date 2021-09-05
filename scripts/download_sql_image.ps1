# Create Temp Dir if not existing
if (!(Test-Path C:\Temp)) {
	md C:\Temp
}

##########################
# Download SQL Server 2019
##########################

$url = 'https://download.microsoft.com/download/7/c/1/7c14e92e-bdcb-4f89-b7cf-93543e7112d1/SQLServer2019-x64-ENU-Dev.iso'
$SQLServer_ISO_Path = "C:\Temp\SQLServe2019.iso"
$start_time = Get-Date
Write-host  "Starting download at $start_time ... "
(New-Object System.Net.WebClient).DownloadFile($url, $SQLServer_ISO_Path)
Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"