org 0x7c00        ;endereço de memória em que o programa será carregado
jmp 0x0000:start  ;far jump - seta cs para 0
 
;hello db 'Hello, World!', 13, 10, 0 ;reserva espaço na memória para a string
 
start:
    xor ax, ax  ;zera ax, xor é mais rápido que mov
    mov ds, ax  ;zera ds (não pode ser zerado diretamente)
    mov es, ax  ;zera es
 
    ;mov si, hello ;faz si apontar para início de 'hello'
    ;call print_string

    call show_background
    call show_big_square
    call show_medium_square
    call show_small_rectangle
 
    jmp done

show_background:
    mov ah, 0   ;numero da chamada
    mov al, 12h ;modo de video VGA
    int 10h

    mov ah, 0xb ;numero da chamada
    mov bh, 0   ;id da paleta
    mov bl, 10  ;cor desejada (branco)
    int 10h

    ret

show_big_square:

    ;seta posicao inicial do quadrado
    mov dx, 50
    mov cx, 75

    .main:
        ;para printar as linhas horizontais
        .printx:
            mov ah, 0ch ;pixel na coordenada [dx, cx]
            mov bh, 0
            mov al, 4 ;cor do pixel (vermelho)
            int 10h
            inc cx

            cmp cx, 225
            je .printy
            jmp .printx

        ;para descer a linha (incrementar dx)
        .printy:
            mov cx, 75
            inc dx
            cmp dx, 200
            je .done
            jmp .printx

            .done:
                ret


show_medium_square:

    ;seta posicao inicial do quadrado
    mov dx, 100
    mov cx, 400

    .main:
        ;para printar as linhas horizontais
        .printx:
            mov ah, 0ch ;pixel na coordenada [dx, cx]
            mov bh, 0
            mov al, 1 ;cor do pixel (azul)
            int 10h
            inc cx

            cmp cx, 525
            je .printy
            jmp .printx

        ;para descer a linha (incrementar dx)
        .printy:
            mov cx, 400
            inc dx
            cmp dx, 225
            je .done
            jmp .printx

            .done:
                ret

show_small_rectangle:

    ;seta posicao inicial do retangulo
    mov dx, 225
    mov cx, 300

    .main:
        ;para printar as linhas horizontais
        .printx:
            mov ah, 0ch ;pixel na coordenada [dx, cx]
            mov bh, 0
            mov al, 14 ;cor do pixel (bege)
            int 10h
            inc cx

            cmp cx, 400
            je .printy
            jmp .printx

        ;para descer a linha (incrementar dx)
        .printy:
            mov cx, 300
            inc dx
            cmp dx, 375
            je .done
            jmp .printx

            .done:
                ret


 
;print_string:
;    lodsb       ;carrega uma letra de si em al e passa para o próximo caractere
;    cmp al, 0   ;chegou no final? (equivalente a um \0)
;    je .done
;
;  mov ah, 0eh ;código da instrução para imprimir um caractere que está em al
;    int 10h     ;interrupção de vídeo.
; 
;    jmp print_string ;loop
; 
;    .done:
;        ret     ;retorna para o start
 
done:
    jmp $       ;$ = linha atual
 
times 510 - ($ - $$) db 0
dw 0xaa55       ;assinatura de boot