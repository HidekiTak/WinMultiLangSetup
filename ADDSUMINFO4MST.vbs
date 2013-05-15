' Sum.vbs. Argument(0) is the original database. Argument(1) is the
' customized database. Argument(2) is the transform file.
Option Explicit

' Check arguments
If WScript.Arguments.Count < 2 Then
WScript.Echo "Usage is sum.vbs [original database] [customized database] [transform]"
WScript.Quit(1)
End If

' Connect to Windows Installer object
On Error Resume Next

Dim installer : Set installer = Nothing
Set installer = Wscript.CreateObject("WindowsInstaller.Installer")

' Open databases and transform
Dim database1 : Set database1 = installer.OpenDatabase(Wscript.Arguments(0), 0)
Dim database2 : Set database2 = installer.OpenDatabase(Wscript.Arguments(1), 0)
Dim transform : transform = Wscript.Arguments(2)

' Create and add Summary Information
Dim transinfo : transinfo = Database2.CreateTransformSummaryInfo(Database1, transform,0,0)
