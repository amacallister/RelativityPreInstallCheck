function Get-SqlFullTextFilterDaemonLauncherServiceInstallStatus {  
    <#
        .SYNOPSIS
        This commandlet returns the SQL Full Text Filter Daemon Launcher Service Install Status for a list of computers.
        .DESCRIPTION
        This commandlet returns the SQL Full Text Filter Daemon Launcher Service Install Status for a list of computers.
        .PARAMETER computerName
        List of computer names to check.  Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .RETURN
        Outputs the SQL Full Text Filter Daemon Launcher Service Install Status for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-SqlFullTextFilterDaemonLauncherServiceInstallStatus -computerName computer -serverRole role
        .EXAMPLE
        Get-SqlFullTextFilterDaemonLauncherServiceInstallStatus -computerName computer1, computer2 -serverRole role
    #>
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]
    param(
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True)]
        [string[]]$computerName,
        
        [Parameter(Mandatory=$True)]
        [string]$serverRole      
    )
    Process {

        # Dot Source Script Functions
        . (Join-Path $PSScriptRoot New-Output.ps1)
        
        # Define Pre-Install Requirement Name
        $requirement = "SQL Full Text Filter Daemon Launcher Service Install Status"
         
        # Get the SQL Full Text Filter Daemon Launcher Service Install Status for each computer
        foreach ($computer in $computerName) {
            
            if ($PSCmdlet.ShouldProcess($computer)){                                           
               
                Write-Host "Checking $computer for $requirement..." -ForegroundColor "DarkCyan"

                # Getting SQL Full Text Filter Daemon Launcher Service Install Status
                try {
                    
                    $serviceStatus = Get-Service -ComputerName $computer | 
                                    Where-Object {$_.Name -eq "MSSQLFDLauncher"} | 
                                    Select-Object Status

                } catch {
                    
                    Write-Host "Connection to account failed" -ForegroundColor "DarkCyan"
                    $outputFailure = "The connection to $requirement failed and no output was returned."
                    New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                    $continue = $false 
                                              
                } # End try catch block
                                                        
                $output = $($serviceStatus.Status)
                      
                New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output
                Write-Host "The information will be written to c:\output.csv" -ForegroundColor "DarkCyan"                            
                Write-Host "The SQL Full Text Filter Daemon Launcher Service Install Status for $computer has been checked." -ForegroundColor "DarkCyan"

            } # End ShouldProcess if statement

        } # End Server list loop

        Write-Host "The SQL Full Text Filter Daemon Launcher Service Install Status in all computers has been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-SqlFullTextFilterDaemonLauncherServiceInstallStatus function

#Get-SqlFullTextFilterDaemonLauncherServiceInstallStatus -computerName emttest, localhost -serverRole "web"