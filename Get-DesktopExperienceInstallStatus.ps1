function Get-DesktopExperienceInstallStatus {  
    <#
        .SYNOPSIS
        This commandlet returns the install status of the Desktop Experience feature.
        .DESCRIPTION
        This commandlet returns the install status of the Desktop Experience feature.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .OUTPUTS
        Returns the the install status of the Desktop Experience feature for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-DesktopExperienceInstallStatus -computerName computer
        .EXAMPLE
        Get-DesktopExperienceInstallStatus -computerName computer1, computer2
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
        [string]$serverRole
    )
    Process {

        # Dot Source Script Functions
        . (Join-Path $PSScriptRoot New-Output.ps1)
        
        # Define Pre-Install Requirement Name
        $requirement = "Desktop Experience Install Status"
        
        # Check the Desktop Experience Install Status.
        foreach ($computer in $computerName) {

            if ($PSCmdlet.ShouldProcess($computer)){

                if ($PSCmdlet.ShouldProcess($role)){                        
                                              
                    Write-Host "Checking $computer for $requirement..." -ForegroundColor "DarkCyan"

                    $role = "Desktop-Experience"

                    # Getting Desktop Experience Install Status
                    try {

                        $currentRole = Get-WindowsFeature -ErrorAction 'Stop' -Name $role -ComputerName $computer

                    } catch {

                        Write-Host "Connection to $requirement failed" -ForegroundColor "DarkCyan"
                        $outputFailure = "The connection to $requirement failed and no output was returned."
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                        $continue = $false
                                                       
                    } #End try catch block

                    if ($currentRole.Installed) {

                        Write-Host "$role is already installed." -ForegroundColor "DarkCyan"
                        Write-Host "$role is being appended to c:\output.csv". -ForegroundColor "DarkCyan"
                        $output = $role
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output

                    } else {

                        Write-Host "$role is not installed." -ForegroundColor "DarkCyan"
                        Write-Host "$role is being appended to c:\output.csv". -ForegroundColor "DarkCyan"
                        $output = "Not Installed: $role"
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output  
                                            
                    } # End if statement

                } # End ShouldProcess statement

                 Write-Host "The $requirement for $computer has been checked." -ForegroundColor "DarkCyan"

            } # End ShouldProcess statement

        } # End Server list loop

        Write-Host "The $requirement for each computer has been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-DesktopExperienceInstallStatus function

#Get-DesktopExperienceInstallStatus -computerName emttest -serverRole "worker"