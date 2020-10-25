<#
.SYNOPSIS
Skrypt do tworzenia użytkowników Office 365 z pliku csv
.DESCRIPTION
Skrypt do tworzenia kont uczniów w Office 365 z pliku csv. Następnie kontom przypisywana jest licencja i na alternatywny adres mailowy wysyłane jest tymczasowe hasło

Created by: Konrad Sagala
#>

# Podajemy poświadczenia administracyjne i łączymy się z chmurą
$cred = get-credential
import-module MSOnline
Connect-MsolService -Credential $cred

$newPwd = 123zxcASD
# importujemy listę uczniów z pliku csv w postaci
# UPN,email

$AllOffice365Students = Import-CSV D:\Scripts\naglowek.csv

# dla każdego wiersza z pliku csv wykonujemy akcję
foreach ($Student in $AllOffice365Students) {
  Set-MsolUserPassword -UserPrincipalName $Student.UPN -NewPassword $Pwd -ForceChangePassword $True     

  # pobieramy dane po resecie konta
  $mail = $Student.email
  $body = "Zresetowano haslo w systemie Office 365. Haslo tymczasowe: $newPwd"

  # wysyłamy maila z hasłem na alternatywny adres uzytkownika
  # adres mailowy nadawcy należy zmienić na adres mailowy konta administracyjnego, przy pomocy którego wykonujemy skrypt
  Send-MailMessage  -SmtpServer smtp.office365.com -usessl -Credential $cred -Port 587 -To "$mail" -From "admin@twojaorganizacja.onmicrosoft.com" -Body $body -BodyAsHtml -Subject "Office 365 - zmiana hasla" 
}
