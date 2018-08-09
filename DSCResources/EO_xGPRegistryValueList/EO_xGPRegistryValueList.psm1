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
    $type = $null
    $disable = $true

    foreach ($gpRegistryValue in $gPRegistryValues) {

       $count = $values.Add($gPRegistryvalue.Value)

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
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $Key,

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
        $Disable,

        [System.Boolean]
        $Additive
    )

    # Remove parameters, we do not need

    if([string]::IsNullOrWhiteSpace($Domain)) {
        $PSBoundParameters.Remove('Domain') | Out-Null
    }

    # Parameters for disabling or deleting values

    $disableRemoveParameters = @{
        Name = $Name
        Key = $Key
        Domain = $Domain
        Disable = $Disable
    }

    if([string]::IsNullOrWhiteSpace($Domain)) {
        $disableRemoveParameters.Remove('Domain') | Out-Null
    }

    # Update setting

    if ($Disable) {
        # Disable values

        Write-Verbose "Disabling value $ValuenName in $Key in GPO $Name..."
        $parameters = $disableRemoveParameters
    }

    if (-not $Disable) {
        $disableRemoveParameters.Remove('Disable') | Out-Null

        $target = Get-TargetResource @disableRemoveParameters

        # First, remove all values

        if ($target.Value.Count -gt 0) {
            Write-Verbose "Removing value in $Key of GPO $Name..."
            Remove-GPRegistryValue @disableRemoveParameters | Out-Null
        }

        # Then, add all values
        Write-Verbose "Setting values in $Key of GPO $Name to $Value..."
        $parameters = $PSBoundParameters
    }

    Write-Verbose "Calling Set-GPRegistryValue..."
    Set-GPRegistryValue @parameters | Out-Null
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
        $Disable,

        [System.Boolean]
        $Additive
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
            $result = $result -and ($Value -contains $PSItem)
        }

        # Second, check if all values in Value paramter
        # are also contained in key.
        # This detects values, that are not in the key yet
        # and should be added.

        $Value | ForEach-Object {
            $result = $result -and ($target.Value -contains $PSItem)
        }
    }

    Write-Verbose "Test-TargetResource returning: $result"
    return $result
}

Export-ModuleMember -Function *-TargetResource

