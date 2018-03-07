function Get-WindowsUpdateSetting {  
    <#
        .SYNOPSIS
        This commandlet returns the Windows Update settings for a list of computers.
        .DESCRIPTION
        This commandlet returns the Windows Update settings for a list of computers.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .RETURN
        Outputs the Windows Update settings for a file called output.csv.
        .EXAMPLE
        Get-WindowsUpdateSetting -computerName computer -serverRole role
        .EXAMPLE
        Get-WindowsUpdateSetting -computerName computer1, computer2 -serverRole role
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
        $requirement = "Windows Update settings"
       
        # Check the Windows Update settings for each computer
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

                    # Look up the $requirement information
                    try {

                         $updateSetting = Get-ItemProperty -ErrorAction 'Stop' -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update' | 
                                                select AUoptions

                     } catch {

                            Write-Host "Connection to $requirement failed" -ForegroundColor "DarkCyan"
                            $outputFailure = "The connection to $requirement failed and no output was returned."
                            New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure   
                            $continue = $false  
                                                      
                     } # End try catch block                
                     
                     if ($($updateSetting.AUoptions) -eq 1) {
                        
                        $output = 'Automatic Updates Disabled'

                     } else {
                        
                        $output = 'Automatic Updates Not Disabled'

                     } # End if else statement

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

        Write-Host "The $requirement for all computers have been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-WindowsUpdateSetting function

#Get-WindowsUpdateSetting -computerName emttest -serverRole "web"
