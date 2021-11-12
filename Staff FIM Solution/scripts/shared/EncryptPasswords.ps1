#encrypt Password
#$key = (3,41,2,3,56,30,254,253,1,90,2,23,42,38,38,231,1,34,48,7,17,5,35,43)
#read-host -assecurestring | convertfrom-securestring -key $key | out-file SecPwdDownstreamAD.txt
#read-host -assecurestring | convertfrom-securestring -key $key | out-file SecPwdUpstreamAD.txt
write-host("Enter Password for downstream account (originenergy\svc-fim-amda-ds):")
read-host -assecurestring | convertfrom-securestring | out-file "C:\FIM\Scripts\Shared\SecPwdDownstreamAD.txt"
write-host("Successfully encrypted to C:\FIM\Scripts\Shared\SecPwdDownstreamAD.txt")
write-host("")
write-host("Enter Password for upstream account (originenergy\svc-fim-amda-us):")
read-host -assecurestring | convertfrom-securestring | out-file "C:\FIM\Scripts\Shared\SecPwdUpstreamAD.txt"
write-host("Successfully encrypted to C:\FIM\Scripts\Shared\SecPwdUpstreamAD.txt")
