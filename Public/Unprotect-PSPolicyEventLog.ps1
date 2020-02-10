  <#
.SYNOPSIS
Removes hardening of the PowerShell Windows event logs
.DESCRIPTION
Removes hardening of the PowerShell Windows event logs
.EXAMPLE
PS C:\> Unprotect-PSPolicyEventLog
.EXAMPLE
PS C:\> Unprotect-PSPolicyEventLog -Verbose
#>
Function Unprotect-PSPolicyEventLog {
    [CmdletBinding()]
    param ()

    $Restart = $False

    ### [Microsoft-Windows-PowerShell/Operational] ###
    $Key       = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-PowerShell/Operational'
    $Value     = 'ChannelAccess'
    $Value_bak = $Value + '_bak'

    If (Test-Path -Path $Key) {
        # Read the current value, may not exist, may be different, may be same
        $strValue = $null
        $strValue = Get-ItemProperty -Path $Key -Name $Value_bak -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $Value_bak
        If ($strValue.Length -gt 1) {
            # Write the old ACL SDDL back to current
            $Void = New-ItemProperty -Path $Key -Name $Value -Value $strValue -PropertyType String -Force -Verbose
            # Delete the backup ACl SDDL
            $void = Remove-ItemProperty -Path $Key -Name $Value_bak -ErrorAction SilentlyContinue -Force -Verbose
            $Restart = $True
        } Else {
            #If we attempt to unharden when it is not hardened, we could overwrite the good ACL with NULL.
            Write-Verbose 'Backup event log ACL not found. [Microsoft-Windows-PowerShell/Operational] is not hardened. Skipping.'
        }
    } Else {
        Write-Warning '[Microsoft-Windows-PowerShell/Operational] Log not found'
    }

    ### [Windows PowerShell] ###
    $Key   = 'HKLM:\System\CurrentControlSet\Services\EventLog\Windows PowerShell'
    $Value = 'CustomSD'

    If (Test-Path -Path $Key) {
        $strValue = $null
        $strValue = Get-ItemProperty -Path $Key -Name $Value -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $Value
        If ($strValue.Length -gt 1) {
            $void = Remove-ItemProperty -Path $Key -Name $Value -ErrorAction SilentlyContinue -Force -Verbose
            $Restart = $True
        } Else {
            Write-Verbose '[Windows PowerShell] hardening not found. Skipping.'
        }
    } Else {
        Write-Warning '[Windows PowerShell] Log not found'
    }

    If ($Restart) {
        Write-Warning 'Hardening settings removed but not fully effective until next EventLog service restart or machine reboot'
    }

} 
 
