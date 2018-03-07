function Get-TLSSettings {  
    <#
        .SYNOPSIS
        This commandlet returns the TLS Settings for a list of computers.
        .DESCRIPTION
        This commandlet returns the TLS Settings for a list of computers.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .RETURN
        Returns the TLS Settings for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-TLSSettings -computerName computer -serverRole role
        .EXAMPLE
        Get-TLSSettings -computerName computer1, computer2 -serverRole role
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
        $requirement = "TLS Settings"
        
        # Get the TLS Settings for each computer
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
                    
                    # Look up the TLS Settings information
                    try {

                        $ssl2client = Get-ItemProperty -ErrorAction 'Stop' -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client' | 
                                                select Enabled
                        $ssl2server = Get-ItemProperty -ErrorAction 'Stop' -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server' | 
                                                select Enabled
                        $ssl3client = Get-ItemProperty -ErrorAction 'Stop' -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client' | 
                                                select Enabled
                        $ssl3server = Get-ItemProperty -ErrorAction 'Stop' -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server' | 
                                                select Enabled
                        $tls10client = Get-ItemProperty -ErrorAction 'Stop' -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client' | 
                                                select Enabled
                        $tls10server = Get-ItemProperty -ErrorAction 'Stop' -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' | 
                                                select Enabled
                        $tls11client = Get-ItemProperty -ErrorAction 'Stop' -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client' | 
                                                select Enabled
                        $tls11server = Get-ItemProperty -ErrorAction 'Stop' -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' | 
                                                select Enabled
                        $tls12client = Get-ItemProperty -ErrorAction 'Stop' -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' | 
                                                select Enabled
                        $tls12server = Get-ItemProperty -ErrorAction 'Stop' -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' | 
                                                select Enabled

                     } catch {

                            Write-Host "Connection to $requirement failed" -ForegroundColor "DarkCyan"
                            $outputFailure = "The connection to $requirement failed and no output was returned."
                            New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure   
                            $continue = $false  
                                                      
                     } # End try catch block                
                     
                     # Get SSL 2.0 Client Output
                     if ($($ssl2client.Enabled) -eq 0) {
                        
                        $ssl2clientOutput = 'Not Enabled'

                     } else {
                        
                        $ssl2clientOutput = 'Enabled'

                     } # End if else SSL 2.0 Client statement

                     # Get SSL 2.0 Server Output
                     if ($($ssl2server.Enabled) -eq 0) {
                        
                        $ssl2serverOutput = 'Not Enabled'

                     } else {
                        
                        $ssl2serverOutput = 'Enabled'

                     } # End if else SSL 2.0 Server statement

                     # Get SSL 3.0 Client Output
                     if ($($ssl3client.Enabled) -eq 0) {
                        
                        $ssl3clientOutput = 'Not Enabled'

                     } else {
                        
                        $ssl3clientOutput = 'Enabled'

                     } # End if else SSL 3.0 Client statement

                     # Get SSL 3.0 Server Output
                     if ($($ssl3server.Enabled) -eq 0) {
                        
                        $ssl3serverOutput = 'Not Enabled'

                     } else {
                        
                        $ssl3serverOutput = 'Enabled'

                     } # End if else SSL 3.0 Server statement

                     # Get TLS 1.0 Client Output
                     if ($($tls10client.Enabled) -eq 0) {
                        
                        $tls10clientOutput = 'Not Enabled'

                     } else {
                        
                        $tls10clientOutput = 'Enabled'

                     } # End if else TLS 1.0 Client statement

                     # Get TLS 1.0 Server Output
                     if ($($tls10server.Enabled) -eq 0) {
                        
                        $tls10serverOutput = 'Not Enabled'

                     } else {
                        
                        $tls10serverOutput = 'Enabled'

                     } # End if else TLS 1.0 Server statement

                     # Get TLS 1.1 Client Output
                     if ($($tls11client.Enabled) -eq 0) {
                        
                        $tls11clientOutput = 'Not Enabled'

                     } else {
                        
                        $tls11clientOutput = 'Enabled'

                     } # End if else TLS 1.1 Client statement

                     # Get TLS 1.1 Output
                     if ($($tls11server.Enabled) -eq 0) {
                        
                        $tls11serverOutput = 'Not Enabled'

                     } else {
                        
                        $tls11serverOutput = 'Enabled'

                     } # End if else TLS 1.1 Server statement

                     # Get TLS 1.2 Client Output
                     if ($($tls12client.Enabled) -eq 0) {
                        
                        $tls12clientOutput = 'Not Enabled'

                     } else {
                        
                        $tls12clientOutput = 'Enabled'

                     } # End if else TLS 1.2 Client statement

                     # Get TLS 1.2 Server Output
                     if ($($tls12server.Enabled) -eq 0) {
                        
                        $tls12serverOutput = 'Not Enabled'

                     } else {
                        
                        $tls12serverOutput = 'Enabled'

                     } # End if else TLS 1.2 Server statement

                     $output = "SSL 2.0 Client: $ssl2clientOutput" + "`r`n" + 
                               "SSL 2.0 Server: $ssl2serverOutput" + "`r`n" + 
                               "SSL 3.0 Client: $ssl3clientOutput" + "`r`n" + 
                               "SSL 3.0 Server: $ssl3serverOutput" + "`r`n" + 
                               "TLS 1.0 Client: $tls10clientOutput" + "`r`n" + 
                               "TLS 1.0 Server: $tls10serverOutput" + "`r`n" + 
                               "TLS 1.1 Client: $tls11clientOutput" + "`r`n" + 
                               "TLS 1.1 Server: $tls11serverOutput" + "`r`n" + 
                               "TLS 1.2 Client: $tls12serverOutput" + "`r`n" + 
                               "TLS 1.2 Server: $tls12serverOutput"

                     New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output 
                     Write-Host "The information will be written to output.csv" -ForegroundColor "DarkCyan"
                     Write-Host "The $requirement for the computer have been checked." -ForegroundColor "DarkCyan"

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

        Write-Host "The $requirement in all computers have been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-TLSSettings function

#Get-TLSSettings -computerName emttest -serverRole "web"

