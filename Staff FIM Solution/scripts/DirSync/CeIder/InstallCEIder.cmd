C:
CD C:\Windows\ADAM
ldifde -i -f CSODBB-User.ex.ldf -s localhost:50000 -k -j . -c "CN=Schema,CN=Configuration,DC=X" #schemaNamingContext
pause
