# Update selected CSBB site records based on the latest SAS2IDM data
PARAM (
    [string]$URI = "http://d-occcp-im202:5725/"
)
Import-Module LithnetRMA
Set-ResourceManagementClient $URI
[string]$xpath = "/csoSite[starts-with(DisplayName,'S____')]"
$siteData = @{
    "SSBCL"=@{"29897"=@("29897")}
    "SHCPK"=@{"13415"=@("13415","05002")}
    "SMCCW"=@{"17384"=@("17384","05006")}
    "SMMCW"=@{"01450"=@("01450","05005")}
    "SSBLM"=@{"13345"=@("13345","05001")}
    "SSJTU"=@{"08790"=@("08790","05978")}
    "SSPCT"=@{"16973"=@("16973")}
}
$sites = @(Search-Resources -XPath $xpath -AttributesToGet @("DisplayName","csoSiteCode","csoMappedSites"))
$sites.Where({$_.DisplayName -in $siteData.Keys}) | % {
    $site = $_
    $site.csoSiteCode = [string]$siteData.($_.DisplayName).Keys[0]
    $site.csoMappedSites.Clear()
    $siteData.($site.DisplayName).($site.csoSiteCode) | % {
        $site.csoMappedSites.Add([string]$_) | Out-Null
    }
    $site | Save-Resource
}
