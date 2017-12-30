;
; launch-hybris.asm
;
; MOST simple hybris launcher, install and launch via
;   chown CUSTOMER:root launch-hybris
;   chmod 4754 launch-hybris
;   ./launch-hybris
; (actually it requires only CAP_SETUID)
;
; this asm-Version must be processed by "nasm -f bin" to produce an executable
; 

         %include "elfheader.asm"

_start:
         mov     ebx,arg0
         mov     ecx,argv
         xor     edx,edx
         xor     eax,eax
         mov     al,11         ;execve()
         int     0x80

         mov     ebx,111       ;error on exec: return 111
         xor     eax, eax
         inc     eax           ;_exit()
         int     0x80

section  .data   ;section declaration

argv     dd      arg0
         dd      arg1
         dd      arg2
         dd      arg3
         dd      arg4
         dd      arg5
         dd      arg6
         dd      0
arg0     db      "/usr/bin/screen"
         dd      0
arg1     db      "-S"
         dd      0
arg2     db      "hybris"
         dd      0
arg3     db      "-dm"
         dd      0
arg4     db      "/bin/bash"
         dd      0
arg5     db      "-c"
         dd      0
arg6     db      "export JAVA_HOME=/usr/lib/jvm/jre-1.8.0;"
         db      "cd /usr/local/hybris-6.3/hybris/bin/platform;"
         db      ". ./setantenv.sh;./hybrisserver.sh debug"
         db      ";sleep 120"
         dd      0

filesize equ    $ - $$
