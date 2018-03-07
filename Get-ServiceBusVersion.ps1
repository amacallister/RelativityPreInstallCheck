function Get-ServiceBusVersion {  
    <#
        .SYNOPSIS
        This commandlet returns the Service Bus Version for a list of computers.
        .DESCRIPTION
        This commandlet returns the Service Bus Version for a list of computers.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .OUTPUTS
        Outputs the Service Bus Version for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-ServiceBusVersion -computerName computer -serverRole role
        .EXAMPLE
        Get-ServiceBusVersion -computerName computer1, computer2 -serverRole role
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
        $requirement = "Service Bus Version"
       
        # Check the Service Bus Version
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

                    # If Service Bus 1.1 is found, this setting will be true.
                    $foundCorrectVersion = "false"

                    # Look up the Service Bus Version                              
                    $path = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"

                    # Create an instance of the Registry Object and open the HKLM base key 
                    try {

                        $reg = [microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$computer,'Registry64') 

                    } catch {
                        
                        Write-Host "Creating registry object failed" -ForegroundColor "DarkCyan"
                        $outputFailure = "Creating registry object failed."
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure                   
                        $continue = $false 

                    } # End try catch block for creating new registry object

                    # Drill down into the Uninstall key using the OpenSubKey Method 
                    try {

                        $regkey = $reg.OpenSubKey("SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall")  

                    } catch {
                        
                       Write-Host "Opening the registry subkey failed" -ForegroundColor "DarkCyan"
                       $outputFailure = "Opening the registry subkey failed."
                       New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure                   
                       $continue = $false  
                        
                    } # End try catch block for opening the registry subkey

                    # Retrieve an array of string that contain all the subkey names 
                    try {

                        $subkeys = $regkey.GetSubKeyNames()  
                                            
                    } catch {
                    
                       Write-Host "Getting the registry subkey names failed" -ForegroundColor "DarkCyan"
                       $outputFailure = "Getting the registry subkey names failed."
                       New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure                   
                       $continue = $false
                    
                    }  # End try catch block for getting the registry subkey names  

                    # Open each Subkey and use GetValue Method to return the required  values for each 
                    ForEach ($key in $subkeys){   

                        $thisKey = $path + $key 
                        $thisSubKey = $reg.OpenSubKey($thisKey) 
    
                        if($thisSubKey -ne $null) {
        
                            try {

                                $displayName = $($thisSubKey.getValue("displayName"))

                            } catch {

                                Write-Host "Getting the registry subkey value failed" -ForegroundColor "DarkCyan"
                                $outputFailure = "Getting the registry subkey value failed."
                                New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure                   
                                $continue = $false

                            } # End try catch block for getting subkey value

                        } # End if statement

                        if($displayName -eq "Service Bus 1.1"){
        
                            $output = $displayName
                            $foundCorrectVersion = "true"

                        } # End if statement
                                            
                    } # End for each loop
                    
                    Write-Host "Correct version: $foundCorrectVersion"              
                    if ($foundCorrectVersion -eq "false") {
                    
                        $output = "Service Bus 1.1 is not installed."
                    
                    } # End if statement
                    
                    New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output 
                    Write-Host "The information will be written to c:\output.csv" -ForegroundColor "DarkCyan"                            
                    Write-Host "The Service Bus Version for $computer has been checked." -ForegroundColor "DarkCyan" 

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

        Write-Host "The Service Bus Version in all computers has been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-ServiceBusVersion function

#Get-ServiceBusVersion -computerName emttest -serverRole "serviceBus"