function Get-Ports {  
    <#
        .SYNOPSIS
        This commandlet returns the Port information for a list of computers.
        .DESCRIPTION
        This commandlet returns the Port information for a list of computers. This includes the rule name, direction, action, remote port, and local port.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .RETURN
        Returns the Port information for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-Ports -computerName computer -serverRole role
        .EXAMPLE
        Get-Ports -computerName computer1, computer2 -serverRole role
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
        $requirement = "Port Information"
        
        # Get the Port information for each computer
        foreach ($computer in $computerName) {

            if ($PSCmdlet.ShouldProcess($computer)){                                         
                
                Write-Host "Checking $computer for $requirement..." -ForegroundColor "DarkCyan"

                try {

                    $firewallProfileEnabled = Get-NetFirewallProfile -ErrorAction 'Stop' | Select-Object Name, Enabled

                } catch {
                
                    Write-Host "Connection to $requirement failed" -ForegroundColor "DarkCyan"
                    $outputFailure = "The connection to $requirement failed and no output was returned."
                    New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                    $continue = $false  
                
                } # End try catch block

                $isFirewallEnabled = "false"

                if($firewallProfileEnabled[0].enabled -eq "True") {

                    $isFirewallEnabled = "true"

                } # End if statement


                if($isFirewallEnabled -eq "true") {
 
                    # Getting Port information
                    try {

                        $firewallRule = Get-NetFirewallRule -ErrorAction 'Stop' | Select-Object DisplayName, Direction, Action

                    } catch {
                    
                        Write-Host "Connection to $requirement failed" -ForegroundColor "DarkCyan"
                        $outputFailure = "The connection to $requirement failed and no output was returned."
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                        $continue = $false  
                    
                    } # End firewallrule try catch block

                    try {

                        $firewallRemotePort = Get-NetFirewallRule -ErrorAction 'Stop' | Get-NetFirewallPortFilter | Select-Object remoteport

                    } catch {
                    
                        Write-Host "Connection to $requirement failed" -ForegroundColor "DarkCyan"
                        $outputFailure = "The connection to $requirement failed and no output was returned."
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                        $continue = $false
                    
                    } # End firewall remote port try catch block

                    try{

                        $firewallLocalPort =Get-NetFirewallRule -ErrorAction 'Stop' | Get-NetFirewallPortFilter | Select-Object localport

                    } catch {
                    
                        Write-Host "Connection to $requirement failed" -ForegroundColor "DarkCyan"
                        $outputFailure = "The connection to $requirement failed and no output was returned."
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                        $continue = $false  
                                             
                    } # End firewall local port try catch block
                    
                    $firewallRuleCollection = @()
                    $firewallRemotePortCollection = @()
                    $firewallLocalPortCollection = @()

                    # Add all firewall rules to the firewall rules array
                    foreach ($rule in $firewallRule) {
    
                        $firewallRuleCollection += $rule
    
                    } # End Rule array foreach block

                    # Add all remote ports to the remote ports array
                    foreach ($remotePort in $firewallRemotePort) {
    
                        $firewallRemotePortCollection += $remotePort
    
                    } # End Remote Port array foreach block

                    # Add all local ports to the local ports array
                    foreach ($localPort in $firewallLocalPort) {
    
                        $firewallLocalPortCollection += $localPort
    
                    } # End Local Port array foreach block

                    $ruleLength = $firewallRuleCollection.Length
                    
                    # Write output one index at a time from all three arrays
                    for ($i = 0; $i -lt $ruleLength; $i++) { 
                        
                        $ruleName =  $($firewallRuleCollection[$i].DisplayName)
                        $ruleDirection = $($firewallRuleCollection[$i].Direction)
                        $ruleAction = $($firewallRuleCollection[$i].Action)
                        $remotePort = $($firewallRemotePortCollection[$i].RemotePort)
                        $localPort = $($firewallLocalPortCollection[$i].LocalPort)

                        $output = "Rule Name: $ruleName" + "`r`n" +
                        "Rule Direction: $ruleDirection" + "`r`n" +
                        "Rule Action: $ruleAction" + "`r`n" +
                        "Remote Port: $remotePort" + "`r`n" +
                        "Local Port: $localPort"
                        
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output
                        
                    } # End for loop

                } else {

                    $output =  "Firewall is disabled"
                    New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output

                } # End if else statement
                                                  
            } # End ShouldProcess if statement

        } # End Server list loop

        Write-Host "The $requirement in all computers has been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-Ports function

#Get-Ports -computerName emttest -serverRole "web"