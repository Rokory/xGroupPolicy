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
        $Target
    )

    # Get GPO link

    Write-Verbose "Getting GPLink $Name from $Target..."

    $gpLink = Get-GPLink @PSBoundParameters -ErrorAction SilentlyContinue

    # Construct output

    $ensure = 'Absent'

    if ($gpLink) {
        $ensure = 'Present'
    }

    return @{
        Ensure = $ensure
        Name = $Name
        LinkEnabled = $gpLink.Enabled  
        Order = $gpLink.Order
        Domain = $gpLink.Domain
        Enforced = $gpLink.Enforced
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

        [parameter(Mandatory = $true)]
        [System.String]
        $Target,

        [ValidateSet("Yes","No")]
        [System.String]
        $LinkEnabled = 'Yes',

        [System.UInt32]
        $Order = 0,

        [System.String]
        $Domain,

        [ValidateSet("Yes","No")]
        [System.String]
        $Enforced = 'No'
)

    # Save the Ensure parameter in a separate variable

    $removeGPLink = $Ensure -eq 'Absent'

    # Remove parameters, we do not need

    $PSBoundParameters.Remove('Ensure') > $null

    if([string]::IsNullOrWhiteSpace($Domain)) {
        $PSBoundParameters.Remove($Domain) > $null
    }

    # Test, if GPLink is already in place

    $gpLink = Get-TargetResource -Name $Name -Target $Target

    # GP link should be present

    if (-not $removeGPLink) {
        # Modify GP link

        if ($gpLink.Ensure -eq 'Present') {
            Write-Verbose "Mofifying link to $Name in $Target..."
            Write-Verbose "Calling Set-GPLink cmdlet..."

            Set-GPLink @PSBoundParameters
        }

        # Create GP link
        
        if ($gpLink.Ensure -eq 'Absent') {
            Write-Verbose "Creating link to $Name in $Target..."
            Write-Verbose "Calling New-GPLink cmdlet..."

            New-GPLink @PSBoundParameters > $null
        }
    }

    # Remove GP link

    if ($removeGPLink) {
        Write-Verbose "Removing link to $Name from $Target..."
        $PSBoundParameters.Remove('LinkEnabled') > $null
        $PSBoundParameters.Remove('Enforced') > $null
        $PSBoundParameters.Remove('Order') > $null
        
        Write-Verbose "Calling Remove-GPLink cmdlet..."

        Remove-GPLink @PSBoundParameters > $null
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

        [parameter(Mandatory = $true)]
        [System.String]
        $Target,

        [ValidateSet("Yes","No")]
        [System.String]
        $LinkEnabled = 'Yes',

        [System.UInt32]
        $Order = 0,

        [System.String]
        $Domain,

        [ValidateSet("Yes","No")]
        [System.String]
        $Enforced = 'No'
)

    $gpLink = Get-TargetResource -Name $Name -Target $Target

    $result =  $Ensure -eq $gpLink.Ensure

    if ($Ensure -eq 'Present') {
        $result = $result -and `
            ($LinkEnabled -eq $gpLink.LinkEnabled) -and `
            (($Order -eq $gpLink.Order) -or (0 -eq $Order)) -and `
            (($Domain -eq $gpLink.Domain) -or ([string]::IsNullOrWhiteSpace($Domain))) -and `
            ($Enforced -eq $gpLink.Enforced)
    }


    Write-Verbose "Test-TargetResource returning: $result"
    return $result
}

Export-ModuleMember -Function *-TargetResource

