
#@("$PSScriptRoot\Private","$PSScriptRoot\Public") |

@("$PSScriptRoot\Public") |
ForEach-Object {Get-ChildItem -Path "$_\*.ps1"} |
    ForEach-Object {. $_.Fullname}

Export-ModuleMember -Function *-*
