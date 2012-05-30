### $utfil må være ren før kjøring av skript, hvis du vil legge til på en eksisterende fil, forandre $utfil 

$innfil = import-csv "ADLoopUsers.csv"
$utfil = ".\sqlUsersText.txt"
$domene = "47P"

$i = 1
 foreach ($bruker in $innfil) {
 $user = "$($domene)\$($bruker.name)"
 $login = "$($domene)\$($bruker.name)_login"
 $farm = "$($domene)\$($bruker.name)_farm"
 write-host "LEGGER TIL $($domene)\$($bruker.name)"
"

/****** ---------- LEGGER TIL $user  --- BRUKERNUMMER $($i)---------- ******/


USE [master]
GO

CREATE LOGIN [$login] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
GO

ALTER SERVER ROLE [securityadmin] ADD MEMBER [$login]
GO

ALTER SERVER ROLE [dbcreator] ADD MEMBER [$login]
GO


USE [master]
GO

CREATE LOGIN [$farm] FROM WINDOWS WITH DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english]
GO

ALTER SERVER ROLE [securityadmin] ADD MEMBER [$farm]
GO

ALTER SERVER ROLE [dbcreator] ADD MEMBER [$farm]
GO

/****** ---------- $user  --- BRUKERNUMMER $($i) ---------- ******/





" | out-file $utfil -append
$i++
 }
write-host "$i brukere lagt til (to konti hver)"