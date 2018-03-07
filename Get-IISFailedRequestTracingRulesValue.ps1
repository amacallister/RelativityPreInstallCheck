﻿function Get-IISFailedRequestTracingRulesValue {  
    <#
        .SYNOPSIS
        This commandlet returns the Failed Request Tracing Rules information for an IIS site in a list of computers.
        .DESCRIPTION
        This commandlet returns the Failed Request Tracing Rules information for an IIS site in a list of computers. This includes whether or not it is enabled and the maximum number of trace files.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .OUTPUTS
        Returns the IIS Failed Request Tracing Rules Value for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-IISFailedRequestTracingRulesValue -computerName computer
        .EXAMPLE
        Get-IISFailedRequestTracingRulesValue -computerName computer1, computer2
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
        $requirement = "FailedRequestTracingRulesValue"
        
        # Import IIS PowerShell module
        Import-Module 'webAdministration'     

        # Get the Failed Request Tracing Rules information in IIS for each computer
        foreach ($computer in $computerName) {
            
            if ($PSCmdlet.ShouldProcess($computer)){                                           
                
                Write-Host "Checking $computer for $requirement..."

                # Check if feature role has been installed
                $role = "web-http-tracing"

                try {

                    $currentRole = Get-WindowsFeature -ErrorAction 'Stop' -Name $role -ComputerName $computer

                } catch {

                    Write-Host "Connection to $role failed" -ForegroundColor "DarkCyan"
                    $outputFailure = "The connection to $role in IIS failed and no output was returned."
                    New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                    $continue = $false  
                                             
                } # End try catch block

                if ($currentRole.Installed) {
                    
                    $createOutputFunctionDef = "function New-Output { ${function:New-Output} }"

                    $Script = {                                                           

                        Param ( $createOutputFunctionDef)

                        . ([ScriptBlock]::Create($using:createOutputFunctionDef))

                        $serverRole = $using:serverRole                                            
                        $computer = $using:computer
                        $requirement = $using:requirement
                        
                        # Look up the current XML value(s) in the applicationHost.config file for the IIS feature
                        try {

                             $filter = "//System.ApplicationHost/sites/site[@name='Default Web Site']"
                             $propertyName = "traceFailedRequestsLogging"
                             $information = Get-WebConfigurationProperty -ErrorAction Stop -filter $filter -name $propertyName | 
                                Select-Object -Property enabled,maxLogFiles

                         } catch {

                                Write-Host "Connection to IIS Failed Request Tracing Rules information failed" -ForegroundColor "DarkCyan"
                                $outputFailure = "The connection to $requirement failed and no output was returned."
                                New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                                $continue = $false 
                                                      
                         } # End try catch block                
               
                         $output = "Enabled Status: $($information.enabled)" + "`r`n" + "Max Log Files: $($information.maxLogFiles)"

                         New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output  
                         Write-Host "The information will be written to c:\output.csv" -ForegroundColor "DarkCyan"                            
                         Write-Host "The Failed Request Tracing Rules Value for $computer have been checked." -ForegroundColor "DarkCyan"

                    } #End script block

                } else {

                            Write-Host "The IIS Role, $role, is not installed in IIS so no output can be returned." -ForegroundColor "DarkCyan"
                            Write-Host "Logging to c:\output.csv". -ForegroundColor "DarkCyan"
                            $outputFailure = "The IIS Role, $role, is not installed so no output was returned."
                            New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                                              
                } # End if statement
                
                try {

                    Invoke-Command -ComputerName $computer -Scriptblock $Script

                } catch {

                    Write-Host "Connection to $computer failed" -ForegroundColor "DarkCyan"
                    $outputFailure = "The connection to $computer failed and no output was returned."
                    New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure   
                    $continue = $false
                
                } # End try catch block 

            } # End ShouldProcess if statement

        } # End Server list loop

        Write-Host "The Failed Request Tracing Rules Value in all computers have been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-IISFailedRequestTracingRulesValue function

#Get-IISFailedRequestTracingRulesValue -computerName emttest -serverRole "web"

