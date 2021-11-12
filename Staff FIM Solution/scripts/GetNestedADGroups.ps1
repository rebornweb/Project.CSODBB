<#
.Synopsis
   Get all (nested) members of an Active Directory Group.
.DESCRIPTION
   Get all (nested) members of an Active Directory Group.
.EXAMPLE
   Get-ADNestedGroupMembers "Domain Admins"
.EXAMPLE
   Get-ADNestedGroupMembers "Domain Admins" | Select-Object DistinguishedName
#>

function Get-ADNestedGroupMembers {
  [cmdletbinding()]
  param ( [String] $Group )            
  Import-Module ActiveDirectory
  $Members = Get-ADGroupMember -Identity $Group -Recursive
  $members
}

Get-ADNestedGroupMembers "Domain Admins" | Select-Object DistinguishedName
