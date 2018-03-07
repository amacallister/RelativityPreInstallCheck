function Get-IISVersion {  
    <#
        .SYNOPSIS
        This commandlet returns the version of IIS that is installed on a list of computers.
        .DESCRIPTION
        This commandlet returns the version of IIS that is installed on a list of computers.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .RETURN
        Outputs the IIS version for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-IISVersion -computerName computer -serverRole role
        .EXAMPLE
        Get-IISVersion -computerName computer1, computer2 -serverRole role
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
        $requirement = "IIS Version"
       
        # Check which version of IIS is installed
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

                    # Look up the IIS version                              
                    try {

                        $IISVersion = Get-ItemProperty -ErrorAction 'Stop' -Path 'HKLM:\SOFTWARE\Microsoft\InetStp' | select VersionString

                    } catch {

                        Write-Host "Connection to registry failed" -ForegroundColor "DarkCyan"
                        $outputFailure = "The connection to the IIS version in the registry failed and no output was returned."
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure                   
                        $continue = $false 
                                              
                    } # End try catch block
                                   
                     $output = $($IISVersion.VersionString)

                     New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output 
                     Write-Host "The information will be written to c:\output.csv" -ForegroundColor "DarkCyan"                            
                     Write-Host "The IIS version for $computer has been checked." -ForegroundColor "DarkCyan" 

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

        Write-Host "The IIS version in all computers has been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-IISVersion function

#Get-IISVersion -computerName emttest -serverRole "web"