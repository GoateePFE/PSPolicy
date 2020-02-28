<#
.SYNOPSIS
Sets the size of PowerShell event logs.
.DESCRIPTION
Sets the size of PowerShell event logs.
.PARAMETER Size
Desired size to set in bytes. Must be an interval of 64KB.
.PARAMETER LogName
Name of event log to set size.
Defaults to both Windows PowerShell logs.
.EXAMPLE
PS C:\> Set-PSPolicyEventLogSize -Size 1GB
Sets event log size for both Windows PowerShell logs.
.EXAMPLE
PS C:\> Set-PSPolicyEventLogSize -Size 512MB
Sets event log size for both Windows PowerShell logs.
.EXAMPLE
PS C:\> Set-PSPolicyEventLogSize -Size 1GB -LogName 'Microsoft-Windows-PowerShell/Operational'
Sets size for one event log.
.EXAMPLE
PS C:\> Set-PSPolicyEventLogSize -Size 512MB -LogName 'Windows PowerShell'
Sets size for one event log.
.NOTES
The maximum size for an event log is 1 byte less than 2GB due to 32bit integer limitation.
That means 2097088KB is the maximum permitted log size parameter value.
#>
Function Set-PSPolicyEventLogSize {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True)]
        [ValidateScript({($_ % 64KB) -eq 0})]
        [int]
        $Size,
        [Parameter()]
        [ValidateSet('Windows PowerShell', 'Microsoft-Windows-PowerShell/Operational')]
        [string[]]
        $LogName = @('Windows PowerShell', 'Microsoft-Windows-PowerShell/Operational')
    )

    ForEach ($log in $LogName) {
        Switch ($log) {
            'Microsoft-Windows-PowerShell/Operational' {
                $BasePath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-PowerShell/Operational'
                $Void = New-ItemProperty -Path $BasePath -Name MaxSize -Value $Size -PropertyType DWord -Force
                $Void = New-ItemProperty -Path $BasePath -Name MaxSizeUpper -Value 0 -PropertyType DWord -Force
                $Void = New-ItemProperty -Path $BasePath -Name Enabled -Value 1 -PropertyType DWord -Force
            }
            'Windows PowerShell' {
                $BasePath = 'HKLM:\System\CurrentControlSet\Services\EventLog\Windows PowerShell'
                $Void = New-ItemProperty -Path $BasePath -Name MaxSize -Value $Size -PropertyType DWord -Force
                $Void = New-ItemProperty -Path $BasePath -Name MaxSizeUpper -Value 0 -PropertyType DWord -Force
            }
        }
    }
}
