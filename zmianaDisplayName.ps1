<#
.SYNOPSIS
Zmiana pola DisplayName, tak żeby użytkownicy wyświetlali się w kolejności Nazwisko Imię
.DESCRIPTION
Zmiana pola DisplayName dla listy użytkowników z pliku csv, tak żeby użytkownicy wyświetlali się w kolejności Nazwisko Imię

Created by: Konrad Sagala
#>

Import-Msonline
Connect-MsolService
#
# nagłówek pliku csv -> UserPrincipalName,Imie,Nazwisko
# jeżeli kolumny rozdzielone są znakiem ";" zamiast "," należy
# użyć przy imporcie atrybutu -Delimeter (import-csv domyślnie szuka ",")
#
$AllStudents = Import-CSV D:\Scripts\uczniowie.csv
ForEach ($student in $AllStudents)
{
  $DisplayName = $student.Nazwisko+" "+$student.Imie
  $currentstudent = get-MsolUser -UserPrincipalName $student.UserPrincipalName
  set-MsolUser -ObjectId $currentstudent.ObjectId -Displayname $DisplayName
}
