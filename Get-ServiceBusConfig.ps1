function Get-ServiceBusConfig {  
    <#
        .SYNOPSIS
        This commandlet returns the Service Bus configuration for a list of computers.
        .DESCRIPTION
        This commandlet returns the Service Bus configuration for a list of computers.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .OUTPUTS
        Outputs the Service Bus Configuration for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-ServiceBusConfig -computerName computer -serverRole role
        .EXAMPLE
        Get-ServiceBusConfig -computerName computer1, computer2 -serverRole role
    #>
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]
    param(
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True)]
        [Alias('hostname')]
        [string[]]$computerName,
        
        [Parameter(Mandatory=$True)]
        [string]$serverRole       
    )
    Process {
        
        # Dot Source Script Functions
        . (Join-Path $PSScriptRoot New-Output.ps1)
        
        # Define Pre-Install Requirement Name
        $requirement = "Service Bus Config"

        # Get the Service Bus Configuration for each computer
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

                    # Get Service Bus information
                    try {

                         $information = Get-SBFarm -ErrorAction 'Stop' | 
                            Select-Object -Property ClusterConnectionEndpointPort, ClientConnectionEndpointPort, LeaseDriverEndpointPort, ServiceConnectionEndpointPort,
                                RunAsAccount, AdminGroup, HttpsPort, TcpPort, MessageBrokerPort, AmqpsPort, AmqpPort, FarmCertificate, EncryptionCertificate, RPHttpPort,
                                RPHttpsUrl, FarmDNS

                     } catch {

                            Write-Host "Connection to Service Bus Configuration failed" -ForegroundColor "DarkCyan"
                            $outputFailure = "The connection to binding in IIS failed and no output was returned."
                            New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure   
                            $continue = $false 
                                                      
                     } # End try catch block                
               
                     $output = "Cluster Connection Endpoint Port: $($information.ClusterConnectionEndpointPort)`r`n" + 
                                    "Client Connection Endpoint Port: $($information.ClientConnectionEndpointPort)`r`n" +
                                    "Lease Driver Endpoint Port: $($information.LeaseDriverEndpointPort)`r`n" +
                                    "Service Connection Endpoint Port: $($information.ServiceConnectionEndpointPort)`r`n" +
                                    "Run As Account: $($information.RunAsAccount)`r`n" + 
                                    "Admin Group: $($information.AdminGroup)`r`n" + 
                                    "HTTPS Port: $($information.HttpsPort)`r`n" +
                                    "TCP Port: $($information.TcpPort)`r`n" + 
                                    "Message Broker Port: $($information.MessageBrokerPort)`r`n" + 
                                    "AMQPS Port: $($information.AmqpsPort)`r`n" +
                                    "AMQP Port: $($information.AmqpPort)`r`n" + 
                                    "Farm Certificate: $($information.FarmCertificate)`r`n" + 
                                    "Encryption Certificate: $($information.EncryptionCertificate)`r`n" +
                                    "RP HTTP Port: $($information.RPHttpPort)`r`n" +
                                    "RP HTTPS Port: $($information.RPHttpsUrl)`r`n" + 
                                    "Farm DNS: $($information.FarmDNS)"

                     New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output 
                     Write-Host "The information will be written to output.csv" -ForegroundColor "DarkCyan"                            
                     Write-Host "The Service Bus Configuration for $computer has been checked." -ForegroundColor "DarkCyan"

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

        Write-Host "The Service Bus Configuration in all computers has been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-ServiceBusConfig function

#Get-ServiceBusConfig -computerName emttest -serverRole "serviceBus"