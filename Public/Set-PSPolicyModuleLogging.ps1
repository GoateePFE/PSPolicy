<#
.SYNOPSIS
Configures PowerShell policy for module logging
.DESCRIPTION
Configures PowerShell policy for module logging, also known as Pipeline Execution logging.
These events appear in two logs:
Microsoft-Windows-PowerShell/Operational as event ID 4103
Windows PowerShell as event ID 800
.PARAMETER Enable
EnableModuleLogging
.PARAMETER ModuleNames
Array of module names for which to enable logging.
Default value is "*".
If module names are already configured, then these will be added to the list.
Use the -Replace parameter to overwrite the module name list entirely.
.PARAMETER Replace
Resets all module names with those specified.
Otherwise module names are added to the list if any already exist.
.EXAMPLE
PS C:\> Set-PSPolicyModuleLogging -Enable -ModuleNames '*'
Enables module logging for all modules
.EXAMPLE
PS C:\> Set-PSPolicyModuleLogging -Enable -ModuleNames 'foo','bar'
Enables for specific modules
.EXAMPLE
PS C:\> Set-PSPolicyModuleLogging -Enable -ModuleNames 'foo','bar' -Replace
Enables for specific modules, remvoing any other modules previously listed.
.EXAMPLE
PS C:\> Set-PSPolicyModuleLogging -Enable:$false
Disables module logging, leaving any other values in place.
.NOTES
Only sets the parameters explicitly passed.
#>
Function Set-PSPolicyModuleLogging {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $Enable,
        [Parameter()]
        [string[]]
        $ModuleNames,
        [Parameter()]
        [switch]
        $Replace
    )

    $BasePath = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ModuleLogging'
    If (-not (Test-Path $BasePath)) {
        $Void = New-Item $BasePath -Force
    }

    If ($PSBoundParameters.ContainsKey('Enable')) {
        If ($Enable.ToBool()) {$Value = 1} Else {$Value = 0}
        $Void = New-ItemProperty -Path $BasePath -Name EnableModuleLogging -Value $Value -PropertyType DWord -Force
    }

    If ($PSBoundParameters.ContainsKey('ModuleNames')) {
        $BasePath = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ModuleLogging\ModuleNames'
        If ($Replace.ToBool() -and (Test-Path $BasePath)) {
            Remove-Item -Path $Basepath -Force
        }
        If (-not (Test-Path $BasePath)) {
            $Void = New-Item $BasePath -Force
        }
        ForEach ($ModuleName in $ModuleNames) {
            $Void = New-ItemProperty -Path $BasePath -Name $ModuleName -Value $ModuleName -PropertyType String -Force
        }
    }
}

### Add logic to check the event log max size. If it is 15MB default, write a warning to increase the size.
### Put this in a custom function to call from both event log policy set functions.
