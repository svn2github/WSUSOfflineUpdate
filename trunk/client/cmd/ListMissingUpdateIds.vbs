' *** Author: T. Wittrock, Kiel ***

Option Explicit

Dim wshShell, objUpdateService, objUpdateSearcher, objSearchResult, objUpdate, objIDFile
Dim strTempFolder, strTextFileName, strArgument

Set wshShell = WScript.CreateObject("WScript.Shell")
strTempFolder = wshShell.ExpandEnvironmentStrings("%TEMP%")
strTextFileName = strTempFolder & "\MissingUpdateIds.txt"
If WScript.Arguments.Count = 0 Then
  strArgument = ""
Else
  strArgument = WScript.Arguments(0)
End If

Set objUpdateService = CreateObject("Microsoft.Update.ServiceManager").AddScanPackageService("Offline Sync Service", strTempFolder & "\wsusscn2.cab")
Set objUpdateSearcher = CreateObject("Microsoft.Update.Session").CreateUpdateSearcher()
objUpdateSearcher.ServerSelection = 3 ' ssOthers
objUpdateSearcher.ServiceID = objUpdateService.ServiceID
If LCase(strArgument) = "/all" Then
  Set objSearchResult = objUpdateSearcher.Search("Type='Software'")
Else
  Set objSearchResult = objUpdateSearcher.Search("Type='Software' and IsInstalled=0")
End If

If objSearchResult.Updates.Count > 0 Then
  Set objIDFile = CreateObject("Scripting.FileSystemObject").CreateTextFile(strTextFileName, True)
  For Each objUpdate In objSearchResult.Updates
    If objUpdate.KBArticleIDs.Count > 0 Then
      objIDFile.Write(objUpdate.KBArticleIDs.Item(0))
    End If
    objIDFile.WriteLine("," & objUpdate.Identity.UpdateID)
  Next
  objIDFile.Close
End If
WScript.Quit(0)
