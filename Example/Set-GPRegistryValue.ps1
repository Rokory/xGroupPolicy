Configuration GPRegistryValues {
    Import-DscResource -ModuleName xGroupPolicy
    
    Node $AllNodes.NodeName {
        xGPRegistryValue TrustedCertThumbprints {
            Name = 'RDS Client Settings'
            Key = 'HKLM\Software\Policies\Microsoft\Windows NT\Terminal Services'
            ValueName = 'TrustedCertThumbprints'
            Value = '‎378ab44a0ca50278636c0675cbf07964c0c4eead'
            Type = 'String'
        }

        xGPRegistryValue DefaultConnectionURL {
            Name = 'RDS Client Settings'
            Key = 'HKCU\Software\Policies\Microsoft\\Workspaces'
            ValueName = 'DefaultConnectionURL'
            Value = 'https://rdgateway.rds.local/rdweb/feed/webfeed.aspx'
            Type = 'String'
        }

        xGPRegistryValue NetCache {
            Name = 'RDS Server Settings'
            Key = 'HKLM\Software\Policies\Microsoft\Windows\NetCache'
            ValueName = 'Enabled'
            Type = 'Dword'
            Value = 0
        }
    }
}

GPRegistryValues -ConfigurationData "$PSScriptRoot\ConfigData.psd1" -PsDscRunAsCredential (Get-Credential)
Start-DscConfiguration GPRegistryValues -Verbose -Wait -Force