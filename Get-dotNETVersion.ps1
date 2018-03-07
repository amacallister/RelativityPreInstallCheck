function Get-dotNETVersion {  
    <#
        .SYNOPSIS
        This commandlet returns the .NET version for a list of computers.
        .DESCRIPTION
        This commandlet returns the .NET version for a list of computers.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .RETURN
        Returns the .NET version for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-dotNETVersion -computerName computer -serverRole role
        .EXAMPLE
        Get-dotNETVersion -computerName computer1, computer2 -serverRole role
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
        $requirement = ".NET version"
        
        # Get the RAM Amount for each computer
        foreach ($computer in $computerName) {

            if ($PSCmdlet.ShouldProcess($computer)){                                         
                
                Write-Host "Checking $computer for $requirement..." -ForegroundColor "DarkCyan"

                # Getting .NET Version
                try {

                    $DotNetRelease = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\').Release 

                } catch {
                    
                    Write-Host "Connection to $requirement failed" -ForegroundColor "DarkCyan"
                    $outputFailure = "The connection to $requirement failed and no output was returned."
                    New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure
                    $continue = $false  
                                             
                } # End try catch block               
                 
                $DotNetVersion = "3.5"
    
                switch($DotNetRelease) {
                
                    460805{$DotNetVersion = "4.7"}
                    394806{$DotNetVersion = "4.6.2"}
                    394271{$DotNetVersion = "4.6.1"}
                    393297{$DotNetVersion = "4.6"}
                    379893{$DotNetVersion = "4.5.2"}
                    378675{$DotNetVersion = "4.5.1"}
                    378389{$DotNetVersion = "4.5"}
                    default{$DotNetVersion}

                } # End Switch statement

                $output = $DotNetVersion

                New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output

            } # End ShouldProcess if statement

        } # End Server list loop

        Write-Host "The $requirement in all computers has been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-dotNETVersion function

#Get-dotNETVersion -computerName emttest -serverRole "web"