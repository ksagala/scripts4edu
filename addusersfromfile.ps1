<#
.SYNOPSIS
Skrypt do tworzenia użytkowników Office 365 z pliku csv
.DESCRIPTION
Skrypt do tworzenia kont uczniów w Office 365 z pliku csv. Następnie kontom przypisywana jest licencja i na alternatywny adres mailowy wysyłane jest tymczasowe hasło

Created by: Konrad Sagala
#>

# Podajemy poświadczenia administracyjne i łączymy się z chmurą
import-module MSOnline
$cred = get-credential
Connect-MsolService -Credential $cred

# podajemy nazwę licencji dla ucznia
# listę dostępnych licencji (nazwa zawiera również oznaczenie organizacji Office 365, tak że zawsze będzie inna)
# możemy sprawdzić komendą get-msolaccountSKU
$StudentsLicense = 'twojaorganizacja:STANDARDWOFFPACK_STUDENT'

# importujemy listę uczniów z pliku csv w postaci
# UserPrincipalName;DisplayName;Imie;Nazwisko;email;telefon
# Musimy wskazać znak rozdzielający, jeżeli plik csv ma kolumny rozdzielone innym znakiem niż domyślny ,

$AllOffice365Students = Import-CSV D:\Scripts\naglowek.csv -Delimiter ";"

# dla każdego wiersza z pliku csv wykonujemy akcję
foreach ($Student in $AllOffice365Students) {
    # tworzymy nowe konto w usłudze Office 365
    $O365student = New-MsolUser -UserPrincipalName $Student.UserPrincipalName -AlternateEmailAddresses $Student.email -DisplayName $Student.DisplayName -FirstName $Student.Imie -LastName $Student.Nazwisko -mobilePhone $Student.telefon -UsageLocation PL -PreferredLanguage PL-pl -PasswordNeverExpires $true -StrongPasswordRequired $true
    # przypisujemy licencję
    Set-MsolUserLicense -UserPrincipalName $Student.UserPrincipalName -AddLicenses $Studentslicense

    # pobieramy dane po utworzeniu konta
    $mail = $Student.email
    $firstpassword = $O365student.Password
    $stu = $Student.UserPrincipalName
    $body = "Utworzono konto w systemie Office 365 o nazwie $stu Haslo tymczasowe: $firstpassword"
    # wysyłamy maila z hasłem na alternatywny adres uzytkownika
    # adres mailowy nadawcy należy zmienić na adres mailowy konta administracyjnego, przy pomocy którego wykonujemy skrypt
    Send-MailMessage  -SmtpServer smtp.office365.com -usessl -Credential $cred -Port 587 -To "$mail" -From "admin@twojaorganizacja.onmicrosoft.com" -Subject "Office 365 - nowe konto" -Body $body -Encoding UTF8 -BodyAsHtml
}