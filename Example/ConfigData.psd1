@{
    AllNodes = @(
        # Common settings applicable to all nodes
        # These settings can be overridded by individual nodes.
        @{

            NodeName = '*'
            
            # DSC related
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser = $true
        }
        @{
            NodeName = 'localhost'
        }
    )
}
