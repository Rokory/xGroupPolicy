Configuration GroupPolicy {
    Import-DscResource -ModuleName xGroupPolicy
    
    Node $AllNodes.NodeName {
        xGPO RDSClient {
            Ensure = 'Absent'
            Name = 'RDS Client Settings'
            Domain = 'rds.local'
        }

        xGPO RDSServer {
            Ensure = 'Absent'
            Name = 'RDS Server Settings'
        }
    }
}

GroupPolicy -ConfigurationData "$PSScriptRoot\ConfigData.psd1" -PsDscRunAsCredential (Get-Credential)
Start-DscConfiguration GroupPolicy -Verbose -Wait -Force