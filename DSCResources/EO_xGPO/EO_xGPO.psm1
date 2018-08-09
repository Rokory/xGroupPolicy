function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.String]
        $Domain
    )

    # Remove domain parameter if not specified

    if ([string]::IsNullOrWhiteSpace($Domain)) {
        $PSBoundParameters.Remove('Domain')
    }

    # Get GPO

    Write-Verbose "Getting GPO $Name..."

    $gpo = Get-GPO @PSBoundParameters -ErrorAction SilentlyContinue

    # Construct output

    $Ensure = 'Absent'

    if ($gpo) {
        $Ensure = 'Present'
    }

    return @{
        Ensure = $Ensure
        Name = $Name
        Comment = $gpo.Description  
        Domain = $Domain
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [ValidateSet("Absent","Present")]
        [System.String]
        $Ensure = 'Present',

        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.String]
        $Comment,

        [System.String]
        $Domain
    )

    # Save the Ensure parameter in a separate variable

    $removeGPO = $Ensure -eq 'Absent'

    # Remove parameters, we do not need

    $PSBoundParameters.Remove('Ensure')

    if([string]::IsNullOrWhiteSpace($Domain)) {
        $PSBoundParameters.Remove($Domain)
    }

    # Create GPO
    
    if (-not $removeGPO) {
        Write-Verbose "Creating GPO $Name..."
        Write-Verbose "Calling New-GPO cmdlet..."

        New-GPO @PSBoundParameters
    }

    # Remove GPO

    if ($removeGPO) {
        Write-Verbose "Removing GPO $Name..."
        Write-Verbose "Calling Remove-GPO cmdlet..."

        Remove-GPO @PSBoundParameters
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [ValidateSet("Absent","Present")]
        [System.String]
        $Ensure = 'Present',

        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [System.String]
        $Comment,

        [System.String]
        $Domain
    )

    $target = Get-TargetResource -Name $Name -Domain $Domain
    $result = $Ensure -eq $target.Ensure
    Write-Verbose "Test-TargetResource returning: $result"
    return $result
}

Export-ModuleMember -Function *-TargetResource

