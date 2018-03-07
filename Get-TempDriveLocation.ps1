function Get-TempDriveLocation {  
    <#
        .SYNOPSIS
        This commandlet returns the TEMP and TMP Environment variable locations for a list of computers.
        .DESCRIPTION
        This commandlet returns the TEMP and TMP Environment variable locations for a list of computers.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .OUTPUTS
        Returns the TEMP and TMP Environment variable locations for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-TempDriveLocation -computerName computer -serverRole role
        .EXAMPLE
        Get-TempDriveLocation -computerName computer1, computer2 -serverRole role
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
        $requirement = "Temp Drive Locations"
        
        # Get the Temp Drive Locations for each computer
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

                    # Look up the Temp Drive Locations
                    try {

                         $TEMPlocation = $Env:TEMP 
                         $TMPlocation = $Env:TMP

                     } catch {

                            Write-Host "Connection to Temp Drive Locations failed" -ForegroundColor "DarkCyan"
                            $outputFailure = "The connection to binding in IIS failed and no output was returned."
                            New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure   
                            $continue = $false 
                                                      
                     } # End try catch block                
                     
                     $output = "TEMP Location: $TEMPlocation" + "`r`n" + "TMP Location: $TMPlocation"
                     
                     New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output 
                     Write-Host "The information will be written to output.csv" -ForegroundColor "DarkCyan"
                     Write-Host "The Temp Drive Locations for the computer have been checked." -ForegroundColor "DarkCyan"

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

        Write-Host "The Temp Drive Locations in all computers have been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-TempDriveLocation function

#Get-TempDriveLocation -computerName emttest -serverRole "serviceBus"