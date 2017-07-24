EnableExplicit
UseSQLiteDatabase()

XIncludeFile "PRINT_PREVIEW.pbi"
Declare Callback(myEvent,Id)
#MainForm=0
Enumeration 
  #Arial10B
  #Arial9
EndEnumeration
Global myPrevieuw.PRINT_PREVIEW::_PRINT_PREVIEW = PRINT_PREVIEW::New("Aperçu facture",
                                                                     800,
                                                                     600,
                                                                     @Callback())
Global cbFac
Global DbName.s="DbTeste.sqlite"
; Ajout d'un combobox facture
cbFac=myPrevieuw\AddComboBox("Facture",100)
; Police de caractère
LoadFont(#Arial10B,"Arial",10,#PB_Font_HighQuality|#PB_Font_Bold)
LoadFont(#Arial9,"Arial",9,#PB_Font_HighQuality)
Procedure DbQuery(req.s)
  Protected id=OpenDatabase(#PB_Any,DbName,"","")
  If Not  id
    MessageRequester("Database Error","Can't open database")
    ProcedureReturn 0
  EndIf
  If Not DatabaseQuery(id,req)
    MessageRequester("Database Error",DatabaseError())
    ProcedureReturn 0
  EndIf
  ProcedureReturn id
EndProcedure
Procedure DrawCustomer()
  Protected y=30,w=40,x=210-w,h=40,txt.s,idDb,req.s,idFac
  idFac=GetGadgetItemData(myPrevieuw\GetComboboxID(cbFac),GetGadgetState(myPrevieuw\GetComboboxID(cbFac)))
  req="SELECT client.nom,"+
      " client.adresse,"+
      " client.localite,"+
      " client.codepo,"+
      " client.pays"+
      " FROM facture "+
      " LEFT JOIN client ON client.IDclient=facture.id_client"+
      " WHERE facture.IDfacture="+Str(idFac)
  idDb=DbQuery(req)
  FirstDatabaseRow(idDb)
  txt=GetDatabaseString(idDb,0)+Chr(10)+
      GetDatabaseString(idDb,1)+Chr(10)+
      GetDatabaseString(idDb,3)+" "+GetDatabaseString(idDb,2)+Chr(10)+
      GetDatabaseString(idDb,4)
  CloseDatabase(idDb)
  VectorFont(FontID(#Arial9))
  MovePathCursor(x,y)
  DrawVectorParagraph(txt,w,h)
EndProcedure
Procedure DrawEntete()
  Protected x=10,y=10,w=60,h=40
  Protected txt.s="Ets MicrodevWeb"+Chr(10)+
                  "Rue Sainry 140"+Chr(10)+
                  "4870 Trooz"+Chr(10)+
                  "(Belgique)"
  VectorSourceColor($FF000000)
  VectorFont(FontID(#Arial10B))
  MovePathCursor(x,y)
  DrawVectorParagraph(txt,w,h)
EndProcedure
Procedure DrawInfoFac()
  Protected x=10,y=60,w=80,h=8,txt.s,req.s,IdDb,idFac
  idFac=GetGadgetItemData(myPrevieuw\GetComboboxID(cbFac),GetGadgetState(myPrevieuw\GetComboboxID(cbFac)))
  req="SELECT numero,date FROM facture WHERE IDFacture="+Str(idFac)
  IdDb=DbQuery(req)
  FirstDatabaseRow(IdDb)
  txt="Trooz le "+
      Right(GetDatabaseString(IdDb,1),2)+"-"+
      Mid(GetDatabaseString(IdDb,1),5,2)+"-"+ 
      Left(GetDatabaseString(IdDb,1),4)
  VectorFont(FontID(#Arial10B))
  MovePathCursor(x,y)
  DrawVectorParagraph(txt,w,h)
  y+h
  txt="FACTURE N°: "+GetDatabaseString(IdDb,0)
  MovePathCursor(x,y)
  DrawVectorParagraph(txt,w,h)
EndProcedure
Procedure DrawFacture()
  DrawEntete()
  DrawCustomer()
  DrawInfoFac()
EndProcedure
Procedure EventPrint()
  If PrintRequester()
;     StartPrinting("Impression")
;     StartVectorDrawing(PrinterVectorOutput(#PB_Unit_Millimeter))
;     NewPrinterPage()
;     DrawFacture()
;     StopPrinting()
  EndIf
EndProcedure
Procedure Callback(myEvent,Id)
  Select myEvent
    Case PRINT_PREVIEW::#EventExit
      myPrevieuw\Free()
    Case PRINT_PREVIEW::#EventPrint
      EventPrint()
    Default
       DrawFacture()
  EndSelect
EndProcedure
Procedure Exit()
  CloseWindow(#MainForm)
  End
EndProcedure
Procedure MakeCbFacture()
  Protected idDb,req.s,i
  req="SELECT IDfacture,numero FROM facture ORDER BY numero"
  idDb=DbQuery(req)
  While NextDatabaseRow(idDb)
    AddGadgetItem(myPrevieuw\GetComboboxID(cbFac),-1,GetDatabaseString(idDb,1))
    SetGadgetItemData(myPrevieuw\GetComboboxID(cbFac),i,GetDatabaseLong(idDb,0))
    i+1
  Wend
  CloseDatabase(idDb)
  SetGadgetState(myPrevieuw\GetComboboxID(cbFac),0)
EndProcedure
OpenWindow(#MainForm,0,0,800,600,"Teste",#PB_Window_ScreenCentered|#PB_Window_SystemMenu)
myPrevieuw\Open(#MainForm)
MakeCbFacture()
myPrevieuw\RefreshMe()
BindEvent(#PB_Event_CloseWindow,@Exit(),#MainForm)
Repeat
  WaitWindowEvent()
ForEver 
; IDE Options = PureBasic 5.60 (Windows - x64)
; CursorPosition = 10
; Folding = ---
; EnableXP