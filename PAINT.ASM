org 100h

mov AH, 00h     ;|
mov AL, 10h     ;|
int 10h         ;| tryb graficzny

mov AX, 01h     ;|
int 33h         ;| wlaczanie kursora

main_loop:
    mov AX, 03h ;|
    int 33h     ;| zwrot pozycji kursora
                ;| CX - kolumna, DX - wiersz,

    call draw_pixel

    mov AH, 01h
    int 16h

    cmp AL, 'q'
    je koniec

    cmp AL, 'a'
    je color_change

    ; kod programu
jmp main_loop

koniec:

mov AX, 2
int 33h

mov AH, 00h     ;|
int 21h         ;| -Koniec programu

jmp end

color_change:
    mov AH, 00h
    int 16h
    inc byte [color]
    jmp main_loop

draw_pixel:
    mov AH, 0Ch
    mov AL, [color]
    dec CX
    dec DX
    int 10h
    dec DX
    int 10h
    dec DX
    int 10h
    ret

end:

color db 0h
