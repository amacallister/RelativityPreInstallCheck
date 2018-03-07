function Start-Remoting {  
    <#
        .SYNOPSIS
        This commandlet checks the remoting status for a list of computers.
        .DESCRIPTION
        This commandlet checks the remoting status for a list of computers. It checks if the PowerShell port (5985) is open, and adds the computers to the wsman Trusted Hosts File if they are not already there.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .OUTPUTS
        Returns the remoting status for a list of computers in a file called output.csv.
        .EXAMPLE
        Start-Remoting -computerName computer -serverRole role
        .EXAMPLE
        Start-Remoting -computerName computer1, computer2 -serverRole role
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
        $requirement = "Remoting Status"

        # Check Remoting Status for each computer
        foreach ($computer in $computerName) {

            if ($PSCmdlet.ShouldProcess($computer)){                                         
                
                Write-Host "Checking $computer for $requirement..."
                    
                $createOutputFunctionDef = "function New-Output { ${function:New-Output} }"
                    
                $Script = {                                                                          
                   Param ( $createOutputFunctionDef)

                   . ([ScriptBlock]::Create($using:createOutputFunctionDef))

                   $serverRole = $using:serverRole                                            
                   $computer = $using:computer
                   $requirement = $using:requirement
                    
                    # Check if PowerShell port is open
                    try {

                        $portTest = Test-NetConnection $computer -ErrorAction Stop -port 5985 -InformationLevel Quiet
                        
                    } catch {
                    
                        Write-Host "Connection to port failed" -ForegroundColor "DarkCyan"
                        $outputFailure = "The connection to port failed and no output was returned."
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                        $continue = $false 
                    
                    }  # End port try catch block
                                                                            
                    # Get contents of trusted host file
                    try {

                        $trustedHostListString = (Get-Item wsman:\localhost\Client\TrustedHosts -ErrorAction Stop).Value

                    } catch {
                            
                        Write-Host "Connection to wsman Trusted Hosts file failed" -ForegroundColor "DarkCyan"
                        $outputFailure = "The connection to wsman Trusted Hosts file failed and no output was returned."
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                        $continue = $false 
                            
                    } # End trusted host file try catch block
                    
                    # Get status of WinRM service
                    try {
                    
                        $winRMServiceStatus = Get-Service -Name WinRM | Select-Object -Property Status
                    
                    } catch {
                    
                        Write-Host "Connection to winRM service failed" -ForegroundColor "DarkCyan"
                        $outputFailure = "The connection to winRM service failed and no output was returned."
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                        $continue = $false 
                    
                    } # End winRM service try catch block                                                      
                    
                    # Configure port output               
                    if ($portTest) {
                     
                       $portOutput = "PowerShell Port, 5895, is open."
                                                                
                    } else {
                     
                       $portOutput = "PowerShell Port, 5895, is closed."
                     
                    } # End port test if else statement

                    # Configure WinRM service status output
                    $winRMOutput = $($winRMServiceStatus.Status)
                  
                    $output = $portOutput + "`r`n" + "Trusted Hosts: $trustedHostListString" + "`r`n" + "WinRM service status: $winRMOutput"
                     
                    New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output 
                    Write-Host "The information will be written to c:\output.csv" -ForegroundColor "DarkCyan"                            
                    Write-Host "The $requirement for $computer has been checked." -ForegroundColor "DarkCyan"

                } #End script block       

                try {

                    Invoke-Command -ComputerName $computer -ErrorAction Stop -Scriptblock $Script

                } catch {

                    Write-Host "Connection to $computer failed" -ForegroundColor "DarkCyan"
                    $outputFailure = "The connection to $computer failed and no output was returned. Make sure $computer is in the Trusted Hosts File."
                    New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure   
                    $continue = $false

                } # End try catch block
                
            } # End ShouldProcess if statement

        } # End Server list loop

        Write-Host "The $requirement in all computers has been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Start-Remoting function

#Start-Remoting -computerName emttest -serverRole "web"                      