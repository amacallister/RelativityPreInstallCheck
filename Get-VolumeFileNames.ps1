function Get-VolumeFileNames {  
    <#
        .SYNOPSIS
        This commandlet returns the top level folder names of all volumes for a list of computers.
        .DESCRIPTION
        This commandlet returns the top level folder names of all volumes for a list of computers.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .OUTPUTS
        Outputs the top level folder names of all volumes for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-VolumeFileNames -computerName computer -serverRole role
        .EXAMPLE
        Get-VolumeFileNames -computerName computer1, computer2 -serverRole role
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
        $requirement = "Volume File Names"
         
        # Get the Volume File Names for each computer
        foreach ($computer in $computerName) {
            
            if ($PSCmdlet.ShouldProcess($computer)){                                           
               
                Write-Host "Checking $computer for $requirement..." -ForegroundColor "DarkCyan"

                # Getting File Names in each Volume
                try {
                    
                    $volumes = Get-WmiObject Win32_LogicalDisk -ErrorAction Stop -ComputerName $computer |
                        Select-Object DeviceID, Size 

                } catch {
                    
                    Write-Host "Connection to volumes failed" -ForegroundColor "DarkCyan"
                    $outputFailure = "The connection to $requirement failed and no output was returned."
                    New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                    $continue = $false 
                                              
                } # End try catch block
                
                #Format output for each computer
                foreach($volume in $volumes){
                   
                    $size = ($volume.Size/1GB)
                    
                    # Check if the volume has any storage. Do not look for a file name if storage is not greater than 0.
                    if($volume.Size -gt 0){ 
                        
                        $driveLetter = $volume.DeviceID
                        $path = "$driveLetter" + "\"
                        
                        $fileNames = Get-ChildItem $path | Select-Object Name
                        
                        foreach($fileName in $fileNames){
                           
                            $name = "$($fileName.Name)"
                            $output = $path + $name                            
                            New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output

                        } # End foreach fileNames loop

                    } # End if statement

                } # End foreach volumes loop

            } # End ShouldProcess if statement

        } # End Server list loop

        Write-Host "The Volume File Names in all computers have been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-VolumeFileNames function

#Get-VolumeFileNames -computerName emttest -serverRole "web"