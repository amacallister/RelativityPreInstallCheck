function Get-RelativityServiceAccount {  
    <#
        .SYNOPSIS
        This commandlet returns the Relativity Service Account for a list of computers.
        .DESCRIPTION
        This commandlet returns the Relativity Service Account for a list of computers. It will return a list of all administrator accounts on each computer.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .OUTPUTS
        Returns the Relativity Service Account for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-RelativityServiceAccount -computerName computer -serverRole role
        .EXAMPLE
        Get-RelativityServiceAccount -computerName computer1, computer2 -serverRole role
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

        # Define Pre-Install Requirement Name
        $requirement = "Relativity Service Account"

        # Get the Relativity Service Account for each computer
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

                    try {

                        $accounts = net localgroup administrators | Out-String
                        
                        # Configure output
                        $output = $accounts
                     
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output 
                        Write-Host "The information will be written to c:\output.csv" -ForegroundColor "DarkCyan"                            
                        Write-Host "The $requirement for $computer has been checked." -ForegroundColor "DarkCyan"              

                     } catch {

                        Write-Host "Connection to $requirement failed" -ForegroundColor "DarkCyan"
                        $outputFailure = "The connection to $requirement failed and no output was returned."
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                        $continue = $false  
                                                     
                     } # End try catch block                
                                          
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

} # End Get-RelativityServiceAccount function

#Get-RelativityServiceAccount -computerName emttest -serverRole "web"                          