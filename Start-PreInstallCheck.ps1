# Dot Source Script Functions
. (Join-Path $PSScriptRoot Start-SqlPreInstallCheck.ps1)
. (Join-Path $PSScriptRoot Start-SecretStorePreInstallCheck.ps1)
. (Join-Path $PSScriptRoot Start-DistributedSqlPreInstallCheck.ps1)
. (Join-Path $PSScriptRoot Start-ServiceBusPreInstallCheck.ps1)
. (Join-Path $PSScriptRoot Start-WebPreInstallCheck.ps1)
. (Join-Path $PSScriptRoot Start-CoreAgentPreInstallCheck.ps1)
. (Join-Path $PSScriptRoot Start-dtSearchAgentPreInstallCheck.ps1)
. (Join-Path $PSScriptRoot Start-ConversionAgentPreInstallCheck.ps1)
. (Join-Path $PSScriptRoot Start-AnalyticsPreInstallCheck.ps1)
. (Join-Path $PSScriptRoot Start-InvariantSqlPreInstallCheck.ps1)
. (Join-Path $PSScriptRoot Start-QueueManagerPreInstallCheck.ps1)
. (Join-Path $PSScriptRoot Start-WorkerPreInstallCheck.ps1)
. (Join-Path $PSScriptRoot Start-FilePreInstallCheck.ps1)
. (Join-Path $PSScriptRoot Start-SMTPPreInstallCheck.ps1)
. (Join-Path $PSScriptRoot New-Output.ps1)
. (Join-Path $PSScriptRoot Start-Remoting.ps1)
. (Join-Path $PSScriptRoot Get-CostThresholdForParallelism.ps1)
. (Join-Path $PSScriptRoot Get-DesktopExperienceInstallStatus.ps1)
. (Join-Path $PSScriptRoot Get-dotNETVersion.ps1)
. (Join-Path $PSScriptRoot Get-DtcEnabledStatus.ps1)
. (Join-Path $PSScriptRoot Get-EddsdboAccount.ps1)
. (Join-Path $PSScriptRoot Get-EddsdboAccountPermissions.ps1)
. (Join-Path $PSScriptRoot Get-FileAllocationUnitSize.ps1)
. (Join-Path $PSScriptRoot Get-FirewallSetting.ps1)
. (Join-Path $PSScriptRoot Get-FullyQualifiedDomainNameSmtpServer.ps1)
. (Join-Path $PSScriptRoot Get-IISExpirationHeaderInfo.ps1)
. (Join-Path $PSScriptRoot Get-IISFailedRequestTracingRulesValue.ps1)
. (Join-Path $PSScriptRoot Get-IISLogFileOptions.ps1)
. (Join-Path $PSScriptRoot Get-IISVersion.ps1)
. (Join-Path $PSScriptRoot Get-IISWebBindingInfo.ps1)
. (Join-Path $PSScriptRoot Get-InstantFileInitializationStatus.ps1)
. (Join-Path $PSScriptRoot Get-InternetExplorerEnhancedSecurityConfigurationStatus.ps1)
. (Join-Path $PSScriptRoot Get-LegacyUnhandledExceptionPolicyStatus.ps1)
. (Join-Path $PSScriptRoot Get-ListOfLinkedSQLServers.ps1)
. (Join-Path $PSScriptRoot Get-MaxDegreeOfParallelism.ps1)
. (Join-Path $PSScriptRoot Get-MaxServerMemory.ps1)
. (Join-Path $PSScriptRoot Get-MixedModeAuthenticationStatus.ps1)
. (Join-Path $PSScriptRoot Get-NumCPU.ps1)
. (Join-Path $PSScriptRoot Get-OptimizeForAdHocWorkloads.ps1)
. (Join-Path $PSScriptRoot Get-Ports.ps1)
. (Join-Path $PSScriptRoot Get-RAMAmount.ps1)
. (Join-Path $PSScriptRoot Get-RelativityServiceAccount.ps1)
. (Join-Path $PSScriptRoot Get-RelativitySqlAccount.ps1)
. (Join-Path $PSScriptRoot Get-RelativitySqlAccountPermissions.ps1)
. (Join-Path $PSScriptRoot Get-RemoteQueryTimeout.ps1)
. (Join-Path $PSScriptRoot Get-SaSqlAccount.ps1)
. (Join-Path $PSScriptRoot Get-ServerRolesAndFeatures.ps1)
. (Join-Path $PSScriptRoot Get-ServiceBusCertStatus.ps1)
. (Join-Path $PSScriptRoot Get-ServiceBusConfig.ps1)
. (Join-Path $PSScriptRoot Get-ServiceBusDNSAccessibility.ps1)
. (Join-Path $PSScriptRoot Get-ServiceBusServicesRunningStatus.ps1)
. (Join-Path $PSScriptRoot Get-ServiceBusVersion.ps1)
. (Join-Path $PSScriptRoot Get-SharePermissions.ps1)
. (Join-Path $PSScriptRoot Get-SqlFullTextFilterDaemonLauncherServiceInstallStatus.ps1)
. (Join-Path $PSScriptRoot Get-SqlServerVersion.ps1)
. (Join-Path $PSScriptRoot Get-SqlServiceLogonAsAccount.ps1)
. (Join-Path $PSScriptRoot Get-TcpChimneyOffloadingStatus.ps1)
. (Join-Path $PSScriptRoot Get-tempDBInformation.ps1)
. (Join-Path $PSScriptRoot Get-TempDriveLocation.ps1)
. (Join-Path $PSScriptRoot Get-TLSSettings.ps1)
. (Join-Path $PSScriptRoot Get-UACSetting.ps1)
. (Join-Path $PSScriptRoot Get-VolumeFileNames.ps1)
. (Join-Path $PSScriptRoot Get-VolumeStorage.ps1)
. (Join-Path $PSScriptRoot Get-WindowsOsVersion.ps1)
. (Join-Path $PSScriptRoot Get-WindowsPowerPlan.ps1)
. (Join-Path $PSScriptRoot Get-WindowsProcessorScheduling.ps1)
. (Join-Path $PSScriptRoot Get-WindowsServerVirtualMemory.ps1)
. (Join-Path $PSScriptRoot Get-WindowsUpdateSetting.ps1)
. (Join-Path $PSScriptRoot Get-WindowsVisualEffects.ps1)
. (Join-Path $PSScriptRoot Get-WorkerInstalledPrograms.ps1)

