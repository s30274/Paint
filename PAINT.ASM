org 100h

mov AH, 00h     ;|
mov AL, 10h     ;|
int 10h         ;| tryb graficzny



; ustawienie tła na białe
mov AL, 0Fh
mov BH, 00h
mov CX, 00h
mov DX, 0x0018
canvas:
    mov AH, 0Ch
    int 10h

    cmp DX, 0x015D
        je canvas_finish
    cmp CX, 0x027F
        jne canvas_column
        mov CX, 00h
        inc DX
        je canvas

    canvas_column:
        inc CX
        jmp canvas

    canvas_finish:
        cmp CX, 0x027F
            jne canvas_column
            mov CX, 0Fh
            mov DX, 01h
            je palette



; rysowanie palety
palette:
    cmp byte [paleta], 17
        jl normal
        jg col

    mov CX, 0Eh
    inc DX
    sub word [brush_size], 3h
    dec byte [color]

    col:
    inc byte [color]
    sub DX, 3h
    cmp byte [paleta], 33
        je quit

    normal:
        inc byte [paleta]
        add CX, 0Fh
        add DX, 10h
        jmp draw



; ustawienie zmiennych przed rysowaniem
quit:
mov byte [borrow2], 00h
mov word [color], 01h
mov word [brush_size], 03h
mov AX, 01h     ;|
int 33h         ;| włączanie kursora

; główna pętla
main_loop:

    mov AX, 03h ;|
    int 33h     ;| zwrot pozycji kursora
                ;| BX - Stan przycisku, CX - kolumna, DX - wiersz

    cmp BX, 1           ;|
        jne no_draw     ;| sprawdzenie czy lpm jest wciśnięty

    jmp color_check
    check_return:

    cmp DX, [brush_size]
        jle no_draw

    cmp DX, 0x0018
        jg draw

    no_draw:

    cmp byte [borrow], 02h
        je draw_color

    return:

    cmp byte [borrow], 01h
        je rewrite

    mov AL, 00h
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

    cmp AL, 00h
        je main_loop

    mov AH, 00h                 ;|
    int 16h                     ;| czyszczenie buforu


;     cmp AL, 's'
;         je save

    ; kod programu
jmp main_loop



; koniec programu
koniec:
mov AX, 2
int 33h

mov AH, 00h     ;|
int 21h         ;| -Koniec programu



; zmiana koloru
color_change:
    mov byte [borrow], 02h
    mov AH, 00h                 ;|
    int 16h                     ;| czyszczenie buforu

    inc byte [color]            ;| zwiększanie wartości color o 1
    jmp main_loop



; rysowanie
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

        cmp byte [borrow2], 01h
            jne back2

        cmp BL, 0
            je palette

        back2:

        cmp BL, 0
            je return

        dec BL

        cmp CX, 0               ;|
            je petla            ;| sprawdzenie lewej krawędzi ekranu

        dec CX                  ;| zmniejszenie CX (kolumny pixela) jeżeli nie jest poza ekranem

        jmp petla

    skok:
        add CX, [brush_size]
        cmp DX, 0x0018          ;|
            je back             ;| sprawdzenie górnej krawędzi ekranu
        dec DX
        jmp back



; zwiększanie pędzla
brush_inc:
    mov byte [borrow], 02h
    mov AH, 00h                 ;|
    int 16h                     ;| czyszczenie buforu

    cmp byte [brush_size], 0xF
        je main_loop

    inc byte [brush_size]       ;|
    jmp main_loop               ;| zwiększanie wielkości pędzla



; zmniejszanie pędzla
brush_dec:
    mov byte [borrow], 02h
    mov AH, 00h                 ;|
    int 16h                     ;| czyszczenie buforu

    cmp byte [brush_size], 1
        je main_loop

    dec byte [brush_size]       ;|
    jmp main_loop               ;| zmniejszanie wielkości pędzla



; rysowanie tła dla wybranego rozmiaru i koloru pędzla
draw_color:
    mov CX, 0x01FF
    mov DX, 0Fh

    push word [color]
    push word [brush_size]

    mov word [color], 00h
    mov word [brush_size], 0Fh

    mov byte [borrow], 01h
    jmp draw



; rysowanie wybranego rozmiaru i koloru pędzla
rewrite:
    mov CX, 0x01FF
    mov DX, 0Fh
    pop word [brush_size]
    pop word [color]
    mov byte [borrow], 00h
    jmp draw



; niedziałająca funkcja zapisywania do pliku
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



; ustawianie koloru
color_check:
    cmp DX, 17h
        jg check_return

    cmp CX, 0x010F
        jg check_return

    mov byte [borrow], 02h
    mov word [color], 0Fh
    cmp CX, 1Fh
        jl check_return

    mov word [color], 00h
    cmp CX, 2Fh
        jl check_return

    mov word [color], 01h
    cmp CX, 3Fh
        jl check_return

    mov word [color], 02h
    cmp CX, 4Fh
        jl check_return

    mov word [color], 03h
    cmp CX, 5Fh
        jl check_return

    mov word [color], 04h
    cmp CX, 6Fh
        jl check_return

    mov word [color], 05h
    cmp CX, 7Fh
        jl check_return

    mov word [color], 06h
    cmp CX, 8Fh
        jl check_return

    mov word [color], 07h
    cmp CX, 9Fh
        jl check_return

    mov word [color], 08h
    cmp CX, 0x00AF
        jl check_return

    mov word [color], 09h
    cmp CX, 0x00BF
        jl check_return

    mov word [color], 0Ah
    cmp CX, 0x00CF
        jl check_return

    mov word [color], 0Bh
    cmp CX, 0x00DF
        jl check_return

    mov word [color], 0Ch
    cmp CX, 0x00EF
        jl check_return

    mov word [color], 0Dh
    cmp CX, 0x00FF
        jl check_return

    mov word [color], 0Eh
    cmp CX, 0x010E
        jl check_return

    jmp check_return


; zmienne
color dw 0Fh
brush_size dw 0Fh
borrow db 02h
borrow2 db 01h
paleta db 01h
filename db "plik.bmp", 0
