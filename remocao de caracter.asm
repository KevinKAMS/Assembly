WORD_SIZE equ 50
org 0x7c00        ;endereço de memória em que o programa será carregado
jmp 0x0000:start  ;far jump - seta cs para 0
 
msg db 'A string nao contem o caractere ', 0 ;reserva espaço na memória para a string de resposta
buffer times WORD_SIZE db 0
frase times WORD_SIZE db 0
char times WORD_SIZE db 0
frasefinal times WORD_SIZE db 0

 
start:
    xor ax, ax  ;zera ax, xor é mais rápido que mov
    mov ds, ax  ;zera ds (não pode ser zerado diretamente)
    mov es, ax  ;zera es
 
    mov di, buffer ;faz di apontar para início de 'buffer'
    mov si, buffer ;faz di apontar para início de 'buffer'

    ;le a string
    call ler_string
    ;armazena em frase
    call store_frase
    
    ;reseta buffer
    call buffer_reset

    ;le o caractere
    call ler_string
    ;armazena em char
    call store_char

    ;começa a procurar
    call search_and_print_string

    ;reseta buffer
    ;call buffer_reset

    ;DEBUG
    ;mov si, frasefinal
    ;call printa_string
 
    jmp done


ler_string:
    pusha
    .main:
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
        JMP .main

        .done:
            ;pula linha
            mov AH, 0xe ;Número da chamada
            mov AL, 10 ;Caractere em ASCII a se escrever
            mov BH, 0 ;Número da página.
            int 10h
            ;volta
            popa
            ret

store_frase:
    pusha
    ;coloca o apontador de origem em buffer
    mov si, buffer
    ;coloca o apontador de destino em frase
    mov di, frase

    .main:
        ;carrega do buffer em al
        lodsb
        ;carrega al em frase
        stosb
        ;ve se ja chegou no fim do buffer
        cmp al, 0
        je .done ;se chegou, acabou
        ;senao, pega a prox
        jmp .main

        .done:
            popa
            ret
    

store_char:
    pusha
    ;coloca o apontador de origem em buffer
    mov si, buffer
    ;coloca o apontador de destino em char
    mov di, char

    .main:
        ;carrega do buffer em al
        lodsb
        ;carrega al em char
        stosb
        ;ve se ja chegou no fim do buffer
        cmp al, 0
        je .done ;se chegou, acabou
        ;senao, pega a prox
        jmp .main

        .done:
            popa
            ret
    

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

 
printa_string:
    
    lodsb       ;carrega uma letra de si em al e passa para o próximo caractere
    cmp al, 0   ;chegou no final? (equivalente a um \0)
    je .done
 
    mov ah, 0eh ;código da instrução para imprimir um caractere que está em al
    int 10h     ;interrupção de vídeo.

    jmp printa_string ;loop

    .done:
        ;pula linha (removido neste exercicio 4)
        ;mov AH, 0xe ;Número da chamada
        ;mov AL, 10 ;Caractere em ASCII a se escrever
        ;mov BH, 0 ;Número da página.
        ;int 10h

        ;mov AL, 13 ;Caractere em ASCII a se escrever
        ;mov BH, 0 ;Número da página.
        ;int 10h
        ;volta
        
        ret

search_and_print_string:
    pusha
    ;vamos usar dl como uma flag pra ver se achamos alguma coisa ou nao
    mov dl, 0
    mov si, char
    lodsb
    ;agora o caractere "chave" está em cl
    mov cl, al
    ;apontamos para o começo de frase
    mov si, frase
    ;apontamos o reg de destino pra frasefinal
    mov di, frasefinal

    .main:
        ;carregamos a primeira letra da frase em al
        lodsb
        ;comparamos para ver se é o fim da frase
        cmp al, 0
        je .lastcheck ;se for, passamos pra ultima checagem
        cmp al, cl ;senao, comparamos para ver se é a letra que procuramos
        ;se for, dizemos que encontramos a letra
        je .found 
        ;se nao for, carregamos ela em nossa frase final
        stosb
        jmp .main ;e voltamos a procurar

    .found: ;isso serve para setar a flag
        inc dl;incrementamos dl dizendo que achamos a letra
        jmp .main ;voltamos para procurar mais

    .lastcheck:
        ;ultima checagem: se achamos ocorrencias da letra ou nao.
        cmp dl, 0
        ;se dl nao for zero, entao achamos ocorrencias. podemos printar nossa frase final.
        jne .print
        ;se for zero, printamos a msg de erro.
        mov si,msg
        call printa_string
        mov si, char
        call printa_string

        jmp .done

    .print:
        ;se chegamos aqui, vamos printar nossa frase frase final.
        mov si, frasefinal
        call printa_string
        jmp .done

        
    .done:
        popa
        ret


done:
    jmp $       ;$ = linha atual
 
times 510 - ($ - $$) db 0
dw 0xaa55       ;assinatura de boot