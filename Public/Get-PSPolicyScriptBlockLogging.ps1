<#
.SYNOPSIS
Displays PowerShell policy for script block logging
.DESCRIPTION
Displays PowerShell policy for script block logging
.EXAMPLE
PS C:\> Get-PSPolicyScriptBlockLogging
#>
Function Get-PSPolicyScriptBlockLogging {
    [CmdletBinding()]
    param ()

    $BasePath = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
    Try {
        $ErrorActionPreference = 'Stop'
        Get-ItemProperty -Path $BasePath | Select-Object EnableScriptBlockLogging, EnableScriptBlockInvocationLogging
    }
    Catch {
        Write-Warning 'Policy not found'
    }
}
