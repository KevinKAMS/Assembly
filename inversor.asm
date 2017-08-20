WORD_SIZE equ 1000

org 0x7c00        ;endereço de memória em que o programa será carregado
jmp 0x0000:start  ;far jump - seta cs para 0
 
;hello db 'Hello, World!', 13, 10, 0 ;reserva espaço na memória para a string
buffer times WORD_SIZE db 0

start:
    xor ax, ax  ;zera ax, xor é mais rápido que mov
    mov ds, ax  ;zera ds (não pode ser zerado diretamente)
    mov es, ax  ;zera es
 
    mov di, buffer ;faz di apontar para início de 'buffer'
    mov si, buffer ;faz si apontar para início de 'buffer'

    ;le a string
    call ler_string


    ;volta o ponteiro pro começo da string
    mov di, buffer
    mov si, buffer

    ;imprime ao contrario
    call print_backwards




    ;FIM
    jmp done

ler_string:
    
    ;ler do teclado
    MOV AH, 0
    INT 16H

    ;mostra o que esta sendo digitado
    mov AH, 0xe ;Número da chamada
    mov BH, 0 ;Número da página.
    int 10h

    ;verifica se foi \n
    CMP AL, 0dh
    ;se foi, acabou
    JE .done

    ;senao, salva e le a prox
    stosb
    JMP ler_string

    .done:
        ;pula linha
        mov AH, 0xe ;Número da chamada
        mov AL, 10 ;Caractere em ASCII a se escrever
        mov BH, 0 ;Número da página.
        int 10h
        ;volta
        
        ret

print_backwards:
    mov di, buffer ;faz di apontar para início de 'buffer'
    mov si, buffer ;faz si apontar para início de 'buffer'
    mov cx, 0

    .main:          ;Vai até o fim da palavra dentro do buffer
        lodsb
        inc cx      ;incrementa o contador de letras no buffer
        cmp al, 0
        jne .main   ;Se não chegar no fim, repete, se chegar...
        std         ;Muda a posição da flag para decrementar cada vez que lê
        lodsb       ;Decrementa dois para que o ponteiro aponte o proximo como numero
        lodsb
        dec cx      ;decrementa o contador
        jmp .print

    .print:         ;imprimi o caracter atual

        lodsb      
        mov ah, 0eh ;código da instrução para imprimir um caractere que está em al
        int 10h     ;interrupção de vídeo.

    loop .print     ;um loop para printrar 'cx' letras, de trás pra frente
        jmp .done


    .done:
        cld         ;reseta a flag
        ret



 
done:
    jmp $       ;$ = linha atual
 
times 510 - ($ - $$) db 0
dw 0xaa55       ;assinatura de boot