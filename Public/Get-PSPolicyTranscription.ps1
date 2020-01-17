<#
.SYNOPSIS
Displays PowerShell policy for transcription
.DESCRIPTION
Displays PowerShell policy for transcription
.EXAMPLE
PS C:\> Get-PSPolicyTranscription
#>
Function Get-PSPolicyTranscription {
    [CmdletBinding()]
    param ()

    $BasePath = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\Transcription'
    Try {
        $ErrorActionPreference = 'Stop'
        Get-ItemProperty -Path $BasePath | Select-Object EnableTranscripting, EnableInvocationHeader, OutputDirectory
    }
    Catch {
        Write-Warning 'Policy not found'
    }
}
