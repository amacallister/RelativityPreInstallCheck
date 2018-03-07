function Get-FirewallSetting {  
    <#
        .SYNOPSIS
        This commandlet returns the Firewall Setting for a list of computers.
        .DESCRIPTION
        This commandlet returns the Firewall Setting for a list of computers. This will indicate if the firewall is enabled or not.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .RETURN
        Returns the Firewall Setting for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-FirewallSetting -computerName computer -serverRole role
        .EXAMPLE
        Get-FirewallSetting -computerName computer1, computer2 -serverRole role
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
        $requirement = "Firewall Setting"
        
        # Get the RAM Amount for each computer
        foreach ($computer in $computerName) {

            if ($PSCmdlet.ShouldProcess($computer)){                                         
                
                Write-Host "Checking $computer for $requirement..." -ForegroundColor "DarkCyan"

                # Getting Firewall Setting
                try {

                    $firewallProfileEnabled = Get-NetFirewallProfile | Select-Object Name, Enabled

                } catch {
                    
                    Write-Host "Connection to $requirement failed" -ForegroundColor "DarkCyan"
                    $outputFailure = "The connection to $requirement failed and no output was returned."
                    New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                    $continue = $false  
                                             
                } # End try catch block               
                 
                $isFirewallEnabled = 0

                if($firewallProfileEnabled[0].enabled -eq "True") {
                
                    $isFirewallEnabled = 1

                } # End if statement
                
                if($isFirewallEnabled) {

                    $output = "Firewall Enabled"

                } else {
                
                    $output = "Firewall Not Enabled"
                
                } # End if else statement

                New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output

            } # End ShouldProcess if statement

        } # End Server list loop

        Write-Host "The $requirement in all computers has been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-FirewallSetting function

#Get-FirewallSetting -computerName emttest -serverRole "web"