;======================================================================================================================================
;
; SimpleButton Custom Control v1.0.0.0
;
; 2017 by fearless
;
; http://github.com/mrfearless/SimpleButton
;
;======================================================================================================================================
.686
.MMX
.XMM
.model flat,stdcall
option casemap:none
include \masm32\macros\macros.asm

;DEBUG32 EQU 1

IFDEF DEBUG32
    PRESERVEXMMREGS equ 1
    includelib M:\Masm32\lib\Debug32.lib
    DBG32LIB equ 1
    DEBUGEXE textequ <'M:\Masm32\DbgWin.exe'>
    include M:\Masm32\include\debug32.inc
ENDIF

include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib

include SimpleButton.inc




;--------------------------------------------------------------------------------------------------------------------------------------
; Prototypes for internal use
;--------------------------------------------------------------------------------------------------------------------------------------
_SB_WndProc                     PROTO :DWORD, :DWORD, :DWORD, :DWORD
_SB_Init                        PROTO :DWORD
_SB_Cleanup                     PROTO :DWORD
_SB_Paint                       PROTO :DWORD
_SB_PaintBackground             PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_SB_PaintText                   PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD
_SB_PaintBorder                 PROTO :DWORD, :DWORD, :DWORD, :DWORD, :DWORD, :DWORD



; Helper Functions:
__AllocMemProperties            PROTO :DWORD, :DWORD, :DWORD           ; hControl, cbWndExtraOffset, dwSizeToAllocate
__FreeMemProperties             PROTO :DWORD, :DWORD                   ; hControl, cbWndExtraOffset
__GetIntProperty                PROTO :DWORD, :DWORD                   ; hControl, dwProperty
__SetIntProperty                PROTO :DWORD, :DWORD, :DWORD           ; hControl, dwProperty, dwPropertyValue
__GetExtProperty                PROTO :DWORD, :DWORD                   ; hControl, dwProperty
__SetExtProperty                PROTO :DWORD, :DWORD, :DWORD           ; hControl, dwProperty, dwPropertyValue




;--------------------------------------------------------------------------------------------------------------------------------------
; Structures for internal use
;--------------------------------------------------------------------------------------------------------------------------------------
; External public properties
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

; Internal properties
_SIMPLEBUTTON_PROPERTIES        STRUCT
    dwEnabledState              DD ?
    dwMouseOver                 DD ?
    dwSelectedState             DD ?
    dwMouseDown                 DD ?
_SIMPLEBUTTON_PROPERTIES        ENDS


.CONST
INTERNAL_PROPERTIES             EQU 0
EXTERNAL_PROPERTIES             EQU 4


; Internal properties
@SimpleButtonEnabledState       EQU 0
@SimpleButtonMouseOver          EQU 4
@SimpleButtonSelectedState      EQU 8
@SimpleButtonMouseDown          EQU 12

; External public properties
; see SimpleButton.inc for these properties

.DATA
SimpleButtonClass               DB 'SimpleButton_Control',0     ; Class name for creating our SimpleButton control
SimpleButtonFont                DB 'Segoe UI',0                 ; Font used for SimpleButton text
hSimpleButtonFont               DD 0                            ; Handle to SimpleButton font (segoe ui)


.CODE


;-------------------------------------------------------------------------------------
; Set property for SimpleButton control
;-------------------------------------------------------------------------------------
SimpleButtonSetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    Invoke SendMessage, hControl, SB_SETPROPERTY, dwProperty, dwPropertyValue
    ret
SimpleButtonSetProperty ENDP


;-------------------------------------------------------------------------------------
; Get property for SimpleButton control
;-------------------------------------------------------------------------------------
SimpleButtonGetProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD
    Invoke SendMessage, hControl, SB_GETPROPERTY, dwProperty, NULL
    ret
SimpleButtonGetProperty ENDP


;-------------------------------------------------------------------------------------
; SimpleButtonRegister - Registers the SimpleButton control
; can be used at start of program for use with RadASM custom control
; Custom control class must be set as 'SimpleButton_Control'
;-------------------------------------------------------------------------------------
SimpleButtonRegister PROC PUBLIC
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    invoke GetClassInfoEx, hinstance, Addr SimpleButtonClass, Addr wc 
    .IF eax == 0 ; if class not already registered do so
        mov wc.cbSize,sizeof WNDCLASSEX
        lea eax, SimpleButtonClass
        mov wc.lpszClassName, eax
        mov eax, hinstance
        mov wc.hInstance, eax
        mov wc.lpfnWndProc, OFFSET _SB_WndProc
        mov wc.hCursor, NULL
        mov wc.hIcon, 0
        mov wc.hIconSm, 0
        mov wc.lpszMenuName, NULL
        mov wc.hbrBackground, NULL
        mov wc.style, NULL
        mov wc.cbClsExtra, 0
        mov wc.cbWndExtra, 8 ; cbWndExtra +0 = dword ptr to internal properties memory block, cbWndExtra +4 = dword ptr to external properties memory block
        Invoke RegisterClassEx, addr wc
    .ENDIF  
    ret
