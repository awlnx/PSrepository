
<#
.SYNOPSIS
    Retrieves a user's password expiration status


.DESCRIPTION
    The Get-MsolPasswordExpirationStatus script can be used to retrieve an individual user's password status, or list of user's password status. An individual user will be
    retrieved if the ObjectId or UserPrincipalName parameter is used.

#>
Param(
    [Parameter(Mandatory=$False)]
        [string]$UserPrincipalName,
        [Parameter(Mandatory=$False)]
        [GUID]$ObjectId



)       

## vars 
$Domain = ((Get-MsolDomain)[0]).Name #Sloppy. Is only checking the default domain. Should expand this out to have to take a domain or check every domain of a users upn.
$ValidityPeriod = (Get-MsolPasswordPolicy -DomainName $domain).ValidityPeriod

if (($PSBoundParameters -eq $null)) {
    $Users = (Get-MsolUser)
    }else {
       $Users = Get-MsolUser @PSBoundParameters
        }
                                


#Credit to Boe Prox on how to setup Custom Default Property Sets in Scripts without a ps1xml https://learn-powershell.net/2013/08/03/quick-hits-set-the-default-property-display-in-powershell-on-custom-objects/

$defaultDisplaySet = 'UserPrincipalName','DisplayName','PasswordIsExpired'

$defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet(‘DefaultDisplayPropertySet’,[string[]]$defaultDisplaySet)

$PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)

foreach($User in $Users){

 $DaysSinceLastChanged = (New-TimeSpan -Start $User.LastPasswordChangeTimestamp -End (Get-Date)).Days
 $Expired = ($daysSinceLastChanged -gt $validityPeriod) -and -not $User.PasswordNeverExpires
    $o = New-Object PSObject -Property @{
        UserPrincipalName = $User.UserPrincipalName
        DisplayName = $User.DisplayName
        BlockCredential = $User.BlockCredential
        PasswordIsExpired = $Expired
        LastPasswordChangeTimeStamp = $User.LastPasswordChangeTimestamp
        DaysSinceLastChange = $DaysSinceLastChanged
        PasswordNeverExpires =  $User.PasswordNeverExpires
        }
   $o.PSObject.TypeNames.Insert(0,'User.Information')
    $o | Add-Member MemberSet PSStandardMembers $PSStandardMembers
    $o
    }
  
