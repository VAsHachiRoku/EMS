#user is provide by argument
if ($args.count -ne 1)
{        
    Write-Host "Usage: GetRegisteredDeviceForUser.ps1 <user name>"
    exit 1 
}
#get user's sid
$domain = Get-ADDomain
$userName = $args[0]
$userSid = (New-Object System.Security.Principal.NTAccount($domain.NetBIOSName, $userName)).Translate([System.Security.Principal.SecurityIdentifier]).value
#search device object when registeredUser = user sid
$objDefaultNC = New-Object System.DirectoryServices.DirectoryEntry
$ldapPath = "LDAP://CN=RegisteredDevices," + $objDefaultNC.distinguishedName 
$objDeviceContainer = New-Object System.DirectoryServices.DirectoryEntry($ldapPath)
$strFilter = "(&(objectClass=msDS-Device)(msDS-RegisteredOwner=$userSid))"
$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
$objSearcher.SearchRoot = $objDeviceContainer 
$objSearcher.PageSize = 100
$objSearcher.Filter = $strFilter
$objSearcher.SearchScope = "Onelevel"
$colResults = $objSearcher.FindAll()
Write-Host "Found" $colResults.count "device objects"
foreach ($objResult in $colResults)
    {$objResult.Properties}