extrn GetUserNameA      : proc,
      GetComputerNameA  : proc,
      GetTempPathA      : proc,
      GetVersionExA     : proc,
      wsprintfA         : proc,
      MessageBoxA       : proc,
      ExitProcess       : proc

;   ��������� OSVERSIONINFO
;   ��� ��������� ���������� � ������ �� ���������� ������ ��������� ���������:

OSVERSIONINFO struct
   dwOSVersionInfoSize dword ?
   dwMajorVersion      dword ?
   dwMinorVersion      dword ?
   dwBuildNumber       dword ?
   dwPlatformId        dword ?
   szCSDVersion        byte 128 dup(?)
OSVERSIONINFO ends

;   ������ ������ ��������� ����������� (� ������� ��������� equ ��� =):
    szMAX_COMP_NAME equ 16
    szUNLEN         equ 257
    szMAX_PATH      equ 261

.data


;   ������� ��������� ���������� ���������� (��������� ���� � ������ ��������������):	
    
    cap db '<��������� ����>',       0

    fmt db 'Username: %s',           0Ah,
           'Computer name: %s',      0Ah,
           'TMP Path: %s',           0Ah,
           'OS version: %d.%d.%d',   0

    


.code
Start proc
;   ��������� ���������� �� ��������� ���������
;
;   HELLO!
;
;   1.  ���������� ��������� ����������
;   ��� �������� ����������� ������� ������� WinAPI ������ ��������� ��������� ���������� :


    local _msg[1024]                :byte, ; � ���������� _msg ����� ��������� �������������� ������ �������� �� 1024 ����
      _username[szUNLEN]            :byte, ; ��� ������������
      _compname[szMAX_COMP_NAME]    :byte, ; �������� ����������
      _temppath[szMAX_PATH]         :byte, ; ���� �� ���������� ��������� ������
      _v                            :OSVERSIONINFO,
      _size                         :dword

;   � ���������� _msg ����� ��������� �������������� ������ �������� �� 1024 ����. 
;   �������� ���������� 
;   _username[szUNLEN], 
;   _compname[szMAX_COMP_NAME], 
;   _temppath[szMAX_PATH] 
;   ����� ��� �������� ����� ������������, �������� ���������� � ���� �� ���������� ��������� ������ ��������������. 
;   ����� ��� ��������� ������ � ������� ��� ����������� ��������� ��������� ��������� OSVERSIONINFO. ������� ��� _v. 
;   ��������� ����������, ������� ���������� ��������, - ��� _size ������� dword. 
;   ��� ���������� ���������� ��� �������� ������� ����� � ������� 
;   (��� ��� ������ ��������� �������� �� ���������, ����������� ��� �������� �� ������������ �� �����).    


;   2.  ���������� �����
;   ��� ����, ����� ������ ������ � WinAPI, ��������� ����������� ����: 
;   ��������� ��� � ������������ �� ���������� __fastcall � �������� ����� ��� 5 ����������:

    sub RSP, 8*5
    and SPL, 0F0h

;   3.  ��������� ����� ������������, �������� ���������� � ���� �� ���������� ��������� ������
;   ��� ���� ����� �������� ��� ������������, �������� ��������� ��������:


    mov _size, szUNLEN  ; �������� � ���������� _size �������� ������� ������ ����� ������������ (szUNLEN)
    lea RCX, fmt        ; �������� ����� ������ � ��������� �� �� ������ � �������� RCX  
    lea RDX, _size      ; � RDX ��������������
    call GetUserNameA   ; ������� ������� GetUserNameA

;   ����� ���������� �������� �������� ���������� � ���� �� ���������� ��������� ������ � ������� ������� 
;   GetComputerNameA, 
;   GetTempPathA. 
;  
;   ������ � ���� �������������� ����������, �� ����������� ����, ��� ��� ��������� ������� ������� ��������: 
;   ������� ���������� ��������� �� ������, � ����� ����� ������.
;
;   4.  ��������� �������� � �������
;   � ������ ������� ����� �������� ��������� ��������� OSVERSIONINFO:

    xor AL,AL               ;   ������� ������� AL
    mov RCX, size _v        ;   ������� � ������� RCX ������ ���������� _v (mov RCX, size _v)
    lea RDI, _v             ;   ��������� � RDI ����� _v
    rep stos byte ptr [RDI] ;   �������� stos ��� ���� ����� ��������� (rep stos byte ptr [RDI]).

;   The STOS instruction copies the data item from AL (for bytes - STOSB), AX (for words - STOSW)
;   or EAX (for doublewords - STOSD) to the destination string, pointed to by ES:DI in memory.

;   ����� ���������� ����������� ��������� � ������� GetVersionExA:

    mov _v.dwOSVersionInfoSize, size _v     ;   ��������� ������ ��������� � �������� ��� � _v.dwOSVersionInfoSize
    lea RCX, _v                             ;   �������� _v � RCX
    call GetVersionExA                      ;   ������� GetVersionExA.
    
   
;   5.  ������������ ����������������� ������
;   ���������� ������ _msg � ������� ������� wsprintfA:
    lea RCX, _msg       ;  �������� � ������� RCX ����� ������ _msg
    lea RDX, fmt        ;  � RDX ������� ����� ������ �������������� fmt
    lea R8, _username   ;  � �������� R8 � R9 �������� ������ _username �
    lea R9, _compname   ;  _compname ��������������
    lea RAX, _temppath  ;  �������� ����������
    push RAX            ;  ��������� � ����
    lea RAX, _v
    push RAX
    call wsprintfA      ;  ������� wsprintfA.

;   6.  ����������� ���������� ���������� � ���������� ����
;   ������� ���������� ������ � ������� MessageBoxA:
    xor RCX, RCX            ;   ������� �������� RCX 
    xor R9, R9              ;   � R9
    lea RDX,  _msg          ;   �������� � RDX ����� ������ ��� ������ �� ����� (_msg)
    lea R8,  cap            ;   �������� � R8 ����� ������, ���������� ��������� ���� (cap)
    call MessageBoxA        ;   ������� MessageBoxA

;   7.  ���������� ������ ��������
;   �������� ��������� ��������:

;    xor RCX, RCX     ;    ������� RCX
;    mov RCX, 0
    call ExitProcess ;    ������� ExitProcess

Start endp
end