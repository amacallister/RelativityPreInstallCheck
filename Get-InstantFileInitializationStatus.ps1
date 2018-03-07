function Get-InstantFileInitializationStatus {  
    <#
        .SYNOPSIS
        This commandlet returns the Instant File Initialization Status for a list of computers.
        .DESCRIPTION
        This commandlet returns the Instant File Initialization Status for a list of computers. It will return the account running the SQL Service and a list of all administrator accounts on each computer. Instant File Initialization is enabled if the account running the service is also an admin.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .OUTPUTS
        Returns the Relativity Service Account for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-InstantFileInitializationStatus -computerName computer -serverRole role
        .EXAMPLE
        Get-InstantFileInitializationStatus -computerName computer1, computer2 -serverRole role
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
        $requirement = "Instant File Initialization Status"

        # Get the Instant File Initialization Status for each computer
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
                        
                        # Return Account running the SQL Service
                        $account = Get-WmiObject Win32_Service -ErrorAction Stop -ComputerName $computer |
                                    Where-Object {$_.Name -eq "MSSQLSERVER"} |
                                    Select-Object StartName

                        $account = $($account.StartName)

                        if($account -ne '') {

                            try {
                                                           
                                #Return list of administrator accounts on server
                                $admins = net localgroup administrators | Out-String 
                        
                                $info = "Check to see if the account running the SQL Service is also in the list of Administrator accounts."
                        
                                # Configure output
                                $output = $info + "`r`n" + "`r`n" + "Account running SQL Service: $account" + "`r`n" + "`r`n" + $admins
                     
                                New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output 
                                Write-Host "The information will be written to c:\output.csv" -ForegroundColor "DarkCyan"                            
                                Write-Host "The $requirement for $computer has been checked." -ForegroundColor "DarkCyan"         

                             } catch {

                                Write-Host "Connection to the administrator accounts failed" -ForegroundColor "DarkCyan"
                                $outputFailure = "The connection to the administrator accounts failed and no output was returned."
                                New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                                $continue = $false  
                                                     
                             } # End admin accounts try catch block 

                        } # End if statement

                    } catch {
                    
                        Write-Host "Connection to SQL service failed" -ForegroundColor "DarkCyan"
                        $outputFailure = "The connection to SQL service failed and no output was returned."
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                        $continue = $false
                    
                    } # End service account try catch block
                                                 
                } #End script block       

                try {

                    Invoke-Command -ComputerName $computer -ErrorAction Stop -Scriptblock $Script

                } catch {

                    Write-Host "Connection to $computer failed" -ForegroundColor "DarkCyan"
                    $outputFailure = "The connection to $computer failed and no output was returned."
                    New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure   
                    $continue = $false

                } # End try catch block
                
            } # End ShouldProcess if statement

        } # End Server list loop

        Write-Host "The $requirement in all computers has been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-InstantFileInitializationStatus function                   

#Get-InstantFileInitializationStatus -computerName emttest -serverRole "web"