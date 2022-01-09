.NOLIST
; Include file for Calling Windows API Functions      (SmallWin.inc)
; Last update: 12/4/01

.386
.MODEL flat, stdcall
.STACK 4096

;--------- my own constants --------------
DO_NOT_SHARE = 0
NULL = 0
TRUE = 1
FALSE = 0
;-----------------------------------------

; Win32 Console handles
STD_INPUT_HANDLE EQU -10
STD_OUTPUT_HANDLE EQU -11		; predefined Win API constant

;  Input Mode flags (used by GetConsoleMode & SetConsoleMode):
ENABLE_PROCESSED_INPUT = 1
ENABLE_LINE_INPUT      = 2
ENABLE_ECHO_INPUT      = 4
ENABLE_WINDOW_INPUT    = 8
ENABLE_MOUSE_INPUT     = 16

; Event constants
KEY_EVENT       =  1
MOUSE_EVENT     =  2
WINDOW_BUFFER_SIZE_EVENT = 4          ; window change event record
MENU_EVENT      = 8                   ; menu event record
FOCUS_EVENT     = 16                  ; focus change

;  Output mode flags  (used by GetConsoleMode & SetConsoleMode):
ENABLE_PROCESSED_OUTPUT    = 1
ENABLE_WRAP_AT_EOL_OUTPUT  = 2

; Constants found in WINNT.H
FILE_SHARE_READ                 = 1
FILE_SHARE_WRITE                = 2
FILE_SHARE_DELETE               = 4

FILE_ATTRIBUTE_READONLY         = 1
FILE_ATTRIBUTE_HIDDEN           = 2
FILE_ATTRIBUTE_SYSTEM           = 4
FILE_ATTRIBUTE_DIRECTORY        = 10h
FILE_ATTRIBUTE_ARCHIVE          = 20h
FILE_ATTRIBUTE_DEVICE           = 40h
FILE_ATTRIBUTE_NORMAL           = 80h
FILE_ATTRIBUTE_TEMPORARY        = 100h
FILE_ATTRIBUTE_SPARSE_FILE      = 200h
FILE_ATTRIBUTE_REPARSE_POINT    = 400h
FILE_ATTRIBUTE_COMPRESSED       = 800h
FILE_ATTRIBUTE_OFFLINE          =    1000h
FILE_ATTRIBUTE_NOT_CONTENT_INDEXED = 2000h
FILE_ATTRIBUTE_ENCRYPTED           = 4000h

FILE_READ_DATA = 1
FILE_WRITE_DATA = 2
FILE_APPEND_DATA = 4
FILE_DELETE_CHILD = 40h

; From Winnt.h
GENERIC_READ     = 80000000h
GENERIC_WRITE    = 40000000h
GENERIC_EXECUTE  = 20000000h
GENERIC_ALL      = 10000000h

; From winbase.h
CREATE_NEW         = 1
CREATE_ALWAYS      = 2
OPEN_EXISTING      = 3
OPEN_ALWAYS        = 4
TRUNCATE_EXISTING  = 5

FILE_BEGIN         =  0
FILE_CURRENT       =  1
FILE_END           =  2

INVALID_HANDLE_VALUE = -1

exit EQU <INVOKE ExitProcess,0>		; exit program

;======================================================
;                     ALIASES
;======================================================
; The following Win32 API functions have an
; extra "A" at the end of their name, so they are
; redefined here with text macros:
CreateFile EQU <CreateFileA>
PeekConsoleInput EQU <PeekConsoleInputA>
ReadConsole EQU <ReadConsoleA>
ReadConsoleInput EQU <ReadConsoleInputA>
SetConsoleTitle EQU <SetConsoleTitleA>
WriteConsole EQU <WriteConsoleA>
WriteConsoleOutputCharacter EQU <WriteConsoleOutputCharacterA>

;=======================================================
; Standard Windows Structure defintions:
;=======================================================

COORD STRUCT
	X WORD ?
	Y WORD ?
COORD ENDS

SYSTEMTIME STRUCT
	wYear WORD ?
	wMonth WORD ?
	wDayOfWeek WORD ?
	wDay WORD ?
	wHour WORD ?
	wMinute WORD ?
	wSecond WORD ?
	wMilliseconds WORD ?
SYSTEMTIME ENDS

; Date and time, measured in 100ns intervals
; since January 1, 1601.
FILETIME STRUCT
    loDateTime DWORD ?
    hiDateTime DWORD ?
FILETIME ENDS

SMALL_RECT STRUCT
  Left     WORD ?
  Top      WORD ?
  Right    WORD ?
  Bottom   WORD ?
SMALL_RECT ENDS

CONSOLE_CURSOR_INFO STRUCT
  dwSize   DWORD ?
  bVisible BYTE ?
CONSOLE_CURSOR_INFO ENDS

CONSOLE_SCREEN_BUFFER_INFO STRUCT
  dwSize           COORD <>
  dwCursorPos      COORD <>
  wAttributes      WORD ?
  srWindow         SMALL_RECT <>
  maxWinSize       COORD <>
CONSOLE_SCREEN_BUFFER_INFO ENDS

;==========================================================
;                   FUNCTION PROTOTYPES
;==========================================================

CloseHandle PROTO,		; close file handle
	handle:DWORD

CreateFile PROTO,		; create new file
	pFilename:PTR BYTE,		; ptr to filename
	accessMode:DWORD,		; access mode
	shareMode:DWORD,		; share mode
	lpSecurity:DWORD,  		; can be NULL
	howToCreate:DWORD,		; how to create the file
	attributes:DWORD,		; file attributes
	htemplate:DWORD		; handle to template file

