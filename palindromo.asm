WORD_SIZE equ 50
org 0x7c00        ;endereço de memória em que o programa será carregado
jmp 0x0000:start  ;far jump - seta cs para 0
 
msg1 db 'Palindroma', 0 ;reserva espaço na memória para a string de resposta
msg2 db 'Nao e Palindroma', 0 ;reserva espaço na memória para a string de resposta

buffer times WORD_SIZE db 0
palavra times WORD_SIZE db 0
palavrainvertida times WORD_SIZE db 0

 
start:
    xor ax, ax  ;zera ax, xor é mais rápido que mov
    mov ds, ax  ;zera ds (não pode ser zerado diretamente)
    mov es, ax  ;zera es
 
    mov di, buffer ;faz di apontar para início de 'buffer'
    mov si, buffer ;faz di apontar para início de 'buffer'

    ;le a string
    call ler_string
    ;armazena em frase
    call GuardarEmPalavra
    ;armazena em char
    call GuardarEmPalavraInvertida

    ;começa a procurar
    call is_palindromo

    ;reseta buffer
    ;call buffer_reset

    ;DEBUG
    ;mov si, frasefinal
    ;call printa_string
 
    jmp done

ler_string:
    
    .main:
        mov dl, 0 ;contador para o tamanho da palavra
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
        inc dl
        ;senao, salva e le a prox
        stosb
        JMP .main

        .done:
            ;pula linha
            mov AH, 0xe ;Número da chamada
            mov AL, 10 ;Caractere em ASCII a se escrever
            mov BH, 0 ;Número da página.
            int 10h
            ;volta
            
            ret

GuardarEmPalavra:
    pusha
    ;coloca o apontador de origem em buffer
    mov si, buffer
    ;coloca o apontador de destino em palavra
    mov di, palavra

    .main:
        ;carrega do buffer em al
        lodsb
        ;carrega al em palavra
        stosb
        ;ve se ja chegou no fim do buffer
        cmp al, 0
        je .done ;se chegou, acabou
        ;senao, pega a prox
        jmp .main

        .done:
            popa
            ret

GuardarEmPalavraInvertida:
    
    ;coloca o apontador de origem em buffer
    ;mov si, buffer
    ;coloca o apontador de destino em palavrainvertida
    mov di, palavrainvertida
    mov cx, dx

    std
    lodsb
    lodsb
    dec cx

    .main:
        ;carrega do buffer em al
        lodsb
        ;carrega al em palavrainvertida
        stosb
        ;ve se ja chegou no fim do buffer
        cmp al, 0
        je .done ;se chegou, acabou
        ;senao, pega a prox
        jmp .main

    loop .main


        .done:
        
            ret

printa_string:
    
    lodsb       ;carrega uma letra de si em al e passa para o próximo caractere
    cmp al, 0   ;chegou no final? (equivalente a um \0)
    je .done
 
    mov ah, 0eh ;código da instrução para imprimir um caractere que está em al
    int 10h     ;interrupção de vídeo.

    jmp printa_string ;loop

    .done:
        ;pula linha (removido neste exercicio 4)
        mov AH, 0xe ;Número da chamada
        mov AL, 10 ;Caractere em ASCII a se escrever
        mov BH, 0 ;Número da página.
        int 10h

        mov AL, 13 ;Caractere em ASCII a se escrever
        mov BH, 0 ;Número da página.
        int 10h
        ;volta
        
        ret

is_palindromo:
    pusha

    mov si, palavra
    lodsb
    ;agora o caractere esta em cl
    mov cl, al
    mov bx, si
    ;apontamos para o começo da palavrainvertida
    mov si, palavrainvertida
    lodsb; carrega em al o primeiro caractere
    mov dx, si
    
    cmp cl,al

    jne .NaoEhP
    jmp .main

    .main:
        mov si, bx
        lodsb
        ;agora o caractere esta em cl
        mov cl, al
        mov bx, si
        mov si, dx
        lodsb; carrega em al o primeiro caractere
        mov dx, si
    
        cmp al, 0
        je .EhP
        cmp cl,al
        jne .NaoEhP
        jmp search_and_print_string

    .NaoEhp:
        mov si, msg2
        call printa_string
        jmp done

    .Ehp:
        mov si, msg1
        call printa_string
        jmp done




done:
    jmp $       ;$ = linha atual
 
times 510 - ($ - $$) db 0
dw 0xaa55       ;assinatura de boot