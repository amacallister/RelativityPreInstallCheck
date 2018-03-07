function Get-IISLogFileOptions {  
    <#
        .SYNOPSIS
        This commandlet returns the Log File Maximum number of trace file size for an IIS site in a list of computers.
        .DESCRIPTION
        This commandlet returns the Log File Maximum number of trace file size for an IIS site in a list of computers.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .OUTPUTS
        Returns the IIS Log File Options for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-IISLogFileOptions -computerName computer -serverRole role
        .EXAMPLE
        Get-IISLogFileOptions -computerName computer1, computer2 -serverRole role
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
        $requirement = "IIS Log File Options"
        
        # Import IIS PowerShell module
        Import-Module 'webAdministration'        

        # Get the Log File Options in IIS for each computer
        foreach ($computer in $computerName) {

            if ($PSCmdlet.ShouldProcess($computer)){                                        
                
                Write-Host "Checking $computer for $requirement..."

                # Check if feature role has been installed
                $role = "web-http-logging"
                
                try {

                    $currentRole = Get-WindowsFeature -ErrorAction 'Stop' -Name $role -ComputerName $computer

                } catch {

                    Write-Host "Connection to $role failed" -ForegroundColor "DarkCyan"
                    $outputFailure = "The connection to $role in IIS failed and no output was returned."
                    New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure                   
                    $continue = $false 
                                              
                } # End try catch block

                # Check to see if the required IIS Log File role is installed in IIS
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
                            $propertyName = "logFile"
                            $information = Get-WebConfigurationProperty -ErrorAction Stop -filter $filter -name $propertyName | 
                                Select-Object -Property truncateSize

                         } catch {

                                Write-Host "Connection to IIS Log File Options failed" -ForegroundColor "DarkCyan"
                                $outputFailure = "The connection to $requirement failed and no output was returned."
                                New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                                $continue = $false    
                                                   
                        } # End try catch block                
               
                        $output = $($information.truncateSize)

                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output 
                        Write-Host "The information will be written to c:\output.csv" -ForegroundColor "DarkCyan"                            
                        Write-Host "The Log File Options for $computer have been checked." -ForegroundColor "DarkCyan"

                    } #End script block

                    try {

                        Invoke-Command -ComputerName $computer -Scriptblock $Script

                    } catch {
                    
                        Write-Host "Connection to $computer failed" -ForegroundColor "DarkCyan"
                        $outputFailure = "The connection to $computer failed and no output was returned."
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure   
                        $continue = $false

                    } # End try catch block

                } else {
                           
                            Write-Host "The IIS Role, $role, is not installed in IIS so no output can be returned." -ForegroundColor "DarkCyan"
                            Write-Host "Logging to c:\output.csv". -ForegroundColor "DarkCyan"
                            $outputFailure = "The IIS Role, $role, is not installed so no output was returned."
                            New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                                              
                } # End if statement
                
            } # End ShouldProcess if statement

        } # End Server list loop

        Write-Host "The Log File Options in all computers have been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-IISLogFileOptions function

#Get-IISLogFileOptions -computerName emttest -serverRole "web"