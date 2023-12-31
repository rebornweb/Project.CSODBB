# the following produces a list which can be pasted diretly into the update activity for workflow "aaa-Set explicit group membership"
# the workflow is then initiated by enabling/disabling "aaa-Explicit set membership is set for AAA set"
# this will recalculate Person.csoRoles for each of the user guids in the workflow
$Path = "D:\Scripts\Entitlements\roleUsers.xml"
$XPath = "roleUsers/user/UserIdentifier"
$guids = Select-Xml -Path $path -XPath $xpath | Select-Object -ExpandProperty Node
foreach ($_ in $guids) {
    "ExplicitMember=guid[]:"+ $_.innerText
}

<#
$query = "/Person[(ObjectID='"
foreach ($_ in $guids) {
    if ($query -ne "/Person[(ObjectID='") {
        $query += "') or (ObjectID='"
    }
    $query += $_.innerText
}
$query += "')]"
$query
#>