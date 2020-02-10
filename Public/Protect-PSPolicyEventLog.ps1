  <#
.SYNOPSIS
Hardens the PowerShell Windows event logs
.DESCRIPTION
Hardens the PowerShell Windows event logs
Everyone - Write
SYSTEM and Built-In Administrators - Full Control
.EXAMPLE
PS C:\> Protect-PSPolicyEventLog
.EXAMPLE
PS C:\> Protect-PSPolicyEventLog -Verbose
#>
Function Protect-PSPolicyEventLog {
    [CmdletBinding()]
    param ()

    $os = Get-CimInstance -ClassName Win32_OperatingSystem -Property Caption, BuildNumber -Verbose:$False

    If ($os.Caption -like "*Windows 10*") {
        #Windows 10
        # *** ADD LOGIC HERE TO HANDLE WIN10 CAPABILITY SIDs ***
        # *** IGNORING FOR A LATER RELEASE UNTIL NEEDED      ***
        #sddl = 'O:BAG:SYD:(A;;0x2;;;S-1-15-2-1)(A;;0x2;;;S-1-15-3-1024-3153509613-960666767-3724611135-2725662640-12138253-543910227-1950414635-4190290187)(A;;0xf0007;;;SY)(A;;0x7;;;BA)(A;;0x2;;;SO)(A;;0x2;;;IU)(A;;0x2;;;SU)(A;;0x2;;;S-1-5-3)(A;;0x2;;;S-1-5-33)'
        $sddl = 'O:BAG:SYD:(A;;0x2;;;S-1-15-2-1)(A;;0xf0007;;;SY)(A;;0x7;;;BA)(A;;0x2;;;SO)(A;;0x2;;;IU)(A;;0x2;;;SU)(A;;0x2;;;S-1-5-3)(A;;0x2;;;S-1-5-33)'
    } ElseIf ([int]$os.BuildNumber -lt 9200) {
        #Windows 7/2008 R2
        $sddl = 'O:BAG:SYD:(A;;0xf0007;;;SY)(A;;0x7;;;BA)(A;;0x2;;;SO)(A;;0x2;;;IU)(A;;0x2;;;SU)(A;;0x2;;;S-1-5-3)(A;;0x2;;;S-1-5-33)'
    } Else {
        #Everything else
        $sddl = 'O:BAG:SYD:(A;;0x2;;;S-1-15-2-1)(A;;0xf0007;;;SY)(A;;0x7;;;BA)(A;;0x2;;;SO)(A;;0x2;;;IU)(A;;0x2;;;SU)(A;;0x2;;;S-1-5-3)(A;;0x2;;;S-1-5-33)'
    }

    $Restart = $False

    ### [Microsoft-Windows-PowerShell/Operational] ###
    $Key       = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-PowerShell/Operational'
    $Value     = 'ChannelAccess'
    $Value_bak = $Value + '_bak'

    # Backup the default OS ACL SDDL.
    # If we run this twice in a row, it would write the same value to current and backup, losing the fallback OS default SDDL value.
    # ONLY harden if it doesn't match current or doesn't exist.
    If (Test-Path -Path $Key) {
        # Read the current value, may not exist, may be different, may be same
        $strValue = Get-ItemProperty -Path $Key -Name $Value -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $Value
        If ($strValue -eq $sddl) {
            Write-Verbose '[Microsoft-Windows-PowerShell/Operational] already hardened. Skipping.'
        } Else {
            # Backup the current ACl SDDL
            $Void = New-ItemProperty -Path $Key -Name $Value_bak -Value $strValue -PropertyType String -Force -Verbose
            # Write the new ACL SDDL
            $Void = New-ItemProperty -Path $Key -Name $Value     -Value $sddl     -PropertyType String -Force -Verbose
            $Restart = $True
        }
    } Else {
        Write-Warning '[Microsoft-Windows-PowerShell/Operational] Log not found'
    }

    ### [Windows PowerShell] ###
    $Key   = 'HKLM:\System\CurrentControlSet\Services\EventLog\Windows PowerShell'
    $Value = 'CustomSD'
    If (Test-Path -Path $Key) {
        # Read the current value, may not exist, may be different, may be same
        $strValue = Get-ItemProperty -Path $Key -Name $Value -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $Value
        If ($strValue -eq $sddl) {
            Write-Verbose '[Windows PowerShell] already hardened. Skipping.'
        } Else {
            # Write the new ACL SDDL
            $Void = New-ItemProperty -Path $Key -Name $Value -Value $sddl -PropertyType String -Force -Verbose
            $Restart = $True
        }
    } Else {
        Write-Warning '[Windows PowerShell] Log not found'
    }

    If ($Restart) {
        Write-Warning 'Hardening settings applied but not fully effective until next EventLog service restart or machine reboot'
    }

} 
 