SimpleButtonRegister ENDP


;-------------------------------------------------------------------------------------
; SimpleButtonCreate - Returns handle in eax of newly created control or NULL otherwise
;-------------------------------------------------------------------------------------
SimpleButtonCreate PROC PRIVATE hWndParent:DWORD, lpszText:DWORD, xpos:DWORD, ypos:DWORD, controlwidth:DWORD, controlheight:DWORD, dwResourceID:DWORD, dwStyle:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL hinstance:DWORD
    LOCAL hControl:DWORD
	LOCAL dwNewStyle:DWORD
	
    Invoke GetModuleHandle, NULL
    mov hinstance, eax

    Invoke SimpleButtonRegister ; register our control if its not already registered.

    mov eax, dwStyle
    mov dwNewStyle, eax
    and eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .IF eax != WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        or dwNewStyle, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .ENDIF
    
    Invoke CreateWindowEx, NULL, Addr SimpleButtonClass, lpszText, dwNewStyle, xpos, ypos, controlwidth, controlheight, hWndParent, dwResourceID, hinstance, NULL
    mov hControl, eax
    .IF eax != NULL
        ; any other code to handle something else here, otherwise we return handle in eax or NULL if failed to create control
    .ENDIF
    mov eax, hControl
    ret
SimpleButtonCreate ENDP


