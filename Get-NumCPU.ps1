function Get-NumCPU {  
    <#
        .SYNOPSIS
        This commandlet returns the Number of CPU Cores for a list of computers.
        .DESCRIPTION
        This commandlet returns the Number of CPU Cores for a list of computers.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .RETURN
        Returns the Number of CPU Corest for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-NumCPU -computerName computer -serverRole role
        .EXAMPLE
        Get-NumCPU -computerName computer1, computer2 -serverRole role
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
        $requirement = "Number of CPU Cores"
        
        # Get the Number of CPU Cores for each computer
        foreach ($computer in $computerName) {

            if ($PSCmdlet.ShouldProcess($computer)){                                         
                
                Write-Host "Checking $computer for $requirement..." -ForegroundColor "DarkCyan"

                # Getting CPU Information
                try {

                    $processor = Get-WmiObject -ComputerName $computer -ErrorAction Stop -Class Win32_Processor

                } catch {
                    
                    Write-Host "Connection to $requirement failed" -ForegroundColor "DarkCyan"
                    $outputFailure = "The connection to $requirement failed and no output was returned."
                    New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                    $continue = $false  
                                             
                } # End try catch block               
                    
                # Set CPU variables
                $physicalCores = 0
                $logicalCores = 0
                $hyperthreadingEnabled = 0
                $numberOfSockets = 0

                # Get number of cores and logical processors
                if($processor.Length -gt 0) {

                    $numberOfSockets = $processor.length

                    ForEach($i in $processor) {

                        $physicalCores = $physicalCores + $i.NumberOfCores
                        $logicalCores = $logicalCores + $i.NumberOfLogicalProcessors

                    } # End foreach processor block
                }
                else{ 

                    # There is one socket
                    $numberOfSockets = 1
                    $physicalCores = $processor.NumberOfCores
                    $logicalCores = $processor.NumberOfLogicalProcessors

                } # End if else statement

                # Check if hyperthreading is enabled
                If($logicalCores -gt $physicalCores) {

                    $hyperthreadingEnabled = 1

                } # End if statement
        
                $output1 = "There are $numberOfSockets sockets."
                $output2 = "There are $physicalCores physical cores."
                $output3 = "There are $logicalCores logical cores."

                # Set output for hyperthreading
                if($hyperthreadingEnabled) {

                    $output4 = "Hyperthreading is enabled."

                }
                else {

                    $output4 = "Hyperthreading is not enabled."

                } # End if else hyperthreading statement

                $output = $output1 + "`r`n" + $output2 + "`r`n" + $output3 + "`r`n" + $output4

                New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output

            } # End ShouldProcess if statement

        } # End Server list loop

        Write-Host "The $requirement in all computers has been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-NumCPU function

#Get-NumCPU -computerName emttest -serverRole "web"

