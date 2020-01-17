<#
.SYNOPSIS
Removes PowerShell policy for transcription
.DESCRIPTION
Removes PowerShell policy for transcription
.EXAMPLE
PS C:\> Remove-PSPolicyTranscription
.EXAMPLE
PS C:\> Remove-PSPolicyTranscription -WhatIf
#>
Function Remove-PSPolicyTranscription {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
    param ()

    $BasePath = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription'
    if ($pscmdlet.ShouldProcess($BasePath, 'Remove')){
        Remove-Item -Path $BasePath -Force
    }
}
