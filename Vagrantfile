AD_Hostname = "DC1AD1"
SP_Hostname = "SharePoint"
SQL_Hostname = "SQLServer"
Search_Hostname = "SPSearch"
CA_Hostname = "CA"
Cache_Hostnem = "SPCache"


$script_join_domain = <<-EOF
$pw = ConvertTo-SecureString -String 'vagrant' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential('vagrant', $pw)
Add-Computer -DomainName 'da.int' -Credential $cred -Restart
EOF

$script_fw_off = <<-EOF
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Set-DnsClientServerAddress -InterfaceAlias 'Ethernet 2' -ServerAddresses ('192.168.85.100')
EOF

$script_ad = <<-EOF
Install-Windowsfeature 'AD-Domain-Services' -IncludeAllSubFeature -IncludeManagementTools
$pw = ConvertTo-SecureString -String '0Password1' -AsPlainText -Force
Import-Module ADDSDeployment
Install-ADDSForest `
-CreateDnsDelegation:$false `
-DatabasePath "C:\\Windows\\NTDS" `
-DomainMode "WinThreshold" `
-DomainName "da.int" `
-DomainNetbiosName "DA" `
-ForestMode "Windows2012R2" `
-InstallDns:$true `
-LogPath "C:\\Windows\\NTDS" `
-NoRebootOnCompletion:$false `
-SysvolPath "C:\\Windows\\SYSVOL" `
-Force:$true `
-SafeModeAdministratorPassword $pw

# Install-WindowsFeature -IncludeAllSubFeature RSAT
EOF

Vagrant.configure("2") do |config|

  config.vm.define "ad" do |ad|
    ad.vm.box = "peru/windows-server-2019-standard-x64-eval"
    ad.vm.network "private_network", ip: "192.168.85.100"
    ad.vm.provision "shell", privileged: "true", inline: $script_fw_off
    ad.vm.provision "shell", privileged: "true", inline: $script_ad
    ad.vm.hostname = "#{AD_Hostname}"
    ad.vm.provider "virtualbox" do |v|
      v.name = "Domain Controller"
      v.cpus = 2
      v.memory = 2048
      v.gui = false
    end
  end
  
  config.vm.define "app" do |app|
    app.vm.box = "peru/windows-server-2019-standard-x64-eval"
    app.vm.hostname = "#{SP_Hostname}"
    app.vm.network "private_network", ip: "192.168.85.103"
    # app.vm.provision "file", source: "./files/officeserver.img", destination: "~/Downloads/officeserver.img"
    app.vm.provision "shell", privileged: "true", inline: $script_fw_off
    app.vm.provision "shell", privileged: "true", inline: $script_join_domain
    app.vm.provision "shell", privileged: "true", path: "./scripts/download_SP2016.ps1"
    app.vm.provision "shell", privileged: "true", path: "./scripts/install_sharepoint2016.ps1"
    app.vm.provider "virtualbox" do |v|
      v.name = "AppServer"
      v.cpus = 4
      v.memory = 2048
      v.gui = false
    end
  end

  config.vm.define 'sql' do |sql|
    sql.vm.box = "peru/windows-server-2019-standard-x64-eval"
    sql.vm.hostname = "#{SQL_Hostname}"
    sql.vm.network "private_network", ip: "192.168.85.101"
    sql.vm.provision "shell", privileged: "true", inline: $script_fw_off
    sql.vm.provision "shell", privileged: "true", inline: $script_join_domain
    sql.vm.provision "file", source: "./scripts/Configuration.ini", destination: "~/Downloads/Configuration.ini"
    sql.vm.provision "shell", privileged: "true", path: "./scripts/download_sql_image.ps1"
    sql.vm.provision "shell", privileged: "true", path: "./scripts/install_sql_server.ps1"
    sql.vm.network "forwarded_port", guest: 1433, host: 1437
    sql.vm.provider "virtualbox" do |v|
      v.name = "SQLServer"
      v.cpus = 4
      v.memory = 2048
      v.gui = false
    end
  end
  
  config.vm.define "ca" do |ca|
    ca.vm.box = "peru/windows-server-2019-standard-x64-eval"
    ca.vm.hostname = "#{CA_Hostname}"
    ca.vm.network "private_network", ip: "192.168.85.104"
    ca.vm.provision "shell", privileged: "true", inline: $script_fw_off
    ca.vm.provision "shell", privileged: "true", inline: $script_join_domain
    ca.vm.provider "virtualbox" do |v|
      v.name = "Cert Auth"
      v.cpus = 2
      v.memory = 2048
      v.gui = false
    end
  end

  config.vm.define "cache" do |cache|
    cache.vm.box = "peru/windows-server-2019-standard-x64-eval"
    cache.vm.hostname = "#{Cache_Hostnem}"
    cache.vm.network "private_network", ip: "192.168.85.105"
    cache.vm.provision "shell", privileged: "true", inline: $script_fw_off
    cache.vm.provision "shell", privileged: "true", inline: $script_join_domain
    cache.vm.provider "virtualbox" do |v|
      v.name = "Cache Server"
      v.cpus = 2
      v.memory = 2048
      v.gui = false
    end
  end

  config.vm.define "search" do |search|
    search.vm.box = "peru/windows-server-2019-standard-x64-eval"
    search.vm.hostname = "#{Search_Hostname}"
    search.vm.network "private_network", ip: "192.168.85.106"
    search.vm.provision "shell", privileged: "true", inline: $script_fw_off
    search.vm.provision "shell", privileged: "true", inline: $script_join_domain
    search.vm.provider "virtualbox" do |v|
      v.name = "Search Server"
      v.cpus = 2
      v.memory = 2048
      v.gui = false
    end
  end
end