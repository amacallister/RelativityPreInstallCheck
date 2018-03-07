function Get-TcpChimneyOffloadingStatus {  
    <#
        .SYNOPSIS
        This commandlet returns the TCP Chimney Offloading Status for a list of computers.
        .DESCRIPTION
        This commandlet returns the TCP Chimney Offloading Status for a list of computers.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .RETURN
        Returns the TCP Chimney Offloading Status for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-TcpChimneyOffloadingStatus -computerName computer -serverRole role
        .EXAMPLE
        Get-TcpChimneyOffloadingStatus -computerName computer1, computer2 -serverRole role
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
        $requirement = "TCP Chimney Offloading Status"
        
        # Get the TCP Chimney Offloading Status for each computer
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
                    
                    # Look up the TCP Chimney Offloading Status information
                    try {

                         $chimney = Get-NetAdapterAdvancedProperty -ErrorAction 'Stop' | Select-Object DisplayName, DisplayValue

                     } catch {

                            Write-Host "Connection to $requirement failed" -ForegroundColor "DarkCyan"
                            $outputFailure = "The connection to $requirement failed and no output was returned."
                            New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure   
                            $continue = $false  
                                                      
                     } # End try catch block 
                     
                     $displayNameArray = @();
                     $displayValueArray = @();

                     $displayNames = $($chimney.DisplayName)
                     $displayValues = $($chimney.DisplayValue)

                     # TODO: get individual objects out

                     # Add all display names to the display names array
                     foreach ($name in $displayNames) {
                     
                        $displayNameArray += $name
                     
                     } # End displayName foreach loop

                     # Add all values to the value array
                     foreach ($value in $displayValues) {
                     
                        $displayValueArray += $value
                     
                     } # End displayValue foreach loop 
                     
                     $length = $displayNameArray.Length                                 
                     
                     # Produce output                                             
                     for ($i = 0; $i -lt $length; $i++) {
                        
                        $output = " Rule: $($displayNameArray[$i])" + "`r`n" + "Value: $($displayValueArray[$i])"
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output
                     
                     } # End output for loop
                     
                     
                     Write-Host "The information will be written to output.csv" -ForegroundColor "DarkCyan"
                     Write-Host "The $requirement for the computer has been checked." -ForegroundColor "DarkCyan"

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

} # End Get-TcpChimneyOffloadingStatus function

#Get-TcpChimneyOffloadingStatus -computerName emttest -serverRole "web"