function Start-PreInstallCheck {  
    <#
        .SYNOPSIS
        This commandlet returns a report called output.csv
        .DESCRIPTION
        This commandlet returns a report called output.csv listing the Server Roles, Server Names, Requirements, and Output for each Pre-Install Requirement based on input in an input.csv file.
        .PARAMETER inputPath
        String value that indicates the path of the input.csv file.
        .PARAMETER all
        Switch value that indicates all server roles should be checked for pre-install requirements.
        .PARAMETER sql
        Switch value that indicates the Primary SQL server role should be checked for pre-install requirements.
        .PARAMETER secretStore
        Switch value that indicates the Secret Store server role should be checked for pre-install requirements.
        .PARAMETER distributedSql
        Switch value that indicates the Distributed SQL server role should be checked for pre-install requirements.
        .PARAMETER serviceBus
        Switch value that indicates the Service Bus server role should be checked for pre-install requirements.
        .PARAMETER web
        Switch value that indicates the Web server role should be checked for pre-install requirements.
        .PARAMETER coreAgent
        Switch value that indicates the Core Agent server role should be checked for pre-install requirements.
        .PARAMETER dtSearchAgent
        Switch value that indicates the dtSearch Agent server role should be checked for pre-install requirements.
        .PARAMETER conversionAgent
        Switch value that indicates the Conversion Agent server role should be checked for pre-install requirements.
        .PARAMETER analytics
        Switch value that indicates the Analytics server role should be checked for pre-install requirements.
        .PARAMETER invariantSql
        Switch value that indicates the Invariant SQL server role should be checked for pre-install requirements.
        .PARAMETER queueManager
        Switch value that indicates the Queue Manager server role should be checked for pre-install requirements.
        .PARAMETER worker
        Switch value that indicates the Worker server role should be checked for pre-install requirements.
        .PARAMETER file
        Switch value that indicates the File server role should be checked for pre-install requirements.
        .PARAMETER smtp
        Switch value that indicates the SMTP server role should be checked for pre-install requirements.
        .PARAMETER input
        CSV file where each entry has a Server Role, Server Name, and Roles and Features if the server role is web or agent.  
        .INPUTS
        input.csv file that contains the Server Roles, Server Names, Web Roles and Features, and Agent Roles and Features
        .OUTPUTS
        output.csv file that contains the Server Roles, Server Names, Requirements, and Output for each Pre-Install Requirement
        .EXAMPLE
        Start-PreInstallCheck -inputPath c:\input.csv -all
        .EXAMPLE
        Start-PreInstallCheck -inputPath c:\input.csv -sql -distributedSql -serviceBus
    #>
    [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Low')]
    param(
        [Parameter(Mandatory=$True,
                   ValueFromPipeline=$True,
                   ValueFromPipelineByPropertyName=$True)]
        [string]$inputPath,
        
        [Parameter(ParameterSetName=’CheckAllServerRoles’)]
        [switch]$all,
        
        [Parameter(ParameterSetName=’CheckSpecificServerRoles’)]
        [switch]$sql,

        [Parameter(ParameterSetName=’CheckSpecificServerRoles’)]
        [switch]$secretStore,

        [Parameter(ParameterSetName=’CheckSpecificServerRoles’)]
        [switch]$distributedSql,

        [Parameter(ParameterSetName=’CheckSpecificServerRoles’)]
        [switch]$serviceBus,

        [Parameter(ParameterSetName=’CheckSpecificServerRoles’)]
        [switch]$web,
        
        [Parameter(ParameterSetName=’CheckSpecificServerRoles’)]
        [switch]$coreAgent,

        [Parameter(ParameterSetName=’CheckSpecificServerRoles’)]
        [switch]$dtSearchAgent,

        [Parameter(ParameterSetName=’CheckSpecificServerRoles’)]
        [switch]$conversionAgent,

        [Parameter(ParameterSetName=’CheckSpecificServerRoles’)]
        [switch]$analytics,

        [Parameter(ParameterSetName=’CheckSpecificServerRoles’)]
        [switch]$invariantSql,

        [Parameter(ParameterSetName=’CheckSpecificServerRoles’)]
        [switch]$queueManager,
        
        [Parameter(ParameterSetName=’CheckSpecificServerRoles’)]
        [switch]$worker,
        
        [Parameter(ParameterSetName=’CheckSpecificServerRoles’)]
        [switch]$file,

        [Parameter(ParameterSetName=’CheckSpecificServerRoles’)]
        [switch]$smtp        
    )
    Process {
        
       # Read computers input in from the input file.
       $csvInput = Import-Csv -Path $inputPath 

       # Run Pre-Install Checks on all server roles
        if($all){
            
            # Set all Server Role flags to True
            $sql = $true
            $secretStore = $true
            $distributedSql = $true
            $serviceBus = $true
            $web = $true       
            $coreAgent = $true      
            $dtSearchAgent = $true
            $conversionAgent = $true
            $analytics = $true
            $invariantSql = $true
            $queueManager = $true
            $worker = $true
            $file = $true
            $smtp = $true     
                                    
        } # End All if statement

        if($sql){
            
            # Run Primary SQL Server Pre-Install Check
            $primarySqlServers = $csvInput | Where-Object{$_.ServerRole -eq "sql"} | Select-Object ServerName
            $primarySqlServers = $primarySqlServers.ServerName
            $credential = @()

            ForEach($computer in $primarySqlServers) {

                $popupComplete = "False"
                $loopCounter = 0

                #region Get SQL Server credentials
                do {

                    try {
                        
                        $done = $True

                        do {

                            Write-Host "Please enter sysadmin credentials for the Primary SQL Server instance on $computer."
                            $newCredential = Get-Credential -Message "Please enter sysadmin credentials for the Primary SQL Server instance on $computer."

                            # Input validation - make sure password is not empty
                            $password = $newCredential.Password
                            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
                            $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

                            # Password if statement
                            if($password::Empty -or $password -eq '' -or $password -eq $null) {
                        
                                $done = $False
                                Write-Host "The password field is empty. Try entering credentials again."
                                                   
                            }# End password if statement
                            
                        } while($done -eq $False)

                        $credential += $newCredential
                        $popupComplete = "True"

                    } catch {
                
                        # The credentials pop-up was cancelled out.
                        $popupComplete = "False"                       

                        # This counter will increment until the value is equal to five.
                        $loopCounter ++
                        
                        # Message user
                        Write-Host "You clicked cancel in the credentials pop-up $loopCounter time(s). Please try again. You will have 5 chances before the Pre-Install Check will continue without credentials."                        

                    } # End try catch block

                } while($popupComplete -eq "False" -AND $loopCounter -lt 5)
           
                if($loopCounter -eq 5) {
                
                    Write-Host "The credential pop-up has been cancelled 5 times. The credentials will remain empty and all SQL scripts relying on that value will produce no output."

                    try {

                        $newCredential.UserName = "NoValue"
                        $newCredential.Password = "NoValue"

                    } catch {
                    
                        Write-Host "Empty credentials will be passed to $computer."
                    
                    } # End empty credential object try catch block

                    $credential += $newCredential

                } # End loop counter if statement

            } #endregion End Credentials ForEach loop

            Write-Host "Running the Primary SQL Server Server Role scripts..."
            Start-SqlPreInstallCheck -computerName $primarySqlServers -serverRole "sql" -credential $credential
            Write-Host "The Primary SQL Server Role Pre-Install Check is complete."
        
        } # End SQL if statement

        if($secretStore){

            # Run Secret Store Server Pre-Install Check
            $secretStoreServers = $csvInput | Where-Object{$_.ServerRole -eq "secretStore"} | Select-Object ServerName
            $secretStoreServers = $secretStoreServers.ServerName
            Write-Host "Running the Secret Store Server Role scripts..."
            Start-SecretStorePreInstallCheck -computerName $secretStoreServers -serverRole "serviceBus"
            Write-Host "The Secret Store Server Role Pre-Install Check is complete."

        } # End Secret Store if statement
                
        if($distributedSql){
            
            # Run Distributed SQL Server Pre-Install Check
            $distributedSqlServers = $csvInput| Where-Object{$_.ServerRole -eq "distributedSql"} | Select-Object ServerName
            $distributedSqlServers = $distributedSqlServers.ServerName
            $credential = @()

            ForEach($computer in $distributedSqlServers) {

                $popupComplete = "False"
                $loopCounter = 0

                #region Get SQL Server credentials
                do {

                    try {
                        
                        $done = $True

                        do {

                            Write-Host "Please enter sysadmin credentials for the Distributed SQL Server instance on $computer."
                            $newCredential = Get-Credential -Message "Please enter sysadmin credentials for the Distributed SQL Server instance on $computer."

                            # Input validation - make sure password is not empty
                            $password = $newCredential.Password
                            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
                            $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

                            # Password if statement
                            if($password::Empty -or $password -eq '' -or $password -eq $null) {
                        
                                $done = $False
                                Write-Host "The password field is empty. Try entering credentials again."
                                                   
                            }# End password if statement
                            
                        } while($done -eq $False)

                        $credential += $newCredential
                        $popupComplete = "True"

                    } catch {
                
                        # The credentials pop-up was cancelled out.
                        $popupComplete = "False"                       

                        # This counter will increment until the value is equal to five.
                        $loopCounter ++
                        
                        # Message user
                        Write-Host "You clicked cancel in the credentials pop-up $loopCounter time(s). Please try again. You will have 5 chances before the Pre-Install Check will continue without credentials."                        

                    } # End try catch block

                } while($popupComplete -eq "False" -AND $loopCounter -lt 5)
           
                if($loopCounter -eq 5) {
                
                    Write-Host "The credential pop-up has been cancelled 5 times. The credentials will remain empty and all SQL scripts relying on that value will produce no output."
                    
                    try {

                        $newCredential.UserName = "NoValue"
                        $newCredential.Password = "NoValue"

                    } catch {
                    
                        Write-Host "Empty credentials will be passed to $computer."
                    
                    } # End empty credential object try catch block

                    $credential += $newCredential

                } # End loop counter if statement

            } #endregion End Credentials ForEach loop

            Write-Host "Running the Distributed SQL Server Role scripts..."
            Start-DistributedSqlPreInstallCheck -computerName $distributedSqlServers -serverRole "distributedSql" -credential $credential
            Write-Host "The Distributed SQL Server Role Pre-Install Check is complete."
        
        } # End Distributed SQL if statement

        if($serviceBus){

            # Run Service Bus Server Pre-Install Check
            $serviceBusServers = $csvInput | Where-Object{$_.ServerRole -eq "serviceBus"} | Select-Object ServerName
            $serviceBusServers = $serviceBusServers.ServerName
            Write-Host "Running the Service Bus Server Role scripts..."
            Start-ServiceBusPreInstallCheck -computerName $serviceBusServers -serverRole "serviceBus"
            Write-Host "The Service Bus Server Role Pre-Install Check is complete."

        } # End Service Bus if statement

        if($web){
            
            # Run Web Server Pre-Install Check
            $webServers = $csvInput | Where-Object{$_.ServerRole -eq "web"} | Select-Object ServerName
            $webServerRoles = $csvInput | Select-Object WebRolesAndFeatures | Where-Object{$_.WebRolesAndFeatures -ne ""}
            $webServers = $webServers.ServerName
            $webServerRoles = $webServerRoles.WebRolesAndFeatures
            Write-Host "Running the Web Server Role scripts..."
            Start-WebPreInstallCheck -computerName $webServers -serverRole "web" -rolesAndFeatures $webServerRoles
            Write-Host "The Web Server Role Pre-Install Check is complete."
        
        } # End Web if statement

        if($coreAgent){

            # Run Core Agent Server Pre-Install Check
            $coreAgentServers = $csvInput | Where-Object{$_.ServerRole -eq "coreAgent"} | Select-Object ServerName
            $coreAgentServerRoles = $csvInput | Select-Object AgentRolesAndFeatures | Where-Object{$_.AgentRolesAndFeatures -ne ""}
            $coreAgentServers = $coreAgentServers.ServerName
            $coreAgentServerRoles = $coreAgentServerRoles.AgentRolesAndFeatures
            Write-Host "Running the Core Agent Server Role scripts..."
            Start-CoreAgentPreInstallCheck -computerName $coreAgentServers -serverRole "coreAgent" -rolesAndFeatures $coreAgentServerRoles
            Write-Host "The Core Agent Server Role Pre-Install Check is complete."
        
        } # End Core Agent if statement

        if($dtSearchAgent){

            # Run dtSearch Agent Server Pre-Install Check
            $dtSearchAgentServers = $csvInput| Where-Object{$_.ServerRole -eq "dtSearchAgent"} | Select-Object ServerName
            $dtSearchAgentServerRoles = $csvInput | Select-Object AgentRolesAndFeatures | Where-Object{$_.AgentRolesAndFeatures -ne ""}
            $dtSearchAgentServers = $dtSearchAgentServers.ServerName
            $dtSearchServerRoles = $dtSearchServerRoles.AgentRolesAndFeatures            
            Write-Host "Running the dtSearch Agent Server Role scripts..."
            Start-dtSearchAgentPreInstallCheck -computerName $dtSearchAgentServers -serverRole "dtSearchAgent" -rolesAndFeatures $dtSearchAgentServerRoles
            Write-Host "The dtSearch Agent Server Role Pre-Install Check is complete."
        
        } # End dtSearch Agent if statement

        if($conversionAgent){

            # Run Conversion Agent Server Pre-Install Check
            $conversionAgentServers = $csvInput | Where-Object{$_.ServerRole -eq "conversionAgent"} | Select-Object ServerName
            $conversionAgentServerRoles = $csvInput | Select-Object AgentRolesAndFeatures | Where-Object{$_.AgentRolesAndFeatures -ne ""}
            $conversionAgentServers = $conversionAgentServers.ServerName
            $conversionServerRoles = $conversionServerRoles.AgentRolesAndFeatures  
            Write-Host "Running the Conversion Agent Server Role scripts..."
            Start-ConversionAgentPreInstallCheck -computerName $conversionAgentServers -serverRole "conversionAgent" -rolesAndFeatures $conversionAgentServerRoles
            Write-Host "The Conversion Agent Server Role Pre-Install Check is complete."
        
        } # End Conversion Agent if statement

        if($analytics){

            # Run Analytics Server Pre-Install Check
            $analyticsServers = $csvInput | Where-Object{$_.ServerRole -eq "analytics"} | Select-Object ServerName
            $analyticsServers = $analyticsServers.ServerName
            Write-Host "Running the Analytics Server Role scripts..."
            Start-AnalyticsPreInstallCheck -computerName $analyticsServers -serverRole "analytics"
            Write-Host "The Analytics Server Role Pre-Install Check is complete."
        
        } # End Analytics if statement

        if($invariantSql){

            # Run Invariant SQL Server Pre-Install Check
            $invariantSqlServers = $csvInput | Where-Object{$_.ServerRole -eq "invariantSql"} | Select-Object ServerName
            $invariantSqlServers = $invariantSqlServers.ServerName
            $popupComplete = "False"
            $loopCounter = 0
            $credential = @()

            ForEach($computer in $invariantSqlServers) {

                $popupComplete = "False"
                $loopCounter = 0

                #region Get SQL Server credentials
                do {

                    try {
                        
                        $done = $True

                        do {

                            Write-Host "Please enter sysadmin credentials for the Invariant SQL Server instance on $computer."
                            $newCredential = Get-Credential -Message "Please enter sysadmin credentials for the Invariant SQL Server instance on $computer."

                            # Input validation - make sure password is not empty
                            $password = $newCredential.Password
                            $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
                            $password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

                            # Password if statement
                            if($password::Empty -or $password -eq '' -or $password -eq $null) {
                        
                                $done = $False
                                Write-Host "The password field is empty. Try entering credentials again."
                                                   
                            }# End password if statement
                            
                        } while($done -eq $False)

                        $credential += $newCredential
                        $popupComplete = "True"

                    } catch {
                
                        # The credentials pop-up was cancelled out.
                        $popupComplete = "False"                       

                        # This counter will increment until the value is equal to five.
                        $loopCounter ++
                        
                        # Message user
                        Write-Host "You clicked cancel in the credentials pop-up $loopCounter time(s). Please try again. You will have 5 chances before the Pre-Install Check will continue without credentials."                        

                    } # End try catch block

                } while($popupComplete -eq "False" -AND $loopCounter -lt 5)
           
                if($loopCounter -eq 5) {
                
                    Write-Host "The credential pop-up has been cancelled 5 times. The credentials will remain empty and all SQL scripts relying on that value will produce no output."
                    
                    try {

                        $newCredential.UserName = "NoValue"
                        $newCredential.Password = "NoValue"

                    } catch {
                    
                        Write-Host "Empty credentials will be passed to $computer."
                    
                    } # End empty credential object try catch block

                    $credential += $newCredential

                } # End loop counter if statement

            } #endregion End Credentials ForEach loop
            
            Write-Host "Running the Invariant SQL Server Role scripts..."
            Start-InvariantSqlPreInstallCheck -computerName $invariantSqlServers -serverRole "invariantSql" -credential $credential
            Write-Host "The Invariant SQL Server Role Pre-Install Check is complete."
        
        } # End Invariant SQL if statement

        if($queueManager){

            # Run Queue Manager Server Pre-Install Check
            $queueManagerServers = $csvInput | Where-Object{$_.ServerRole -eq "queueManager"} | Select-Object ServerName
            $queueManagerServers = $queueManagerServers.ServerName
            Write-Host "Running the Queue Manager Server Role scripts..."
            Start-QueueManagerPreInstallCheck -computerName $queueManagerServers -serverRole "queueManager"
            Write-Host "The Queue Manager Server Role Pre-Install Check is complete."
        
        } # End Queue Manager if statement

        if($worker){
            
            # Run Worker Server Pre-Install Check
            $workerServers = $csvInput | Where-Object{$_.ServerRole -eq "worker"} | Select-Object ServerName
            $workerServers = $workerServers.ServerName
            Write-Host "Running the Worker Server Role scripts..."
            Start-WorkerPreInstallCheck -computerName $workerServers -serverRole "worker"
            Write-Host "The Worker Server Role Pre-Install Check is complete."
        
        } # End Worker if statement

        if($file){

            # Run File Server Pre-Install Check
            $fileServers = $csvInput | Where-Object{$_.ServerRole -eq "file"} | Select-Object ServerName     
            $fileServers = $fileServers.ServerName
            Write-Host "Running the File Server Role scripts..."
            Start-FilePreInstallCheck -computerName $fileServers -serverRole "file"
            Write-Host "The File Server Role Pre-Install Check is complete."
        
        } # End File if statement

        if($smtp){

            # Run SMTP Server Pre-Install Check
            $smtpServers = $csvInput | Where-Object{$_.ServerRole -eq "smtp"} | Select-Object ServerName
            $smtpServers = $smtpServers.ServerName
            Write-Host "Running the SMTP Server Role scripts..."
            Start-SMTPPreInstallCheck -computerName $smtpServers -serverRole "smtp"
            Write-Host "The SMTP Server Role Pre-Install Check is complete."
        
        } # End SMTP if statement

        Write-Host "All server pre-install checks are now complete. The results were compiled in c:\output.csv."

    } # End Process Block

} # End Start-PreInstallCheck function

#Start-PreInstallCheck -inputPath C:\input.csv -sql -secretStore -distributedSql -serviceBus -web -coreAgent -dtSearchAgent -conversionAgent -analytics -invariantSql -queueManager -worker -file -smtp
#Start-PreInstallCheck -inputPath C:\input.csv -invariantSql