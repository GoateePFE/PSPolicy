<#
.SYNOPSIS
Warns if the PowerShell event logs are set to a default of 15MB maximum size.
.DESCRIPTION
Warns if the PowerShell event logs are set to a default of 15MB maximum size.
Returns size details of the PowerShell event logs and a property indicating if they are the default size.
.PARAMETER Quiet
Replaces the full object output with a simple boolean value for each log tested
.EXAMPLE
PS C:\> Test-PSPolicyEventLogSize
.EXAMPLE
PS C:\> Test-PSPolicyEventLogSize -Quiet
.EXAMPLE
PS C:\> Test-PSPolicyEventLogSize -WarningAction SilentlyContinue
.EXAMPLE
PS C:\> Test-PSPolicyEventLogSize -Quiet -WarningAction SilentlyContinue 
.NOTES
Once PowerShell Script Block Logging and/or Module Logging are enabled, the default event log sizes are no longer sufficient.
Consider increasing event log sizes using the function Set-PSPolicyEventLogSize.
#>
Function Test-PSPolicyEventLogSize {
    [CmdletBinding()]
    param(
        [Parameter()]
        [switch]
        $Quiet
    )

    ForEach ($log in (Get-WinEvent -ListLog 'Windows PowerShell', 'Microsoft-Windows-PowerShell/Operational')) {
        $IsDefaultSize = $false
        If ($log.MaximumSizeInBytes -eq 15728640) {
            Write-Warning "Log [$($log.LogName)] is default size of 15MB. Consider increasing log size when PowerShell logging policies are enabled."
            $IsDefaultSize = $True
        } Else {
            $IsDefaultSize = $False
        }

        If (-not $Quiet) {
            [pscustomobject]@{
                LogName = $log.LogName
                TotalBytes = $log.FileSize
                MaximumBytes = $log.MaximumSizeInBytes
                TotalMB = $log.FileSize / 1MB
                MaximumMB = $log.MaximumSizeInBytes / 1MB
                MaxSizeDefault = $IsDefaultSize
            }
        } Else {
            $IsDefaultSize
        }
    }
}
