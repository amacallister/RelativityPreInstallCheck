function Get-DtcEnabledStatus {  
    <#
        .SYNOPSIS
        This commandlet returns the DTC Enabled Status for a list of computers.
        .DESCRIPTION
        This commandlet returns the DTC Enabled Status for a list of computers. This includes whether the RPC Endpoint Mapper, DTC incoming and outgoing firewall rules are enabled, the current Authentication level, whether inbound and outbound transactions are enabled, whether remote client access is enabled, whether remote administrative access is enabled, and whether XA and LU transactions are enabled.
        .PARAMETER computerName
        List of computer names to check.  Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .OUTPUTS
        Returns the DTC Enabled Status for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-DtcEnabledStatus -computerName computer -serverRole role
        .EXAMPLE
        Get-DtcEnabledStatus -computerName computer1, computer2 -serverRole role
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
        $requirement = "DTC Enabled Status"
        
        # Get DTC Enabled Status for each computer in the list
        foreach ($computer in $computerName) {

            if ($PSCmdlet.ShouldProcess($computer)){                                         
                
                Write-Host "Checking $computer for $requirement..." -ForegroundColor "DarkCyan"

                # Enable the WMI firewall rule group on the current computer
                #Write-Host "The WMI firewall rule group on the current computer will be enabled if it's not already"
                #netsh advfirewall firewall set rule group="Windows Management Instrumentation (WMI)" new enable=yes


                # Getting DTC Enabled Status on a computer
                try {

                    [string]$dtcWarning = (Test-Dtc -LocalComputerName $computer) 3>&1
                    [string]$dtcVerbose = (Test-Dtc -LocalComputerName $computer -Verbose) 4>&1
                   
                } catch {
                    
                    Write-Host "Connection to volumes failed" -ForegroundColor "DarkCyan"
                    $outputFailure = "The connection to $requirement failed and no output was returned."
                    New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                    $continue = $false  
                                             
                } # End try catch block
                                    
                $output = "Warnings: $dtcWarning" + "`r`n" + "`r`n" + "Verbose messages: $dtcVerbose"
                New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output
                Write-Host "The information will be written to c:\output.csv" -ForegroundColor "DarkCyan"                            
                Write-Host "The DTC Enabled Status for $computer has been checked." -ForegroundColor "DarkCyan"

            } # End ShouldProcess if statement

        } # End Server list loop

        Write-Host "The DTC Enabled Status in all computers has been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-DtcEnabledStatus function

#Get-DtcEnabledStatus -computerName emttest -serverRole "sql"



#https://docs.microsoft.com/en-us/powershell/module/msdtc/test-dtc?view=win10-ps