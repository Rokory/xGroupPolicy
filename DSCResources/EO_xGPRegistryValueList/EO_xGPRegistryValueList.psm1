function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true)]
        [System.String]
        $Key,

        [System.String]
        $Domain
    )

    # Remove domain parameter if not specified

    if ([string]::IsNullOrWhiteSpace($Domain)) {
        $PSBoundParameters.Remove('Domain') | Out-Null
    }
    
    Write-Verbose "Getting GPO registry values from $Key..."

    $gPRegistryValues = Get-GPRegistryValue @PSBoundParameters -ErrorAction SilentlyContinue

    
    $values = New-Object -TypeName System.Collections.ArrayList
    $valueNames = New-Object -TypeName System.Collections.ArrayList
    $type = $null
    $disable = $true

    foreach ($gpRegistryValue in $gPRegistryValues) {

        $values.Add($gPRegistryvalue.Value) > $null
        $valueNames.Add($gpRegistryValue.ValueName) > $null

        if ($null -eq $type) {
            $type = $gpRegistryValue.Type
        }

        if (($null -ne $type) -and ($type -ne $gpRegistryValue.Type)) {
            $type = ''
        }

        if ($null -ne $disable) {
                if ($gPRegistryvalue.PolicyState -eq 'Set') {
                    $disable = $disable -and $false
                }

                if ($gPRegistryvalue.PolicyState -eq 'Delete') {
                    $disable = $disable -and $true
                }
        }
    }

    $returnValue = @{
        Name = $Name
        Key = $Key
        ValueName = $valueNames
        Value = $values
        Type = $type
        Disable = $disable
        Domain = $Domain
    }

    return $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true)]
        [System.String]
        $Key,

        [System.String[]]
        $ValueName,

        [System.String]
        $ValuePrefix,

        [System.String[]]
        $Value,

        [ValidateSet("String", "ExpandString")]
        [System.String]
        $Type,

        [System.String]
        $Domain,

        [System.Boolean]
        $Disable

        # [System.Boolean]
        # $Additive # TODO: remove, should always be true
    )

    # Test, if ValuePrefix and ValueName are set at the same time.

    if (($ValueName.Length -gt 0) -and -not ([String]::IsNullOrWhiteSpace($ValuePrefix))) {
        throw 'ValuePrefix and ValueName paramter must no be present at the same time.'
    }
 
    # Build core parameters

    $coreParameters = @{
        Name = $Name
        Key = $Key
        Domain = $Domain
    }

    # Remove parameters, we do not need

    if([string]::IsNullOrWhiteSpace($Domain)) {
        $PSBoundParameters.Remove('Domain') | Out-Null
        $coreParameters.Remove('Domain') | Out-Null
    }

    # Update setting

    # First, disable all values

    $target = Get-TargetResource @coreParameters

    if ($target.Value.Count -gt 0) {
        Write-Verbose "Disabling values $ValueName in $Key in GPO $Name..."
        Write-Verbose "Calling Set-GPRegistryValue..."
        Set-GPRegistryValue @coreParameters -Disable | Out-Null
    }

    # Then, add all values

    if (-not $Disable) {
        Write-Verbose "Setting values $ValueName in $Key of GPO $Name to $Value..."
        $parameters = $PSBoundParameters
        Write-Verbose "Calling Set-GPRegistryValue..."
        Set-GPRegistryValue @parameters -Additive | Out-Null
    }
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [ValidateNotNullOrEmpty()]
        [Parameter(Mandatory = $true)]
        [System.String]
        $Key,

        [System.String[]]
        $ValueName,

        [System.String]
        $ValuePrefix,

        [System.String[]]
        $Value,

        [ValidateSet("String", "ExpandString")]
        [System.String]
        $Type,

        [System.String]
        $Domain,

        [System.Boolean]
        $Disable

        # [System.Boolean]
        # $Additive # Remove
    )

    $target = Get-TargetResource `
        -Name $Name `
        -Key $Key `
        -Domain $Domain


    # If values should be disabled, check, if all values in key are disabled

    if ($Disable) {
        $result = $target.Disable
    }
    
    # If values should not disabled,
    # compare list $Value with actual values of target

    if (-not $Disable) {
        # First, check for the type
        $result = $Type -eq $target.Type

        # Second, check if all values in key
        # are also contained in Value parameter.
        # This detects values, that are not in the parameter
        # and should be removed.

        $target.Value | ForEach-Object {
            $index = $Value.IndexOf($PSItem)
            $result = $result -and ($index -ne -1)
            if ($ValueName.Length -gt 0) {
                $result = $result -and (
                    $target.ValueName[$index] -eq $ValueName[$index]
                )
            }
        }

        # Third, check if all values in Value paramter
        # are also contained in key.
        # This detects values, that are not in the key yet
        # and should be added.

        $Value | ForEach-Object {
            $index = $target.Value.IndexOf($PSItem)
            $result = $result -and ($index -ne -1)
            if ($ValueName.Length -gt 0) {
                $result = $result -and (
                    $target.ValueName[$index] -eq $ValueName[$index]
                )
            }
        }
    }

    Write-Verbose "Test-TargetResource returning: $result"
    return $result
}

Export-ModuleMember -Function *-TargetResource

