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


    cmp BX, 1               ;|
        jne return          ;| sprawdzenie czy lpm jest wciśnięty

    jmp draw                ;| rysowanie

    return:

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

    ; kod programu
jmp main_loop

koniec:

mov AX, 2
int 33h

mov AH, 00h     ;|
int 21h         ;| -Koniec programu

color_change:
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
        push BX
        mov BX, [brush_size]
        mov BH, 00h
        dec DX
        add CX, BX
        pop BX
        jmp back

brush_inc:
    mov AH, 00h                 ;|
    int 16h                     ;| czyszczenie buforu

    inc byte [brush_size]       ;|
    jmp main_loop               ;| zwiększanie wielkości pędzla

brush_dec:
    mov AH, 00h                 ;|
    int 16h                     ;| czyszczenie buforu

    dec byte [brush_size]       ;|
    jmp main_loop               ;| zmniejszanie wielkości pędzla

color db 1h
brush_size db 3h
