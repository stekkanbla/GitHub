
$userlist = "\\bach47edc2\47p\ps\userlist\addUsers\sqlloopUsers.csv"
$pw = read-host "Oppgi passord for de tre SQL-kontiene" -AsSecureString
import-csv $userlist | ForEach-Object { 

##for å oppgi rett OU
$base = "SQL"
$baseOu ="OU="+$base
$komplett = $baseOU+","+$tot
if (Get-QADObject -type 'organizationalUnit'  -Name $base -SearchRoot 'OU=prosjekt,DC=47p,DC=aitel,dc=hist,dc=no' )
    {
        write-host $($base)"-OUet eksisterer allerede"
    }
    else
    {
        New-QADObject -type 'organizationalUnit' -name $base -ParentContainer $fullSti
    }

##oppretter de to brukere
$login = $_.Name
if (get-qaduser -samaccountname $login) 
{ write-host $login "finnes" }
else
{ write-host "oppretter" $login
New-QADUser -name $login -SamAccountName $login -ParentContainer $komplett -userPassword $pw `
|Enable-QADUser }##end if exists



}