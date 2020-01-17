<#
.SYNOPSIS
Removes PowerShell policy for module logging
.DESCRIPTION
Removes PowerShell policy for module logging
.EXAMPLE
PS C:\> Remove-PSPolicyModuleLogging
.EXAMPLE
PS C:\> Remove-PSPolicyModuleLogging -WhatIf
#>
Function Remove-PSPolicyModuleLogging {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
    param ()

    $BasePath = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ModuleLogging'
    if ($pscmdlet.ShouldProcess($BasePath, 'Remove')){
        Remove-Item -Path $BasePath -Force -Recurse
    }
}