;-------------------------------------------------------------------------------------
; _SB_WndProc - Main processing window for our control
;-------------------------------------------------------------------------------------
_SB_WndProc PROC PRIVATE USES EBX hWin:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL TE:TRACKMOUSEEVENT
    LOCAL hParent:DWORD
    LOCAL rect:RECT    
    
    mov eax,uMsg
    .IF eax == WM_NCCREATE
        mov ebx, lParam
        ; sets text of our control
        Invoke SetWindowText, hWin, (CREATESTRUCT PTR [ebx]).lpszName   
        mov eax, TRUE
        ret

    .ELSEIF eax == WM_CREATE
        ; Allocate memory to store our internal and external properties and call our own init procedure
        Invoke __AllocMemProperties, hWin, INTERNAL_PROPERTIES, SIZEOF _SIMPLEBUTTON_PROPERTIES ; internal properties
        Invoke __AllocMemProperties, hWin, EXTERNAL_PROPERTIES, SIZEOF SIMPLEBUTTON_PROPERTIES ; external properties
        Invoke _SB_Init, hWin
        mov eax, 0
        ret    

    .ELSEIF eax == WM_NCDESTROY
        ; Do any cleanup here and free memory allocated for our internal and external properties
        Invoke _SB_Cleanup, hWin ; cleanup any other stuff as required
        Invoke __FreeMemProperties, hWin, INTERNAL_PROPERTIES
        Invoke __FreeMemProperties, hWin, EXTERNAL_PROPERTIES
        mov eax, 0
        ret     
        
    .ELSEIF eax == WM_ERASEBKGND
        ; handle our own background and painting
        mov eax, 1
        ret

    .ELSEIF eax == WM_PAINT
        ; Do the painting of the SimpleButton control
        Invoke _SB_Paint, hWin
        mov eax, 0
        ret

    .ELSEIF eax== WM_SETCURSOR
        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, SBBS_HAND ; check if the SBBS_HAND style flag was specified
        .IF eax == SBBS_HAND ; if so we change cursor to hand
            invoke LoadCursor, NULL, IDC_HAND
        .ELSE
            invoke LoadCursor, NULL, IDC_ARROW
        .ENDIF
        Invoke SetCursor, eax
        mov eax, 0
        ret  

    .ELSEIF eax == WM_LBUTTONUP
        ; simulates click on our SimpleButton control
        Invoke GetDlgCtrlID, hWin
        mov ebx,eax
        Invoke GetParent, hWin
        Invoke PostMessage, eax, WM_COMMAND, ebx, hWin ; send WM_COMMAND to parent to inform it that SimpleButton was 'clicked'
        
        Invoke __GetIntProperty, hWin, @SimpleButtonMouseDown ; if SBBS_PUSHBUTTON style flag (see WM_LBUTTONDOWN) and mouse button is down
        .IF eax == TRUE ; then move our SimpleButton control back
            invoke GetClientRect, hWin, addr rect
            Invoke GetParent, hWin
            mov hParent, eax            
            invoke MapWindowPoints, hWin, hParent, addr rect, 2   
            sub rect.top, 1
            Invoke SetWindowPos, hWin, NULL, rect.left, rect.top, rect.right, rect.bottom, SWP_NOSIZE + SWP_NOZORDER  + SWP_FRAMECHANGED
            Invoke __SetIntProperty, hWin, @SimpleButtonMouseDown, FALSE
        .ELSE
            Invoke InvalidateRect, hWin, NULL, TRUE
            Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_FRAMECHANGED 
        .ENDIF
        
        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, SBBS_AUTOSTATE ; check if the SBBS_AUTOSTATE style flag was specified
        .IF eax == SBBS_AUTOSTATE ; if so we toggle the selected state of our SimpleButton control
            Invoke __GetIntProperty, hWin, @SimpleButtonSelectedState
            .IF eax == FALSE
                Invoke __SetIntProperty, hWin, @SimpleButtonSelectedState, TRUE
            .ELSE
                Invoke __SetIntProperty, hWin, @SimpleButtonSelectedState, FALSE
            .ENDIF
            Invoke InvalidateRect, hWin, NULL, TRUE
        .ENDIF

    .ELSEIF eax == WM_LBUTTONDOWN
        Invoke GetWindowLong, hWin, GWL_STYLE
        and eax, SBBS_PUSHBUTTON ; check if the SBBS_PUSHBUTTON style flag was specified
        .IF eax == SBBS_PUSHBUTTON ; if so we simulate a button press, move our SimpleButton control slightly
            invoke GetClientRect, hWin, addr rect
            Invoke GetParent, hWin
            mov hParent, eax
            invoke MapWindowPoints, hWin, hParent, addr rect, 2        
            add rect.top, 1
            Invoke SetWindowPos, hWin, NULL, rect.left, rect.top, rect.right, rect.bottom, SWP_NOSIZE + SWP_NOZORDER + SWP_FRAMECHANGED
            Invoke __SetIntProperty, hWin, @SimpleButtonMouseDown, TRUE
        .ELSE
            Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_FRAMECHANGED
        .ENDIF

   .ELSEIF eax == WM_MOUSEMOVE
        Invoke __GetIntProperty, hWin, @SimpleButtonEnabledState
        .IF eax == TRUE   
            Invoke __SetIntProperty, hWin, @SimpleButtonMouseOver, TRUE
            .IF eax != TRUE
                Invoke InvalidateRect, hWin, NULL, TRUE
                mov TE.cbSize, SIZEOF TRACKMOUSEEVENT
                mov TE.dwFlags, TME_LEAVE
                mov eax, hWin
                mov TE.hwndTrack, eax
                mov TE.dwHoverTime, NULL
                Invoke TrackMouseEvent, Addr TE
            .ENDIF
        .ENDIF

    .ELSEIF eax == WM_MOUSELEAVE
        Invoke __SetIntProperty, hWin, @SimpleButtonMouseOver, FALSE
        Invoke __GetIntProperty, hWin, @SimpleButtonMouseDown
        .IF eax == TRUE     
            invoke GetClientRect, hWin, addr rect
            Invoke GetParent, hWin
            mov hParent, eax            
            invoke MapWindowPoints, hWin, hParent, addr rect, 2   
            sub rect.top, 1
            Invoke SetWindowPos, hWin, NULL, rect.left, rect.top, rect.right, rect.bottom, SWP_NOSIZE + SWP_NOZORDER + SWP_FRAMECHANGED
            Invoke __SetIntProperty, hWin, @SimpleButtonMouseDown, FALSE
        .ELSE
            Invoke InvalidateRect, hWin, NULL, FALSE
            ;Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_FRAMECHANGED 
        .ENDIF

    .ELSEIF eax == WM_KILLFOCUS
        Invoke __SetIntProperty, hWin, @SimpleButtonMouseOver, FALSE
        Invoke __GetIntProperty, hWin, @SimpleButtonMouseDown
        .IF eax == TRUE     
            invoke GetClientRect, hWin, addr rect
            Invoke GetParent, hWin
            mov hParent, eax            
            invoke MapWindowPoints, hWin, hParent, addr rect, 2   
            sub rect.top, 1
            Invoke SetWindowPos, hWin, NULL, rect.left, rect.top, rect.right, rect.bottom, SWP_NOSIZE + SWP_NOZORDER + SWP_FRAMECHANGED
            Invoke __SetIntProperty, hWin, @SimpleButtonMouseDown, FALSE
        .ELSE
            Invoke InvalidateRect, hWin, NULL, FALSE
            ;Invoke SetWindowPos, hWin, NULL, 0, 0, 0, 0, SWP_NOMOVE + SWP_NOSIZE + SWP_FRAMECHANGED 
        .ENDIF
        
    .ELSEIF eax == WM_ENABLE
        Invoke __SetIntProperty, hWin, @SimpleButtonEnabledState, wParam
        Invoke InvalidateRect, hWin, NULL, TRUE
        mov eax, 0
        
    .ELSEIF eax == WM_SETTEXT
        Invoke DefWindowProc, hWin, uMsg, wParam, lParam
        Invoke InvalidateRect, hWin, NULL, TRUE
        ret

    .ELSEIF eax == WM_SETFONT
        Invoke __SetExtProperty, hWin, @SimpleButtonTextFont, lParam
        .IF lParam == TRUE
            Invoke InvalidateRect, hWin, NULL, TRUE
        .ENDIF   
    
    ; custom messages start here
    
    .ELSEIF eax == SB_GETPROPERTY
        Invoke __GetExtProperty, hWin, wParam
        ret
        
    .ELSEIF eax == SB_SETPROPERTY   
        Invoke __SetExtProperty, hWin, wParam, lParam
        ret

	.ELSEIF eax == SB_GETSTATE ; wParam = NULL, lParam = NULL. EAX contains state (TRUE/FALSE)
	    Invoke __GetIntProperty, hWin, @SimpleButtonSelectedState
	    ret
	 
	.ELSEIF eax == SB_SETSTATE ; wParam = TRUE/FALSE, lParam = NULL
	    Invoke __SetIntProperty, hWin, @SimpleButtonSelectedState, wParam
	    Invoke InvalidateRect, hWin, NULL, TRUE
	    ret
        
    .ENDIF
    
    Invoke DefWindowProc, hWin, uMsg, wParam, lParam
    ret
