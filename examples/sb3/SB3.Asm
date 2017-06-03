.686
.MMX
.XMM
.model flat,stdcall
option casemap:none

include SB3.inc

.code

start:

	Invoke GetModuleHandle,NULL
	mov hInstance, eax
	Invoke GetCommandLine
	mov CommandLine, eax
	Invoke InitCommonControls
	mov icc.dwSize, sizeof INITCOMMONCONTROLSEX
    mov icc.dwICC, ICC_COOL_CLASSES or ICC_STANDARD_CLASSES or ICC_WIN95_CLASSES
    Invoke InitCommonControlsEx, offset icc

	; Register our SimpleButton control class here
	Invoke SimpleButtonRegister
	
	Invoke WinMain, hInstance, NULL, CommandLine, SW_SHOWDEFAULT
	Invoke ExitProcess, eax

;-------------------------------------------------------------------------------------
; WinMain
;-------------------------------------------------------------------------------------
WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
	LOCAL	wc:WNDCLASSEX
	LOCAL	msg:MSG

	mov		wc.cbSize, sizeof WNDCLASSEX
	mov		wc.style, CS_HREDRAW or CS_VREDRAW
	mov		wc.lpfnWndProc, offset WndProc
	mov		wc.cbClsExtra, NULL
	mov		wc.cbWndExtra, DLGWINDOWEXTRA
	push	hInst
	pop		wc.hInstance
	mov		wc.hbrBackground, COLOR_BTNFACE+1 ; COLOR_WINDOW+1
	mov		wc.lpszMenuName, IDM_MENU
	mov		wc.lpszClassName, offset ClassName
	Invoke LoadIcon, NULL, IDI_APPLICATION
	mov		wc.hIcon, eax
	mov		wc.hIconSm, eax
	Invoke LoadCursor, NULL, IDC_ARROW
	mov		wc.hCursor,eax
	Invoke RegisterClassEx, addr wc
	Invoke CreateDialogParam, hInstance, IDD_DIALOG, NULL, addr WndProc, NULL
	mov hWnd, eax
	Invoke ShowWindow, hWnd, SW_SHOWNORMAL
	Invoke UpdateWindow, hWnd
	.WHILE TRUE
		invoke GetMessage, addr msg, NULL, 0, 0
	  .BREAK .if !eax
		Invoke TranslateMessage, addr msg
		Invoke DispatchMessage, addr msg
	.ENDW
	mov eax, msg.wParam
	ret
WinMain endp


