include windows.inc
include user32.inc
include kernel32.inc
include gdi32.inc
include shell32.inc
include comctl32.inc
include comdlg32.inc
include masm32.inc

includelib user32.lib
includelib kernel32.lib
includelib gdi32.lib
includelib shell32.lib
includelib comctl32.lib
includelib comdlg32.lib
includelib masm32.lib

include SimpleButton.inc
includelib SimpleButton.lib

;-----------------------------------------------------------------------------------------
; SB2 Prototypes
;-----------------------------------------------------------------------------------------
WinMain					PROTO :DWORD,:DWORD,:DWORD,:DWORD
WndProc					PROTO :DWORD,:DWORD,:DWORD,:DWORD


.CONST
;-----------------------------------------------------------------------------------------
; SB2 Constants
;-----------------------------------------------------------------------------------------
; Main Dialog
IDD_DIALOG				EQU 1000
IDC_SB2                 EQU 1001

; Main Menu 
IDM_MENU				EQU 10000
IDM_FILE_EXIT			EQU 10001
IDM_HELP_ABOUT			EQU 10101



.DATA
;-----------------------------------------------------------------------------------------
; SB2 Initialized Data
;-----------------------------------------------------------------------------------------
ClassName				DB 'DLGCLASS',0
AppName					DB 'SimpleButton #2 Example',0
AboutMsg				DB 'github.com/mrfearless',13,10,'fearless 2017',0
SBText                  DB 'SimpleButton Rules!',0
szMsgText               DB 'SimpleButton was clicked!',0
szMsgTitle              DB 'SimpleButton',0


.DATA?
;-----------------------------------------------------------------------------------------
; SB2 Uninitialized Data
;-----------------------------------------------------------------------------------------
icc 					INITCOMMONCONTROLSEX <>
hInstance				DD ?
CommandLine				DD ?
hWnd					DD ?
hSB2                    DD ?




