function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $Key,

        [parameter(Mandatory = $true)]
        [System.String]
        $ValueName,

        [System.String]
        $Domain
    )

    # Remove domain parameter if not specified

    if ([string]::IsNullOrWhiteSpace($Domain)) {
        $PSBoundParameters.Remove('Domain')
    }
    
    Write-Verbose "Getting GPO registry value $ValueName from $Key..."

    $gPRegistryvalue = Get-GPRegistryValue @PSBoundParameters -ErrorAction SilentlyContinue

    if ($gPRegistryvalue.PolicyState -eq 'Set') {
        $disable = $false
    }

    if ($gPRegistryvalue.PolicyState -eq 'Delete') {
        $disable = $true
    }

    $returnValue = @{
        Name = $Name
        Key = $gPRegistryvalue.FullKeyPath
        ValueName = $gPRegistryvalue.ValueName
        Value = $gPRegistryvalue.Value
        Type = $gPRegistryvalue.Type
        Domain = $Domain
        Disable = $disable
    }

    $returnValue
}

function Convert-Value {
    param(
        [System.String[]]
        $Value,

        [ValidateSet("Unknown","String","ExpandString","Binary","DWord","MultiString","Qword")]
        [System.String]
        $Type
    )

    switch ($Type) {
        'DWord' { return [int32]::Parse($Value)  }
        'QWord' { return [long]::Parse($Value) }
        Default { return $Value }
    }
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $Key,

        [parameter(Mandatory = $true)]
        [System.String]
        $ValueName,

        [System.String[]]
        $Value,

        [ValidateSet("Unknown","String","ExpandString","Binary","DWord","MultiString","Qword")]
        [System.String]
        $Type,

        [System.String]
        $Domain,

        [System.Boolean]
        $Disable
    )

    # Remove parameters, we do not need

    if([string]::IsNullOrWhiteSpace($Domain)) {
        $PSBoundParameters.Remove('Domain')
    }

    # Convert value

    $PSBoundParameters['Value'] = Convert-Value -Value $Value -Type $Type

    # Try to get the value first, in case it is of wrong type, remove it

    $GetParameters = @{
        Name  = $Name
        Key = $Key
        Valuename = $ValueName
        Domain = $Domain
    }

    if([string]::IsNullOrWhiteSpace($Domain)) {
        $GetParameters.Remove('Domain')
    }

    $gPRegistryvalue = Get-TargetResource @GetParameters

    if ((-not ([string]::IsNullOrWhiteSpace($gPRegistryvalue.ValueName))) `
        -and ($gPRegistryvalue.Type -ne $Type)) {
        
        Write-Verbose 'Calling Remove-GPRegistryValue...'
        Remove-GPRegistryValue @GetParameters
    }

    # Update setting

    if ($Disable) {
        Write-Verbose "Disabling value $ValueName in $Key in GPO $Name..."

        # Remove parameters, we do not need
        $PSBoundParameters.Remove('Value')
        $PSBoundParameters.Remove('Type')
    }

    if (-not $Disable) {
        Write-Verbose "Setting value $ValueName in $Key in GPO $Name to $Value..."
    }

    Write-Verbose "Calling Set-GPRegistryValue..."
    Set-GPRegistryValue @PSBoundParameters
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $Key,

        [parameter(Mandatory = $true)]
        [System.String]
        $ValueName,

        [System.String[]]
        $Value,

        [ValidateSet("Unknown","String","ExpandString","Binary","DWord","MultiString","Qword")]
        [System.String]
        $Type,

        [System.String]
        $Domain,

        [System.Boolean]
        $Disable
    )

    # Convert value

    $PSBoundParameters['Value'] = Convert-Value -Value $Value -Type $Type

    $target = Get-TargetResource `
        -Name $Name `
        -Key $Key `
        -ValueName $ValueName `
        -Domain $Domain

    if ($Disable) {
        $result = $target.Disable -eq $Disable
    }

    if (-not $Disable) {
        $result = `
            ($Value -eq $target.Value) -and `
            ($Type -eq $target.Type)
    }

    Write-Verbose "Test-TargetResource returning: $result"
    return $result
}


Export-ModuleMember -Function *-TargetResource

