if ( (Get-PSSnapin -Name  Quest.ActiveRoles.ADManagement  -ErrorAction SilentlyContinue) -eq $null )
{
    Add-PSSnapin Quest.ActiveRoles.ADManagement 
}

## setter variabler
## korriger $domene
# bytt ut $semester ved behov
$domene = 'DC=47p,DC=aitel,dc=hist,dc=no'
$spOU = 'OU=SharePoint,OU=prosjekt,DC=47p,DC=aitel,DC=hist,DC=no'
#$fullSti= "OU=2012H,OU=SharePoint,OU=prosjekt,DC=47p,DC=aitel,DC=hist,DC=no"
$semester = "2012H"
$semesterOU = "OU=$semester,"
$fullSti = $semesterOU+$spOU

$userlist = "\\bach47edc2\47p\ps\userlist\addUsers\ADloopusers.csv"


    
    if (Get-QADObject -type 'organizationalUnit'  -Name $semester -SearchRoot 'OU=SharePoint,OU=prosjekt,DC=47p,DC=aitel,dc=hist,dc=no' )
    {
        write-host $($semester)"eksisterer allerede"
    }
    else
    {
        write-host "Oppretter $($semester)"
        new-qadobject -type 'organizationalUnit' -Name $semester -ParentContainer $spOU #'OU=SharePoint,OU=prosjekt,DC=47p,DC=aitel,dc=hist,dc=no'
    }


##oppretter brukere som er gitt i $userlist
##hver bruker har to accs(bruker_login og bruker_farm) som ligger i egen OU(bruker)

##her starter imprt, omgjøre $_.Name til $base for å modifisere videre til _login , _farm og _svc accounts
## dette brukes for testing : 
##hvis du ikke vil bruker random passord fra .csv, skift ut $userPassword til en String, alle brukerne vil få samme passord i tilfelle (se den utkommenterte linja under)

import-csv $userlist | ForEach-Object { # start if
$base = $_.Name
$login = $base+"_login"
$farm = $base+"_farm"
$svc = $base+"_svc" ## for servicene /managed acc
#$userPassWord =  $_.PassWord 
$userPassWord =  "ZheShiWO3" 
$fakeDomain ="@47p.aitel.hist.no"

##for å oppgi rett OU
$baseOu ="OU="+$base+","
$komplett = $baseOU + $fullSti
write-host $komplett

if (Get-QADObject -type 'organizationalUnit'  -Name $base -SearchRoot $fullsti )
    {
        write-host $($base)"eksisterer allerede"
    }
    else
    {
        New-QADObject -type 'organizationalUnit' -name $base -ParentContainer $fullSti
    }

##oppretter de tre brukere
# _login
if (get-qaduser -samaccountname $login) 
{ write-host $login "finnes" }
else
{ write-host "oppretter" $login
New-QADUser -name $login -SamAccountName $login -userpassword $userPassWord -userPrincipalName "$login$fakeDomain" -ParentContainer $komplett `
|Enable-QADUser }##end if exists
#_farm
if (get-qaduser -samaccountname $farm) 
{ write-host $farm "finnes" }
else
{ write-host "oppretter" $farm 
New-QADUser -name $farm -SamAccountName $farm -userpassword $userPassWord -userPrincipalName "$farm$fakeDomain" -ParentContainer $komplett `
|Enable-QADUser }##end if exists
#_svc
if (get-qaduser -samaccountname $svc) 
{ write-host $svc "finnes" }
else
{ write-host "oppretter" $svc 
New-QADUser -name $svc -SamAccountName $svc -userpassword $userPassWord  -userPrincipalName "$svc$fakeDomain"-ParentContainer $komplett `
|Enable-QADUser }##end if exists

### oppretter mapper for backup for hver bruker
# stien vil være \\sqlnet\backup\bruker1 
##sqlnet er failoverclusteret
## det er ikke et oppsatt som er gunstig siden originaler og backup lagres på samme område
# tatt med for å vise hvordan det kan gjøres
# ideelt sett er backuplokasjonen på et annet LUN

if ($base -eq "") ##sjekker for tomme linker, hindrer at skriptet kan forandre rettighetene på backup-rota
{
write-host "det er tomme linjer i CSV"
}
else
{


$newPath = Join-Path "\\sqlnet\backup2012H" -childpath $base
write-host $newpath

new-item -path $newPath -type directory 


$rule = New-object System.Security.AccessControl.FileSystemAccessRule ("$login", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
$rule2 = New-object System.Security.AccessControl.FileSystemAccessRule ("$farm", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
$rule3 = New-object System.Security.AccessControl.FileSystemAccessRule ("$svc", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
$acl = get-acl $newpath
$acl.addaccessRule($Rule)
$acl.addaccessRule($Rule2)
$acl.addaccessRule($Rule3)
Set-Acl -aclObject $acl -path $newPath



} ##end ifsjekk




}
