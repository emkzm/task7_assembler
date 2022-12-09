extrn GetUserNameA      : proc,
      GetComputerNameA  : proc,
      GetTempPathA      : proc,
      GetVersionExA     : proc,
      wsprintfA         : proc,
      MessageBoxA       : proc,
      ExitProcess       : proc

;   Структура OSVERSIONINFO
;   Для получения информации о версии ОС необходимо ввести следующую структуру:

OSVERSIONINFO struct
   dwOSVersionInfoSize dword ?
   dwMajorVersion      dword ?
   dwMinorVersion      dword ?
   dwBuildNumber       dword ?
   dwPlatformId        dword ?
   szCSDVersion        byte 128 dup(?)
OSVERSIONINFO ends

;   Удобно ввести следующие макрозамены (с помощью директивы equ или =):
    szMAX_COMP_NAME equ 16
    szUNLEN         equ 257
    szMAX_PATH      equ 261

.data


;   Введите следующие глобальные переменные (заголовок окна и строка форматирования):	
    
    cap db '<заголовок окна>',       0

    fmt db 'Username: %s',           0Ah,
           'Computer name: %s',      0Ah,
           'TMP Path: %s',           0Ah,
           'OS version: %d.%d.%d',   0

    


.code
Start proc
;   Пошаговая инструкция по написанию программы
;
;   HELLO!
;
;   1.  Объявление локальных переменных
;   Для хранения результатов вызовов функций WinAPI введем следующие локальные переменные :


    local _msg[1024]                :byte, ; В переменной _msg будет храниться результирующая строка размером до 1024 байт
      _username[szUNLEN]            :byte, ; имя пользователя
      _compname[szMAX_COMP_NAME]    :byte, ; название компьютера
      _temppath[szMAX_PATH]         :byte, ; путь до директории временных файлов
      _v                            :OSVERSIONINFO,
      _size                         :dword

;   В переменной _msg будет храниться результирующая строка размером до 1024 байт. 
;   Байтовые переменные 
;   _username[szUNLEN], 
;   _compname[szMAX_COMP_NAME], 
;   _temppath[szMAX_PATH] 
;   нужны для хранения имени пользователя, названия компьютера и пути до директории временных файлов соответственно. 
;   Также для получения данных о системе нам потребуется локальный экземпляр структуры OSVERSIONINFO. Назовем его _v. 
;   Последняя переменная, которую необходимо объявить, - это _size размера dword. 
;   Эта переменная необходима для передачи размера строк в функции 
;   (так как размер требуется передать по указателю, макрозамены для передачи мы использовать не можем).    


;   2.  Подготовка стека
;   Для того, чтобы начать работу с WinAPI, требуется подготовить стек: 
;   выровнять его в соответствии со стандартом __fastcall и выделить место под 5 аргументов:

    sub RSP, 8*5
    and SPL, 0F0h

;   3.  Получение имени пользователя, названия компьютера и пути до директории временных файлов
;   Для того чтобы получить имя пользователя, выполним следующие действия:


    mov _size, szUNLEN  ; поместим в переменную _size значение размера строки имени пользователя (szUNLEN)
    lea RCX, fmt        ; загрузим АДРЕС строки и УКАЗАТЕЛЬ на ее размер в регистры RCX  
    lea RDX, _size      ; и RDX соответственно
    call GetUserNameA   ; вызовем функцию GetUserNameA

;   Далее необходимо получить название компьютера и путь до директории временных файлов с помощью функций 
;   GetComputerNameA, 
;   GetTempPathA. 
;  
;   Работа с ними осуществляется аналогично, за исключением того, что для последней функции порядок меняется: 
;   сначала передается указатель на размер, а затем адрес строки.
;
;   4.  Получение сведений о системе
;   В первую очередь нужно очистить экземпляр структуры OSVERSIONINFO:

    xor AL,AL               ;   очистим регистр AL
    mov RCX, size _v        ;   занесем в регистр RCX размер экземпляра _v (mov RCX, size _v)
    lea RDI, _v             ;   загрузить в RDI адрес _v
    rep stos byte ptr [RDI] ;   применим stos для всех полей структуры (rep stos byte ptr [RDI]).

;   The STOS instruction copies the data item from AL (for bytes - STOSB), AX (for words - STOSW)
;   or EAX (for doublewords - STOSD) to the destination string, pointed to by ES:DI in memory.

;   Далее необходимо подготовить аргументы и вызвать GetVersionExA:

    mov _v.dwOSVersionInfoSize, size _v     ;   установим размер структуры и поместим его в _v.dwOSVersionInfoSize
    lea RCX, _v                             ;   поместим _v в RCX
    call GetVersionExA                      ;   вызовем GetVersionExA.
    
   
;   5.  Формирование отформатированной строки
;   Сформируем строку _msg с помощью функции wsprintfA:
    lea RCX, _msg       ;  поместим в регистр RCX адрес строки _msg
    lea RDX, fmt        ;  в RDX занесем адрес строки форматирования fmt
    lea R8, _username   ;  в регистры R8 и R9 поместим адреса _username и
    lea R9, _compname   ;  _compname соответственно
    lea RAX, _temppath  ;  поместим оставшиеся
    push RAX            ;  аргументы в стек
    lea RAX, _v
    push RAX
    call wsprintfA      ;  вызовем wsprintfA.

;   6.  Отображение полученной информации в диалоговом окне
;   Выведем полученную строку с помощью MessageBoxA:
    xor RCX, RCX            ;   обнулим регистры RCX 
    xor R9, R9              ;   и R9
    lea RDX,  _msg          ;   загрузим в RDX адрес строки для вывода на экран (_msg)
    lea R8,  cap            ;   загрузим в R8 адрес строки, содержащей заголовок окна (cap)
    call MessageBoxA        ;   вызовем MessageBoxA

;   7.  Завершение работы процесса
;   Выполним следующие действия:

;    xor RCX, RCX     ;    обнулим RCX
;    mov RCX, 0
    call ExitProcess ;    вызовем ExitProcess

Start endp
end