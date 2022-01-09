IMAGE_NUMBEROF_DIRECTORY_ENTRIES 		equ 16

IMAGE_DIRECTORY_ENTRY_EXPORT     		equ     0   ;// Export Directory
IMAGE_DIRECTORY_ENTRY_IMPORT     		equ     1   ;// Import Directory
IMAGE_DIRECTORY_ENTRY_RESOURCE   		equ     2   ;// Resource Directory
IMAGE_DIRECTORY_ENTRY_EXCEPTION  		equ     3   ;// Exception Directory
IMAGE_DIRECTORY_ENTRY_SECURITY   		equ     4   ;// Security Directory
IMAGE_DIRECTORY_ENTRY_BASERELOC  		equ     5   ;// Base Relocation Table
IMAGE_DIRECTORY_ENTRY_DEBUG      		equ     6   ;// Debug Directory
;IMAGE_DIRECTORY_ENTRY_COPYRIGHT       			7   ;// (X86 usage)
IMAGE_DIRECTORY_ENTRY_ARCHITECTURE 		equ   	7   ;// Architecture Specific Data
IMAGE_DIRECTORY_ENTRY_GLOBALPTR    		equ   	8   ;// RVA of GP
IMAGE_DIRECTORY_ENTRY_TLS          		equ   	9   ;// TLS Directory
IMAGE_DIRECTORY_ENTRY_LOAD_CONFIG  		equ  	10  ;// Load Configuration Directory
IMAGE_DIRECTORY_ENTRY_BOUND_IMPORT 		equ  	11  ;// Bound Import Directory in headers
IMAGE_DIRECTORY_ENTRY_IAT          		equ  	12  ;// Import Address Table
IMAGE_DIRECTORY_ENTRY_DELAY_IMPORT 		equ  	13  ;// Delay Load Import Descriptors
IMAGE_DIRECTORY_ENTRY_COM_DESCRIPTOR 	equ 	14  ;// COM Runtime descriptor

IMAGE_SIZEOF_SHORT_NAME 				equ 8


IMAGE_DOS_HEADER struc  		;// DOS .EXE header
    e_magic		dw ?			;// Magic number
    e_cblp		dw ?			;// Bytes on last page of file
    e_cp		dw ?			;// Pages in file
    e_crlc		dw ?			;// Relocations
    e_cparhdr	dw ?			;// Size of header in paragraphs
    e_minalloc	dw ?			;// Minimum extra paragraphs needed
    e_maxalloc	dw ?			;// Maximum extra paragraphs needed
    e_ss		dw ?			;// Initial (relative) SS value
    e_sp		dw ?			;// Initial SP value
    e_csum		dw ?			;// Checksum
    e_ip		dw ?			;// Initial IP value
    e_cs		dw ?			;// Initial (relative) CS value
    e_lfarlc	dw ?			;// File address of relocation table
    e_ovno		dw ?			;// Overlay number
    e_res		dw 4 dup (?)	;// Reserved words
    e_oemid		dw ?			;// OEM identifier (for e_oeminfo)
    e_oeminfo	dw ?			;// OEM information; e_oemid specific
    e_res2		dw 10 dup (?)	;// Reserved words
    e_lfanew	dd ?			;// File address of new exe header
IMAGE_DOS_HEADER ends



IMAGE_DATA_DIRECTORY struc
    VirtualAddress dd ?
    Size0 dd ?
IMAGE_DATA_DIRECTORY ends



IMAGE_OPTIONAL_HEADER32 struc 
    Magic 						dw ?		;0
    MajorLinkerVersion 			db ?		;2
    MinorLinkerVersion 			db ?		;3
    SizeOfCode 					dd ?		;4
    SizeOfInitializedData 		dd ?		;8
    SizeOfUninitializedData 	dd ?		;12
    AddressOfEntryPoint 		dd ?		;16
    BaseOfCode 					dd ?		;20
    BaseOfData 					dd ?		;24
    ImageBase 					dd ?		;28
    SectionAlignment 			dd ?		;32
    FileAlignment 				dd ?		;36
    MajorOperatingSystemVersion dw ?		;40
    MinorOperatingSystemVersion dw ?		;42
    MajorImageVersion 			dw ?		;44
    MinorImageVersion 			dw ?		;46
    MajorSubsystemVersion 		dw ?		;48
    MinorSubsystemVersion 		dw ?		;50
    Win32VersionValue 			dd ? 		;52
    SizeOfImage 				dd ?		;56
    SizeOfHeaders 				dd ?		;60
    CheckSum 					dd ?		;64
    Subsystem 					dw ?		;68
    DllCharacteristics 			dw ?		;70
    SizeOfStackReserve 			dd ?		;72
    SizeOfStackCommit 			dd ?		;76
    SizeOfHeapReserve 			dd ?		;80
    SizeOfHeapCommit 			dd ?		;84
    LoaderFlags 				dd ?		;88
    NumberOfRvaAndSizes 		dd ?		;92
    DataDirectory  				IMAGE_DATA_DIRECTORY IMAGE_NUMBEROF_DIRECTORY_ENTRIES dup (<?>)	;96-120
IMAGE_OPTIONAL_HEADER32 ends



IMAGE_FILE_HEADER struc
    Machine 				dw ?		;0
    NumberOfSections 		dw ?		;2
    TimeDateStamp 			dd ?		;4
    PointerToSymbolTable 	dd ?		;8
    NumberOfSymbols 		dd ?		;12
    SizeOfOptionalHeader 	dw ?		;16
    Characteristics 		dw ?		;18
IMAGE_FILE_HEADER ends






IMAGE_NT_HEADERS32 struc
    Signature 			dd ?
    FileHeader 			IMAGE_FILE_HEADER <?>
    OptionalHeader 		IMAGE_OPTIONAL_HEADER32 <?>
IMAGE_NT_HEADERS32 ends





IMAGE_SECTION_HEADER struc
    Name0 					db IMAGE_SIZEOF_SHORT_NAME dup (0)	;0
	VirtualSize				dd ?	;8
    VirtualAddress 			dd ?	;12
    SizeOfRawData 			dd ?	;16
    PointerToRawData 		dd ?	;20
    PointerToRelocations 	dd ?	;24
    PointerToLinenumbers 	dd ?	;28
    NumberOfRelocations 	dw ?	;32
    NumberOfLinenumbers 	dw ?	;34
    Characteristics 		dd ?	;36
IMAGE_SECTION_HEADER ends





IMAGE_BASE_RELOCATION struc
    VirtualAddress 	dd ?
    SizeOfBlock 	dd ?
IMAGE_BASE_RELOCATION ends


;must set name to name0,else masm615 will ignore this field

IMAGE_EXPORT_DIRECTORY struc
    Characteristics 		dd ?	;0
    TimeDateStamp			dd ?	;4
    MajorVersion			dw ?	;8
    MinorVersion			dw ?	;10
    Name0					dd ?	;12
    Base					dd ?	;16
    NumberOfFunctions 		dd ?	;20
    NumberOfNames			dd ?	;24
    AddressOfFunctions		dd ?	;28
    AddressOfNames			dd ?	;32
    AddressOfNameOrdinals	dd ?	;36
IMAGE_EXPORT_DIRECTORY ends


