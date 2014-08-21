//
// Update application versioning information. Sets App.ShortVersion
// and also looks at the current git revision.
//

Dim GitRev As String = Trim(DoShellCommand("git --git-dir=""$PROJECT_PATH/.git"" rev-parse HEAD"))
Dim Now As String = Trim(DoShellCommand("date"))

If Len(Now) = 14 Then
Now = Now.Right(10)
Else
Now = Trim(DoShellCommand("date +%m/%d/%Y"))
End If

Dim BuildNumber As String = ConstantValue("App.BuildNumber")
If ConstantValue("App.BuildDateString") <> Now Then
BuildNumber = "1"
Else
BuildNumber = Str(Val(BuildNumber) + 1)
End If

// Console applications do not have a Product Name.
Dim ProductName As String = ConstantValue("App.ProductName")
Dim StageCode As Integer = Val(PropertyValue("App.StageCode"))
Dim StageCodes() As String = Array("dev", "alpha", "beta", "prod")
Dim Copyright As String = ConstantValue("App.Copyright")
Dim ShortVersion As String = Now + " r" + BuildNumber
Dim LongVersion As String = ProductName + " build " + ShortVersion + _
" " + StageCodes(StageCode) + " (" + GitRev.Left(8) + ")"

If Copyright <> "" Then
LongVersion = LongVersion + ". " + Copyright
End If

PropertyValue("App.ShortVersion") = ShortVersion
PropertyValue("App.LongVersion") = LongVersion
ConstantValue("App.GitRevision") = GitRev
ConstantValue("App.BuildNumber") = BuildNumber
ConstantValue("App.BuildDateString") = Now

Dim appPath As String

appPath = BuildApp(3)
appPath = BuildApp(4)
appPath = BuildApp(7)
