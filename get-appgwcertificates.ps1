[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, HelpMessage = "Specify the Resource Group of the AppGw")]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory = $true, HelpMessage = "Specify the Name of the AppGw")]
    [string]$Name
)

#requires -version 7
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'        # progress bar slows down the download!

# Get the AppGw
$appGw = Get-AzApplicationGateway -ResourceGroupName $ResourceGroupName -Name $Name

# Get the certificates
$certs = $appgw | Get-AzApplicationGatewaySslCertificate

# Output the certificates showing details
foreach ($cert in $certs) {

    $certBytes = [Convert]::FromBase64String($cert.PublicCertData)
    $certCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
    $certCollection.Import($certBytes)

    write-host
    write-host -ForegroundColor Cyan "AppGW Certificate Name: $($cert.Name)"

    # Output the certificate details
    $certCollection | ForEach-Object {
        Write-Host "`tIssuer: $($_.Issuer)"
        Write-Host "`tSubject: $($_.Subject)"
        Write-Host "`tDnsNameList: $($_.DnsNameList)"
        Write-Host "`tThumbprint: $($_.Thumbprint)"
        Write-Host "`tNotBefore: $($_.NotBefore)"
        Write-Host -NoNewline "`tNotAfter: $($_.NotAfter)"

        # check if the certificate is going to expire (within 30 days)
        $daysToExpire = [math]::Round(($_.NotAfter - (Get-Date)).TotalDays)
        if ($daysToExpire -lt 30) {
            Write-Host -ForegroundColor Red " WARNING! Certificate is going to expire in $daysToExpire days"
        }
        else {
            Write-Host
        }

        Write-Host "`t---------"
    }

}