_SB_WndProc ENDP


;-------------------------------------------------------------------------------------
; _SB_Init - set initial default values
;-------------------------------------------------------------------------------------
_SB_Init PROC PRIVATE hControl:DWORD
    LOCAL ncm:NONCLIENTMETRICS
    LOCAL lfnt:LOGFONT
    LOCAL hFont:DWORD
    LOCAL hParent:DWORD
    LOCAL dwStyle:DWORD
    
    Invoke GetParent, hControl
    mov hParent, eax
    
    ; get style and check it is our default at least
    Invoke GetWindowLong, hControl, GWL_STYLE
    mov dwStyle, eax
    and eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
    .IF eax != WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        mov eax, dwStyle
        or eax, WS_CHILD or WS_VISIBLE or WS_CLIPCHILDREN
        mov dwStyle, eax
        Invoke SetWindowLong, hControl, GWL_STYLE, dwStyle
    .ENDIF
    
    ; Set default initial external property values
    Invoke __SetIntProperty, hControl, @SimpleButtonEnabledState, TRUE
    Invoke __SetIntProperty, hControl, @SimpleButtonSelectedState, FALSE
    Invoke __SetIntProperty, hControl, @SimpleButtonMouseOver, FALSE
    Invoke __SetIntProperty, hControl, @SimpleButtonMouseDown, FALSE

    Invoke __SetExtProperty, hControl, @SimpleButtonTextColor, SBRGBCOLOR(51,51,51)
    Invoke __SetExtProperty, hControl, @SimpleButtonTextColorAlt, SBRGBCOLOR(51,51,51)
    Invoke __SetExtProperty, hControl, @SimpleButtonTextColorSel, SBRGBCOLOR(51,51,51)
    Invoke __SetExtProperty, hControl, @SimpleButtonTextColorSelAlt, SBRGBCOLOR(51,51,51)
    Invoke __SetExtProperty, hControl, @SimpleButtonTextColorDisabled, SBRGBCOLOR(204,204,204)

    Invoke __SetExtProperty, hControl, @SimpleButtonBackColor, SBRGBCOLOR(255,255,255) ;MUI_RGBCOLOR(21,133,181)
    Invoke __SetExtProperty, hControl, @SimpleButtonBackColorAlt, SBRGBCOLOR(221,221,221)
    Invoke __SetExtProperty, hControl, @SimpleButtonBackColorSel, SBRGBCOLOR(255,255,255)
    Invoke __SetExtProperty, hControl, @SimpleButtonBackColorSelAlt, SBRGBCOLOR(221,221,221)
    Invoke __SetExtProperty, hControl, @SimpleButtonBackColorDisabled, SBRGBCOLOR(192,192,192)
    
    Invoke __SetExtProperty, hControl, @SimpleButtonBorderColor, SBRGBCOLOR(204,204,204)
    Invoke __SetExtProperty, hControl, @SimpleButtonBorderColorAlt, SBRGBCOLOR(204,204,204)
    Invoke __SetExtProperty, hControl, @SimpleButtonBorderColorSel, SBRGBCOLOR(27,161,226)
    Invoke __SetExtProperty, hControl, @SimpleButtonBorderColorSelAlt, SBRGBCOLOR(27,161,226)
    Invoke __SetExtProperty, hControl, @SimpleButtonBorderColorDisabled, SBRGBCOLOR(204,204,204)
    
    Invoke __SetExtProperty, hControl, @SimpleButtonBorderStyle, SBES_ALL    
    
    
    .IF hSimpleButtonFont == 0
        mov ncm.cbSize, SIZEOF NONCLIENTMETRICS
        Invoke SystemParametersInfo, SPI_GETNONCLIENTMETRICS, SIZEOF NONCLIENTMETRICS, Addr ncm, 0
        Invoke CreateFontIndirect, Addr ncm.lfMessageFont
        mov hFont, eax
        Invoke GetObject, hFont, SIZEOF lfnt, Addr lfnt
        mov lfnt.lfHeight, -12d
        mov lfnt.lfWeight, FW_BOLD
        Invoke CreateFontIndirect, Addr lfnt
        mov hSimpleButtonFont, eax
        Invoke DeleteObject, hFont
    .ENDIF
    Invoke __SetExtProperty, hControl, @SimpleButtonTextFont, hSimpleButtonFont
    ret
