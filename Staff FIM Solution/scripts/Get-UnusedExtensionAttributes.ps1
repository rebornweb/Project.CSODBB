$Properties = @()
@(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15) | % {$Properties += "ExtensionAttribute$_"}
#$users = @(Get-ADUser -LDAPFilter "(mail=*)" -Properties $Properties)
$users = @(Get-ADUser -Filter * -Properties $Properties)
Write-Host "$($users.Count) users found! Checking ExtensionAttributes ..."
@(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15) | % {
    [string]$extAtt = "ExtensionAttribute$_"
    $count = (@($users | Where-Object {$_.$extAtt.Length -gt 0})).Count
    if ($count -eq 0) {
        Write-Host "$extAtt is free!"
    } else {
        Write-Host "$extAtt [$count]"
    }
}
