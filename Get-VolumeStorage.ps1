function Get-VolumeStorage {  
    <#
        .SYNOPSIS
        This commandlet returns the drive letter, total storage, and free storage of all volumes for a list of computers.
        .DESCRIPTION
        This commandlet returns the drive letter, total storage, and free storage of all volumes for a list of computers.
        .PARAMETER computerName
        List of computer names to check.  Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .OUTPUTS
        Returns the drive letter, total storage, and free storage of all volumes for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-VolumeStorage -computerName computer -serverRole role
        .EXAMPLE
        Get-VolumeStorage -computerName computer1, computer2 -serverRole role
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
        $requirement = "Volume Storage Information"
        
        # Get the storage in each volume for each computer
        foreach ($computer in $computerName) {

            if ($PSCmdlet.ShouldProcess($computer)){                                         
                
                Write-Host "Checking $computer for $requirement..." -ForegroundColor "DarkCyan"

                # Getting volume letter, volume size, and volume freespace
                try {

                    $volumes = Get-WmiObject Win32_LogicalDisk -ErrorAction Stop -ComputerName $computer |
                        Select-Object DeviceID,Size,FreeSpace 

                } catch {
                    
                    Write-Host "Connection to $requirement failed" -ForegroundColor "DarkCyan"
                    $outputFailure = "The connection to $requirement failed and no output was returned."
                    New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                    $continue = $false  
                                             
                } # End try catch block
                
                foreach($volume in $volumes){
                    
                    $deviceID = $volume.DeviceID
                    $size = ($volume.Size/1GB)
                    $size = [math]::Round($size,2)
                    $freeSpace = ($volume.FreeSpace/1GB)
                    $freeSpace = [math]::Round($freeSpace,2) 

                    $output = "Volume Drive Letter: $deviceID" + "`r`n" + "Size: $size GB" + "`r`n" + "Free Space: $freeSpace MB"
                    New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output

                } # End foreach loop

            } # End ShouldProcess if statement

        } # End Server list loop

        Write-Host "The $requirement in all computers has been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-VolumeStorage function

#Get-VolumeStorage -computerName emttest -serverRole "web"