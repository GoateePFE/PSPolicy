<#
.SYNOPSIS
Configures PowerShell policy for script block logging
.DESCRIPTION
Configures PowerShell policy for script block logging.
These events appear in the log: Microsoft-Windows-PowerShell/Operational
.PARAMETER Enable
EnableScriptBlockLogging
Event ID 4104 logs executed script blogs
.PARAMETER Invocation
EnableScriptBlockInvocationLogging
Event ID 4105 logs the start of execution
Event ID 4106 logs the end of execution
.EXAMPLE
PS C:\> Set-PSPolicyScriptBlockLogging -Enable -Invocation
Sets explicit values
.EXAMPLE
PS C:\> Set-PSPolicyScriptBlockLogging -Enable:$false
Disables script block logging, leaving any other values in place.
.NOTES
No default values. Only sets the parameters explicitly passed.
#>
Function Set-PSPolicyScriptBlockLogging {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $Enable,
        [Parameter()]
        [switch]
        $Invocation
    )

    $BasePath = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
    If (-not (Test-Path $BasePath)) {
        $Void = New-Item $BasePath -Force
    }

    If ($PSBoundParameters.ContainsKey('Enable')) {
        If ($Enable.ToBool()) {$Value = 1} Else {$Value = 0}
        $Void = New-ItemProperty -Path $BasePath -Name EnableScriptBlockLogging -Value $Value -PropertyType DWord -Force
    }

    If ($PSBoundParameters.ContainsKey('Invocation')) {
        If ($Invocation.ToBool()) {$Value = 1} Else {$Value = 0}
        $Void = New-ItemProperty -Path $BasePath -Name EnableScriptBlockInvocationLogging -Value $Value -PropertyType DWord -Force
    }

}

### Add logic to check the event log max size. If it is 15MB default, write a warning to increase the size.
### Put this in a custom function to call from both event log policy set functions.
