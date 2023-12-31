PARAM (
    $dll
)

BEGIN {
    $ErrorActionPreference = "Stop"
    if ( $null -eq ([AppDomain]::CurrentDomain.GetAssemblies() |? { $dll.FullName -eq "System.EnterpriseServices, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a" }) ) {
        [System.Reflection.Assembly]::Load("System.EnterpriseServices, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a") | Out-Null
    }
    $publish = New-Object System.EnterpriseServices.Internal.Publish
}

PROCESS {
    $assembly = $null
    if ( $dll -is [string] ) {
        $assembly = $dll
    } elseif ( $dll -is [System.IO.FileInfo] ) {
        $assembly = $dll.FullName
    } else {
        throw ("The object type '{0}' is not supported." -f $dll.GetType().FullName)
    }
    if ( -not (Test-Path $assembly -type Leaf) ) {
        throw "The assembly '$assembly' does not exist."
    }
    if ( [System.Reflection.Assembly]::LoadFile($assembly).GetName().GetPublicKey().Length -eq 0 ) {
        throw "The assembly '$assembly' must be strongly signed."
    }
    Write-Output "Installing: $assembly"
    $publish.GacInstall( $assembly )
}