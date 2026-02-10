Set ol = CreateObject("Outlook.Application")
Set mail = ol.CreateItem(0)

dataAtual = Now
dataHoraAtual = Year(dataAtual) & "-" & Right("0" & Month(dataAtual),2) & "-" & Right("0" & Day(dataAtual),2) & " " _
    & Right("0" & Hour(dataAtual),2) & ":" & Right("0" & Minute(dataAtual),2) & ":" & Right("0" & Second(dataAtual),2)

subject = "INFO: ATUALIZAÇÃO DADOS BLACK FRIDAY"
mail.Subject = subject

h = Hour(dataAtual)
If h < 12 Then
    greeting = "bom dia"
ElseIf h < 18 Then
    greeting = "boa tarde"
Else
    greeting = "boa noite"
End If

mail.To = "pipeline-alerts@orbit-analytics.fake"
body = "Equipe, " & greeting & "!" & vbCrLf & vbCrLf & _
    "Atualizacao das informações dos dados da Black Friday finalizada às" & dataHoraAtual & "."

mail.Body = body
mail.Send