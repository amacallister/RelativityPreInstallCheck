function Get-InternetExplorerEnhancedSecurityConfigurationStatus {  
    <#
        .SYNOPSIS
        This commandlet returns the Internet Explorer Enhanced Security Configuration Status for a list of computers.
        .DESCRIPTION
        This commandlet returns the Internet Explorer Enhanced Security Configuration Status for a list of computers.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .OUTPUTS
        Returns the Internet Explorer Enhanced Security Configuration Status for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-InternetExplorerEnhancedSecurityConfigurationStatus -computerName computer -serverRole role
        .EXAMPLE
        Get-InternetExplorerEnhancedSecurityConfigurationStatus -computerName computer1, computer2 -serverRole role
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
        $requirement = "Internet Explorer Enhanced Security Configuration Status"
        
        # Get the Share Permissions for each computer
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
                    
                    # Look up the Internet Explorer Enhanced Security Configuration Status information
                    try {

                         $IEEnhancedstatus = Get-ItemProperty -ErrorAction 'Stop' -Path 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}' | 
                                                select IsInstalled

                     } catch {

                            Write-Host "Connection to Internet Explorer Enhanced Security Configuration Status failed" -ForegroundColor "DarkCyan"
                            $outputFailure = "The connection to Internet Explorer Enhanced Security Configuration Status failed and no output was returned."
                            New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure   
                            $continue = $false  
                                                      
                     } # End try catch block                
                     
                     if ($($IEEnhancedstatus.IsInstalled) -eq 0) {
                        
                        $output = 'Not Enabled'

                     } else {
                        
                        $output = 'Enabled'

                     } # End if else statement

                     New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output 
                     Write-Host "The information will be written to output.csv" -ForegroundColor "DarkCyan"
                     Write-Host "The Internet Explorer Enhanced Security Configuration Status for the computer have been checked." -ForegroundColor "DarkCyan"

                 } #End script block

                 try {

                    Invoke-Command -ComputerName $computer -ErrorAction 'Stop' -Scriptblock $Script

                 } catch {
                 
                    Write-Host "Connection to $computer failed" -ForegroundColor "DarkCyan"
                    $outputFailure = "The connection to $computer failed and no output was returned."
                    New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure   
                    $continue = $false

                 } # End try catch block

            } # End ShouldProcess if statement

        } # End Server list loop

        Write-Host "The Internet Explorer Enhanced Security Configuration Status in all computers have been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-InternetExplorerEnhancedSecurityConfigurationStatus function

#Get-InternetExplorerEnhancedSecurityConfigurationStatus -computerName emttest -serverRole "worker"
