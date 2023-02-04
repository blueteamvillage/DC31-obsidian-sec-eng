<powershell>

$password   = "${windows_admin_password}" | ConvertTo-SecureString -asPlainText -Force
$UserAccount = Get-LocalUser -Name "administrator"
$UserAccount | Set-LocalUser -Password $Password

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
Invoke-Expression ((New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1'))

</powershell>
