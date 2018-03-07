function Get-FileAllocationUnitSize {  
    <#
        .SYNOPSIS
        This commandlet returns the drive letter and Allocation Unit Size of all volumes for a list of computers.
        .DESCRIPTION
        This commandlet returns the drive letter and Allocation Unit Size of all volumes for a list of computers.
        .PARAMETER computerName
        List of computer names to check.  Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .OUTPUTS
        Returns the drive letter and Allocation Unit Size of all volumes for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-FileAllocationUnitSize -computerName computer -serverRole role
        .EXAMPLE
        Get-FileAllocationUnitSize -computerName computer1, computer2 -serverRole role
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
        $requirement = "Allocation Unit Size"
        
        # Get the Allocation Unit Size for each volume for each computer
        foreach ($computer in $computerName) {

            if ($PSCmdlet.ShouldProcess($computer)){                                         
                
                Write-Host "Checking $computer for $requirement..." -ForegroundColor "DarkCyan"

                # Getting drive letter and Allocation Unit Size
                try {

                    $volumes = Get-WmiObject -ErrorAction Stop -ComputerName $computer -Class Win32_Volume | 
                                            Where-Object {$_.FileSystem -eq "NTFS"} | 
                                            Select-Object Name, BlockSize

                } catch {
                    
                    Write-Host "Connection to volumes failed" -ForegroundColor "DarkCyan"
                    $outputFailure = "The connection to $requirement failed and no output was returned."
                    New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                    $continue = $false  
                                             
                } # End try catch block
                    
                    foreach($volume in $volumes){
                                    
                        $driveLetter = $($volume.Name)
                        $size = $($volume.BlockSize)

                        $output = "$driveLetter" + "`r`n" + "$size GB"
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output

                    } # End volume foreach loop

            } # End ShouldProcess if statement

        } # End Server list loop

        Write-Host "The Allocation Unit Size in all computers has been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-FileAllocationUnitSize function

#Get-FileAllocationUnitSize -computerName emttest -serverRole "web"