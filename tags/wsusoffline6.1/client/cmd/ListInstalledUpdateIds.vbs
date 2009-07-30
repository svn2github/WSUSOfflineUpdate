' *** Author: T. Wittrock, RZ Uni Kiel ***

Option Explicit

Dim wshShell, objUpdateService, objUpdateSearcher, objSearchResult, objUpdate, objIDFile
Dim strTempFolder, strTextFileName, i

Set wshShell = WScript.CreateObject("WScript.Shell")
strTempFolder = wshShell.ExpandEnvironmentStrings("%TEMP%")
strTextFileName = strTempFolder & "\InstalledUpdateIds.txt"
  
Set objUpdateService = CreateObject("Microsoft.Update.ServiceManager").AddScanPackageService("Offline Sync Service", strTempFolder & "\wsusscn2.cab")
Set objUpdateSearcher = CreateObject("Microsoft.Update.Session").CreateUpdateSearcher()
objUpdateSearcher.ServerSelection = 3 ' ssOthers
objUpdateSearcher.ServiceID = objUpdateService.ServiceID
Set objSearchResult = objUpdateSearcher.Search("Type='Software' and IsInstalled=1")

If objSearchResult.Updates.Count > 0 Then
  Set objIDFile = CreateObject("Scripting.FileSystemObject").CreateTextFile(strTextFileName, True)
  For Each objUpdate In objSearchResult.Updates
    For i = 0 to objUpdate.KBArticleIDs.Count - 1
      objIDFile.WriteLine(objUpdate.KBArticleIDs.Item(i))
    Next
  Next
  objIDFile.Close
End If
WScript.Quit(0)
