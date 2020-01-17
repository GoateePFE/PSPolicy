<#
.SYNOPSIS
Configures PowerShell policy for transcription
.DESCRIPTION
Configures PowerShell policy for transcription
.PARAMETER Enable
EnableTranscripting
.PARAMETER Invocation
EnableInvocationHeader
.PARAMETER Path
OutputDirectory
.EXAMPLE
PS C:\> Set-PSPolicyTranscription -Enable -Invocation -Path 'C:\PSTranscript'
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
        $Invocation,
        [Parameter()]
        [string]
        $Path
    )

    $BasePath = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription'
    If (-not (Test-Path $BasePath)) {
        $Void = New-Item $BasePath -Force
    }

    If ($PSBoundParameters.ContainsKey('Enable')) {
        If ($Enable.ToBool()) {$Value = 1} Else {$Value = 0}
        $Void = New-ItemProperty -Path $BasePath -Name EnableTranscripting -Value $Value -PropertyType DWord -Force
    }

    If ($PSBoundParameters.ContainsKey('Invocation')) {
        If ($Invocation.ToBool()) {$Value = 1} Else {$Value = 0}
        $Void = New-ItemProperty -Path $BasePath -Name EnableInvocationHeader -Value $Value -PropertyType DWord -Force
    }

    If ($PSBoundParameters.ContainsKey('Path')) {
        $Void = New-ItemProperty -Path $BasePath -Name OutputDirectory -Value $Path -PropertyType String -Force
    }
}
