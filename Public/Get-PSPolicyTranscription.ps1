<#
.SYNOPSIS
Displays PowerShell policy for transcription
.DESCRIPTION
Displays PowerShell policy for transcription
.EXAMPLE
PS C:\> Get-PSPolicyTranscription
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
    Get-ItemProperty -Path $BasePath | Select-Object EnableTranscripting, EnableInvocationHeader, OutputDirectory
}
