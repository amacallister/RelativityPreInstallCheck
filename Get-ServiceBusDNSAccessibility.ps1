function Get-ServiceBusDNSAccessibility {  
    <#
        .SYNOPSIS
        This commandlet returns the Service Bus DNS Accessibility for a list of computers.
        .DESCRIPTION
        This commandlet returns the Service Bus DNS Accessibility for a list of computers.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .OUTPUTS
        Outputs the Service Bus DNS Accessibility for a file called output.csv.
        .EXAMPLE
        Get-ServiceBusDNSAccessibility -computerName computer -serverRole role
        .EXAMPLE
        Get-ServiceBusDNSAccessibility -computerName computer1, computer2 -serverRole role
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
        $requirement = "Service Bus DNS Accessibility"
       
        # Check the Service Bus DNS Accessibility for each computer
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

                    # Look up the Service Bus IP Address
                    try {

                         $serviceBusIPAddress = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction Stop | Select-Object IPAddress | Where-Object {$_.IPAddress -ne "127.0.0.1"}
                         $serviceBusIPAddress = $($serviceBusIPAddress.IPAddress)

                    } catch {

                         Write-Host "Connection to $requirement failed" -ForegroundColor "DarkCyan"
                         $outputFailure = "The connection to $requirement failed and no output was returned."
                         New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure   
                         $continue = $false  
                                                      
                    } # End try catch block

                    # Attempt to hit the Service Bus Default Namespace
                    try {

                        # Find the Service Bus HTTPS Port
                        $httpsPort = Get-SBFarm -ErrorAction 'Stop' | Select-Object -Property HttpsPort
                        $httpsPort = $($httpsPort.HttpsPort)

                    } catch {
                    
                        Write-Host "Connection to the Service Bus HTTPS Port failed" -ForegroundColor "DarkCyan"
                        $outputFailure = "The connection to the Service Bus HTTPS Port failed and no output was returned."
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure   
                        $continue = $false 
                    
                    } # End Service Bus HTTPS Port try catch block

                    try {

                         # Configure Service Bus URL
                         $url = "https://" + $serviceBusIPAddress + ":" + "$httpsPort" + "/servicebusdefaultnamespace"
                         
                         # Ignore TLS errors with certificate
                         add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
            return true;
        }
 }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

                         $webResponse = Invoke-WebRequest $url -ErrorAction 'Stop' | Select-Object StatusCode, StatusDescription

                    } catch {

                         Write-Host "Connection to invoke web request failed" -ForegroundColor "DarkCyan"
                         $outputFailure = "The connection to invoke web request  failed and no output was returned."
                         New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure   
                         $continue = $false  
                                                      
                    } # End web request try catch block                
                                             
                    $output1 = "Status Code: $($webResponse.StatusCode)"
                    $output2 = "Status Description: $($webResponse.StatusDescription)"

                    $output = $output1 + "`r`n" + $output2

                    New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output 
                    Write-Host "The information will be written to output.csv" -ForegroundColor "DarkCyan"
                    Write-Host "The $requirement for the computer have been checked." -ForegroundColor "DarkCyan"

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

        Write-Host "The $requirement for all computers has been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-ServiceBusDNSAccessibility function

#Get-ServiceBusDNSAccessibility -computerName emttest -serverRole "web"
