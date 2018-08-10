Configuration GPLink {
    Import-DscResource -ModuleName xGroupPolicy
    
    Node $AllNodes.NodeName {
        xGPLink RDSClient {
            Ensure = 'Present'
            Name = 'RDS Client Settings'
            Target = 'dc=rds, dc=local'
            LinkEnabled = 'Yes'
            Enforced = 'No'
        }
    }
}

GPLink -ConfigurationData "$PSScriptRoot\ConfigData.psd1" -PsDscRunAsCredential (Get-Credential)
Start-DscConfiguration GPLink -Verbose -Wait -Force