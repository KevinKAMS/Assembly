WORD_SIZE equ 100

org 0x7c00        ;endereço de memória em que o programa será carregado
jmp 0x0000:start  ;far jump - seta cs para 0
 
;hello db 'Hello, World!', 13, 10, 0 ;reserva espaço na memória para a string
buffer times WORD_SIZE db 0

start:
    xor ax, ax  ;zera ax, xor é mais rápido que mov
    mov ds, ax  ;zera ds (não pode ser zerado diretamente)
    mov es, ax  ;zera es
 
    mov di, buffer ;faz di apontar para início de 'buffer'
    mov si, buffer ;faz di apontar para início de 'buffer'

    ;le o primeiro numero
    call ler_string
    ;call printa_string
    call str_to_int
    ;guarda o valor em ch
    mov ch,dl

    ;limpa buffer
    call buffer_reset

    ;le segundo numero
    call ler_string
    ;call printa_string
    call str_to_int

    ;soma os numeros
    add dl, ch

    call int_to_str
    call print_backwards
   ; call printa_string

    call buffer_reset



    ;FIM
    jmp done

buffer_reset:
    pusha
    mov di, buffer ;faz di apontar para início de 'buffer'
    mov si, buffer

    mov cx, WORD_SIZE
    zeragem:
        mov AL, 0
        stosb
    loop zeragem

    mov di, buffer ;faz di apontar para início de 'buffer'
    mov si, buffer
    popa
    ret

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

printa_string:
    
    lodsb       ;carrega uma letra de si em al e passa para o próximo caractere
    cmp al, 0   ;chegou no final? (equivalente a um \0)
    je .done
 
    mov ah, 0eh ;código da instrução para imprimir um caractere que está em al
    int 10h     ;interrupção de vídeo.

    jmp printa_string ;loop

    .done:
        ;pula linha
        mov AH, 0xe ;Número da chamada
        mov AL, 10 ;Caractere em ASCII a se escrever
        mov BH, 0 ;Número da página.
        int 10h

        mov AL, 13 ;Caractere em ASCII a se escrever
        mov BH, 0 ;Número da página.
        int 10h
        ;volta
        
        ret

str_to_int:
    mov di, buffer ;faz di apontar para início de 'buffer'
    mov si, buffer ;faz di apontar para início de 'buffer'
    mov dl, 0

    ;pega digito de buffer e coloca em AL
    lodsb
    cmp al, 0 ;ve se é \0

    je .done ;se for, acabou a palavra
    jmp .main

    .main:
        ;passa de ascii para binario
        sub al, 48

        ;move o numero pro registrador dx
        add dl, al

        lodsb

        cmp al, 0; ve se é \0

        je .done

        mov dh, al ;salva o que esta em al em dh
        mov ah, 0  ;prepara pra multiplicacao
        mov al, dl ;o digito que será multiplicado é o que está em dl
        mov cl, 10 ;preparo o multiplicador como cl
        mul cl     ;multiplico por 10 e deixo o resultado em ax
        mov dl, al ;ponho o resultado multipĺicado por 10 em dl
        mov al, dh ;delvovo o numero de dh em al

    jmp .main

    .done:
        ret

int_to_str:
    mov di, buffer ;faz di apontar para início de 'buffer'
    mov si, buffer ;faz si apontar para início de 'buffer'

    mov dh, 0  ;garante que dh seja zero para poder dividir dl
    mov ax, dx ;move o dl para o ax para fazer a divisão

    .main:
        mov cl, 10 ;cl é o divisor
        div cl     ;divide o que está em ax, pondo o resto em ah e o quociente em al

        xchg ah, al;troco o que tá em al e em ah
        add al, 48 ;transformo o int que está em al em um char

        stosb
        
        cmp ah, 0  ;condição de parada

        mov al, ah ;faz com que ax trabalhe com o que sobrou do numero
        mov ah, 0  ;zera ah, para garantir a segurança

        je .done
        jmp .main

    .done:
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