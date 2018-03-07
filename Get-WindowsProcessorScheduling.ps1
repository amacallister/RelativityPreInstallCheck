function Get-WindowsProcessorScheduling {  
    <#
        .SYNOPSIS
        This commandlet returns the Windows Processor Scheduling for a list of computers.
        .DESCRIPTION
        This commandlet returns the Windows Processor Scheduling for a list of computers.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .OUTPUTS
        Returns the Windows Processor Scheduling for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-WindowsProcessorScheduling -computerName computer -serverRole role
        .EXAMPLE
        Get-WindowsProcessorScheduling -computerName computer1, computer2 -serverRole role
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
        $requirement = "Windows Processor Scheduling"
        
        # Get the Windows Processor Scheduling for each computer
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
                    
                    # Look up the Windows Processor Scheduling information
                    try {

                        $processorScheduling = Get-ItemProperty -ErrorAction 'Stop' -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl' | 
                                                select Win32PrioritySeparation

                    } catch {

                        Write-Host "Connection to $requirement failed" -ForegroundColor "DarkCyan"
                        $outputFailure = "The connection to $requirement failed and no output was returned."
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure   
                        $continue = $false  
                                                      
                    } # End try catch block             
                     
                    if ($($processorScheduling.Win32PrioritySeparation) -eq "0") {

                        $output = "Background services is enabled"

                    } elseif ($($processorScheduling.Win32PrioritySeparation) -eq "24"){
                    
                        $output = "Background services is enabled"
                    
                    }else {

                        $output = "Background services is not enabled"

                    } # End if else output statement

                     New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output 
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

} # End Get-WindowsProcessorScheduling function

#Get-WindowsProcessorScheduling -computerName emttest -serverRole "web"

