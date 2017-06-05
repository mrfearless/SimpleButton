;======================================================================================================================================
;
; SimpleButton Custom Control v1.0.0.0
;
; 2017 by fearless
;
; http://github.com/mrfearless/SimpleButton
;
;======================================================================================================================================

;--------------------------------------------------------------------------------------------------------------------------------------
; SimpleButton Prototypes
;--------------------------------------------------------------------------------------------------------------------------------------


SimpleButtonRegister            PROTO                                                                   ; Use 'SimpleButton_Control' as class in RadASM custom class control
SimpleButtonCreate              PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD    ; hWndParent, lpszText, xpos, ypos, dwWidth, dwHeight, dwResourceID, dwStyle
SimpleButtonGetProperty         PROTO :DWORD, :DWORD                                                    ; hSimpleButton, dwProperty
SimpleButtonSetProperty         PROTO :DWORD, :DWORD, :DWORD                                            ; hSimpleButton, dwProperty, dwPropertyValue
SimpleButtonGetState            PROTO :DWORD
SimpleButtonSetState            PROTO :DWORD, :DWORD


SBRGBCOLOR MACRO red:REQ, green:REQ, blue:REQ
    EXITM < red or green shl 8 or blue shl 16 >
ENDM

;--------------------------------------------------------------------------------------------------------------------------------------
; SimpleButton Structures
;--------------------------------------------------------------------------------------------------------------------------------------
IFNDEF SIMPLEBUTTON_PROPERTIES
SIMPLEBUTTON_PROPERTIES         STRUCT
    dwTextFont                  DD ?
    dwTextColor                 DD ? 
    dwTextColorAlt              DD ? 
    dwTextColorSel              DD ? 
    dwTextColorSelAlt           DD ? 
    dwTextColorDisabled         DD ? 
    dwBackColor                 DD ? 
    dwBackColorAlt              DD ? 
    dwBackColorSel              DD ? 
    dwBackColorSelAlt           DD ? 
    dwBackColorDisabled         DD ? 
    dwBorderColor               DD ? 
    dwBorderColorAlt            DD ? 
    dwBorderColorSel            DD ? 
    dwBorderColorSelAlt         DD ? 
    dwBorderColorDisabled       DD ? 
    dwBorderStyle               DD ? 
SIMPLEBUTTON_PROPERTIES         ENDS
ENDIF

.CONST
;--------------------------------------------------------------------------------------------------------------------------------------
; SimpleButton Constants
;--------------------------------------------------------------------------------------------------------------------------------------

; SimpleButton Messages:
SB_GETPROPERTY                  EQU WM_USER + 1800 ; wParam = dwProperty, lParma = NULL. EAX = dwPropertyValue.
SB_SETPROPERTY                  EQU WM_USER + 1799 ; wParam = dwProperty, lParam = dwPropertyValue.
SB_GETSTATE                     EQU WM_USER + 1798 ; wParam = NULL, lParam = NULL. EAX = dwState.
SB_SETSTATE                     EQU WM_USER + 1797 ; wParam = TRUE/FALSE, lParam = NULL.

; SimpleButton Button Styles:
SBBS_CENTER                     EQU 0h  ; Align text centrally (default).
SBBS_LEFT                       EQU 1h  ; Align text to the left of the button.
SBBS_HAND                       EQU 2h  ; Show a hand instead of an arrow when mouse moves over button.
SBBS_PUSHBUTTON                 EQU 4h  ; Simulate button movement when mouse clicks on button.
SBBS_AUTOSTATE                  EQU 8h  ; Automatically toggle between TRUE/FALSE state when clicked. TRUE = Selected.

; SimpleButton Edge (Border) Styles:
SBES_NONE                       EQU 0   ; No border.
SBES_LEFT                       EQU 1   ; Left border.
SBES_TOP                        EQU 2   ; Top Border.
SBES_BOTTOM                     EQU 4   ; Bottom Border.
SBES_RIGHT                      EQU 8   ; Right Border.
SBES_ALL                        EQU SBES_LEFT + SBES_TOP + SBES_BOTTOM + SBES_RIGHT ; (Default) border around control


;--------------------------------------------------------------------------------------------------------------------------------------
; SimpleButton Properties: Use with SimpleButtonSetProperty / SimpleButtonGetProperty or SB_SETPROPERTY / SB_GETPROPERTY msgs
;--------------------------------------------------------------------------------------------------------------------------------------
@SimpleButtonTextFont           EQU 0       ; hFont. Text font.
@SimpleButtonTextColor          EQU 4       ; Colorref. Text color.
@SimpleButtonTextColorAlt       EQU 8       ; Colorref. Text color when mouse hovers over control.
@SimpleButtonTextColorSel       EQU 12      ; Colorref. Text color when selected state = TRUE.
@SimpleButtonTextColorSelAlt    EQU 16      ; Colorref. Text color when selected state = TRUE and mouse hovers over control.
@SimpleButtonTextColorDisabled  EQU 20      ; Colorref. Text color when control is disabled.
@SimpleButtonBackColor          EQU 24      ; Colorref. Back color.
@SimpleButtonBackColorAlt       EQU 28      ; Colorref. Back color when mouse hovers over control.
@SimpleButtonBackColorSel       EQU 32      ; Colorref. Back color when selected state = TRUE.
@SimpleButtonBackColorSelAlt    EQU 36      ; Colorref. Back color when selected state = TRUE and mouse hovers over control.
@SimpleButtonBackColorDisabled  EQU 40      ; Colorref. Back color when control is disabled.
@SimpleButtonBorderColor        EQU 44      ; Colorref. Border color.
@SimpleButtonBorderColorAlt     EQU 48      ; Colorref. Border color when mouse hovers over control.
@SimpleButtonBorderColorSel     EQU 52      ; Colorref. Border color when selected state = TRUE.
@SimpleButtonBorderColorSelAlt  EQU 56      ; Colorref. Border color when selected state = TRUE and mouse hovers over control.
@SimpleButtonBorderColorDisabled EQU 60     ; Colorref. Border color when control is disabled.
@SimpleButtonBorderStyle        EQU 64      ; Button Border Styles. See SimpleButton Edge (Border) Styles above.



