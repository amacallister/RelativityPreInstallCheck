function Get-EddsdboAccountPermissions {  
    <#
        .SYNOPSIS
        This commandlet returns the EDDSDBO Account Permissions for a list of computers.
        .DESCRIPTION
        This commandlet returns the EDDSDBO Account Permissions for a list of computers.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .PARAMETER credential
        SQL Server Instance sysadmin username and password
        .OUTPUTS
        Outputs the EDDSDBO Account Permissions for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-EddsdboAccountPermissions -computerName computer -serverRole role -credential credential
        .EXAMPLE
        Get-EddsdboAccountPermissions -computerName computer1, computer2 -serverRole role -credential credential
    #>
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]
    param(
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True)]
        [string[]]$computerName,

        [Parameter(Mandatory=$True)]
        [string]$serverRole,
        
        [ValidateNotNull()]
        [Parameter(Mandatory=$True)]
        $credential
    )
    Process {

        # Dot Source Script Functions
        . (Join-Path $PSScriptRoot New-Output.ps1)
        
        # Define Pre-Install Requirement Name
        $requirement = "EDDSDBO Account Permissions"

        # Set a computer counter in order to match the correct credentials to the correct computer
        $computerCounter = 0
       
        # Get the EDDSDBO Account Permissions
        foreach ($computer in $computerName) {

            if ($PSCmdlet.ShouldProcess($computer)){                
                
                Write-Host "Checking $computer for $requirement..."

                # Find SQL Server instance name
                $displayName = get-service MSSQLSERVER | Select-Object DisplayName
                $displayName = $displayName.DisplayName
                $displayName = $displayName.Split('(')
                $displayName = $displayName.Split(')')

                if($displayName[1] -eq 'MSSQLSERVER') {
                    
                # A custom name is not being used
                $sqlInstance = $computer

                }else {
                
                    # A custom name is being used
                    $sqlInstance = "$computer\$displayName"

                } # End if else block
                
                $createOutputFunctionDef = "function New-Output { ${function:New-Output} }"
                
                $Script = {                                                           
                    Param ( $createOutputFunctionDef)

                    . ([ScriptBlock]::Create($using:createOutputFunctionDef))

                    $serverRole = $using:serverRole                                            
                    $computer = $using:computer
                    $requirement = $using:requirement
                    $sqlInstance = $using:sqlInstance
                    $credential = $using:credential
                    $computerCounter = $using:computerCounter
                        
                    # Getting EDDSDBO Account Permissions
                    try {
                        
                        $username = $($credential[$computerCounter].UserName)
                        $password = $($credential[$computerCounter].Password)

                        # Decrypt secure string so it can be used with Invoke-Sqlcmd
                        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
                        $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
                        
                        # Query the SQL Server
                        $sqlQuery = "SELECT role.name FROM sys.server_role_members
                                        JOIN sys.server_principals AS role
                                         ON sys.server_role_members.role_principal_id = role.principal_id
                                        JOIN sys.server_principals AS member
                                         ON sys.server_role_members.member_principal_id = member.principal_id
	                                    WHERE member.name = 'eddsdbo'"
                        
                        $sqlResult = Invoke-Sqlcmd -ErrorAction Stop -ServerInstance $sqlInstance -Query $sqlQuery -Username $username -Password $password
                                               
                    } catch {
                 
                        Write-Host "Connection to the SQL Instance failed" -ForegroundColor "DarkCyan"
                        $outputFailure = "The connection to the SQL Instance failed and no output was returned."
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure   
                        $continue = $false

                    } # End try catch block                     
                    $name = $($sqlResult.name)

                    # Check if the account exists
                    if([string]::IsNullOrEmpty($name)){
                    
                        $output = "The account does not exist."

                    }else {

                        $output = "Name: $name"

                    } # End if else statement

                    New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output 
                    Write-Host "The information will be written to c:\output.csv" -ForegroundColor "DarkCyan"                            
                    Write-Host "The EDDSDBO Account Permissions for $computer has been checked." -ForegroundColor "DarkCyan"
                      
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

            $computerCounter ++

        } # End Server list loop

        Write-Host "The EDDSDBO Account Permissions in all computers has been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-EddsdboAccount function

#$credential = @()

#$cred1 = get-credential
#$cred2 = get-credential

#$credential += $cred1
#$credential += $cred2

#Get-EddsdboAccountPermissions -computerName emttest -serverRole "web" -credential $credential


