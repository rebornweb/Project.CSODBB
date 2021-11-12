@echo off
cls
ldifde -m -n -f users.containers.ldif -o "gPLink,whenCreated,whenChanged,uSNCreated,uSNChanged,dSCorePropagationData,lockoutTime,userAccountControl" -r "(objectClass=organizationalUnit)" -d "ou=staff,ou=users,ou=diocese,dc=dbb,dc=local" -p subtree -c DC=dbb,DC=local #dccontext
ldifde -m -n -f users.ldif -o "whenCreated,whenChanged,uSNCreated,uSNChanged,dSCorePropagationData,lockoutTime,userAccountControl" -r "(objectClass=user)" -d "ou=staff,ou=users,ou=diocese,dc=dbb,dc=local" -p subtree -c DC=dbb,DC=local #dccontext
pause