function Get-SharePermissions {  
    <#
        .SYNOPSIS
        This commandlet returns the Share Permissions for a list of computers.
        .DESCRIPTION
        This commandlet returns the Share Permissions for a list of computers.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .RETURN
        Returns the Share Permissions for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-SharePermissions -computerName computer -serverRole role
        .EXAMPLE
        Get-SharePermissions -computerName computer1, computer2 -serverRole role
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
        $requirement = "Share Permissions"
        
        # Get the Share Permissions for each computer
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
                    
                    # Look up the Path and Description information
                    try {

                         $shares = Get-SmbShare -ErrorAction 'Stop' | Where-Object {$_.Path -ne ""} | Select-Object Path, Description

                     } catch {

                          Write-Host "Connection to Share Permissions failed" -ForegroundColor "DarkCyan"
                          $outputFailure = "The connection to Share Permissions failed and no output was returned."
                          New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure   
                          $continue = $false  
                                                      
                     } # End try catch block 
                     
                     # Look up the Owner information
                    try {

                         # TODO: figure out how to deal with one object in the object list that has a null ACL
                         $permissions = Get-WmiObject -ErrorAction 'Stop' -Class Win32_Share | Where-Object {$_.Path -ne ""} | Get-Acl | Select-Object Owner

                     } catch {

                          Write-Host "Connection to Share Owner failed" -ForegroundColor "DarkCyan"
                          $outputFailure = "The connection to Share Permissions failed and no output was returned."
                          New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure   
                          $continue = $false  
                                                      
                     } # End try catch block                
                     
                     $pathCollection = @()
                     $descriptionCollection = @()
                     $ownerCollection = @()

                     # Add all paths to the path collection array
                     foreach ($path in $shares) {
    
                        $pathCollection += $path
    
                     } # End path collection foreach block

                     # Add all descriptions to the description array
                     foreach ($description in $shares) {
    
                        $descriptionCollection += $description
    
                     } # End description array foreach block

                     # Add all owners in the owner array
                     foreach ($owner in $permissions) {
    
                        $ownerCollection += $owner
    
                     } # End owner array foreach block

                     $pathLength = $($pathCollection.Length)

                     # Write output one index at a time from all three arrays
                     for ($i = 0; $i -lt $pathLength; $i++) { 
                        
                        $newPath =  $($pathCollection[$i].Path)
                        $newDescription = $($descriptionCollection[$i].Description)
                        $newOwner = $($ownerCollection[$i].Owner)

                        $output = "Path: $newPath" + "`r`n" +
                        "Description: $newDescription" + "`r`n" +
                        "Owner: $newOwner"
                        
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output
                        
                     } # End for loop

                        Write-Host "The information will be written to output.csv" -ForegroundColor "DarkCyan"
                        Write-Host "The Share Permissions for the computer have been checked." -ForegroundColor "DarkCyan"

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

        Write-Host "The Share Permissions in all computers have been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-SharePermissions function

#Get-SharePermissions -computerName emttest -serverRole "serviceBus"