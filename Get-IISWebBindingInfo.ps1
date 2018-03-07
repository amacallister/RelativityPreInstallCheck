function Get-IISWebBindingInfo {  
    <#
        .SYNOPSIS
        This commandlet returns the protocol and binding information for an IIS site in a list of computers.
        .DESCRIPTION
        This commandlet returns the protocol and binding information for an IIS site in a list of computers.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .OUTPUTS
        Returns the IIS Web Binding Information for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-IISWebBindingInfo -computerName computer -serverRole role
        .EXAMPLE
        Get-IISWebBindingInfo -computerName computer1, computer2 -serverRole role
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
        $requirement = "IIS Web Binding Info"
        
        # Import IIS PowerShell module
        Import-Module 'webAdministration'       

        # Get the bindings in IIS for each computer
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

                    # Look up the IIS binding information
                    try {
                         
                         $bindings = Get-WebBinding -ErrorAction 'Stop' -Name "Default Web Site" | 
                            Select protocol,bindingInformation

                     } catch {
                     
                        Write-Host "Connection to binding failed" -ForegroundColor "DarkCyan"
                        $outputFailure = "The connection to binding in IIS failed and no output was returned."
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure                   
                        $continue = $false   
                                            
                     } # End try catch block                
                 
                     foreach($binding in $bindings){

                        $output = "Binding: $($binding.protocol)" + "`r`n" + "$($binding.bindingInformation)"

                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output 
                        Write-Host "The information will be written to c:\output.csv" -ForegroundColor "DarkCyan"                            
                        Write-Host "The IIS Web Binding Info for $computer has been checked." -ForegroundColor "DarkCyan"

                     } # End binding foreach loop
                             
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

        Write-Host "All bindings in all computers have been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-IISWebBindingInfo function

#Get-IISWebBindingInfo -computerName emttest -serverRole "web"
