function Get-WindowsPowerPlan {  
    <#
        .SYNOPSIS
        This commandlet returns the Windows Power Plan for a list of computers.
        .DESCRIPTION
        This commandlet returns the Windows Power Plan for a list of computers.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .OUTPUTS
        Returns the Windows Power Plan for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-WindowsPowerPlan -computerName computer -serverRole role
        .EXAMPLE
        Get-WindowsPowerPlan -computerName computer1, computer2 -serverRole role
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
        $requirement = "Windows Power Plan"

        # Get the Windows Power Plan for each computer
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

                        $powerPlan = powercfg -list | Select-String -Pattern '(High performance) *'

                        if ($powerPlan -eq $null) {
                        
                            $output = "High Performance is not set as the Power Plan."
                        
                        } else {
                        
                            $output = "High Performance is set as the Power Plan."
                        
                        } # End if else statement             

                     } catch {

                            Write-Host "Connection to $requirement failed" -ForegroundColor "DarkCyan"
                            $outputFailure = "The connection to $requirement failed and no output was returned."
                            New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                            $continue = $false  
                                                     
                     } # End try catch block                
                                                                            
                     New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output 
                     Write-Host "The information will be written to c:\output.csv" -ForegroundColor "DarkCyan"                            
                     Write-Host "The $requirement for $computer has been checked." -ForegroundColor "DarkCyan"

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

} # End Get-WindowsPowerPlan function

#Get-WindowsPowerPlan -computerName emttest -serverRole "web"                     


