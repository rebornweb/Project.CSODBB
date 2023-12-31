PARAM(  [string]$RunType = "Delta",
	    [string]$SourceMA = "FIM Portal",
	    [string]$ReplayMA = "Replay FIM Portal",
        [string]$ScriptFldr = "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\MaData\FIM Portal",
        [string]$MaData = "C:\Program Files\Microsoft Forefront Identity Manager\2010\Synchronization Service\MaData",
        [string]$ImportFULL = "FIMMA.FullImport.xml",
        [string]$OutputFULL = "full.ldif",
        [string]$TemplateFULL = "XMLtoLDIF-Full.xslt",
        [string]$ImportDELTA = "FIMMA.DeltaImport.xml",
        [string]$OutputDELTA = "delta.ldif",
        [string]$TemplateDELTA = "XMLtoLDIF-Delta.xslt"
)

# Usage:
# $RunType = "Full" or "Delta" (run modes)
# $SourceMA = source MA name 
# $ReplayMA = target MA name
# $ScriptFldr = folder context in which this script is to be run
# $MaData = MaData folder for your FIM Sync Server
# $ImportFULL = file name of audit drop file for FULL import of source MA
# $OutputFULL = file name of target LDIF file for FULL import
# $TemplateFULL = name of stylesheet file to transform FULL audit drop file
# $ImportDELTA = file name of audit drop file for DELTA import of source MA
# $OutputDELTA = file name of target LDIF file for DELTA import
# $TemplateDELTA = name of stylesheet file to transform DELTA audit drop file

# Copyright (c) 2012, Unify Solutions Pty Ltd
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
# 
# Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
# Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT 
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
## ---------------------------------------------------------------- ##

if ($runType -eq "Delta") 
{
  $xsltTemplateFile = $ScriptFldr + "\" + $TemplateDELTA
  $sourceFile = $MaData + "\" + $SourceMA + "\" + $ImportDELTA
  $outFile = $MaData + "\" + $ReplayMA + "\" + $OutputDELTA
}
else 
{
  $xsltTemplateFile = $ScriptFldr + "\" + $TemplateFULL
  $sourceFile = $MaData + "\" + $SourceMA + "\" + $ImportFULL
  $outFile = $MaData + "\" + $ReplayMA + "\" + $OutputFULL
}

$xslt = new-object system.xml.xsl.XslTransform
$xslt.load($xsltTemplateFile)
$xslt.Transform($sourceFile,$outFile)

#------------------------------------------------------------------------------------------------------
 trap
 { 
    Write-Host "`nError: $($_.Exception.Message)`n" -foregroundcolor white -backgroundcolor darkred
    Exit
 }
#------------------------------------------------------------------------------------------------------
