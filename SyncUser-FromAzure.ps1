#===================================================================================================
#Author = Muhammed Yılmaz
#Email= myilmazbm@gmail.com
#Blogs= bilincsizkullanici.wordpress.com
#=====================================================================================================
# This Script can be useful to Quickly Sync office365 users with Active Directory
# You must have user create permission in your AD to create new users in AD
# You must have internet access to use this script
# if your azure user pass MFA then this script can be run on task scheduler
#
#Usage Example:
#Sync Users from Office365 to Active Directory
#>.\SyncUser-FromAzure.ps1 -username "userreader@contoso.com" -password "Pass123456--" -OU "CN=Users,DC=yilmaz,DC=local"
#
#Create Users in Active Directory with password and Desctiption
#>.\SyncUser-FromAzure.ps1 -username "userreader@contoso.com" -password "Pass123456--" -OU "CN=Users,DC=yilmaz,DC=local" -DefaultPassword "Pass123456--" -DefaultDescription "User Description"
#=====================================================================================================

param(
    # Azure AD User Name which have access to Office 365 and read access to user attributes
    [Parameter(Mandatory)]
    [string]$username,
    # Azure AD User Password
    [Parameter(Mandatory)]
    [SecureString]$password,
    # Organizational Unit Name From On-Premise AD which you want to Sync Users
    [Parameter(Mandatory)]
    [string]$OU,
    # Default User Password
    [SecureString]$DefaultPassword="Pass123456!!",
    # Default Description of User Account in AD
    [string]$DefaultDescription="Synced From AzureAD"
)

$Cred = New-Object System.Management.Automation.PSCredential ($username, $password)
Connect-AzureAD -Credential $Cred #$(get-credential)

$AZUsers=Get-AzureADUser -All $true
$ADUsers=Get-ADUser -Filter * -Properties *

foreach($AZUser in $AZUsers){
    $isNotInAD=$true
    foreach($ADUser in $ADUsers){
        if(($ADUser.DisplayName -eq $AZUser.DisplayName)){
            $isNotInAD = $false
        }
    }
    if( $isNotInAD){
            $name = $AZUser.GivenName + " " +  $AZUser.Surname
            $SAM = "$(($AZUser.UserPrincipalName -split '@')[0])"
            New-ADUser `
                -Name $name `
                -GivenName "$($AZUser.GivenName)" `
                -Surname "$($AZUser.Surname)" `
                -Path  $OU `
                -SamAccountName  $sam.Substring(0,@{$true=18;$false=$sam.Length}[$sam.Length -gt 18]).Trim() `
                -DisplayName "$($AZUser.DisplayName)" `
                -AccountPassword $DefaultPassword `
                -ChangePasswordAtLogon $true  `
                -EmailAddress "$($AZUser.Mail)"  `
                -Description $DefaultDescription  `
                -UserPrincipalName "$($AZUser.UserPrincipalName)"  `
                -Enabled $true
                #
    }
}


