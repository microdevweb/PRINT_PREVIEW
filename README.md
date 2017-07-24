# PRINT_PREVIEUW

Is a class for create a printing previeuw.Developed in PureBasic and for used by PureBasic

## Zip pack content
+ PRINT_PREVIEW.pbi
```
file of the class
```
+ main.pb
```
file of the testing code
```
+ DBTeste.sqlite
```
A little database for the code test
```
## Creating object:

``` markdown
myPrevieuw.PRINT_PREVIEW::_PRINT_PREVIEW = PRINT_PREVIEW::New((TitleWindow.s,w,h,*Callback,PageWidth=210,PageHeigth=297,ZommFactor.f=1,Unity=#PB_Unit_Millimeter)
TitleWindow --> Title of preview window
w --> window-width
h --> window-height
*Callback --> address of your personal function, she is call when a event is detected.
--> please declare this function like this:
    myFunction(Event-type,item-id)
    Event-type --> you can compare event-type with this enumerations
                  '#EventOpenWindow'
                  '#EventRefreshing'
                  '#EventZoom'
                  '#EventPrint
                  '#EventExit'
                  '#EventCombo'
                  '#EventButton'
                  '#EventSizeWindow'
   item-id --> It's the id of your personal combobox or buttons.  
               If the event don't concerne a personal item, its value is -1
   PageWidth  --> preview page-width
   PageHeigth --> preview page-height
   ZommFactor --> It's the starting zoom-factor
   Unity      --> It's the unit used for drawing the preview page
                  (for more details watch the help file of Purebasic, chapter "Vector drawing")
```

## Methods list:

+ AddComboBox (please use this method before opening window with method "open")
``` markdown
objectName\AddComboBox(label.s,width=#PB_Ignore)
; Adding a combobox on the toolbar
; label --> title of  combobox
; width --> width of combobox or #PB_Ignore if not determinate
; This method return the combobox-id for future use
```
+ AddButton (please use this method before opening window with method "open")
``` markdown
objectName\AddButton(label.s,width=#PB_Ignore)
; Adding a button on the toolbar
; label --> title of  button
; width --> width of button or #PB_Ignore if not determinate
; This method return the button-id for future use
```
+ RefreshMe (please use only this method after opening window with method "open")
``` markdown
objectName\RefreshMe()
;  Draw the preview and called your personal function
```
+ GetWindowID() (please use only this method after opening window with method "open")
``` markdown
objectName\GetWindowID()
;  This method return the id of window
```
+ GetComboboxID (please use only this method after opening window with method "open")
``` markdown
objectName\GetComboboxID(ComboboxId)
;  This method return the id of your personal combobox
; ComboboxId --> The id returned by the create method
``` 
+ GetButtonID (please use only this method after opening window with method "open")
``` markdown
objectName\GetButtonID(ButtonId)
;  This method return the id of your personal button
; ButtonId --> The id returned by the create method
``` 
