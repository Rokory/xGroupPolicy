Configuration GPRegistryValues {
    Import-DscResource -ModuleName xGroupPolicy
    
    Node $AllNodes.NodeName {
        xGPRegistryValueList AllowDefaultCredentials {
            Name = 'RDS Client Settings'
            Key = 'HKLM\Software\Policies\Microsoft\Windows\CredentialsDelegation\AllowDefaultCredentials'
            Value = 'TERMSRV/rdbroker.rds.local'
            Type = 'String'
            Additive = $true
        }
    }
}

GPRegistryValues -ConfigurationData "$PSScriptRoot\ConfigData.psd1" -PsDscRunAsCredential (Get-Credential)
Start-DscConfiguration GPRegistryValues -Verbose -Wait -Force