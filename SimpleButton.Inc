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
SB_GETPROPERTY                  EQU WM_USER + 1800
SB_SETPROPERTY                  EQU WM_USER + 1799


; SimpleButton Button Styles:
SBBS_CENTER                     EQU 0h  ; Align text centrally
SBBS_LEFT                       EQU 1h  ; Align text to the left of the button
SBBS_HAND                       EQU 2h  ; Show a hand instead of an arrow when mouse moves over button.
SBBS_PUSHBUTTON                 EQU 4h  ; Simulate button movement when mouse clicks on button
SBBS_AUTOSTATE                  EQU 8h  ; Automatically toggle between TRUE/FALSE state when clicked. TRUE = Selected.

; SimpleButton Edge (Border) Styles:
SBES_NONE                       EQU 0
SBES_LEFT                       EQU 1
SBES_TOP                        EQU 2
SBES_BOTTOM                     EQU 4
SBES_RIGHT                      EQU 8
SBES_ALL                        EQU SBES_LEFT + SBES_TOP + SBES_BOTTOM + SBES_RIGHT


;--------------------------------------------------------------------------------------------------------------------------------------
; SimpleButton Properties: Use with SimpleButtonSetProperty / SimpleButtonGetProperty or SB_SETPROPERTY / SB_GETPROPERTY msgs
;--------------------------------------------------------------------------------------------------------------------------------------
@SimpleButtonTextFont           EQU 0       ; hFont
@SimpleButtonTextColor          EQU 4       ; Colorref
@SimpleButtonTextColorAlt       EQU 8       ; Colorref
@SimpleButtonTextColorSel       EQU 12      ; Colorref
@SimpleButtonTextColorSelAlt    EQU 16      ; Colorref
@SimpleButtonTextColorDisabled  EQU 20      ; Colorref
@SimpleButtonBackColor          EQU 24      ; Colorref
@SimpleButtonBackColorAlt       EQU 28      ; Colorref
@SimpleButtonBackColorSel       EQU 32      ; Colorref
@SimpleButtonBackColorSelAlt    EQU 36      ; Colorref
@SimpleButtonBackColorDisabled  EQU 40      ; Colorref
@SimpleButtonBorderColor        EQU 44      ; Colorref
@SimpleButtonBorderColorAlt     EQU 48      ; Colorref
@SimpleButtonBorderColorSel     EQU 52      ; Colorref
@SimpleButtonBorderColorSelAlt  EQU 56      ; Colorref
@SimpleButtonBorderColorDisabled EQU 60     ; Colorref
@SimpleButtonBorderStyle        EQU 64      ; Button Border Styles












