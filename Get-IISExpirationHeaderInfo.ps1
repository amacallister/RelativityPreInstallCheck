function Get-IISExpirationHeaderInfo {  
    <#
        .SYNOPSIS
        This commandlet returns the Expiration Header Info information for an IIS site in a list of computers.
        .DESCRIPTION
        This commandlet returns the Expiration Header Info information for an IIS site in a list of computers. It will return the current value for cacheControlMode. DisableCache would mean content is set to Expire Immediately. NoControl would mean the content is not set to expire.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .OUTPUTS
        Returns the IIS Expiration Header Info for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-IISExpirationHeaderInfo -computerName computer -serverRole role
        .EXAMPLE
        Get-IISExpirationHeaderInfo -computerName computer1, computer2 -serverRole role
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
        $requirement = "IIS Expiration Header Info"
        
        # Import IIS PowerShell module
        Import-Module 'webAdministration'

        # Get the IIS Expiration Header Info for each computer
        foreach ($computer in $computerName) {

            if ($PSCmdlet.ShouldProcess($computer)){                                         
                
                Write-Host "Checking $computer for $requirement..."

                # Check if feature role has been installed
                $role = "web-Filtering"

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

                             $filter = "//System.WebServer/staticContent"
                             $propertyName = "clientCache"
                             $information = Get-WebConfigurationProperty -ErrorAction 'Stop' -filter $filter -name $propertyName | 
                                Select-Object -Property cacheControlMode                        

                         } catch {

                                Write-Host "Connection to IIS Expiration Header Information failed" -ForegroundColor "DarkCyan"
                                $outputFailure = "The connection to $requirement failed and no output was returned."
                                New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                                $continue = $false  
                                                     
                         } # End try catch block                
               
                         $output = $($information.cacheControlMode)

                         if ($output -eq "DisableCache") {
                         
                            $output = "Content set to expire immediately"
                         
                         } # End output if statement
                         
                         New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output 
                         Write-Host "The information will be written to c:\output.csv" -ForegroundColor "DarkCyan"                            
                         Write-Host "The IIS Expiration Header Information for $computer has been checked." -ForegroundColor "DarkCyan"

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

        Write-Host "The Expiration Header Information in all computers have been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-IISExpirationHeaderInfo function

#Get-IISExpirationHeaderInfo -computerName emttest -serverRole "web"
                        