_SB_Init ENDP


;-------------------------------------------------------------------------------------
; _SB_Cleanup - cleanup a few things before control is destroyed
;-------------------------------------------------------------------------------------
_SB_Cleanup PROC PRIVATE hControl:DWORD

    ret
_SB_Cleanup ENDP


;-------------------------------------------------------------------------------------
; _SB_Paint - Main painting procedure
;-------------------------------------------------------------------------------------
_SB_Paint PROC PRIVATE hControl:DWORD
    LOCAL ps:PAINTSTRUCT 
    LOCAL rect:RECT
    LOCAL hdc:HDC
    LOCAL hdcMem:HDC
    LOCAL hbmMem:DWORD
    LOCAL hBitmap:DWORD
    LOCAL hOldBitmap:DWORD
    LOCAL EnabledState:DWORD
    LOCAL MouseOver:DWORD
    LOCAL SelectedState:DWORD

    Invoke BeginPaint, hControl, Addr ps
    mov hdc, eax
    
    ;----------------------------------------------------------
    ; Setup Double Buffering
    ;----------------------------------------------------------
    Invoke GetClientRect, hControl, Addr rect
    Invoke CreateCompatibleDC, hdc
    mov hdcMem, eax
    Invoke CreateCompatibleBitmap, hdc, rect.right, rect.bottom
    mov hbmMem, eax
    Invoke SelectObject, hdcMem, hbmMem
    mov hOldBitmap, eax
    
    ;----------------------------------------------------------
    ; Get some property values
    ;---------------------------------------------------------- 
    Invoke __GetIntProperty, hControl, @SimpleButtonEnabledState
    mov EnabledState, eax
    Invoke __GetIntProperty, hControl, @SimpleButtonMouseOver
    mov MouseOver, eax
    Invoke __GetIntProperty, hControl, @SimpleButtonSelectedState
    mov SelectedState, eax  
    
    ;----------------------------------------------------------
    ; Background
    ;----------------------------------------------------------
    Invoke _SB_PaintBackground, hControl, hdcMem, Addr rect, EnabledState, MouseOver, SelectedState

    ;----------------------------------------------------------
    ; Text
    ;----------------------------------------------------------
    Invoke _SB_PaintText, hControl, hdcMem, Addr rect, EnabledState, MouseOver, SelectedState

    ;----------------------------------------------------------
    ; Border
    ;----------------------------------------------------------
    Invoke _SB_PaintBorder, hControl, hdcMem, Addr rect, EnabledState, MouseOver, SelectedState

    ;----------------------------------------------------------
    ; BitBlt from hdcMem back to hdc
    ;----------------------------------------------------------
    Invoke BitBlt, hdc, 0, 0, rect.right, rect.bottom, hdcMem, 0, 0, SRCCOPY

    ;----------------------------------------------------------
    ; Cleanup
    ;----------------------------------------------------------
    Invoke SelectObject, hdcMem, hOldBitmap
    Invoke DeleteDC, hdcMem
    Invoke DeleteObject, hbmMem
    .IF hOldBitmap != 0
        Invoke DeleteObject, hOldBitmap
    .ENDIF      
     
    Invoke EndPaint, hControl, Addr ps
    ret
_SB_Paint ENDP


;-------------------------------------------------------------------------------------
; _SB_PaintBackground - Paints the background of the SimpleButton control
;-------------------------------------------------------------------------------------
_SB_PaintBackground PROC PRIVATE hControl:DWORD, hdc:DWORD, lpRect:DWORD, bEnabledState:DWORD, bMouseOver:DWORD, bSelectedState:DWORD
    LOCAL BackColor:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD
    
    .IF bEnabledState == TRUE
        .IF bSelectedState == FALSE
            .IF bMouseOver == FALSE
                Invoke __GetExtProperty, hControl, @SimpleButtonBackColor        ; Normal back color
            .ELSE
                Invoke __GetExtProperty, hControl, @SimpleButtonBackColorAlt     ; Mouse over back color
            .ENDIF
        .ELSE
            .IF bMouseOver == FALSE
                Invoke __GetExtProperty, hControl, @SimpleButtonBackColorSel     ; Selected back color
            .ELSE
                Invoke __GetExtProperty, hControl, @SimpleButtonBackColorSelAlt  ; Selected mouse over color 
            .ENDIF
        .ENDIF
    .ELSE
        Invoke __GetExtProperty, hControl, @SimpleButtonBackColorDisabled        ; Disabled back color
    .ENDIF
    .IF eax == 0 ; try to get default back color if others are set to 0
        Invoke __GetExtProperty, hControl, @SimpleButtonBackColor                ; fallback to default Normal back color
    .ENDIF
    mov BackColor, eax
    
    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdc, eax
    mov hOldBrush, eax
    Invoke SetDCBrushColor, hdc, BackColor
    Invoke FillRect, hdc, lpRect, hBrush
    
    .IF hOldBrush != 0
        Invoke SelectObject, hdc, hOldBrush
        Invoke DeleteObject, hOldBrush
    .ENDIF     
    .IF hBrush != 0
        Invoke DeleteObject, hBrush
    .ENDIF    
    ret
