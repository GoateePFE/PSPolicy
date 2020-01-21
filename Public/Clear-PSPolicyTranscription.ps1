<#
.SYNOPSIS
Clears all old transcript files created before the timespan specified.
.DESCRIPTION
When PowerShell transcription is enabled there is no built-in means to clean old files.
Otherwise the disk will eventually fill up with tiny text files.
This function resolves that issue.
.PARAMETER Before
A PowerShell Timespan object with the interval of files to keep.
.EXAMPLE
PS C:\> Clear-PSPolicyTranscription -Before (New-TimeSpan -Days 7)
Delete all files older than 7 days.
.EXAMPLE
PS C:\> Clear-PSPolicyTranscription -Before (New-TimeSpan -Hours 12)
Delete all files older than 12 hours.
.EXAMPLE
PS C:\> Clear-PSPolicyTranscription -Before (New-TimeSpan -Start 9/1/2019)
Delete all files older than 9/1/2019.
.NOTES
Transcript files generally do not accumulate very large in size.
Be sure to leave enough transcripts for meaningful incident investigations.
#>
Function Clear-PSPolicyTranscription {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
    param (
        [Parameter(Mandatory)]
        [timespan]
        $Before
    )

    $basePath = "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription"
    If (Test-Path $basePath) {
        $ErrorActionPreference = 'SilentlyContinue'
        $OutputDirectory = Get-ItemProperty $basePath -Name OutputDirectory | Select-Object -ExpandProperty OutputDirectory
        If (!$?) {
            Write-Warning 'Transcription not configured'
        } Else {
            If (Test-Path -Path $OutputDirectory) {
                If ($pscmdlet.ShouldProcess("transcript files older than [$((Get-Date) - $Before)] from the path [$($OutputDirectory)]", 'Clear')){
                    Get-ChildItem -Path $OutputDirectory -Recurse |
                        Where-Object {$_.CreationTime -lt ((Get-Date) - $Before)} |
                        Remove-Item -Force -Confirm:$false -Recurse
                }
            } Else {
                Write-Warning 'Transcription path not found'
            }
        }
    } Else {
        Write-Warning 'Transcription not configured'
    }
}