;-------------------------------------------------------------------------------------
; WndProc - Main Window Message Loop
;-------------------------------------------------------------------------------------
WndProc proc hWin:HWND,uMsg:UINT,wParam:WPARAM,lParam:LPARAM
	
	mov eax, uMsg
	.IF eax == WM_INITDIALOG
		push hWin
		pop hWnd
		
		; SimpleButton is registered using call to SimpleButtonRegister at start of our program.
		; We allow the controls to be created via a dialog resource. The dialog box handles creating our control.
		; We fetch the handle for various control resources and store them for use with other functions.		
		
		Invoke GetDlgItem, hWin, IDC_BtnOK
		mov hBtnOk, eax
		Invoke GetDlgItem, hWin, IDC_Tab1
		mov hTab1, eax
		Invoke GetDlgItem, hWin, IDC_Tab2
		mov hTab2, eax
		Invoke GetDlgItem, hWin, IDC_Tab3
		mov hTab3, eax
		Invoke GetDlgItem, hWin, IDC_LblCurrentTab
        mov hLblCurrentTab, eax
		
		; Set properties for our SimpleButtons that will be like tab controls:
		
		; Tab1
		Invoke SimpleButtonSetProperty, hTab1, @SimpleButtonTextColor, SBRGBCOLOR(48,48,48)
		Invoke SimpleButtonSetProperty, hTab1, @SimpleButtonTextColorAlt, SBRGBCOLOR(48,48,48)
		Invoke SimpleButtonSetProperty, hTab1, @SimpleButtonTextColorSel, SBRGBCOLOR(24,175,56)
		Invoke SimpleButtonSetProperty, hTab1, @SimpleButtonTextColorSelAlt, SBRGBCOLOR(24,175,56)
		Invoke SimpleButtonSetProperty, hTab1, @SimpleButtonBackColor, SBRGBCOLOR(240,240,240)
		Invoke SimpleButtonSetProperty, hTab1, @SimpleButtonBackColorAlt, SBRGBCOLOR(240,240,240)
		Invoke SimpleButtonSetProperty, hTab1, @SimpleButtonBackColorSel, SBRGBCOLOR(240,240,240)
		Invoke SimpleButtonSetProperty, hTab1, @SimpleButtonBackColorSelAlt, SBRGBCOLOR(240,240,240)
		Invoke SimpleButtonSetProperty, hTab1, @SimpleButtonBorderColorSel, SBRGBCOLOR(24,175,56)
		Invoke SimpleButtonSetProperty, hTab1, @SimpleButtonBorderColorSelAlt, SBRGBCOLOR(24,175,56)
		Invoke SimpleButtonSetProperty, hTab1, @SimpleButtonBorderStyle, SBES_BOTTOM
		
		; Tab 2
		Invoke SimpleButtonSetProperty, hTab2, @SimpleButtonTextColor, SBRGBCOLOR(48,48,48)
		Invoke SimpleButtonSetProperty, hTab2, @SimpleButtonTextColorAlt, SBRGBCOLOR(48,48,48)
		Invoke SimpleButtonSetProperty, hTab2, @SimpleButtonTextColorSel, SBRGBCOLOR(24,175,56)
		Invoke SimpleButtonSetProperty, hTab2, @SimpleButtonTextColorSelAlt, SBRGBCOLOR(24,175,56)
		Invoke SimpleButtonSetProperty, hTab2, @SimpleButtonBackColor, SBRGBCOLOR(240,240,240)
		Invoke SimpleButtonSetProperty, hTab2, @SimpleButtonBackColorAlt, SBRGBCOLOR(240,240,240)
		Invoke SimpleButtonSetProperty, hTab2, @SimpleButtonBackColorSel, SBRGBCOLOR(240,240,240)
		Invoke SimpleButtonSetProperty, hTab2, @SimpleButtonBackColorSelAlt, SBRGBCOLOR(240,240,240)
		Invoke SimpleButtonSetProperty, hTab2, @SimpleButtonBorderColorSel, SBRGBCOLOR(24,175,56)
		Invoke SimpleButtonSetProperty, hTab2, @SimpleButtonBorderColorSelAlt, SBRGBCOLOR(24,175,56)		
		Invoke SimpleButtonSetProperty, hTab2, @SimpleButtonBorderStyle, SBES_BOTTOM
		
		; Tab 3
		Invoke SimpleButtonSetProperty, hTab3, @SimpleButtonTextColor, SBRGBCOLOR(48,48,48)
		Invoke SimpleButtonSetProperty, hTab3, @SimpleButtonTextColorAlt, SBRGBCOLOR(48,48,48)
		Invoke SimpleButtonSetProperty, hTab3, @SimpleButtonTextColorSel, SBRGBCOLOR(24,175,56)
		Invoke SimpleButtonSetProperty, hTab3, @SimpleButtonTextColorSelAlt, SBRGBCOLOR(24,175,56)
		Invoke SimpleButtonSetProperty, hTab3, @SimpleButtonBackColor, SBRGBCOLOR(240,240,240)
		Invoke SimpleButtonSetProperty, hTab3, @SimpleButtonBackColorAlt, SBRGBCOLOR(240,240,240)
		Invoke SimpleButtonSetProperty, hTab3, @SimpleButtonBackColorSel, SBRGBCOLOR(240,240,240)
		Invoke SimpleButtonSetProperty, hTab3, @SimpleButtonBackColorSelAlt, SBRGBCOLOR(240,240,240)
		Invoke SimpleButtonSetProperty, hTab3, @SimpleButtonBorderColorSel, SBRGBCOLOR(24,175,56)
		Invoke SimpleButtonSetProperty, hTab3, @SimpleButtonBorderColorSelAlt, SBRGBCOLOR(24,175,56)		
		Invoke SimpleButtonSetProperty, hTab3, @SimpleButtonBorderStyle, SBES_BOTTOM
		
		; Set the first 'tab' to selected state and update label to reflect current selected tab
		Invoke SimpleButtonSetState, hTab1, TRUE
		Invoke SetWindowText, hLblCurrentTab, Addr szTab1Selected
		
		; Set some border colors for our SimpleButton ok button
		Invoke SimpleButtonSetProperty, hBtnOk, @SimpleButtonBorderColor, SBRGBCOLOR(27,161,226)
        Invoke SimpleButtonSetProperty, hBtnOk, @SimpleButtonBorderColorAlt, SBRGBCOLOR(27,161,226)	
		
	.ELSEIF eax == WM_COMMAND
		mov eax, wParam
		and eax, 0FFFFh
		.IF eax == IDM_FILE_EXIT
			Invoke SendMessage,hWin,WM_CLOSE,0,0
			
		.ELSEIF eax == IDM_HELP_ABOUT
			Invoke ShellAbout,hWin,addr AppName,addr AboutMsg,NULL
		
		.ELSEIF eax == IDC_BtnOK ; our ok SimpleButton was clicked so close program
		    Invoke SendMessage,hWin,WM_CLOSE,0,0
		
		.ELSEIF eax == IDC_Tab1 ; 'tab 1' was clicked so set other 'tabs' to not selected and set this one to selected
		    Invoke SimpleButtonSetState, hTab1, TRUE
		    Invoke SimpleButtonSetState, hTab2, FALSE
		    Invoke SimpleButtonSetState, hTab3, FALSE
		    Invoke SetWindowText, hLblCurrentTab, Addr szTab1Selected
		
		.ELSEIF eax == IDC_Tab2 ; 'tab 2' was clicked so set other 'tabs' to not selected and set this one to selected
		    Invoke SimpleButtonSetState, hTab1, FALSE
		    Invoke SimpleButtonSetState, hTab2, TRUE
		    Invoke SimpleButtonSetState, hTab3, FALSE
		    Invoke SetWindowText, hLblCurrentTab, Addr szTab2Selected
		    
		.ELSEIF eax == IDC_Tab3 ; 'tab 3' was clicked so set other 'tabs' to not selected and set this one to selected
		    Invoke SimpleButtonSetState, hTab1, FALSE
		    Invoke SimpleButtonSetState, hTab2, FALSE
		    Invoke SimpleButtonSetState, hTab3, TRUE
		    Invoke SetWindowText, hLblCurrentTab, Addr szTab3Selected
		    
		.ENDIF

	.ELSEIF eax == WM_CLOSE
		Invoke DestroyWindow,hWin
		
	.ELSEIF eax == WM_DESTROY
		Invoke PostQuitMessage,NULL
		
	.ELSE
		Invoke DefWindowProc,hWin,uMsg,wParam,lParam
		ret
	.ENDIF
	xor    eax,eax
	ret
WndProc endp

end start
