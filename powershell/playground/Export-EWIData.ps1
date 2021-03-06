<#
    .SYNOPSIS
        Export EWI data from the online form
    .DESCRIPTION
        This script parses the .csv file that is downloaded from the online form for
        Evening with industry. Using the data in the .csv it sorts the filenames that
        are also downloaded from the form and places them in a folder based on one or
        more majors that the student declared in the form.
        
        As the filenames are auto-generated when the student uploads, a new filename
        is created in the form of LastName_FirstName_Major.
    .PARAMETER CSVFileName
        The filename of the spreadsheet to import
    .EXAMPLE
        Set-Location .\Evening_With_Industry_201107Sep2011
        .\Export-EWIData.ps1 -CSVFileName .\Evening_With_Industry_201107Sep2011.csv
        
        Description
        -----------
        This is the only syntax for this script.
    .NOTES
        ScriptName: Export-EWIData.ps1
        Created By: Jeff Patton
        Date Coded: September 8, 2011
        ScriptName is used to register events for this script
        LogName is used to determine which classic log to write to
        
        ErrorCodes
            100 = Success
            101 = Error
            102 = Warning
            104 = Information
        
        There are some manual steps that need to be done first.
            1. Make sure that you are a reviewer on the EWI form
            2. Open the form from the Review Forms tab
            3. Download the spreadsheet
            4. Download all files
            5. Extract the .zip you downloaded in step 4
            6. Copy the spreadsheet you downloaded in step 3, to the folder created in step 5
            7. Set-Location to the path of the spreadsheet and run the script.
        
        If fields have been added or renamed you will need to modify the $Header variable manually
    .LINK
        https://trac.engr.ku.edu/powershell/browser/Public/Export-EWIData.ps1
    .LINK
        https://engr.ku.edu/online_forms/
#>
Param
    (
    [string]$CSVFileName
    )
Begin
    {
        $ScriptName = $MyInvocation.MyCommand.ToString()
        $LogName = "Application"
        $ScriptPath = $MyInvocation.MyCommand.Path
        $Username = $env:USERDOMAIN + "\" + $env:USERNAME

        New-EventLog -Source $ScriptName -LogName $LogName -ErrorAction SilentlyContinue

        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message 

        $DebugPreference=$VerbosePreference="Continue"
        $Header = "First Name","Last Name","E-mail","Level","Major","If other chosen above, please specify","Gender","Company 1","Company 2","Company 3","Company 4","Company 5","Resume","SWE Member?","If yes are you Volunteering?","Vegetarian Meal?","Comments","Paid?","Paid by Cash/Check?","Paid Online?","Application ID","Username","Submission Date"
        $Applicants = Import-Csv $CSVFileName -Header $Header
        }
Process
    {
        foreach ($Applicant in $Applicants)
        {
            Write-Verbose "Check if the resume is empty (65 -eq engineering url)."
            $Resume = $Applicant.Resume
            if ($Resume.Length -gt 65)
            {
                Write-Verbose "Build the resume filename"
                $Filename = "$($Applicant.("Application ID"))_Resume_$($Applicant.Resume.Remove(0,65))"
                Write-Verbose $FileName
                if ($Applicant.Major -like "*|*")
                {
                    Write-Verbose "This applicant has more than one major declared"
                    foreach ($Major in $Applicant.Major.Split("|"))
                    {
                        Write-Verbose "Check if the major directory exists"
                        if ((Test-Path -Path ".\$($Major.Trim())") -eq $false)
                        {
                            Write-Verbose "The $($Major.Trim()) directory doesn't exist, create it."
                            New-Item -Name $Major.Trim() -ItemType directory -Force
                            }
                        Write-Verbose "Build the proper resume filename"
                        $ResumeFilename = "$($Applicant.("Last Name"))_$($Applicant.("First Name"))_$($Major.Trim())$($Filename.Substring($Filename.IndexOf("."),($Filename.Length)-($Filename.IndexOf("."))))"
                        Write-Verbose $ResumeFilename
                        Write-Verbose "Copy $($Filename) to .\$($Major.Trim())"
                        Copy-Item ".\$($Filename)" -Destination ".\$($Major.Trim())\$($ResumeFilename)"
                        }
                    }
                else
                {
                    Write-Verbose "This applicant declared one major"
                    $Major = $Applicant.Major.Trim()
                    Write-Verbose "Check if the major directory exists"
                    if ((Test-Path -Path ".\$($Major)") -eq $false)
                    {
                        Write-Verbose "The $($Major) directory doesn't exist, create it."
                        New-Item -Name $Major -ItemType directory -Force
                        }
                    Write-Verbose "Build the proper resume filename"
                    $ResumeFilename = "$($Applicant.("Last Name"))_$($Applicant.("First Name"))_$($Major.Trim())$($Filename.Substring($Filename.IndexOf("."),($Filename.Length)-($Filename.IndexOf("."))))"
                    Write-Verbose $ResumeFilename
                    Write-Verbose "Copy $($Filename) to .\$($Major)"
                    Copy-Item ".\$($Filename)" -Destination ".\$($Major)\$($ResumeFilename)"
                    }
                }
            }
        }
End
    {
        $DebugPreference=$VerbosePreference="SilentlyContinue"
        $Message = "Script: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
        Write-EventLog -LogName $LogName -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message	
        }