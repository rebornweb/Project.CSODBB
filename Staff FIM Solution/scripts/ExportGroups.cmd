@echo off
cls
@rem ldifde -m -n -f group.containers.ldif -o "gPLink,whenCreated,whenChanged,uSNCreated,uSNChanged,dSCorePropagationData" -r "(objectClass=organizationalUnit)" -d "ou=groups,dc=dbb,dc=local" -p subtree -c DC=dbb,DC=local #dccontext
@rem ldifde -m -n -f groups.ldif -o "member,whenCreated,whenChanged,uSNCreated,uSNChanged,dSCorePropagationData" -r "(objectClass=group)" -d "ou=groups,dc=dbb,dc=local" -p subtree -c DC=dbb,DC=local #dccontext
ldifde -f AllData.ldif -o "member,whenCreated,whenChanged,uSNCreated,uSNChanged,dSCorePropagationData" -r "(objectClass=group)" -d "ou=groups,dc=dbb,dc=local" -p subtree
pause