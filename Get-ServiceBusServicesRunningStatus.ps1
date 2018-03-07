function Get-ServiceBusServicesRunningStatus {  
    <#
        .SYNOPSIS
        This commandlet returns the Service Bus Services Running Status for a list of computers.
        .DESCRIPTION
        This commandlet returns the Service Bus Services Running Status for a list of computers. This includes the Windows Fabric Host Service, the Service Bus Resource Provider Service, the Service Bus Message Broker Service, and the Service Bus Gateway Service.
        .PARAMETER computerName
        List of computer names to check.  Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .OUTPUTS
        Outputs the Service Bus Services Running Status for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-ServiceBusServicesRunningStatus -computerName computer -serverRole role
        .EXAMPLE
        Get-ServiceBusServicesRunningStatus -computerName computer1, computer2 -serverRole role
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
        $requirement = "Service Bus Services Running Status"
         
        # Get the Service Bus Services Running Status for each computer
        foreach ($computer in $computerName) {
            
            if ($PSCmdlet.ShouldProcess($computer)){                                           
               
                Write-Host "Checking $computer for $requirement..." -ForegroundColor "DarkCyan"

                # Getting Service Bus Services Running Status
                try {
                    
                    $WindowsFabricHostServiceStatus = Get-Service -ComputerName $computer | 
                                    Where-Object {$_.Name -eq "FabricHostSvc"} | 
                                    Select-Object Status

                    $ServiceBusResourceProviderServiceStatus = Get-Service -ComputerName $computer | 
                                    Where-Object {$_.Name -eq "Service Bus Resource Provider"} | 
                                    Select-Object Status

                    $ServiceBusMessageBrokerServiceStatus = Get-Service -ComputerName $computer | 
                                    Where-Object {$_.Name -eq "Service Bus Message Broker"} | 
                                    Select-Object Status

                    $ServiceBusGatewayServiceStatus = Get-Service -ComputerName $computer | 
                                    Where-Object {$_.Name -eq "Service Bus Gateway"} | 
                                    Select-Object Status

                } catch {
                    
                    Write-Host "Connection to services failed" -ForegroundColor "DarkCyan"
                    $outputFailure = "The connection to $requirement failed and no output was returned."
                    New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                    $continue = $false 
                                              
                } # End try catch block
                                                        
                $output1 = $($WindowsFabricHostServiceStatus.Status)
                $output2 = $($ServiceBusResourceProviderServiceStatus.Status)
                $output3 = $($ServiceBusMessageBrokerServiceStatus.Status)
                $output4 = $($ServiceBusGatewayServiceStatus.Status)

                $output = "Windows Fabric Host Service: $output1" + "`r`n" + "Service Bus Resource Provider Service: $output2" + "`r`n" + "Service Bus Message Broker Service: $output3" + "`r`n" + "Service Bus Gateway Service: $output4"
                      
                New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output
                Write-Host "The information will be written to c:\output.csv" -ForegroundColor "DarkCyan"                            
                Write-Host "The Service Bus Services Running Status for $computer has been checked." -ForegroundColor "DarkCyan"

            } # End ShouldProcess if statement

        } # End Server list loop

        Write-Host "The Service Bus Services Running Status in all computers has been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-ServiceBusServicesRunningStatus function

#Get-ServiceBusServicesRunningStatus -computerName emttest -serverRole "web"