ExitProcess PROTO,                  	; exit program
	dwExitCode:DWORD		; return code

FlushConsoleInputBuffer PROTO,		; flush the input buffer
	nConsoleHandle:DWORD		; standard input handle

GetConsoleCP PROTO		; returns code page ID in eax

GetConsoleCursorInfo PROTO,
	outHandle:DWORD,		; console output handle
	pCursorInfo:PTR CONSOLE_CURSOR_INFO	; cursor information

GetConsoleMode PROTO,
	nConsoleHandle:DWORD,		; input or output handle
	lpMode:PTR DWORD		; pointer to dword containing flags

GetConsoleScreenBufferInfo PROTO,
	outHandle:DWORD,		; handle to screen buffer
	pBufferInfo:PTR CONSOLE_SCREEN_BUFFER_INFO

GetLocalTime PROTO,		; system time, adjusted for local time zone
	lpSystemTime:PTR SYSTEMTIME		; ptr to SYSTEMTIME object

GetNumberOfConsoleInputEvents PROTO,	; get number of unread records
	handle:DWORD,		; input handle
	lpCount:PTR DWORD		; pointer to counter

GetStdHandle PROTO,                 	; get standard handle
	nStdHandle:DWORD  		; type of console handle

GetSystemTime PROTO,		; returns the system time
	lpSystemTime:PTR SYSTEMTIME		; ptr to SYSTEMTIME object

GetTickCount PROTO		; get elapsed milliseconds
			; since computer turned on

PeekConsoleInput PROTO,
	handle:DWORD,		; input handle
	lpBuffer:PTR BYTE,		; pointer to buffer
	nNumberOfBytesToRead:DWORD,    	; number of chars to read
	lpNumberOfBytesWritten:PTR DWORD  	; num bytes read

ReadConsole PROTO,
	handle:DWORD,                    	; input handle
	lpBuffer:PTR BYTE,                	; pointer to buffer
	nNumberOfBytesToRead:DWORD,    	; number of chars to read
	lpNumberOfBytesWritten:PTR DWORD,  	; num bytes read
	lpReserved:DWORD               	; (not used)

ReadConsoleInput PROTO,
	inHandle:DWORD,		; input handle
	pInputRec:PTR INPUT_RECORD,		; ptr to input record
	numRecs:DWORD,		; request number of recs
	pNumRead:PTR DWORD		; ptr to number read

ReadFile PROTO,		; read buffer from input file
	fileHandle:DWORD,		; handle to file
	pBuffer:PTR BYTE,		; ptr to buffer
	nBufsize:DWORD,		; num bytes to read
	pBytesRead:PTR DWORD,		; bytes actually read
	pOverlapped:PTR DWORD		; ptr to asynchronous info

SetConsoleCursorInfo PROTO,
	outHandle:DWORD,		; console output handle
	pCursorInfo:PTR CONSOLE_CURSOR_INFO	; cursor information

SetConsoleCursorPosition PROTO,
	nStdHandle:DWORD,		; input mode handle
	coords:COORD		; screen X,Y coordinates

SetConsoleMode PROTO,
	hConsoleHandle:DWORD,		; console handle
	dwMode:DWORD		; console mode flags

SetConsoleScreenBufferSize PROTO,
	outHandle:DWORD,		; handle to screen buffer
	dwSize:COORD		; new screen buffer size

SetConsoleTextAttribute PROTO,
	nStdHandle:DWORD,		; console output handle
	nColor:DWORD		; color attribute

SetConsoleTitle PROTO,		; set console window title
	pString:PTR BYTE		; points to string

SetConsoleWindowInfo PROTO,		; set position of console window
	nStdHandle:DWORD,		; screen buffer handle
	bAbsolute:DWORD,		; coordinate type
	pConsoleRect:PTR SMALL_RECT		; ptr to window rectangle

SetFilePointer PROTO,
	fileHandle:DWORD,		; file handle
	nDistanceLo:SDWORD,		; bytes to move pointer
	pDistanceHi:PTR SDWORD,		; ptr to bytes to move, high
	moveMethod:DWORD		; starting point

Sleep PROTO,	   	; sleeep for n milliseconds
	dwMilliseconds:DWORD

SystemTimeToFileTime PROTO,		; Convert a SYSTEMTIME structure
  lpSystemTime:PTR SYSTEMTIME,		; to a FILETIME structure
  lpFileTime:PTR FILETIME

WriteFile PROTO,		; write buffer to output file
	fileHandle:DWORD,		; output handle
	pBuffer:PTR BYTE,		; pointer to buffer
	nBufsize:DWORD,		; size of buffer
	pBytesWritten:PTR DWORD,		; num bytes written
	pOverlapped:PTR DWORD		; ptr to asynchronous info

WriteConsole PROTO,		; write a buffer to the console
	handle:DWORD,		; output handle
	lpBuffer:PTR BYTE,		; pointer to buffer
	nNumberOfBytesToWrite:DWORD,	; size of buffer
	lpNumberOfBytesWritten:PTR DWORD,	; num bytes written
	lpReserved:DWORD		; (not used)

WriteConsoleOutputCharacter PROTO,
	handleScreenBuf:DWORD,		; console output handle
	pBuffer:PTR BYTE,		; pointer to buffer
	bufsize:DWORD,		; size of buffer
	xyPos:COORD,		; first cell coordinates
	pCount:PTR DWORD		; output count

WriteConsoleOutputAttribute PROTO,
	outHandle:DWORD,		; output handle
	pAttribute:PTR WORD,		; write attributes
	nLength:DWORD,		; number of cells
	xyCoord:COORD,		; first cell coordinates
	lpCount:PTR DWORD		; number of cells written

.LIST