;======================================================================================================================================
; SIMPLEBUTTON API DOCUMENTATION
;======================================================================================================================================


;--------------------------------------------------------------------------------------------------------------------------------------
; SimpleButtonRegister - Registers the SimpleButton control's class
;--------------------------------------------------------------------------------------------------------------------------------------
;
; Parameters:               None
;
; Returns:                  None
;
; Notes:
;
; Use 'SimpleButton_Control', without quotes, as the classname property in RadASM custom class control (UDC) if creating this control
; via dialog resource. 
;
;--------------------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------------------
; SimpleButtonCreate - Creates a SimpleButton control
;--------------------------------------------------------------------------------------------------------------------------------------
;
; Parameters:
; 
;   hWndParent (DWORD)      the parent handle of our main dialog window, with which to create a child control for.
;   xpos (DWORD)            the left position of our control relative to the parent's client space.
;   ypos (DWORD)            the top position of our control relative to the parent's client space.
;   controlwidth (DWORD)    the width of our control.
;   controlheight (DWORD)   the height of our control.
;   dwResourceID (DWORD)    the resource id used by our control.
;   dwStyle (DWORD)         A combination of constants (flags) that define some features of our control. See notes.
;
; Returns:
;
;   EAX contains the handle to the control if successful or NULL otherwise.
;
; Notes:
;
;   The dwStyle parameter can accept windows style flags: WS_CHILD, WS_VISIBLE, and flags defined in SimpleButton Button Styles.
;
;--------------------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------------------
; SimpleButtonGetProperty - Gets a properties value
;--------------------------------------------------------------------------------------------------------------------------------------
;
; Parameters:               
; 
;   hSimpleButton (DWORD)   handle to SimpleButton control created via SimpleButtonCreate, resource dialog or CreateWindowEx
;   dwProperty (DWORD)      constant property value to get, defined in SimpleButton Properties above.
;
; Returns:                  
;
;   EAX contains a DWORD value of the property value retrieved. See SimpleButton Properties above for comments on values returned.
;
; Notes:
;
;   Same as using SB_GETPROPERTY message with SendMessage api call - wParam = dwProperty, lParma = NULL. EAX = dwPropertyValue.
;
;--------------------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------------------
; SimpleButtonSetProperty - Sets a properties value
;--------------------------------------------------------------------------------------------------------------------------------------
;
; Parameters:               
; 
;   hSimpleButton (DWORD)   handle to SimpleButton control created via SimpleButtonCreate, resource dialog or CreateWindowEx.
;   dwProperty (DWORD)      constant property value to set, defined in SimpleButton Properties above.
;   dwPropertyValue (DWORD) value to set the property as. See SimpleButton Properties above for comments on what values are expected.
;
; Returns:                  
;
;   EAX contains a DWORD value of the property value that was set. See SimpleButton Properties above for comments on values returned.
;
; Notes:
;
;   Same as using SB_SETPROPERTY message with SendMessage api call - wParam = dwProperty, lParam = dwPropertyValue.
;
;--------------------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------------------
; SimpleButtonGetState - Get the state of the control
;--------------------------------------------------------------------------------------------------------------------------------------
;
; Parameters:               
; 
;   hSimpleButton (DWORD)   handle to SimpleButton control created via SimpleButtonCreate, resource dialog or CreateWindowEx.
;
; Returns:                  
;
;   EAX returns state value, as TRUE (selected), or FALSE (not selected).
;
; Notes:
;
;   Same as using SB_GETSTATE message with SendMessage api call - wParam = NULL, lParam = NULL. EAX = dwState.
;
;--------------------------------------------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------------------------------------------
; SimpleButtonSetState - Set the state of the control
;--------------------------------------------------------------------------------------------------------------------------------------
;
; Parameters:               
; 
;   hSimpleButton (DWORD)   handle to SimpleButton control created via SimpleButtonCreate, resource dialog or CreateWindowEx.
;   dwState (DWORD)         TRUE to set as selected state, FALSE to set as not selected state.    
;
; Returns:                  
;
;   EAX returns state value that was set, as TRUE (selected), or FALSE (not selected).
;
; Notes:
;
;   Same as using SB_SETSTATE message with SendMessage api call - wParam = TRUE/FALSE, lParam = NULL.
; 
;   Both the function and message will automatically refresh the control when the state changes.
;
;--------------------------------------------------------------------------------------------------------------------------------------
























