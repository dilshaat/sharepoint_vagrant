Install-Windowsfeature 'AD-Domain-Services'

Import-Module ADDSDeployment
Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath "C:\\Windows\\NTDS" `
-DomainMode "WinThreshold" `
-DomainName "da.int" `
-DomainNetbiosName "DA" `
-ForestMode "WinThreshold" `
-InstallDns:$true `
-LogPath "C:\\Windows\\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "C:\\Windows\\SYSVOL" `
-Force:$true