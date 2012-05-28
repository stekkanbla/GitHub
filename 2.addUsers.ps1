if ( (Get-PSSnapin -Name  Quest.ActiveRoles.ADManagement  -ErrorAction SilentlyContinue) -eq $null )
{
    Add-PSSnapin Quest.ActiveRoles.ADManagement 
}


##fullfører dette etter konsultasjon med andre og TI

$domene = 'DC=47p,DC=aitel,dc=hist,dc=no'
$spOU = "OU=SharePoint,OU=prosjekt,DC=47p,DC=aitel,DC=hist,DC=no"
#$fullSti= "OU=2012H,OU=SharePoint,OU=prosjekt,DC=47p,DC=aitel,DC=hist,DC=no"
$semester = "2012H"
$semesterOU = "OU=$semester,"
$fullSti = $semesterOU+$spOU

#Write-Host $semesterOU
#Write-Host $fullSti

$userlist = "\\bach47edc2\47p\ps\userlist\addUsers\ADloopusers.csv"


    
    if (Get-QADObject -type 'organizationalUnit'  -Name $semester -SearchRoot 'OU=SharePoint,OU=prosjekt,DC=47p,DC=aitel,dc=hist,dc=no' )
    {
        write-host $($semester)"eksisterer allerede"
    }
    else
    {
        write-host "Oppretter $($semester)"
        new-qadobject -type 'organizationalUnit' -Name $semester -ParentContainer 'OU=SharePoint,OU=prosjekt,DC=47p,DC=aitel,dc=hist,dc=no'
    }


##oppretter brukere som er gitt i $userlist
##hver bruker har to accs(bruker_login og bruker_farm) som ligger i egen OU(bruker)

##her starter imprt, omgjøre $_.Name til $base for å modifisere videre til _login , _farm og _svc accounts
## dette brukes for testing : 
##hvis du ikke vil bruker random passord fra .csv, skift ut $userPassword til en String, alle brukerne vil få samme passord i tilfelle (se den utkommenterte linja under)
import-csv $userlist | ForEach-Object { 
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
if (get-qaduser -samaccountname $login) 
{ write-host $login "finnes" }
else
{ write-host "oppretter" $login
New-QADUser -name $login -SamAccountName $login -userpassword $userPassWord -userPrincipalName "$login$fakeDomain" -ParentContainer $komplett `
|Enable-QADUser }##end if exists

if (get-qaduser -samaccountname $farm) 
{ write-host $farm "finnes" }
else
{ write-host "oppretter" $farm 
New-QADUser -name $farm -SamAccountName $farm -userpassword $userPassWord -userPrincipalName "$farm$fakeDomain" -ParentContainer $komplett `
|Enable-QADUser }##end if exists

if (get-qaduser -samaccountname $svc) 
{ write-host $svc "finnes" }
else
{ write-host "oppretter" $svc 
New-QADUser -name $svc -SamAccountName $svc -userpassword $userPassWord  -userPrincipalName "$svc$fakeDomain"-ParentContainer $komplett `
|Enable-QADUser }##end if exists


}
