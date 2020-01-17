<#
.SYNOPSIS
Removes PowerShell policy for script block logging
.DESCRIPTION
Removes PowerShell policy for script block logging
.EXAMPLE
PS C:\> Remove-PSPolicyScriptBlockLogging
.EXAMPLE
PS C:\> Remove-PSPolicyScriptBlockLogging -WhatIf
#>
Function Remove-PSPolicyScriptBlockLogging {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
    param ()

    $BasePath = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
    if ($pscmdlet.ShouldProcess($BasePath, 'Remove')){
        Remove-Item -Path $BasePath -Force
    }
}
