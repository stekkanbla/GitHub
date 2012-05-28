
#$utfil = "\\bach47edc2\47p\ps\userlist\addUsers\ADloopusers2.csv"
$utfil = "C:\Users\toro\Dropbox\12v\Prosjekt\47p\ps\userlist\addUsers\ADloopusers.csv"
"name,password" | out-file $utfil 

### Genererer tilfeldige passord på 8tegn for hver bruker
## kopiert fra http://www.powergui.org/thread.jspa?threadID=12685
function Get-RandomPassword($length)
{
    $length-=1
    $lower = 'abcdefghijklmnopqrstuvwxyz'
    $upper = $lower.ToUpper()
    $number = 0..9
    $chars = "$lower$upper".ToCharArray()

    $pass = Get-Random -InputObject $chars -Count $length
    $digit = Get-Random -InputObject $number

    (-join $pass).insert((Get-Random $length),$digit)
}



for ($i=1;$i -le 10;$i++)
{
$pw = Get-RandomPassword(8)
"bruker"+$i+","+$pw | out-file $utfil -append


}

