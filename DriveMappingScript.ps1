Start-Transcript -Path $(Join-Path $env:temp "DriveMapping.log")

$driveMappingConfig=@()
$username


######################################################################
#                section script configuration                        #
######################################################################

<#
   Add your internal Active Directory Domain name and custom network drives below
#>

$dnsDomainName= "gk.no"


$driveMappingConfig+= [PSCUSTOMOBJECT]@{
    DriveLetter = "I"
    UNCPath= "\\gk.no\data\winapps"
    Description="winapps"
}


$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "J"
    UNCPath= "\\gk-fil04\users\$env:USERNAME"
    Description="Home"
}

$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "O"
    UNCPath= "\\gk.no\data"
    Description="Data"
}

$driveMappingConfig+=  [PSCUSTOMOBJECT]@{
    DriveLetter = "P"
    UNCPath= "\\gk.no\data"
    Description="Data"
}

######################################################################
#               end section script configuration                     #
######################################################################

$connected=$false
$retries=0
$maxRetries=3

Write-Output "Starting script..."
do {
    
    if (Resolve-DnsName $dnsDomainName -ErrorAction SilentlyContinue){
    
        $connected=$true

    } else{
 
        $retries++
        
        Write-Warning "Cannot resolve: $dnsDomainName, assuming no connection to fileserver"
 
        Start-Sleep -Seconds 3
 
        if ($retries -eq $maxRetries){
            
            Throw "Exceeded maximum numbers of retries ($maxRetries) to resolve dns name ($dnsDomainName)"
        }
    }
 
}while( -not ($Connected))

#Map drives
    $driveMappingConfig.GetEnumerator() | ForEach-Object {

        Write-Output "Mapping network drive $($PSItem.UNCPath)"

        New-PSDrive -PSProvider FileSystem -Name $PSItem.DriveLetter -Root $PSItem.UNCPath -Description $PSItem.Description -Persist -Scope global

        (New-Object -ComObject Shell.Application).NameSpace("$($PSItem.DriveLEtter):").Self.Name=$PSItem.Description
}

Stop-Transcript