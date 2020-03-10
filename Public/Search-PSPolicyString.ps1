<#
.SYNOPSIS
Searches PowerShell logging locations for a pattern.
.DESCRIPTION
Searches PowerShell logging locations for a string pattern with wildcards or a regular expression, limiting the search to the scope and timespan specified.
.PARAMETER Scope
800 - Module logging event ID from 'Windows PowerShell' log
4103 - Module logging event ID from 'Microsoft-Windows-PowerShell/Operational' log
4104 - Script block logging event ID from 'Microsoft-Windows-PowerShell/Operational' log
Transcript - Retrieve the output directory of transcription from the policy path in the registry
PSReadline - All PSReadline history files across all user profiles
All - All of the above
.PARAMETER Timespan
A PowerShell timespan object defining how far back to search,
retrieving all entries newer than that time.
Defaults to searching the previous 24 hours of logs.
.PARAMETER Pattern
Behaves like the -Pattern parameter of Select-String.
With the -SimpleMatch parameter it is a simple string that can use * and ? wildcards. Automatically surrounds the string with a * at front and back.
Without the -SimpleMatch parameter it is a regular expression. Automatically surrounds the string with a .* at front and back.
.PARAMETER SimpleMatch
Behaves like the -SimpleMatch parameter of Select-String.
Instructs the Pattern parameter to use wildcards instead of regular expressions.
.EXAMPLE
PS C:\> Search-PSPolicyString -Pattern foo
Searches all PowerShell logging locations for the string "foo" over the last 24 hours.
.EXAMPLE
PS C:\> Search-PSPolicyString -Scope All -Timespan (New-TimeSpan -Hours 6) -Pattern foo
Searches all PowerShell logging locations for the string "foo" over the last six hours.
.EXAMPLE
PS C:\> Search-PSPolicyString -Pattern get-proc?ss -SimpleMatch -Scope 800,4103,4104 -TimeSpan (New-TimeSpan -Minutes 100)
Searches event logs over the last 100 minutes for the wildcard pattern "*get-proc?ss*".
.EXAMPLE
PS C:\> Search-PSPolicyString -Pattern 127\.0\.0\.1 -SimpleMatch -Scope All -TimeSpan (New-TimeSpan -Hours 1)
Searches all logs over the last 1 hour for the regular expression".*127\.0\.0\.1.*".
.NOTES
The PSReadline history file does not have datetime stamps for each command executed. It will only be searched if the file has been touched within the specified time period, but commands could have been executed at an undeterminable time in the past.
The TimeSpan parameter usage is directly proportional to the amount of time required to complete the search.
FOR NOW THIS OUTPUT IS UGLY. OPEN TO SUGGESTIONS ON BETTER WAYS TO PROCESS THE OUTPUT.
Beware that using PowerShell commands to search for a keyword will introduce that keyword into the logs, poisoning the logs so-to-speak. Now all future searches will show the search itself, including any occurrences. This can create huge transcript files especially.
#>
Function Search-PSPolicyString {
    [CmdletBinding()]
    param(
        [Parameter()]
        [ValidateSet('800','4103','4104','Transcript','PSReadline','All')]
        [string[]]
        $Scope = @('All'),
        [Parameter()]
        [timespan]
        $TimeSpan = (New-TimeSpan -Hours 24),
        [Parameter(Mandatory=$True)]
        [string]
        $Pattern,
        [Parameter()]
        [switch]
        $SimpleMatch
    )

    If ($Scope -contains 'All' -or $Scope -contains '800') {
        Write-Host '********** 800 **********'
        If ($SimpleMatch) {
            Get-WinEvent -LogName 'Windows PowerShell' -FilterXPath "*[System[(EventID=800) and TimeCreated[timediff(@SystemTime) <= $($TimeSpan.TotalMilliseconds)]]]" -ErrorAction SilentlyContinue | Where-Object {$_.Message -like "*$($Pattern)*"} | Format-List *
        } Else {
            Get-WinEvent -LogName 'Windows PowerShell' -FilterXPath "*[System[(EventID=800) and TimeCreated[timediff(@SystemTime) <= $($TimeSpan.TotalMilliseconds)]]]" -ErrorAction SilentlyContinue | Where-Object {$_.Message -match ".*$($Pattern).*"} | Format-List *
        }
    }

    If ($Scope -contains 'All' -or $Scope -contains '4103') {
        Write-Host '********** 4103 **********'
        If ($SimpleMatch) {
            Get-WinEvent -LogName 'Microsoft-Windows-PowerShell/Operational' -FilterXPath "*[System[(EventID=4103) and TimeCreated[timediff(@SystemTime) <= $($TimeSpan.TotalMilliseconds)]]]" -ErrorAction SilentlyContinue | Where-Object {$_.Message -like "*$($Pattern)*"} | Format-List *
        } Else {
            Get-WinEvent -LogName 'Microsoft-Windows-PowerShell/Operational' -FilterXPath "*[System[(EventID=4103) and TimeCreated[timediff(@SystemTime) <= $($TimeSpan.TotalMilliseconds)]]]" -ErrorAction SilentlyContinue | Where-Object {$_.Message -match ".*$($Pattern).*"} | Format-List *
        }
    }

    If ($Scope -contains 'All' -or $Scope -contains '4104') {
        Write-Host '********** 4104 **********'
        If ($SimpleMatch) {
            Get-WinEvent -LogName 'Microsoft-Windows-PowerShell/Operational' -FilterXPath "*[System[(EventID=4104) and TimeCreated[timediff(@SystemTime) <= $($TimeSpan.TotalMilliseconds)]]]" -ErrorAction SilentlyContinue | Where-Object {$_.Message -like "*$($Pattern)*"} | Format-List *
        } Else {
            Get-WinEvent -LogName 'Microsoft-Windows-PowerShell/Operational' -FilterXPath "*[System[(EventID=4104) and TimeCreated[timediff(@SystemTime) <= $($TimeSpan.TotalMilliseconds)]]]" -ErrorAction SilentlyContinue | Where-Object {$_.Message -match ".*$($Pattern).*"} | Format-List *
        }
    }

    If ($Scope -contains 'All' -or $Scope -contains 'Transcript') {
        Write-Host '********** Transcript **********'
        $SearchScope = (Get-PSPolicyTranscription).OutputDirectory
        $FilesInScope = (Get-ChildItem -Path $SearchScope -Recurse -File -Filter "*.txt" | Where-Object {$_.LastWriteTime -gt (Get-Date).AddMilliseconds(-1 * ($TimeSpan).TotalMilliseconds)}).FullName
        Select-String -Path $FilesInScope -Pattern $Pattern -SimpleMatch:$SimpleMatch
    }

    If ($Scope -contains 'All' -or $Scope -contains 'PSReadline') {
        Write-Host '********** PSReadline **********'
        $SearchScope = ((Get-PSReadlineOption).HistorySavePath -replace '\\Users\\.*\\AppData','\Users\*\AppData') -replace '\\PSReadLine\\.*','\PSReadLine\*.txt'
        $FilesInScope = (Get-ChildItem -Path $SearchScope -Recurse | Where-Object {$_.LastWriteTime -gt (Get-Date).AddMilliseconds(-1 * ($TimeSpan).TotalMilliseconds)}).FullName
        Select-String -Path $FilesInScope -Pattern $Pattern -SimpleMatch:$SimpleMatch
    }

    Write-Host '********** EOL **********'

}