_SB_PaintBackground ENDP


;-------------------------------------------------------------------------------------
; _SB_PaintText - Paints (draws) the text used in the SimpleButton control
;-------------------------------------------------------------------------------------
_SB_PaintText PROC PRIVATE USES EBX hControl:DWORD, hdc:DWORD, lpRect:DWORD, bEnabledState:DWORD, bMouseOver:DWORD, bSelectedState:DWORD
    LOCAL TextColor:DWORD
    LOCAL BackColor:DWORD
    LOCAL dwStyle:DWORD
    LOCAL dwTextStyle:DWORD
    LOCAL hFont:DWORD
    LOCAL hOldFont:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD
    LOCAL rect:RECT
    LOCAL pt:POINT
    LOCAL sz:_SIZE
    LOCAL szText[256]:BYTE
    LOCAL LenText:DWORD

    Invoke GetWindowText, hControl, Addr szText, sizeof szText
    Invoke lstrlen, Addr szText
    .IF eax == 0
        ret
    .ENDIF
    mov LenText, eax

    Invoke CopyRect, Addr rect, lpRect
    
    .IF bEnabledState == TRUE
        .IF bSelectedState == FALSE
            .IF bMouseOver == FALSE
                Invoke __GetExtProperty, hControl, @SimpleButtonBackColor        ; Normal back color
            .ELSE
                Invoke __GetExtProperty, hControl, @SimpleButtonBackColorAlt     ; Mouse over back color
            .ENDIF
        .ELSE
            .IF bMouseOver == FALSE
                Invoke __GetExtProperty, hControl, @SimpleButtonBackColorSel     ; Selected back color
            .ELSE
                Invoke __GetExtProperty, hControl, @SimpleButtonBackColorSelAlt  ; Selected mouse over color 
            .ENDIF
        .ENDIF
    .ELSE
        Invoke __GetExtProperty, hControl, @SimpleButtonBackColorDisabled        ; Disabled back color
    .ENDIF
    .IF eax == 0 ; try to get default back color if others are set to 0
        Invoke __GetExtProperty, hControl, @SimpleButtonBackColor                ; fallback to default Normal back color
    .ENDIF    
    mov BackColor, eax    
    
    Invoke GetWindowLong, hControl, GWL_STYLE
    mov dwStyle, eax
    
    Invoke __GetExtProperty, hControl, @SimpleButtonTextFont        
    mov hFont, eax

    .IF bEnabledState == TRUE
        .IF bSelectedState == FALSE
            .IF bMouseOver == FALSE
                Invoke __GetExtProperty, hControl, @SimpleButtonTextColor        ; Normal text color
            .ELSE
                Invoke __GetExtProperty, hControl, @SimpleButtonTextColorAlt     ; Mouse over text color
            .ENDIF
        .ELSE
            .IF bMouseOver == FALSE
                Invoke __GetExtProperty, hControl, @SimpleButtonTextColorSel     ; Selected text color
            .ELSE
                Invoke __GetExtProperty, hControl, @SimpleButtonTextColorSelAlt  ; Selected mouse over color 
            .ENDIF
        .ENDIF
    .ELSE
        Invoke __GetExtProperty, hControl, @SimpleButtonTextColorDisabled        ; Disabled text color
    .ENDIF
    .IF eax == 0 ; try to get default text color if others are set to 0
        Invoke __GetExtProperty, hControl, @SimpleButtonTextColor                ; fallback to default Normal text color
    .ENDIF  
    mov TextColor, eax

    mov rect.left, 4
    sub rect.right, 4
    
    Invoke SelectObject, hdc, hFont
    mov hOldFont, eax

    Invoke GetStockObject, DC_BRUSH
    mov hBrush, eax
    Invoke SelectObject, hdc, eax
    mov hOldBrush, eax
    Invoke SetDCBrushColor, hdc, BackColor
    
    Invoke SetBkMode, hdc, OPAQUE
    Invoke SetBkColor, hdc, BackColor    
    Invoke SetTextColor, hdc, TextColor
    
    mov dwTextStyle, DT_SINGLELINE
    mov eax, dwStyle
    and eax, SBBS_LEFT
    .IF eax == SBBS_LEFT
        or dwTextStyle, DT_LEFT
    .ELSE
        or dwTextStyle, DT_CENTER
    .ENDIF
    or dwTextStyle, DT_VCENTER

    Invoke DrawText, hdc, Addr szText, LenText, Addr rect, dwTextStyle
    
    .IF hOldFont != 0
        Invoke SelectObject, hdc, hOldFont
        Invoke DeleteObject, hOldFont
    .ENDIF
    .IF hOldBrush != 0
        Invoke SelectObject, hdc, hOldBrush
        Invoke DeleteObject, hOldBrush
    .ENDIF     
    .IF hBrush != 0
        Invoke DeleteObject, hBrush
    .ENDIF
    ret
