<#
.SYNOPSIS
Displays statistics for PowerShell policy for transcription.
.DESCRIPTION
Displays statistics for PowerShell policy for transcription.
Use this data to do the following:
-check hardening status
-understand the disk storage impact of the policy
-determine appropriate settings to balance disk space used vs. days of logging
.EXAMPLE
PS C:\> Get-PSPolicyStatsTranscription
.EXAMPLE
@((Get-PSPolicyStatsEventLog),(Get-PSPolicyStatsTranscription)) | Format-Table
.NOTES
LogName - Descriptive string for correlation with the event log policy statistics
Count - How many transcript files exist in the directory structure
TotalBytes - Total disk space used
OldestInDays - How old is the oldest transcript file?
IsHidden - Do the directory attributes include by System and Hidden?
Attributes - The directory attributes
#>
Function Get-PSPolicyStatsTranscription {
    [CmdletBinding()]
    param ()

    $PSTranscriptPath = (Get-PSPolicyTranscription).OutputDirectory
    $PSTranscriptDir = Get-ChildItem $PSTranscriptPath -Recurse -File -ErrorAction SilentlyContinue
    $CountLen = $PSTranscriptDir | Measure-Object -Sum -Property Length

    If ($CountLen.Count -eq 0) {
        Write-Warning 'PowerShell transcript directory not found.'
    } Else {
        $attrib = (Get-ItemProperty -Path $PSTranscriptPath).Mode
        [pscustomobject]@{
            LogName = 'Transcription'
            Count = $CountLen.Count
            TotalBytes = $CountLen.Sum
            OldestInDays = [math]::Floor((New-TimeSpan -Start ($PSTranscriptDir | Measure-Object -Minimum -Property LastWriteTime | Select-Object -ExpandProperty Minimum)).TotalDays)
            IsHidden = ($attrib -like "*s*" -and $attrib -like "*h*")
            Attributes = $attrib
        }
    }

}
