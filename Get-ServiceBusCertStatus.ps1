function Get-ServiceBusCertStatus {  
    <#
        .SYNOPSIS
        This commandlet returns the Service Bus Certificate Status for a list of computers.
        .DESCRIPTION
        This commandlet returns the Service Bus Certificate Status for a list of computers. The script will look for the certificate in the Local Computer Trusted Root and Personal stores.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .OUTPUTS
        Outputs the Service Bus Certificate Status for a file called output.csv.
        .EXAMPLE
        Get-ServiceBusCertStatus -computerName computer -serverRole role
        .EXAMPLE
        Get-ServiceBusCertStatus -computerName computer1, computer2 -serverRole role
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
        $requirement = "Service Bus Certificate Status"
       
        # Check the Service Bus Certificate Status for each computer
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

                    # Look up the Service Bus Certificate Status information
                    try {

                        # Find Service Bus certificate thumbprint
                        $certThumbprint = Get-SBFarm -ErrorAction 'Stop' | Select-Object -ExpandProperty EncryptionCertificate | Select-Object -Property Thumbprint
                        $certThumbprint = $($certThumbprint.Thumbprint)

                    } catch {

                        Write-Host "Connection to Service Bus certificate thumbprint failed" -ForegroundColor "DarkCyan"
                        $outputFailure = "The connection to Service Bus certificate thumbprint failed and no output was returned."
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure   
                        $continue = $false  
                                                      
                     } # End try catch block 

                     try {

                        # Check Trusted Root Store for certificate
                        cd Cert:\LocalMachine\Root
                        $rootCert = dir -ErrorAction 'Stop' -recurse | where {$_.Thumbprint -eq $certThumbprint} | Format-List -property *

                    } catch {

                        Write-Host "Connection to Trusted Root Store failed" -ForegroundColor "DarkCyan"
                        $outputFailure = "The connection to Trusted Root Store failed and no output was returned."
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure   
                        $continue = $false  
                                                      
                     } # End try catch block 

                     try {

                        # Check Personal Store for certificate
                        cd Cert:\LocalMachine\My
                        $personalCert = dir -ErrorAction 'Stop' -recurse | where {$_.Thumbprint -eq $certThumbprint} | Format-List -property *

                     } catch {

                        Write-Host "Connection to Personal Store failed" -ForegroundColor "DarkCyan"
                        $outputFailure = "The connection to Personal Store failed and no output was returned."
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure   
                        $continue = $false  
                                                      
                     } # End try catch block                
                     
                     # Configure output for each certificate store
                     if (!$rootCert) {
                        
                        $output1 = 'Not Installed'

                     } else {
                     
                        $output1 = 'Installed'
                     
                     }# End Trusted Root Store output if else statement

                     if (!$personalCert) {
                        
                        $output2 = 'Not Installed'

                     } else {
                     
                        $output2 = 'Installed'
                     
                     }# End Personal Store output if else statement

                     $output = "Trusted Root Store: $output1" + "`r`n" + "Personal Store: $output2" + "`r`n" + "Thumbprint: $certThumbprint"

                     New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output 
                     Write-Host "The information will be written to output.csv" -ForegroundColor "DarkCyan"
                     Write-Host "The $requirement for $computer has been checked." -ForegroundColor "DarkCyan"

                } # End Script block
                
                try {

                    Invoke-Command -ComputerName $computer -ErrorAction 'Stop' -Scriptblock $Script

                } catch {
                 
                    Write-Host "Connection to $computer failed" -ForegroundColor "DarkCyan"
                    $outputFailure = "The connection to $computer failed and no output was returned."
                    New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure   
                    $continue = $false

                } # End try catch block         
                         
            } # End Should Process if statement

        } # End Server list loop

        Write-Host "The $requirement for all computers have been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-ServiceBusCertStatus  function

#Get-ServiceBusCertStatus  -computerName emttest -serverRole "web"








