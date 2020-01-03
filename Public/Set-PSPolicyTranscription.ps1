<#
.SYNOPSIS
Configures PowerShell policy for transcription
.DESCRIPTION
Configures PowerShell policy for transcription
.PARAMETER Enable
EnableTranscripting
.PARAMETER Header
EnableInvocationHeader
.PARAMETER Path
OutputDirectory
.EXAMPLE
PS C:\> Set-PSPolicyTranscription -Enable -Header -Path 'C:\PSTranscript'
Sets explicit values
.EXAMPLE
PS C:\> Set-PSPolicyTranscription -Enable:$false
Disables transcription, leaving any other values in place.
.NOTES
No default values. Only sets the parameters explicitly passed.
#>
Function Set-PSPolicyTranscription {
    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $Enable,
        [Parameter()]
        [switch]
        $Header,
        [Parameter()]
        [string]
        $Path
    )

    $BasePath = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription'
    If (-not (Test-Path $BasePath)) {
        $Void = New-Item $BasePath -Force -Verbose:$Verbose
    }

    If ($PSBoundParameters.ContainsKey('Enable')) {
        If ($Enable.ToBool()) {$Value = 1} Else {$Value = 0}
        $Void = New-ItemProperty -Path $BasePath -Name EnableTranscripting -Value $Value -PropertyType DWord -Force
    }

    If ($PSBoundParameters.ContainsKey('Header')) {
        If ($Header.ToBool()) {$Value = 1} Else {$Value = 0}
        $Void = New-ItemProperty -Path $BasePath -Name EnableInvocationHeader -Value $Value -PropertyType DWord -Force
    }

    If ($PSBoundParameters.ContainsKey('Path')) {
        $Void = New-ItemProperty -Path $BasePath -Name OutputDirectory -Value $Path -PropertyType String -Force
    }
}
