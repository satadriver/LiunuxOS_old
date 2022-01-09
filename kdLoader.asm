.386p
include pe.ASM

Kernel Segment public para use32
assume cs:Kernel


;8 function name
;4 ret address
;0 ebp
;-4 ecx
;-8 edx
;-12 ebx
;-16 esi
;-20 edi
;-24 pe hdr
;-28 new pe hdr

;param:loadaddr:KERNELDLL_LOAD_ADDRESS,runaddr:KERNELDLL_RUN_ADDRESS
__vsDllLoader proc
	push ebp
	mov ebp,esp
	push ecx
	push edx
	push ebx
	push esi
	push edi
	sub esp,100h
	
	;check pe format
	push dword ptr ss:[ebp + 8]
	call __CheckPE
	add esp,4
	cmp eax,2
	jnz _loadDllErr
	
	
	
	;get pe header
	mov ebx,dword ptr ss:[ebp + 8]
	add ebx,ds:[ebx + 3ch]
	mov ss:[ebp - 24],ebx
	;assume ebx:ptr IMAGE_NT_HEADERS32
	
	movzx eax, word ptr ds:[ebx + IMAGE_NT_HEADERS32.FileHeader.Characteristics]
	test eax,2000h
	jz _loadDllErr

	cld
	
	;copy pe header
	mov ecx,ds:[ebx + IMAGE_NT_HEADERS32.OptionalHeader.SizeOfHeaders]
	mov esi,dword ptr ss:[ebp + 8]
	MOV edi,dword ptr ss:[ebp + 12]
	rep movsb

	
	
	;copy sections
	movzx ecx,ds:[ebx + IMAGE_NT_HEADERS32.FileHeader.NumberOfSections]
	cmp ecx,0
	jle _loadDllErr

	add ebx,sizeof IMAGE_NT_HEADERS32
	;assume ebx:nothing
	;assume ebx:ptr IMAGE_SECTION_HEADER
	_mapSections:
	push ecx
	mov edi,ds:[ebx + IMAGE_SECTION_HEADER.VirtualAddress]
	mov esi,ds:[ebx + IMAGE_SECTION_HEADER.PointerToRawData]
	mov ecx,ds:[ebx + IMAGE_SECTION_HEADER.SizeOfRawData]		;file alignment with 512
	cmp ecx,0
	jle _mapNextSection
	cmp esi,0
	jle _mapNextSection
	cmp edi,0
	jle _mapNextSection
	add esi,dword ptr ss:[ebp + 8]
	add edi,dword ptr ss:[ebp + 12]
	rep movsb
	_mapNextSection:
	add ebx,sizeof IMAGE_SECTION_HEADER
	pop ecx
	loop _mapSections
	
	

	;get dst location pe header
	mov esi,dword ptr ss:[ebp + 12]
	add esi,dword ptr ds:[esi + 3ch]
	mov ss:[ebp - 28],esi
	
	
	
	;relocation
	;assume esi:ptr IMAGE_NT_HEADERS32
	mov esi,ds:[esi + IMAGE_NT_HEADERS32.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC*8].VirtualAddress]
	cmp esi,0
	jle _setImageBase
	add esi,dword ptr ss:[ebp + 12]
	
	_relocatePages:
	;assume esi:ptr IMAGE_BASE_RELOCATION
	;every relocation block size is not sure,first 8 bytes is IMAGE_BASE_RELOCATION
	mov ebx,ds:[esi + IMAGE_BASE_RELOCATION.VirtualAddress]
	cmp ebx,0
	jle _setImageBase
	
	mov ecx,ds:[esi + IMAGE_BASE_RELOCATION.SizeOfBlock]
	cmp ecx,0
	jle _setImageBase
	sub ecx,sizeof IMAGE_BASE_RELOCATION
	shr ecx,1
	
	mov edi,esi
	add edi,sizeof IMAGE_BASE_RELOCATION
	
	_relocateOnePage:
	push ecx
	push ebx
	push esi
	
	movzx eax,word ptr ds:[edi]
	;in every 16 bits relocation item,high 4 bits is 0 or 3,low 12 bits is address,0 is used to alignment
	and eax,0000F000h
	cmp eax,00003000h
	jnz _relocateNext

	movzx eax,word ptr ds:[edi]
	and eax,0fffh
	add eax,ebx
	add eax,dword ptr ss:[ebp + 12]

	mov edx,ss:[ebp - 28]
	;assume edx:ptr IMAGE_NT_HEADERS32
	mov ecx,dword ptr ss:[ebp + 12]
	sub ecx,dword ptr ds:[edx + IMAGE_NT_HEADERS32.OptionalHeader.ImageBase]
	
	add dword ptr ds:[eax],ecx
	
	_relocateNext:	
	add edi,2
	pop esi
	pop ebx
	pop ecx
	loop _relocateOnePage

	add esi,ds:[esi + IMAGE_BASE_RELOCATION.SizeOfBlock]
	jmp _relocatePages
	
	
	;reset ImageBase
	_setImageBase:
	mov edi,ss:[ebp - 28]
	;assume edi:ptr IMAGE_NT_HEADERS32
	mov eax,dword ptr ss:[ebp + 12]
	mov dword ptr ds:[edi + IMAGE_NT_HEADERS32.OptionalHeader.ImageBase],eax
	
	mov eax,dword ptr ss:[ebp + 12]
	jmp _loadPeOver

	_loadDllErr:
	mov eax,0
	_loadPeOver:
	add esp,100h
	pop edi
	pop esi
	pop ebx
	pop edx
	pop ecx
	mov esp,ebp
	pop ebp
	ret
