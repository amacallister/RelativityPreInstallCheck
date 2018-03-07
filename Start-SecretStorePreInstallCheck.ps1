# Dot Source Script Functions
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

function Start-SecretStorePreInstallCheck { 
    <#
        .SYNOPSIS
        This commandlet runs all scripts for the Secret Store server role Pre-Install Check.
        .DESCRIPTION
        This commandlet runs all scripts for the Secret Store server role Pre-Install Check.
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .EXAMPLE
        Start-SecretStorePreInstallCheck -computerName computer -serverRole serverRole
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
    # Call all scripts for Secret Store Pre-Install Check
    Start-Remoting -computerName $computerName -serverRole $serverRole 
    Get-WindowsOsVersion -computerName $computerName -serverRole $serverRole
    Get-RAMAmount -computerName $computerName -serverRole $serverRole
    Get-NumCPU -computerName $computerName -serverRole $serverRole
    Get-dotNETVersion -computerName $computerName -serverRole $serverRole
    Get-VolumeFileNames -computerName $computerName -serverRole $serverRole
    Get-VolumeStorage -computerName $computerName -serverRole $serverRole
    Get-UACSetting -computerName $computerName -serverRole $serverRole
    Get-FirewallSetting -computerName $computerName -serverRole $serverRole
    Get-Ports -computerName $computerName -serverRole $serverRole
    Get-WindowsUpdateSetting -computerName $computerName -serverRole $serverRole
    Get-WindowsPowerPlan -computerName $computerName -serverRole $serverRole
    Get-WindowsVisualEffects -computerName $computerName -serverRole $serverRole
    Get-WindowsProcessorScheduling -computerName $computerName -serverRole $serverRole
    Get-WindowsServerVirtualMemory -computerName $computerName -serverRole $serverRole
    #DEFERREDGet-AntivirusExclusions -computerName $computerName -serverRole $serverRole
    Get-TLSSettings -computerName $computerName -serverRole $serverRole
    
} # End Start-SecretStorePreInstallCheck function