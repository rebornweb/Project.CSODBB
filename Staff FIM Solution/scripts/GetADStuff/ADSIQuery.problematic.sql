
  
   Select top 902 
	cn
From --
    OPENROWSET
    (
    'AdsDsoObject',
    'User ID=;Password=;ADSI Flag=0x11;Page Size=100',
    'SELECT
    sAMAccountName,
    displayName, 
	cn,
	info,
	description
   FROM ''LDAP://D-OCCCP-DC001.dbb.local/OU=Groups,DC=dbb,DC=local''
   WHERE objectCategory = ''group'' AND
      objectClass = ''group'' and info = ''O*''') A 
--group by info
--having COUNT(*) > 1

      
/*
exec   sp_configure 'show advanced options', 1;
RECONFIGURE;
exec sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
*/
