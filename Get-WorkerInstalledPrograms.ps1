function Get-WorkerInstalledPrograms {  
    <#
        .SYNOPSIS
        This commandlet returns a report listing whether the required/optional Worker programs are installed for a list of computers.
        .DESCRIPTION
        This commandlet returns a report listing whether the required/optional Worker programs are installed for a list of computers. The programs include Microsoft Office 64-Bit Components 2010, SolidWorks, Hancom, JungUm Global Viewer, Microsoft Office Professional Plus 2010, Microsoft Office Project Professional 2010, Microsoft Office Visio 2010, Microsoft Works 6-9 Converter, Adobe Acrobat Reader DC, and Lotus Notes.                                    
        .PARAMETER computerName
        List of computer names to check. Accepts pipeline input.
        .PARAMETER serverRole
        Server Role Type of the computers passed into the function.
        .OUTPUTS
        Outputs the install status of required Worker Installed Programs for a list of computers in a file called output.csv.
        .EXAMPLE
        Get-WorkerInstalledPrograms -computerName computer -serverRole role
        .EXAMPLE
        Get-WorkerInstalledPrograms -computerName computer1, computer2 -serverRole role
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
        $requirement = "Required Worker Installed Programs"
       
        # Check the required Worker Installed Programs
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

                    # If the required Worker Installed Program is found, this setting will be true.
                    $foundMicrosoftOffice64BitComponents2010 = "false"
                    $foundSolidWorks = "false"
                    $foundHancom = "false"
                    $foundJungUmGlobalViewer = "false"
                    $foundMicrosoftOfficeProfessionalPlus2010 = "false"
                    $foundMicrosoftOfficeProjectProfessional2010 = "false"
                    $foundMicrosoftOfficeVisio2010 = "false"
                    $foundMicrosoftWorks69Converter = "false"
                    $foundAdobeAcrobatReaderDC = "false"
                    $foundLotusNotes = "false"

                    # Look up the Worker Installed Programs                              
                    $path1 = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\"
                    $path2 = "SOFTWARE\Wow6432node\Microsoft\Windows\CurrentVersion\Uninstall\"

                    # Create an instance of the Registry Object and open the HKLM base key 
                    try {

                        $reg1 = [microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$computer,'Registry64') 
                        $reg2 = [microsoft.win32.registrykey]::OpenRemoteBaseKey('LocalMachine',$computer,'Registry64') 

                    } catch {
                        
                        Write-Host "Creating registry object failed" -ForegroundColor "DarkCyan"
                        $outputFailure = "Creating registry object failed."
                        New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure                   
                        $continue = $false 

                    } # End try catch block for creating new registry object

                    # Drill down into the Uninstall key using the OpenSubKey Method 
                    try {

                        $regkey1 = $reg1.OpenSubKey($path1)  
                        $regkey2 = $reg2.OpenSubKey($path2) 

                    } catch {
                        
                       Write-Host "Opening the registry subkey failed" -ForegroundColor "DarkCyan"
                       $outputFailure = "Opening the registry subkey failed."
                       New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure                   
                       $continue = $false  
                        
                    } # End try catch block for opening the registry subkey

                    # Retrieve an array of string that contain all the subkey names 
                    try {

                        $subkeys1 = $regkey1.GetSubKeyNames()  
                        $subkeys2 = $regkey2.GetSubKeyNames() 
                                            
                    } catch {
                    
                       Write-Host "Getting the registry subkey names failed" -ForegroundColor "DarkCyan"
                       $outputFailure = "Getting the registry subkey names failed."
                       New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure                   
                       $continue = $false
                    
                    }  # End try catch block for getting the registry subkey names  

                    # Open each Subkey for $path1 and use GetValue Method to return the required values for each 
                    ForEach ($key in $subkeys1){   

                        $thisKey = $path1 + $key 
                        $thisSubKey = $reg1.OpenSubKey($thisKey) 
    
                        if($thisSubKey -ne $null) {
        
                            try {

                                $displayName = $($thisSubKey.getValue("displayName"))
                                $publisher = $($thisSubKey.getValue("publisher"))

                            } catch {

                                Write-Host "Getting the registry subkey value failed" -ForegroundColor "DarkCyan"
                                $outputFailure = "Getting the registry subkey value failed."
                                New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure                   
                                $continue = $false

                            } # End try catch block for getting subkey value

                        } # End if statement
                        
                        # Check Microsoft Office Office 64-bit Components 2010 program
                        if($DisplayName -eq "Microsoft Office Office 64-bit Components 2010"){
        
                            $MicrosoftOffice64BitComponents2010Output = $displayName
                            $foundMicrosoftOffice64BitComponents2010 = "true"

                        } # End if statement

                        # Check SolidWorks Program
                        if($publisher -eq "Dassault Systèmes SolidWorks Corp"){
        
                            $SolidWorksOutput = $displayName
                            $foundSolidWorks = "true"

                        } # End if statement
                                            
                    } # End $path1 for each loop

                    # Open each Subkey for $path2 and use GetValue Method to return the required values for each 
                    ForEach ($key in $subkeys2){   

                        $thisKey = $path2 + $key 
                        $thisSubKey = $reg2.OpenSubKey($thisKey) 
    
                        if($thisSubKey -ne $null) {
        
                            try {

                                $displayName = $($thisSubKey.getValue("displayName"))
                                $publisher = $($thisSubKey.getValue("publisher"))

                            } catch {

                                Write-Host "Getting the registry subkey value failed" -ForegroundColor "DarkCyan"
                                $outputFailure = "Getting the registry subkey value failed."
                                New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $outputFailure                   
                                $continue = $false

                            } # End try catch block for getting subkey value

                        } # End if statement

                        # Check Hancom Program
                        if($publisher -eq "Hancom"){
        
                            $HancomOutput = $publisher #$displayName
                            $foundHancom = "true"

                        } # End if statement

                        # Check JungUm Global Viewer Program
                        if($displayName -eq "JungUm Global Viewer"){
        
                            $JungUmGlobalViewerOutput = $displayName
                            $foundJungUmGlobalViewer = "true"

                        } # End if statement

                        # Check Microsoft Office Professional Plus 2010 Program
                        if($displayName -eq "Microsoft Office Professional Plus 2010"){
        
                            $MicrosoftOfficeProfessionalPlus2010Output = $displayName
                            $foundMicrosoftOfficeProfessionalPlus2010 = "true"

                        } # End if statement

                        # Check Microsoft Office Project Professional 2010 Program
                        if($displayName -eq "Microsoft Office Project Professional 2010"){
        
                            $MicrosoftOfficeProjectProfessional2010Output = $displayName
                            $foundMicrosoftOfficeProjectProfessional2010 = "true"

                        } # End if statement

                        # Check Microsoft Office Visio 2010 Program
                        if($displayName -eq "Microsoft Office Visio 2010"){
        
                            $MicrosoftOfficeVisio2010Output = $displayName
                            $foundMicrosoftOfficeVisio2010 = "true"

                        } # End if statement

                        # Check Microsoft Works 6-9 Converter Program
                        if($displayName -eq "Microsoft Works 6-9 Converter"){
        
                            $MicrosoftWorks69ConverterOutput = $displayName
                            $foundMicrosoftWorks69Converter = "true"

                        } # End if statement

                        # Check Adobe Acrobat Reader DC Program
                        if($displayName -eq "Adobe Acrobat Reader DC"){
        
                            $AdobeAcrobatReaderDCOutput = $displayName
                            $foundAdobeAcrobatReaderDC = "true"

                        } # End if statement

                        # Check Lotus Notes Program
                        if($publisher -eq "IBM"){
        
                            $LotusNotesOutput = $displayName
                            $foundLotusNotes = "true"

                        } # End if statement
                                                                    
                    } # End $path2 for each loop
                    
                    # Check if Microsoft Office 64-Bit Components 2010 was not installed       
                    if ($foundMicrosoftOffice64BitComponents2010 -eq "false") {
                    
                        $MicrosoftOffice64BitComponents2010Output = "Microsoft Office Office 64-bit is not installed."
                    
                    } # End if statement
                    
                    # Check if SolidWorks was not installed         
                    if ($foundSolidWorks -eq "false") {
                    
                        $SolidWorksOutput = "SolidWorks is not installed."
                    
                    } # End if statement

                    # Check if Hancom was not installed         
                    if ($foundHancom -eq "false") {
                    
                        $HancomOutput = "Hancom is not installed."
                    
                    } # End if statement

                    # Check if JungUm Global Viewer was not installed         
                    if ($foundJungUmGlobalViewer -eq "false") {
                    
                        $JungUmGlobalViewerOutput = "JungUm Global Viewer is not installed."
                    
                    } # End if statement

                    # Check if Microsoft Office Professional Plus 2010 was not installed         
                    if ($foundMicrosoftOfficeProfessionalPlus2010 -eq "false") {
                    
                        $MicrosoftOfficeProfessionalPlus2010Output = "Microsoft Office Professional Plus 2010 is not installed."
                    
                    } # End if statement

                    # Check if Microsoft Office Project Professional 2010 was not installed         
                    if ($foundMicrosoftOfficeProjectProfessional2010 -eq "false") {
                    
                        $MicrosoftOfficeProjectProfessional2010Output = "Microsoft Office Project Professional 2010 is not installed."
                    
                    } # End if statement

                    # Check if Microsoft Office Visio 2010 was not installed         
                    if ($foundMicrosoftOfficeVisio2010 -eq "false") {
                    
                        $MicrosoftOfficeVisio2010Output = "Microsoft Office Visio 2010 is not installed."
                    
                    } # End if statement

                    # Check if Microsoft Works 6-9 Converter was not installed         
                    if ($foundMicrosoftWorks69Converter -eq "false") {
                    
                        $MicrosoftWorks69ConverterOutput = "Microsoft Works 6-9 Converter is not installed."
                    
                    } # End if statement

                    # Check if Adobe Acrobat Reader DC was not installed         
                    if ($foundAdobeAcrobatReaderDC -eq "false") {
                    
                        $AdobeAcrobatReaderDCOutput = "Adobe Acrobat Reader DC is not installed."
                    
                    } # End if statement

                    # Check if Lotus Notes was not installed         
                    if ($foundLotusNotes -eq "false") {
                    
                        $LotusNotesOutput = "Lotus Notes is not installed."
                    
                    } # End if statement
                    
                    # Format final output
                    $output = $MicrosoftOffice64BitComponents2010Output + "`r`n" + 
                                $SolidWorksOutput + "`r`n" + 
                                $HancomOutput + "`r`n" + 
                                $JungUmGlobalViewerOutput + "`r`n" +                   
                                $MicrosoftOfficeProfessionalPlus2010Output + "`r`n" + 
                                $MicrosoftOfficeProjectProfessional2010Output + "`r`n" + 
                                $MicrosoftOfficeVisio2010Output + "`r`n" + 
                                $MicrosoftWorks69ConverterOutput + "`r`n" + 
                                $AdobeAcrobatReaderDCOutput + "`r`n" + 
                                $LotusNotesOutput

                    New-Output -serverRole $serverRole -serverName $computer -requirement $requirement -output $output 
                    Write-Host "The information will be written to c:\output.csv" -ForegroundColor "DarkCyan"                            
                    Write-Host "The Worker Installed Programs for $computer has been checked." -ForegroundColor "DarkCyan" 

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

        Write-Host "The Worker Installed Programs in all computers has been checked." -ForegroundColor "DarkCyan"
        Write-Host "All information was added to c:\output.csv". -ForegroundColor "DarkCyan"

    } # End Process Block

} # End Get-WorkerInstalledPrograms function

#Get-WorkerInstalledPrograms -computerName emttest -serverRole "worker"