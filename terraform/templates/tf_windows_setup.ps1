<powershell>

# Set Administrator password
$OSVersion = (get-itemproperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName
if($OSVersion -eq "Windows Server 2012 R2 Standard")
{
    net user Administrator ${windows_admin_password}
} else{
    $password   = "${windows_admin_password}" | ConvertTo-SecureString -asPlainText -Force
    $UserAccount = Get-LocalUser -Name "administrator"
    $UserAccount | Set-LocalUser -Password $Password
}

# Install WinRM
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
Invoke-Expression ((New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1'))

</powershell>