__vsDllLoader endp



;param:peBase,string
__getProcAddress proc
	push ebp
	mov ebp,esp
	push ecx
	push edx
	push ebx
	push esi
	push edi
	sub esp,100h
	
	mov ebx,ss:[ebp + 8]
	add ebx,dword ptr ds:[ebx + 3ch]
	;save pe header address
	mov ss:[ebp - 24],ebx
	;assume ebx:ptr IMAGE_NT_HEADERS32
	
	_GetProcAddress:
	;not IMAGE_DIRECTORY_ENTRY_EXPORT but IMAGE_DIRECTORY_ENTRY_EXPORT*8
	mov ebx,ds:[ebx + IMAGE_NT_HEADERS32.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT*8].VirtualAddress]
	cmp ebx,0
	jle _notFoundFunAddr
	add ebx,ss:[ebp + 8]
	;assume ebx:nothing
	;assume ebx:ptr IMAGE_EXPORT_DIRECTORY
	;numbers of function names
	cmp ds:[ebx + IMAGE_EXPORT_DIRECTORY.NumberOfNames],0
	jle _notFoundFunAddr

	cld 
	mov ecx,0
	;addresses of function names
	mov esi,ds:[ebx + IMAGE_EXPORT_DIRECTORY.AddressOfNames]
	add esi,ss:[ebp + 8]
	_getFuncName:
	push ecx
	lodsd
	add eax,ss:[ebp + 8]
	push dword ptr ss:[ebp + 12]
	push eax
	call __strcmp
	add esp,8
	cmp eax,0
	jnz _nextFuncName
	
	;named functions ordinals
	mov edi,ds:[ebx + IMAGE_EXPORT_DIRECTORY.AddressOfNameOrdinals]
	add edi,ss:[ebp + 8]
	mov eax,ecx
	shl eax,1
	movzx edx,word ptr ds:[edi + eax] 
	
	;all the functions addresses in list
	mov esi,ds:[ebx + IMAGE_EXPORT_DIRECTORY.AddressOfFunctions]
	add esi,ss:[ebp + 8]
	shl edx,2
	mov eax,dword ptr ds:[esi + edx]
	add eax,ss:[ebp + 8]
	mov ss:[ebp - 28],eax
	pop ecx
	jmp _GetProcAddressEnd
	
	_nextFuncName:
	pop ecx
	inc ecx
	cmp ecx,ds:[ebx + IMAGE_EXPORT_DIRECTORY.NumberOfNames]
	jl _getFuncName

	
	_notFoundFunAddr:
	mov eax,0
	_GetProcAddressEnd:
	add esp,100h
	pop edi
	pop esi
	pop ebx
	pop edx
	pop ecx
	mov esp,ebp
	pop ebp
	ret
__getProcAddress endp



;param:address
__CheckPE proc near
	push ebp
	mov ebp,esp
	
	push esi

	mov esi,ss:[ebp + 8]
	cmp word ptr ds:[esi],5a4dh
	jnz _notPE

	mov eax,dword ptr ds:[esi + 3ch]
	cmp eax,0
	jle _pe16
	cmp eax,1000h
	jge _pe16
	mov eax,dword ptr ds:[esi + eax]
	cmp eax,dword ptr 00004550h
	jz _pe32

	_pe16:
	pop esi
	mov esp,ebp
	pop ebp
	
	mov eax,1
	ret

	_pe32:
	pop esi
	mov esp,ebp
	pop ebp
	
	mov eax,2
	ret

	_notPE:
	pop esi
	mov esp,ebp
	pop ebp
	
	mov eax,-1
	ret
__CheckPE endp


kernel ends