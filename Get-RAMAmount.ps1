function Get-RAMAmount {  
    <#
        .SYNOPSIS
        This commandlet returns the RAM Amount for a list of computers.
        .DESCRIPTION
        This commandlet returns the RAM Amount for a list of computers.
        .PARAMETER computerName
        List of computer names to check.  Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .RETURN
        Returns the RAM Amount for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-RAMAmount -computerName computer -serverRole role
        .EXAMPLE
        Get-RAMAmount -computerName computer1, computer2 -serverRole role
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
        $requirement = "RAM Amount"
        
        # Get the RAM Amount for each computer
        foreach ($computer in $computerName) {

            if ($PSCmdlet.ShouldProcess($computer)){                                         
                
                Write-Host "Checking $computer for $requirement..." -ForegroundColor "DarkCyan"

                # Getting RAM Amount
                try {

                    $InstalledRAM = Get-WmiObject -ComputerName $computer -ErrorAction Stop -Class Win32_ComputerSystem
                    $InstalledRAM = [Math]::Round(($InstalledRAM.TotalPhysicalMemory/ 1GB)) 

                } catch {
                    
                    Write-Host "Connection to $requirement failed" -ForegroundColor "DarkCyan"
                    $outputFailure = "The connection to $requirement failed and no output was returned."
                    New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                    $continue = $false  
                                             
                } # End try catch block               
                    
                 $output = "$($InstalledRAM) GB"

                 New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output

            } # End ShouldProcess if statement

        } # End Server list loop

        Write-Host "The $requirement in all computers has been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-RAMAmount function

#Get-RAMAmount -computerName emttest -serverRole "web"