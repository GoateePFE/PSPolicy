<#
.SYNOPSIS
Hardens and hides the directory path for transcription
.DESCRIPTION
Hardens and hides the directory path for transcription
Sets the directory attributes to System and Hidden
Sets the directory ACL to Everyone Write, Administrators and System Read
.EXAMPLE
PS C:\> Protect-PSPolicyTranscription
.NOTES
There are no parameters, because the directory path is retrieved from the policy setting.
#>
Function Protect-PSPolicyTranscription {
    [CmdletBinding()]
    param ()

    $TranscriptionPath = (Get-PSPolicyTranscription).OutputDirectory
    If (Test-Path $TranscriptionPath) {
        attrib +s +h $TranscriptionPath
        $void = echo Y| cacls $TranscriptionPath /S:"D:PAI(A;OICI;0x100196;;;WD)(A;OICI;FA;;;SY)(A;OICI;FA;;;BA)"
    } Else {
        Write-Warning "Transcription path not found"
    }
}
