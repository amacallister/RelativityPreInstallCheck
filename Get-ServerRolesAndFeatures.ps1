function Get-ServerRolesAndFeatures {  
    <#
        .SYNOPSIS
        This commandlet returns a report listing the required server roles and features and whether they are installed or not installed.
        .DESCRIPTION
        This commandlet returns a report listing the required server roles and features and whether they are installed or not installed.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER rolesAndFeatures
        One or more required roles and features to install if not installed already. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .RETURN
        Returns the install status of roles and features for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-ServerRolesAndFeatures -computerName computer -rolesAndFeatures role -serverRole role 
        .EXAMPLE
        Get-ServerRolesAndFeatures -computerName computer1, computer2 -rolesAndFeatures role1, role2 -serverRole role
    #>
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]
    param(
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True)]
        [string[]]$computerName,

        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True)]
        [string[]]$rolesAndFeatures,

        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True)]
        [string]$serverRole
    )
    Process {

        # Dot Source Script Functions
        . (Join-Path $PSScriptRoot New-Output.ps1)
        
        # Define Pre-Install Requirement Name
        $requirement = "Required Server Roles and Features"
        
        # Check if Required Server Roles and Features on each server are already installed.
        foreach ($computer in $computerName) {

            if ($PSCmdlet.ShouldProcess($computer)){

                foreach($role in $rolesAndFeatures) {

                    if ($PSCmdlet.ShouldProcess($role)){                        
                                              
                        Write-Host "Checking $role on $computer for $requirement..." -ForegroundColor "DarkCyan"

                        # Getting Installed Roles and Features
                        try {

                            $currentRole = Get-WindowsFeature -ErrorAction 'Stop' -Name $role -ComputerName $computer

                        } catch {

                            Write-Host "Connection to $role failed" -ForegroundColor "DarkCyan"
                            $outputFailure = "The connection to $requirement failed and no output was returned."
                            New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                            $continue = $false
                                                       
                        } #End try catch block

                        if ($currentRole.Installed) {

                            $output = "Installed: $role"
                            New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output

                        } else {

                            $output = "Not Installed: $role"
                            New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output  
                                            
                        } # End if statement

                    } # End ShouldProcess statement

                 } # End Roles and Features loop

                 Write-Host "All $requirement for $computer have been checked." -ForegroundColor "DarkCyan"

            } # End ShouldProcess statement

        } # End Server list loop

        Write-Host "All required $requirement for each computer have been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-ServerRolesAndFeatures function

#Get-ServerRolesAndFeatures -computerName emttest -rolesAndFeatures web-server, web-webserver -serverRole "web" 