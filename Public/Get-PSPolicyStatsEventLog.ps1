<#
.SYNOPSIS
Displays statistics for PowerShell policies that write to event logs.
.DESCRIPTION
Displays statistics for PowerShell policies that write to event logs.
Use this data to do the following:
-check hardening status
-understand the disk storage impact of the policy
-determine appropriate settings to balance disk space used vs. days of logging
.EXAMPLE
PS C:\> Get-PSPolicyStatsEventLog
.EXAMPLE
@((Get-PSPolicyStatsEventLog),(Get-PSPolicyStatsTranscription)) | Format-Table
.NOTES
LogName - Event log name
Count - How many event log entries exist in total
TotalBytes - Actual event log space on disk
MaximumBytes - Configured maximum size of log
OldestInDays - How old is the oldest event log entry?
IsHardened - Has the hardening ACL been applied? Does not verify that a reboot has happened to enforce the ACL.
SDDL - The actual event log ACL
#>
Function Get-PSPolicyStatsEventLog {
    [CmdletBinding()]
    param ()

    $HardenedACLs = "O:BAG:SYD:(A;;0xf0007;;;SY)(A;;0x7;;;BA)(A;;0x2;;;SO)(A;;0x2;;;IU)(A;;0x2;;;SU)(A;;0x2;;;S-1-5-3)(A;;0x2;;;S-1-5-33)",
        "O:BAG:SYD:(A;;0x2;;;S-1-15-2-1)(A;;0xf0007;;;SY)(A;;0x7;;;BA)(A;;0x2;;;SO)(A;;0x2;;;IU)(A;;0x2;;;SU)(A;;0x2;;;S-1-5-3)(A;;0x2;;;S-1-5-33)"

    'Windows PowerShell', 'Microsoft-Windows-PowerShell/Operational' | 
    ForEach-Object {
        Get-WinEvent -ListLog $_ | Select-Object LogName, 
            @{n='Count';e={$_.RecordCount}}, 
            @{n='TotalBytes';e={$_.FileSize}}, 
            @{n='MaximumBytes';e={$_.MaximumSizeInBytes}}, 
            @{n='OldestInDays';e={"$([math]::Ceiling((New-TimeSpan -Start (Get-WinEvent -LogName $_.LogName -MaxEvents 1 -Oldest).TimeCreated).TotalDays))"}}, 
            @{n='IsHardened';e={$_.SecurityDescriptor -in $HardenedACLs}}, 
            @{n='SDDL';e={$_.SecurityDescriptor}}
        }

}