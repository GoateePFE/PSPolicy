<#
.SYNOPSIS
Removes hardening and hiding of the directory path for transcription
.DESCRIPTION
Removes hardening and hiding of the directory path for transcription
Removes the directory attributes of System and Hidden
Sets the directory ACL back to inheriting parent folder permissions
.EXAMPLE
PS C:\> Unprotect-PSPolicyTranscription
.NOTES
There are no parameters, because the directory path is retrieved from the policy setting.
#>
Function Unprotect-PSPolicyTranscription {
    [CmdletBinding()]
    param ()

    $TranscriptionPath = (Get-PSPolicyTranscription).OutputDirectory
    If (Test-Path $TranscriptionPath) {
        attrib -s -h $TranscriptionPath
        $void = icacls.exe $TranscriptionPath /reset /q /c /t
    } Else {
        Write-Warning "Transcription path not found"
    }
}
