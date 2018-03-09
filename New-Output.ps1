function New-Output { 
    <#
        .SYNOPSIS
        This commandlet creates an output.csv file.
        .DESCRIPTION
        This commandlet creates an output.csv file that contains the Server Roles, Server Names, Requirements, and Output for each Pre-Install Requirement.
        .PARAMETER serverRole
        The type of server
        .PARAMETER serverName
        The hostname of the server
        .PARAMETER requirement
        The Pre-Install Requirement
        .PARAMETER output
        The output from each Pre-Install Requirement script
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
  
  try {

    # Write output data to CSV file
    $fileData | Export-Csv -Append -ErrorAction 'Stop' -Path C:\output.csv

  } catch {
  
    Write-Host "Output could not be written to the output file. Make sure the file is not open."
  
  } # End try catch block

} # End New-Output function