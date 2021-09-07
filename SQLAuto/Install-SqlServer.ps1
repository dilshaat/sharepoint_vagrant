[CmdletBinding(DefaultParameterSetName = 'Online')]
param(
	### Mandatory Parameter to determine 
	### Which SQL Server version to install
	[Parameter(Mandatory=$True, ParameterSetName="Online")]
	[Parameter(Mandatory=$True, ParameterSetName="Local")]
	[ValidateSet("2012", "2014", "2016", "2017", "2019")]
	[string]$SQLVersion,

	### INI configuration file path
	### Must be a local path or SBM share path
	### No needed in general as default standard
	### Configuration.ini files are built for each version
	### only if the user intends to provide customized installation
	[Parameter(Mandatory=$False, ParameterSetName="Online")]
	[Parameter(Mandatory=$False, ParameterSetName="Local")]
	[string]$ConfigFile,

	### Usually not needed as 'Configuration.ini' file is standard
	### and it contains most/all SQL server installation parameters
	### Unless user wants to override the configuration in INI file
	### Example: /SecurityMode='Windows' 
	### /PID="SQL server Product Key"
	[Parameter(Mandatory=$False, ParameterSetName="Online")]
	[Parameter(Mandatory=$False, ParameterSetName="Local")]
	[string]$OverrideConfigs,
	
	# Online Download ParameterSet
	[Parameter(Mandatory=$False, ParameterSetName="Online")]
	[string]$DownloadLinkISO,
	# Local Install ParameterSet
	[Parameter(Mandatory=$False, ParameterSetName="Local")]
	[string]$LocalPathISO
)

if ($SQLVersion -eq 2014 -or $SQLVersion -eq 2012) {
	$Net35State = (get-WindowsFeature -Name 'NET-Framework-Core')."InstallState"
	if ($Net35State -ne 'Installed') {
		Write-Warning "SQL Server $SqlVersion has dependencies on .NET Framework 3.5 SP1 and it is not installed on this machine."
		Write-Warning "Trying to install it..., your computer might restart."
		Install-WindowsFeature -Name 'NET-Framework-Core' -Restart
		$Net35State = (get-WindowsFeature -Name 'NET-Framework-Core')."InstallState"
		if ($Net35State -eq "Installed") {
			Write-Host ".NET Framework 3.5 SP1 is installed successfuly. Moving on to install SQL Server $SqlVersion."
		} else {
			throw "Something went wrong during .NET Framework 3.5 installation. It might be the Network issue, Windows being unable to download. Please Install .NET 3.5 maually and try reinstall SQL Server $SqlServer." 
		}
	} else {
		Write-Host ".NET Framework 3.5 detected, moving on to install SQL Server..."
	}
}

if ($PSCmdlet.ParameterSetName -eq "Online") {
	Write-Host "Online download option is chosen by you." -ForegroundColor Magenta
	Write-Host "An Internet connection or valid internal HTTP connection is required" -ForegroundColor Magenta
	Write-Host "If supplied a link in the 'DownloadLinkISO' parameter, this script will try to download it." -ForegroundColor Magenta
	Write-Host "If no link provided, a default link to the chosen version is used to download the ISO file."
} else {
	Write-Host "Local Image installation is chosen by you." -ForegroundColor Magenta
	Write-Host "A valid Image ISO file either from this machine or a network share location is required." -ForegroundColor Magenta
}



### Local Configuration Files for all Sql server versions
$Config2012 = Join-Path $PSScriptRoot "ConfigurationFile2012.ini"
$Config2014 = Join-Path $PSScriptRoot "ConfigurationFile2014.ini"
$Config2016 = Join-Path $PSScriptRoot "ConfigurationFile2016.ini"
$Config2017 = Join-Path $PSScriptRoot "ConfigurationFile2017.ini"
$Config2019 = Join-Path $PSScriptRoot "ConfigurationFile2019.ini"

### Download links for all SQL Server versions
$Link2012 = "https://download.microsoft.com/download/3/B/D/3BD9DD65-D3E3-43C3-BB50-0ED850A82AD5/SQLServer2012SP1-FullSlipstream-ENU-x64.iso"
$Link2014 = "http://download.microsoft.com/download/7/9/F/79F4584A-A957-436B-8534-3397F33790A6/SQLServer2014SP3-FullSlipstream-x64-ENU.iso"
$Link2016 = "https://download.microsoft.com/download/4/1/A/41AD6EDE-9794-44E3-B3D5-A1AF62CD7A6F/sql16_sp2_dlc/en-us/SQLServer2016SP2-FullSlipstream-x64-ENU-DEV.iso"
$Link2017 = "https://download.microsoft.com/download/E/F/2/EF23C21D-7860-4F05-88CE-39AA114B014B/SQLServer2017-x64-ENU-Dev.iso"
$Link2019 = 'https://download.microsoft.com/download/7/c/1/7c14e92e-bdcb-4f89-b7cf-93543e7112d1/SQLServer2019-x64-ENU-Dev.iso'

