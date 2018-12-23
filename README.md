# launch hybris

Most simple hybris launcher using Assembler or C

## Why the ...?

Take it as "educational software".

Take it as "demo software".

Take it as "drunken developer software".

Take it as a joke.

Your mileage may vary.

## What does it?

It shows a most simple way to start SAP hybris.

Two versions are provided: A C version and a Assembler version.

(Hey! Didn't you ever dream about starting a very big Java application like Hybris with a small launcher written in Assembler code?)

## How does it work?

It sets JAVA_HOME and then starts Hybris in a screen session.

## Requirements

Build:

   * POSIX/Unix system
   * C compiler
   * nasm
   * make

Runtime:

   * POSIX/Unix system
   * screen

## Binaries

    $ ls -l launch-hybris-asm launch-hybris-c
    -rwxr-xr-x 1 abcdef abcdef  344 23. Dez 15:07 launch-hybris-asm
    -rwxr-xr-x 1 abcdef abcdef 1475 23. Dez 15:07 launch-hybris-c
    $ file launch-hybris-asm launch-hybris-c
    launch-hybris-asm: ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), statically linked, stripped
    launch-hybris-c:   ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), statically linked, stripped
    $ strings launch-hybris-asm
    /usr/bin/screen
    hybris
    /bin/bash
    export JAVA_HOME=/usr/lib/jvm/jre-1.8.0;cd /usr/local/hybris-6.3/hybris/bin/platform;. ./setantenv.sh;./hybrisserver.sh debug;sleep 120
    $ strings launch-hybris-asm|wc
          4       9     169


