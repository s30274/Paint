org 100h

mov AH, 00h     ;|
mov AL, 10h     ;|
int 10h         ;| tryb graficzny

mov AX, 01h     ;|
int 33h         ;| wlaczanie kursora

main_loop:

    mov AX, 03h ;|
    int 33h     ;| zwrot pozycji kursora
                ;| BX - Stan przycisku, CX - kolumna, DX - wiersz


    cmp BX, 1   ;|
        je draw ;| sprawdzenie czy lpm jest wciśnięty


    cmp byte [borrow], 02h
        je draw_color

    return:


    cmp byte [borrow], 01h
        je rewrite

    mov AH, 01h
    int 16h

    cmp AL, 'q'
        je koniec

    cmp AL, 'a'
        je color_change

    cmp AL, 'z'
        je brush_inc

    cmp AL, 'x'
        je brush_dec

    cmp AL, 's'
        je save

    ; kod programu
jmp main_loop

koniec:

mov AX, 2
int 33h

mov AH, 00h     ;|
int 21h         ;| -Koniec programu

color_change:
    mov byte [borrow], 02h
    mov AH, 00h                 ;|
    int 16h                     ;| czyszczenie buforu

    inc byte [color]            ;| zwiększanie wartości color o 1
    jmp main_loop

draw:
    dec DX

    mov AL, [brush_size]
    mul AL                      ;| w AL,  - liczba pikseli
    dec AL
    mov BL, AL

    petla:
        mov AH, 0h
        mov AL, BL
        div byte [brush_size]   ;| po tym w AH=reszta

        cmp AH, 0

        mov AH, 0Ch
        mov AL, [color]
        int 10h

            je skok

        back:

        cmp BL, 0
            je return

        dec BL

        cmp CX, 0               ;|
            je petla            ;| sprawdzenie lewej krawędzi ekranu

        dec CX                  ;| zmniejszenie CX (kolumny pixela) jeżeli nie jest poza ekranem

        jmp petla

    skok:
        dec DX
        add CX, [brush_size]
        jmp back

brush_inc:
    mov byte [borrow], 02h
    mov AH, 00h                 ;|
    int 16h                     ;| czyszczenie buforu

    cmp byte [brush_size], 0xF
        je main_loop

    inc byte [brush_size]       ;|
    jmp main_loop               ;| zwiększanie wielkości pędzla

brush_dec:
    mov byte [borrow], 02h
    mov AH, 00h                 ;|
    int 16h                     ;| czyszczenie buforu

    cmp byte [brush_size], 1
        je main_loop

    dec byte [brush_size]       ;|
    jmp main_loop               ;| zmniejszanie wielkości pędzla

draw_color:
    mov CX, 027Fh
    mov DX, 0Fh

    push word [color]
    push word [brush_size]

    mov word [color], 00h
    mov word [brush_size], 0Fh

    mov byte [borrow], 01h
    jmp draw

rewrite:
    mov CX, 027Fh
    mov DX, 0Fh
    pop word [brush_size]
    pop word [color]
    mov byte [borrow], 00h
    jmp draw

save:
    mov AH, 00h                 ;|
    int 16h                     ;| czyszczenie buforu

    mov AH, 3Ch
    mov CX, 00h
    mov DX, filename
    int 21h

    mov BX, AX
    mov AH, 40h
    mov CX, 0xFFFF
    push DS
    mov BX, 0xA000
    mov DS, BX
    mov DX, 00h
    int 21h
    mov AH, 3Eh
    int 21h
    pop DS
    jmp main_loop


color dw 1h
brush_size dw 3h
borrow db 02h
filename db "plik.bmp", 0
