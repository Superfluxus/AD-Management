# AD-Management
Powershell module to reset a user's AD password to a randomly generated string


Requires you to manually specify varibles for:

$DomainUser = Domain User to authenticate against the domain controller with (domain admin preferably)

$DomainPassword = Password to the $DomainUser account

$DC = Domain Controller hostname/IP

$DN = Distinguished Name of the AD Forest you're searching, such as DC=Contoso, DC=com
