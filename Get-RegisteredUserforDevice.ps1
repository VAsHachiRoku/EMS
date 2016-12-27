#user is provide by argument
if ($args.count -ne 1)
{        
    Write-Host "Usage: GetRegisteredUserForDevice.ps1 <device name>"
    exit 1 
}
#get user's sid
$domain = Get-ADDomain
$deviceDisplayName = $args[0]
#search device object when device displayName = client computer name
$objDefaultNC = New-Object System.DirectoryServices.DirectoryEntry
$ldapPath = "LDAP://CN=RegisteredDevices," + $objDefaultNC.distinguishedName 
$objDeviceContainer = New-Object System.DirectoryServices.DirectoryEntry($ldapPath)
$strFilter = "(&(objectClass=msDS-Device)(displayName=$deviceDisplayName))"
$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
$objSearcher.SearchRoot = $objDeviceContainer 
$objSearcher.PageSize = 100
$objSearcher.Filter = $strFilter
$objSearcher.SearchScope = "Onelevel"
$colResults = $objSearcher.FindAll()
Write-Host "Found" $colResults.count "device objects in AD whose displayName is " $args[0]
foreach ($objResult in $colResults)
{
    $sidString = ""
    $objItem = $objResult.Properties
    $userSid = $objItem.'msds-registeredowner'
    $userSid = $userSid[0]
    for($i=0;$i -lt $userSid.count; $i++)
    {
        $sidString = $sidString + [char]$userSid[$i]
    }
    $objSID = New-Object System.Security.Principal.SecurityIdentifier($sidString)
    try
    {
        $objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
        Write-Host "UserSid:" $sidString "UserName:" $objUser.Value
    }
    catch
    {
        Write-Host "UserSid:" $sidString "Failed to get user name, user might be deleted" 
    }
    
}