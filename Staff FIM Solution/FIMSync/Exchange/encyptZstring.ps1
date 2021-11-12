$CredsFile = "E:\Scripts\Exchange\Creds2.txt"
Write-Host 'Credential file not found. Enter your password:' -ForegroundColor Red
    Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File $CredsFile