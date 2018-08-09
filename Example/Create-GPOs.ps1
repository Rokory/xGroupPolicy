Configuration GroupPolicy {
    Import-DscResource -ModuleName xGroupPolicy
    
    Node $AllNodes.NodeName {
        xGPO RDSClient {
            Ensure = 'Present'
            Name = 'RDS Client Settings'
            Comment = 'Contains important settings for clients using the RDS enviromnent'
            Domain = 'rds.local'
        }

        xGPO RDSServer {
            Name = 'RDS Server Settings'
            Comment = 'Contains important settings for servers in the RDS enviromnent'
        }
    }
}

GroupPolicy -ConfigurationData "$PSScriptRoot\ConfigData.psd1" -PsDscRunAsCredential (Get-Credential)
Start-DscConfiguration GroupPolicy -Verbose -Wait -Force