_SB_PaintText ENDP


;-------------------------------------------------------------------------------------
; _SB_PaintBorder - Paints the border surrounding the SimpleButton control
;-------------------------------------------------------------------------------------
_SB_PaintBorder PROC PRIVATE hControl:DWORD, hdc:DWORD, lpRect:DWORD, bEnabledState:DWORD, bMouseOver:DWORD, bSelectedState:DWORD
    LOCAL BorderColor:DWORD
    LOCAL BorderStyle:DWORD
    LOCAL hBrush:DWORD
    LOCAL hOldBrush:DWORD
    LOCAL hPen:DWORD
    LOCAL hOldPen:DWORD
    LOCAL rect:RECT
    LOCAL pt:POINT

    .IF bEnabledState == TRUE
        .IF bSelectedState == FALSE
            .IF bMouseOver == FALSE
                Invoke __GetExtProperty, hControl, @SimpleButtonBorderColor        ; Normal border color
            .ELSE
                Invoke __GetExtProperty, hControl, @SimpleButtonBorderColorAlt     ; Mouse over border color
            .ENDIF
        .ELSE
            .IF bMouseOver == FALSE
                Invoke __GetExtProperty, hControl, @SimpleButtonBorderColorSel     ; Selected border color
            .ELSE
                Invoke __GetExtProperty, hControl, @SimpleButtonBorderColorSelAlt  ; Selected mouse over border color 
            .ENDIF
        .ENDIF
    .ELSE
        Invoke __GetExtProperty, hControl, @SimpleButtonBorderColorDisabled        ; Disabled border color
    .ENDIF
    mov BorderColor, eax

    .IF BorderColor != 0
        Invoke __GetExtProperty, hControl, @SimpleButtonBorderStyle
        mov BorderStyle, eax

        .IF BorderStyle != SBES_NONE
            mov eax, BorderStyle
            and eax, SBES_ALL
            .IF eax == SBES_ALL
                Invoke GetStockObject, DC_BRUSH
                mov hBrush, eax
                Invoke SelectObject, hdc, eax
                mov hOldBrush, eax
                Invoke SetDCBrushColor, hdc, BorderColor
                Invoke FrameRect, hdc, lpRect, hBrush
            .ELSE
                Invoke CreatePen, PS_SOLID, 1, BorderColor
                mov hPen, eax
                Invoke SelectObject, hdc, hPen
                mov hOldPen, eax 
               
                Invoke CopyRect, Addr rect, lpRect
                
                mov eax, BorderStyle
                and eax, SBES_TOP
                .IF eax == SBES_TOP
                    Invoke MoveToEx, hdc, rect.left, rect.top, Addr pt
                    Invoke LineTo, hdc, rect.right, rect.top
                .ENDIF
                mov eax, BorderStyle
                and eax, SBES_RIGHT
                .IF eax == SBES_RIGHT
                    dec rect.right                
                    Invoke MoveToEx, hdc, rect.right, rect.top, Addr pt
                    Invoke LineTo, hdc, rect.right, rect.bottom
                    inc rect.right
                .ENDIF
                mov eax, BorderStyle
                and eax, SBES_BOTTOM
                .IF eax == SBES_BOTTOM
                    dec rect.bottom
                    Invoke MoveToEx, hdc, rect.left, rect.bottom, Addr pt
                    Invoke LineTo, hdc, rect.right, rect.bottom
                    inc rect.bottom
                .ENDIF
                mov eax, BorderStyle
                and eax, SBES_LEFT
                .IF eax == SBES_LEFT
                    Invoke MoveToEx, hdc, rect.left, rect.top, Addr pt
                    Invoke LineTo, hdc, rect.left, rect.bottom
                .ENDIF
                .IF hOldPen != 0
                    Invoke SelectObject, hdc, hOldPen
                    Invoke DeleteObject, hOldPen
                .ENDIF
                .IF hPen != 0
                    Invoke DeleteObject, hPen
                .ENDIF

            .ENDIF
        .ENDIF
    .ENDIF

    .IF hOldBrush != 0
        Invoke SelectObject, hdc, hOldBrush
        Invoke DeleteObject, hOldBrush
    .ENDIF     
    .IF hBrush != 0
        Invoke DeleteObject, hBrush
    .ENDIF     
    ret
