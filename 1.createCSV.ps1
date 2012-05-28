#### NB! bruker relative stier, se til at du står i rett folder når du oppretter brukerne!

$utfil = ".\ADloopusers.csv"
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

##delen som oppretter brukerne.
#går fra 1-10, forandre etterbehov

for ($i=1;$i -le 10;$i++)
{
$pw = Get-RandomPassword(8)
"bruker"+$i+","+$pw | out-file $utfil -append


}

