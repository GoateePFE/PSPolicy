<#
.SYNOPSIS
Displays PowerShell policy for module logging
.DESCRIPTION
Displays PowerShell policy for module logging
.EXAMPLE
PS C:\> Get-PSPolicyModuleLogging
#>
Function Get-PSPolicyModuleLogging {
    [CmdletBinding()]
    param ()

    $BasePath = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ModuleLogging'
    Try {
        $ErrorActionPreference = 'Stop'
        $EnableModuleLogging = Get-ItemProperty -Path $BasePath | Select-Object -ExpandProperty EnableModuleLogging
        $ModuleNames = Get-ItemProperty -Path "$BasePath\ModuleNames" | Select-Object * -ExcludeProperty PSPath, PSParentPath, PSChildName, PSDrive, PSProvider | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
        [pscustomobject]@{
            EnableModuleLogging = $EnableModuleLogging
            ModuleNames = $ModuleNames
        }
    }
    Catch {
        Write-Warning 'Policy not found'
    }
}
