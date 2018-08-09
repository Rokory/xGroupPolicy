function Get-GPLink {
    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $Target
    )

    #get content of attribut gplink on site object or OU

    $gplink = Get-ADObject -Filter { distinguishedName -eq $target } -Properties gPLink

    #set variale $o to define link order
    $o = 0    
    
    #we split the gplink string in order to seperate the diffent GPO linked

    $split = $gplink.gplink.split("]")
    
    #we need to do a reverse for to get the proper link order

    for ($s = $split.count - 1; $s -gt -1; $s--) {
          
        #since the last character in the gplink string is a "]" the last split is empty we need to ignore it
           
        if ($split[$s].length -gt 0) {
            $o++
            $order = $o            
            $gpoGuid = $split[$s].substring(12,36)
            $gpoDomainDn= ($split[$s].substring(72)).split(";")
            $domain = ($gpoDomainDn[0].substring(3)).replace(",DC=",".")
                                        
            #we test if the $gpoGuid is a valid GUID in the domain if not we return a "Oprhaned GpLink or External GPO" in the $gponname
    
            $myGpo = Get-GPO -Guid $gpoGuid -Domain $domain 2> $null
            
            if ($myGpo -ne $null ) {
                $gpoName = $myGpo.DisplayName
                $gpoDomain = $domain	
            }	
            else
            {
                Write-Warning '"Orphaned GPLink"'
                $gpoName = $null 
                $gpoDomain = $domain   
            }

            if (($null -eq $Name) -or ($gpoName -eq $Name)) {

                #we test the last 2 charaters of the split do determine the status of the GPO link

                if (($split[$s].endswith(";0"))) {
                    $enforced = "No"
                    $enabled = "Yes"
                }
                elseif (($split[$s].endswith(";1"))) {
                    $enabled = "No"
                    $enforced ="No"
                }
                elseif (($split[$s].endswith(";2"))) {
                    $enabled = "Yes"
                    $enforced = "Yes"
                }
                elseif (($split[$s].endswith(";3")))
                {
                    $enabled = "No"
                    $enforced = "Yes"
                }

                #we create an object representing each GPOs, its links status and link order

                $return = New-Object psobject 
                $return | Add-Member -membertype NoteProperty -Name "Target" -Value $target 
                $return | Add-Member -membertype NoteProperty -Name "GpoId" -Value $gpoguid
                $return | Add-Member -membertype NoteProperty -Name "DisplayName" -Value $gponame
                $return | Add-Member -membertype NoteProperty -Name "Domain" -Value $gpodomain
                $return | Add-Member -membertype NoteProperty -Name "Enforced" -Value $enforced
                $return | Add-Member -membertype NoteProperty -Name "Enabled" -Value $enabled
                $return | Add-Member -membertype NoteProperty -Name "Order" -Value $order
                return $return
            }
        }
    }
}

Export-ModuleMember -Function Get-GPLink
