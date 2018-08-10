Configuration GroupPolicy {
    Import-DscResource -ModuleName xGroupPolicy
    
    Node $AllNodes.NodeName {
        xGPO RDSClient {
            Ensure = 'Present'
            Name = 'RDS Client Settings'
            Comment = 'Contains important settings for clients using the RDS enviromnent'
            Domain = 'rds.local'
        }

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

        xGPRegistryValueList AllowDefaultCredentials {
            Name = 'RDS Client Settings'
            Key = 'HKLM\Software\Policies\Microsoft\Windows\CredentialsDelegation\AllowDefaultCredentials'
            Value = 'TERMSRV/rdbroker.rds.local'
            Type = 'String'
            Additive = $true
        }
        
        xGPLink RDSClient {
            Ensure = 'Present'
            Name = 'RDS Client Settings'
            Target = 'dc=rds, dc=local'
            LinkEnabled = 'Yes'
            Enforced = 'No'
        }
    }
}

GroupPolicy -ConfigurationData "$PSScriptRoot\ConfigData.psd1" -PsDscRunAsCredential (Get-Credential)
Start-DscConfiguration GroupPolicy -Verbose -Wait -Force