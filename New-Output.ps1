function New-Output { 
    <#
        .SYNOPSIS
        This commandlet creates an output.csv file.
        .DESCRIPTION
        This commandlet creates an output.csv file that contains the Server Roles, Server Names, Requirements, and Output for each Pre-Install Requirement.
        .PARAMETER serverRole
        .PARAMETER serverName
        .PARAMETER requirement
        .PARAMETER output
        .EXAMPLE
        New-Output -serverRole role -serverName name -requirement requirement -output output
    #>
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]
    param(
        [Parameter(Mandatory=$True)]
        [string]$serverRole,

        [Parameter(Mandatory=$True)]
        [string]$serverName,

        [Parameter(Mandatory=$True)]
        [string]$requirement,

        [Parameter(Mandatory=$True)]
        [string]$output
    )
    
    # Create custom object with all output attributes
    $fileData = @(
        [pscustomobject]@{
            ServerRole = $serverRole
            ServerName  = $serverName
            Requirement  = $requirement
            Output = $output
        }
     ) # End fileData object creation block
  
  # Write output data to CSV file
  $fileData | Export-Csv -Append -Path C:\output.csv

} # End New-Output function