_SB_PaintBorder ENDP


;-------------------------------------------------------------------------------------
; SimpleButtonGetState - Returns in eax TRUE of FALSE if control is selected or not
;-------------------------------------------------------------------------------------
SimpleButtonGetState PROC PUBLIC hControl:DWORD
    Invoke SendMessage, hControl, SB_GETSTATE, 0, 0
    ret
SimpleButtonGetState ENDP


;-------------------------------------------------------------------------------------
; SimpleButtonSetState - Set control to selected state (TRUE) or not (FALSE)
;-------------------------------------------------------------------------------------
SimpleButtonSetState PROC PUBLIC hControl:DWORD, bState:DWORD
    Invoke SendMessage, hControl, SB_SETSTATE, bState, 0
    ret
SimpleButtonSetState ENDP




;======================================================================================================================================
; Helper Functions:
;
; - Allocating or freeing memory for memory blocks used for variables 
; - Setting and getting internal or external variables in the memory blocks pointed to and stored in cbWndExtra +0 and cbWndExtra +4 
;======================================================================================================================================


;*************************************************************************************
; __AllocMemProperties - Allocate memory block for variables and store pointer in
; cbWndExtra +0 for internal properties and cbWndExtra +4 for external properties
;*************************************************************************************
__AllocMemProperties PROC PUBLIC hControl:DWORD, cbWndExtraOffset:DWORD, dwSize:DWORD
    LOCAL pMem:DWORD
    Invoke GlobalAlloc, GMEM_FIXED or GMEM_ZEROINIT, dwSize
    .IF eax == NULL
        mov eax, FALSE
        ret
    .ENDIF
    mov pMem, eax
    
    Invoke SetWindowLong, hControl, cbWndExtraOffset, pMem
    
    mov eax, TRUE
    ret
__AllocMemProperties ENDP


;*************************************************************************************
; __FreeMemProperties - Free memory block pointed to by cbWndExtra +0 or cbWndExtra +4
;*************************************************************************************
__FreeMemProperties PROC PUBLIC hControl:DWORD, cbWndExtraOffset:DWORD
    Invoke GetWindowLong, hControl, cbWndExtraOffset
    .IF eax != NULL
        invoke GlobalFree, eax
        Invoke SetWindowLong, hControl, cbWndExtraOffset, 0
        mov eax, TRUE
    .ELSE
        mov eax, FALSE
    .ENDIF
    ret
__FreeMemProperties ENDP


;*************************************************************************************
; __GetIntProperty - Get internal property in memory block pointed to by cbWndExtra +0
;*************************************************************************************
__GetIntProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD
    Invoke GetWindowLong, hControl, INTERNAL_PROPERTIES ; 0
    .IF eax == 0
        ret
    .ENDIF
    mov ebx, eax
    add ebx, dwProperty
    mov eax, [ebx]
    ret
    ret
__GetIntProperty ENDP


;*************************************************************************************
; __SetIntProperty - Set internal property in memory block pointed to by cbWndExtra +0
;*************************************************************************************
__SetIntProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    LOCAL dwPrevValue:DWORD
    Invoke GetWindowLong, hControl, INTERNAL_PROPERTIES ; 0
    .IF eax == 0
        ret
    .ENDIF    
    mov ebx, eax
    add ebx, dwProperty
    mov eax, [ebx]
    mov dwPrevValue, eax    
    mov eax, dwPropertyValue
    mov [ebx], eax
    mov eax, dwPrevValue
    ret
    ret
__SetIntProperty ENDP


;*************************************************************************************
; __GetExtProperty - Set external property in memory block pointed to by cbWndExtra +4
;*************************************************************************************
__GetExtProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD
    Invoke GetWindowLong, hControl, EXTERNAL_PROPERTIES ; 4
    .IF eax == 0
        ret
    .ENDIF
    mov ebx, eax
    add ebx, dwProperty
    mov eax, [ebx]
    ret
__GetExtProperty ENDP


;*************************************************************************************
; __SetExtProperty - Set external property in memory block pointed to by cbWndExtra +4
;*************************************************************************************
__SetExtProperty PROC PUBLIC hControl:DWORD, dwProperty:DWORD, dwPropertyValue:DWORD
    LOCAL dwPrevValue:DWORD
    Invoke GetWindowLong, hControl, EXTERNAL_PROPERTIES ; 4
    .IF eax == 0
        ret
    .ENDIF    
    mov ebx, eax
    add ebx, dwProperty
    mov eax, [ebx]
    mov dwPrevValue, eax    
    mov eax, dwPropertyValue
    mov [ebx], eax
    mov eax, dwPrevValue
    ret
__SetExtProperty ENDP


;======================================================================================================================================










































END







;    Invoke SimpleButtonGetProperty, hControl, @SimpleButtonBackColor






































