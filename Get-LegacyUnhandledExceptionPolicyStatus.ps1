function Get-LegacyUnhandledExceptionPolicyStatus {  
    <#
        .SYNOPSIS
        This commandlet returns the Legacy Unhandled Exception Policy Status for a list of computers.
        .DESCRIPTION
        This commandlet returns the Expiration Header Info information for a list of computers. It will return the current value for cacheControlMode. DisableCache would mean content is set to Expire Immediately. NoControl would mean the content is not set to expire.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .OUTPUTS
        Returns the Legacy Unhandled Exception Policy Status for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-LegacyUnhandledExceptionPolicyStatus -computerName computer -serverRole role
        .EXAMPLE
        Get-LegacyUnhandledExceptionPolicyStatus -computerName computer1, computer2 -serverRole role
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
        $requirement = "Legacy Unhandled Exception Policy Status"

        # Get the IIS Expiration Header Info for each computer
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

                    try {

                        $xml = New-Object XML
                        $xml.Load("C:\Windows\Microsoft.NET\Framework64\v4.0.30319\Aspnet.config")                      

                     } catch {

                            Write-Host "Connection to $requirement failed" -ForegroundColor "DarkCyan"
                            $outputFailure = "The connection to $requirement failed and no output was returned."
                            New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                            $continue = $false  
                                                     
                     } # End try catch block                
                                   
                     $output = $xml.configuration.runtime.legacyUnhandledExceptionPolicy.enabled
 
                     New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output 
                     Write-Host "The information will be written to c:\output.csv" -ForegroundColor "DarkCyan"                            
                     Write-Host "The $requirement for $computer has been checked." -ForegroundColor "DarkCyan"

                } #End script block       

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

        Write-Host "The $requirement in all computers have been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-LegacyUnhandledExceptionPolicyStatus function

#Get-LegacyUnhandledExceptionPolicyStatus -computerName emttest -serverRole "web"
                        