switch ($SQLVersion) {
	"2012" {  
		if ($ConfigFile -eq "" -or $null -eq $ConfigFile) {
			$ConfigFile = $Config2012
		}
		$ISOFileName = $Link2012.Split('/')[-1]
		$Link = $Link2012
	}

	"2014" {  
		if ($ConfigFile -eq "" -or $null -eq $ConfigFile) {
			$ConfigFile = $Config2014
		}
		$ISOFileName = $Link2014.Split('/')[-1]
		$Link = $Link2014
	}

	"2016" {  
		if ($ConfigFile -eq "" -or $null -eq $ConfigFile) {
			$ConfigFile = $Config2016
		}
		$ISOFileName = $Link2016.Split('/')[-1]
		$Link = $Link2016
	}

	"2017" {  
		if ($ConfigFile -eq "" -or $null -eq $ConfigFile) {
			$ConfigFile = $Config2017
		}
		$ISOFileName = $Link2017.Split('/')[-1]
		$Link = $Link2017
	}

	"2019" {  
		if ($ConfigFile -eq "" -or $null -eq $ConfigFile) {
			$ConfigFile = $Config2019
		}
		$ISOFileName = $Link2019.Split('/')[-1]
		$Link = $Link2019
	}

	Default {
		throw "No valid SQL Server version is provided."
	}
}

$MediaFolder = Join-Path $PSScriptRoot "MediaFiles"
$MediaFilePath = Join-Path $MediaFolder $ISOFileName

if ($PSCmdlet.ParameterSetName -eq 'Online') {
	### When http download link is provided
	### checking if the machine can reach the link via internet/intranet
	if ($DownloadLinkISO -ne "") {
		$HttpStatus = (Invoke-WebRequest -Method Head -Uri $DownloadLinkISO -ErrorAction SilentlyContinue).StatusCode
		if ($HttpStatus -ne 200) {
			throw "The link $DownloadLinkISO is NOT reachable please check network status or check the link provided is correct."
		} else {
			Write-Host "The link $DownloadLinkISO is reachable, downloading to $MediaFilePath..."
			$Link = $DownloadLinkISO
		}
	} else {
		Write-Host "Downaloding the SQL Server $SqlVersion from Internet/Intranet:" -ForegroundColor Green
		Write-Host "using link: $Link"
	}
	
	$StartTime = Get-Date
	(New-Object System.Net.WebClient).DownloadFile($Link, $MediaFilePath)
	$EndTime = Get-Date
	Write-Host "Time Taken to download the ISO file: $(($EndTime.Subtract($StartTime)).Seconds) second(s)"
}

if ($PSCmdlet.ParameterSetName -eq 'Local') {
	if ($LocalPathISO -eq '' -or $null -eq $LocalPathISO) {
		throw "The path provided is an empty string or null value."
	} 
	if (!(Test-Path $LocalPathISO)) {
		throw "The path provided is not reachable, please confirm the path is correct and reachable by this machine $env:COMPUTERNAME."
	} 
	Write-Host "Copying the ISO file pointed by you to this project folder:"
	Write-Host "From: '$LocalPathISO' To: $MediaFilePath ..."
	$StartTime = Get-Date
	Copy-Item -Path $LocalPathISO -Destination $MediaFilePath
	$EndTime = Get-Date
	Write-Host "Time Taken to copy the ISO file: $(($EndTime.Subtract($StartTime)).Seconds) second(s)"
}

### All required configurations and paths are obtained 
### Starting installation
$errorOutputFile = Join-Path $PSScriptRoot "Logs\ErrorOutput.txt"
$standardOutputFile = Join-Path $PSScriptRoot "Logs\StandardOutput.txt"
#Removing old log files
Remove-Item -Path $errorOutputFile -Force -ErrorAction SilentlyContinue
Remove-Item -Path $standardOutputFile -Force -ErrorAction SilentlyContinue

Write-Host "Configuration File: $ConfigFile"
Write-Host "Standard output file: $standardOutputFile"
Write-Host "Standard error output file: $errorOutputFile"

Write-Host "Mounting DiskImage and extracting Drive Letter..." -ForegroundColor Magenta

$MountedDriveLetter = Mount-DiskImage -ImagePath $MediaFilePath -PassThru | 
						Get-Volume | 
						% {Get-PSDrive -Name $_.DriveLetter} | 
						% {$_.Root}

Write-Host "Mount Drive letter: $MountedDriveLetter"
Write-Host "Starting the installation of SQL Server..." -ForegroundColor Green
Start-Process "$MountedDriveLetter\setup.exe" `
			 -ArgumentList "/ConfigurationFile=$ConfigFile $OverrideConfigs" `
			 -Wait `
			 -RedirectStandardOutput $standardOutputFile `
			 -RedirectStandardError $errorOutputFile

Write-Host "Dismounting the drive."
Dismount-DiskImage -ImagePath $MediaFilePath

Get-Service *sql*

$env:Path += ";C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn" # 2019
$env:path += ";C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\130\Tools\Binn" # 2017
$env:path += ";C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\110\Tools\Binn" # 2014 2016
$env:path += ";C:\Program Files\Microsoft SQL Server\110\Tools\Binn" # 2012

& SQLCMD.EXE -S $env:COMPUTERNAME -Q "SELECT @@VERSION"

Write-Host "Installation Complete, if you see SQL Server service status and version infomation above"
Write-Host "Then the installation was successful!!!"
