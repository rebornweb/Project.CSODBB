#region Net.New-XsdFromXml

# Define function
function Net.New-XsdFromXml {

<#
.AUTHOR Will Steele
.DEPENDENCIES None.
.DESCRIPTION This script generates an .xsd file from an .xml file.
.EXAMPLE Net.New-XsdFromXml 
.EXTERNALHELP None.
.FORWARDHELPTARGETNAME None.
.INPUTS System.String
.LINK None. 
.NAME Net.New-XsdFromXml 
.NOTES This function require that the .NET 4.0 xsd.exe file be located on the system.
.OUTPUTS None.
.PARAMETER XmlPath A required parameter indicating the path to the source .xml file. 
.PARAMETER XsdPath An optional parameter indicating the output path for the new .xsd file. Default is the directory containing the .xml file.
.SYNOPSIS Create an .xsd file from .xml.
#>

[CmdletBinding()]
param(
[Parameter(
HelpMessage = "Specify an .xml file to convert to .xsd.",
Mandatory = $true,
ValueFromPipeline = $true
)]
[String]
[ValidateScript({Test-Path $_})]
$XmlPath,

[Parameter(
HelpMessage = "Specify a directory to store the output .xsd file. Default is the path to the .xml file.",
Mandatory = $false
)]
[String]
[ValidateScript({Test-Path $_})]
$XsdPath = (Split-Path $XmlPath)
)

# Generate XSD from XML file
$proc = New-Object System.Diagnostics.Process
$proc.StartInfo.WindowStyle = "Hidden"
$proc.StartInfo.UseShellExecute = $false # Necessary to capture stderr/stdout.
$proc.StartInfo.RedirectStandardOutput = $true
$proc.StartInfo.RedirectStandardError = $true
$proc.StartInfo.FileName = "C:\program files\microsoft sdks\windows\v6.0A\bin\xsd.exe"
$proc.StartInfo.Arguments = "$XmlPath /outputdir:$XsdPath"

# Start the process, read all output and errors,
# then wait for the process to end.
$proc.Start() | Out-Null
$output = $proc.StandardOutput.ReadToEnd()
$outputErr = $proc.StandardError.ReadToEnd()
$proc.WaitForExit()

# Report failed processing
if($outputErr -ne $null -and $outputErr.Length -gt 0) {
Write-Error $outputErr
}
} # end function Net.New-XsdFromXml

# Set alias
Set-Alias -Name n.cxfx -Value "Net.New-XsdFromXml"

#endregion Net.New-XsdFromXml

Net.New-XsdFromXml("D:\Logs\FIMService\archive\RequestHistory.2011Sep26.121825.xml")
