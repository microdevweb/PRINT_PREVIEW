; *******************************************************************************************************************************************************
; AUTHOR        : MicrodevWeb
; PROJECT NAME  : Sqlite vieuw
; CLASS NAME    : PRINT_PREVIEW
; VERSION       : 1.0
; REQUIERED     : PB 5.60
; *******************************************************************************************************************************************************
DeclareModule PRINT_PREVIEW
  ;======================================================================================================================================================
  ;-* PUBLIC CONSTANTE
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------
  Enumeration 
    #EventOpenWindow
    #EventRefreshing
    #EventZoom
    #EventPrint
    #EventExit
    #EventCombo
    #EventButton
    #EventSizeWindow
  EndEnumeration
  ;}-----------------------------------------------------------------------------------------------------------------------------------------------------
  ;======================================================================================================================================================
  ;-* PUBLIC INTERFACE
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------
  Interface _PRINT_PREVIEW
    Free()
    AddComboBox(label.s,width=#PB_Ignore)
    GetComboboxID(ComboboxId)
    GetWindowID()
    Open(MotherWindow=#PB_Ignore)
    AddButton(label.s,width=#PB_Ignore)
    GetButtonID(ButtonId)
    RefreshMe()
  EndInterface
  ;}-----------------------------------------------------------------------------------------------------------------------------------------------------
  ;======================================================================================================================================================
  ;-* PUBLIC PROTOTYPES
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------
  Declare New(TitleWindow.s,w,h,*Callback,PageWidth=210,PageHeigth=297,ZommFactor.f=1,Unity=#PB_Unit_Millimeter)
  ;}-----------------------------------------------------------------------------------------------------------------------------------------------------
EndDeclareModule
Module PRINT_PREVIEW
  EnableExplicit
  ;======================================================================================================================================================
  ;-* PRIVATE CONSTANTE
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------
  ;}-----------------------------------------------------------------------------------------------------------------------------------------------------
  ;======================================================================================================================================================
  ;-* PRIVATE STRUCTURES
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------
  Structure sCB
    w.l
    label.s
    Id.l
  EndStructure
  Structure sPRINT_PREVIEW
    *pPRINT_PREVIEW
    List myCb.sCB()
    List myBt.sCB()
    titleWindow.s
    Unity.l
    w.l
    h.l
    IdArea.l
    IdCanvas.l
    IdForm.l
    IdDialog.l
    MotherWindow.l
    ZoomFactor.f
    IdCbZoom.l
    IdBtPrint.l
    IdBtExit.l
    pageWidth.l
    pageHeight.l
    IdFont.l
    *CallBack
  EndStructure
  ;}-----------------------------------------------------------------------------------------------------------------------------------------------------
  ;======================================================================================================================================================
  ;-* PRIVATE VARIABLES
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------
  ;}-----------------------------------------------------------------------------------------------------------------------------------------------------
  ;======================================================================================================================================================
  ;-* PRIVATE PROTOTYPES
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------
  ;}-----------------------------------------------------------------------------------------------------------------------------------------------------
  ;======================================================================================================================================================
  ;-* PRIVATE FUNCTIONS
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------
  Procedure.s MakeXml(*This.sPRINT_PREVIEW)
    Protected xml.s,flags.s
    flags="#PB_Window_SystemMenu|#PB_Window_MaximizeGadget|#PB_Window_SizeGadget"
    With *This
      If \MotherWindow=#PB_Ignore
        flags+"|#PB_Window_ScreenCentered"
      Else
        flags+"|#PB_Window_WindowCentered"
      EndIf
      xml="<window name='form' "+
          "  width='"+Str(\w)+"'"+
          "  height='"+Str(\h)+"'"+
          "  text="+Chr(34)+\titleWindow+Chr(34)+
          "  flags='"+flags+"'>"+
          "   <vbox expand='item:2'>"+
          "     <hbox expand='no'>"
      ; add combobox
      ForEach \myCb()
        xml+"<frame text="+Chr(34)+\myCb()\label+Chr(34)+">"+
            "  <combobox name='cb_"+Str(ListIndex(\myCb()))+"'"
        If \myCb()\w<>#PB_Ignore
          xml+" width='"+Str(\myCb()\w)+"' "
        EndIf    
        xml+"/>"+
            "</frame>"
      Next
      ; add zomm combo
      xml+"<frame text='Zoom'>"+
          " <combobox name='cb_zoom' width='80'/>"+
          "</frame>"
      ; add button
      ForEach \myBt()
        xml+"<button name='bt_"+Str(ListIndex(\myBt()))+"'"
        If \myCb()\w<>#PB_Ignore
          xml+" width='"+Str(\myBt()\w)+"' "
        EndIf    
        xml+"/>"
      Next
      ; add printing button
      xml+"<button name='bt_print' width='90' text='Imprimer'/>"
      ; add exit button
      xml+"<button name='bt_exit' width='90' text='Quitter'/>"
      xml+"     </hbox>"+
          "     <scrollarea name='area'>"+
          "     </scrollarea>"+
          "   </vbox>"+       
          "</window>"
    EndWith
    ProcedureReturn xml
  EndProcedure
  Procedure ResizeCanvas(*This.sPRINT_PREVIEW)
    Protected W,H,X,Y,cW,cH
    With *This
      StartVectorDrawing(CanvasVectorOutput(\IdCanvas,\Unity))
      ScaleCoordinates(\ZoomFactor,\ZoomFactor,#PB_Coordinate_User)
      cW=ConvertCoordinateX(\pageWidth,0,#PB_Coordinate_User,#PB_Coordinate_Device)
      cH=ConvertCoordinateY(0,\pageHeight,#PB_Coordinate_User,#PB_Coordinate_Device)
      StopVectorDrawing()
      If (cw)<GadgetWidth(\IdArea)-50
        SetGadgetAttribute(\IdArea,#PB_ScrollArea_InnerWidth,GadgetWidth(\IdArea)-50)
        x=(GadgetWidth(\IdArea)/2)-((cw)/2)
      Else
        SetGadgetAttribute(\IdArea,#PB_ScrollArea_InnerWidth,(cw)+50)
        x=0
      EndIf
      If (ch)<GadgetHeight(\IdArea)-50
        SetGadgetAttribute(\IdArea,#PB_ScrollArea_InnerHeight,GadgetHeight(\IdArea)-50)
        Y=(GadgetHeight(\IdArea)/2)-((ch)/2)
      Else
        SetGadgetAttribute(\IdArea,#PB_ScrollArea_InnerHeight,ch+50)
        Y=0
      EndIf
      ResizeGadget(\IdCanvas,X,Y,cW,cH)
    EndWith
  EndProcedure
  Procedure FillCbZoom(*This.sPRINT_PREVIEW)
    Protected z=25,i,s,zz.f
    With *This
      For i=0 To 11
        AddGadgetItem(\IdCbZoom,-1,Str(z)+" %")
        SetGadgetItemData(\IdCbZoom,i,z)
        zz= (z/100)
        If zz=\ZoomFactor
          s=i
        EndIf
        z+25
      Next
      SetGadgetState(\IdCbZoom,s)
    EndWith
  EndProcedure
  Procedure Draw(*This.sPRINT_PREVIEW)
    With *This
      StartVectorDrawing(CanvasVectorOutput(\IdCanvas,\Unity))
      ScaleCoordinates(\ZoomFactor,\ZoomFactor,#PB_Coordinate_User)
      VectorSourceColor($FFFFFFFF)
      FillVectorOutput()
    EndWith
  EndProcedure
  Procedure Exit()
    Protected *This.sPRINT_PREVIEW=GetWindowData(EventWindow())
    With *This
      CloseWindow(\IdForm)
      CallFunctionFast(\CallBack,#EventExit,-1)
    EndWith
  EndProcedure
  Procedure MyEvent()
    Protected *This.sPRINT_PREVIEW=GetWindowData(EventWindow())
    With *This
      Select EventGadget()
        Case \IdCbZoom
          \ZoomFactor=GetGadgetItemData(\IdCbZoom,GetGadgetState(\IdCbZoom))/100
          ResizeCanvas(*This)
          Draw(*This)
          CallFunctionFast(\CallBack,#EventZoom,-1)
          StopVectorDrawing()
          ProcedureReturn 
        Case \IdBtExit
          CloseWindow(\IdForm)
          CallFunctionFast(\CallBack,#EventExit,-1)
          ProcedureReturn
        Case \IdBtPrint
          CallFunctionFast(\CallBack,#EventPrint,-1)
          ProcedureReturn
        Case \IdArea
          ProcedureReturn
        Case \IdCanvas
          ProcedureReturn
        Default
          ForEach \myCb()
            If EventGadget()=\myCb()\Id
              Draw(*This)
              CallFunctionFast(\CallBack,#EventCombo,ListIndex(\myCb()))
              StopVectorDrawing()
              ProcedureReturn
            EndIf
          Next
          ForEach \myBt()
            If EventGadget()=\myCb()\Id
              Draw(*This)
              CallFunctionFast(\CallBack,#EventButton,ListIndex(\myBt()))
              StopVectorDrawing()
              ProcedureReturn
            EndIf
          Next
      EndSelect
    EndWith
  EndProcedure
  Procedure EventSize()
    Protected *This.sPRINT_PREVIEW=GetWindowData(EventWindow())
    With *This
      ResizeGadget(\IdArea,0,0,WindowWidth(\IdForm),WindowHeight(\IdForm))
      ResizeCanvas(*This)
      Draw(*This)
      CallFunctionFast(\CallBack,#EventSizeWindow,-1)
      StopVectorDrawing()
    EndWith
  EndProcedure
  ;}-----------------------------------------------------------------------------------------------------------------------------------------------------
  ;======================================================================================================================================================
  ;-* PUBLIC FUNCTIONS
  ; -----------------------------------------------------------------------------------------------------------------------------------------------------
  ;-* CONSTRUCTOR DESTRUCTOR
  Procedure New(TitleWindow.s,w,h,*Callback,PageWidth=210,PageHeigth=297,ZommFactor.f=1,Unity=#PB_Unit_Millimeter)
    Protected *object.sPRINT_PREVIEW = AllocateStructure(sPRINT_PREVIEW)
    With *object
      \titleWindow=TitleWindow
      \w=w
      \h=h
      \Unity=Unity
      \ZoomFactor=ZommFactor
      \pageWidth=PageWidth
      \pageHeight=PageHeigth
      \IdFont=LoadFont(#PB_Any,"Arial",9,#PB_Font_HighQuality)
      \CallBack=*Callback
      \pPRINT_PREVIEW=?PROC
      ProcedureReturn *object
    EndWith
  EndProcedure
  Procedure Free(*This.sPRINT_PREVIEW)
    With *This
      ClearStructure(*This,sPRINT_PREVIEW)
    EndWith
  EndProcedure
  ;}
  ;-* PUBLIC METHOD
  Procedure AddComboBox(*This.sPRINT_PREVIEW,label.s,width=#PB_Ignore)
    With *This
      AddElement(\myCb())
      \myCb()\label=label
      \myCb()\w=width
      ProcedureReturn ListIndex(\myCb())
    EndWith
  EndProcedure
  Procedure GetComboboxID(*This.sPRINT_PREVIEW,ComboboxId)
    With *This
      If Not SelectElement(\myCb(),ComboboxId)
        MessageRequester("PRINT_PREVIEW Error","This combox "+Str(ComboboxId)+" don't exists")
        ProcedureReturn -1
      EndIf
      ; The window is not opened
      If Not IsWindow(\IdForm)
        MessageRequester("PRINT_PREVIEW Error","Please Open the window before this method GetComboboxID")
        ProcedureReturn -1
      EndIf
      ProcedureReturn \myCb()\Id
    EndWith
  EndProcedure
  Procedure GetWindowID(*This.sPRINT_PREVIEW)
    With *This
      ; The window is not opened
      If Not IsWindow(\IdForm)
        MessageRequester("PRINT_PREVIEW Error","Please Open the window before this method GetWindowID")
        ProcedureReturn -1
      EndIf
      ProcedureReturn \IdForm
    EndWith
  EndProcedure
  Procedure Open(*This.sPRINT_PREVIEW,MotherWindow=#PB_Ignore)
    Protected xml.s=MakeXml(*This)
    With *This
      \MotherWindow=MotherWindow
      If Not CatchXML(0,@xml,StringByteLength(xml),0,#PB_UTF8)
        MessageRequester("PRINT_PREVIEW Error","Can't make xml")
        ProcedureReturn -1
      EndIf
      \IdDialog=CreateDialog(#PB_Any)
      SetGadgetFont(#PB_Default,FontID(\IdFont))
      If \MotherWindow=#PB_Ignore
        If Not OpenXMLDialog(\IdDialog,0,"form")
          MessageRequester("PRINT_PREVIEW Error","Can't open window")
          ProcedureReturn -1
        EndIf
      Else
        If Not OpenXMLDialog(\IdDialog,0,"form",0,0,0,0,WindowID(\MotherWindow))
          MessageRequester("PRINT_PREVIEW Error","Can't open window")
          ProcedureReturn -1
        EndIf
      EndIf
      ; Make the gadgets id and make callback
      \IdForm=DialogWindow(\IdDialog)
      SetWindowData(\IdForm,*This)
      \IdCbZoom=DialogGadget(\IdDialog,"cb_zoom")
      \IdBtExit=DialogGadget(\IdDialog,"bt_exit")
      \IdBtPrint=DialogGadget(\IdDialog,"bt_print")
      \IdArea=DialogGadget(\IdDialog,"area")
      ; Make canvas
      OpenGadgetList(\IdArea)
      \IdCanvas=CanvasGadget(#PB_Any,0,0,0,0,#PB_Canvas_Keyboard)
      CloseGadgetList()
      ; Make cb gadget id
      ForEach \myCb()
        \myCb()\Id=DialogGadget(\IdDialog,"cb_"+Str(ListIndex(\myCb())))
      Next
      ; Make bt gadget id
      ForEach \myBt()
        \myBt()\Id=DialogGadget(\IdDialog,"cb_"+Str(ListIndex(\myBt())))
      Next
      ResizeCanvas(*This)
      FillCbZoom(*This)
      ; make callback
      BindEvent(#PB_Event_Gadget,@MyEvent(),\IdForm)
      BindEvent(#PB_Event_CloseWindow,@Exit(),\IdForm)
      BindEvent(#PB_Event_SizeWindow,@EventSize(),\IdForm)
      Draw(*This)
      CallFunctionFast(\CallBack,#EventOpenWindow,-1)
      StopVectorDrawing()
    EndWith
  EndProcedure
  Procedure AddButton(*This.sPRINT_PREVIEW,label.s,width=#PB_Ignore)
    With *This
      AddElement(\myBt())
      \myBt()\label=label
      \myBt()\w=width
      ProcedureReturn ListIndex(\myBt())
    EndWith
  EndProcedure
  Procedure GetButtonID(*This.sPRINT_PREVIEW,ButtonId)
    With *This
      If Not SelectElement(\myBt(),ButtonId)
        MessageRequester("PRINT_PREVIEW Error","This button "+Str(ButtonId)+" don't exists")
        ProcedureReturn -1
      EndIf
      ; The window is not opened
      If Not IsWindow(\IdForm)
        MessageRequester("PRINT_PREVIEW Error","Please Open the window before this method GetComboboxID")
        ProcedureReturn -1
      EndIf
      ProcedureReturn \myBt()\Id
    EndWith
  EndProcedure
  Procedure RefreshMe(*This.sPRINT_PREVIEW)
    With *This
      Draw(*This)
      CallFunctionFast(\CallBack,#EventRefreshing,-1)
      StopVectorDrawing()
    EndWith
  EndProcedure
  ;}
  ;}-----------------------------------------------------------------------------------------------------------------------------------------------------
  DataSection
    PROC:
    Data.i @Free()
    Data.i @AddComboBox()
    Data.i @GetComboboxID()
    Data.i @GetWindowID()
    Data.i @Open()
    Data.i @AddButton()
    Data.i @GetButtonID()
    Data.i @RefreshMe()
  EndDataSection
EndModule
; IDE Options = PureBasic 5.60 (Windows - x64)
; CursorPosition = 252
; FirstLine = 211
; Folding = fZe-vHB--
; EnableXP