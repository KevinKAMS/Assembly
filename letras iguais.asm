WORD_SIZE equ 60
org 0x7c00        ;endereço de memória em que o programa será carregado
jmp 0x0000:start  ;far jump - seta cs para 0
 
hifen db ' - ', 0 ;reserva espaço na memória para a string ' - '
frase1 times WORD_SIZE db 0
buffer times WORD_SIZE db 0

start:
    xor ax, ax  ;zera ax, xor é mais rápido que mov
    mov ds, ax  ;zera ds (não pode ser zerado diretamente)
    mov es, ax  ;zera es
 
    mov di, buffer ;faz di apontar para início de 'buffer'
    mov si, buffer ;faz di apontar para início de 'buffer'

    ;le a string 1
    call ler_string
    ;ve quais caracteres existem na primeira frase
    call store_frase1
    
    ;reseta buffer
    call buffer_reset

    ;le a segunda string
    call ler_string

    ;examina as duas strings
    call examinate

    ;DEBUG
    ;mov si, frase1
    ;call printa_string
 
    jmp done

;check_chars:
;    pusha
    ;aponta o registrador de destino para buffer
;    mov si, buffer


examinate:
    pusha

    ;para começar a procurar do primeiro caractere "visivel" na tabela ascii
    mov cl, 33 ;era 33

    .main:

        ;bl conta as ocorrencias do caractere na palavra 1, e dl na palavra 2
        mov bl, 0
        mov dl, 0

        


        ;vai pro inicio de frase1
        mov si, frase1

        .examinate_1:
            ;coloca o primeiro caractere em al
            lodsb
            ;primeiro, vemos se nao chegamos no final da frase
            cmp al, 0
            ;se chegamos, vamos pra proxima frase
            je .next
            ;senão
            ;ve se al é o que estamos olhando na ascii agora
            cmp al, cl
            ;se nao for, vamos continuar procurando a palavra toda
            jne .examinate_1
            ;se for, incrementamos a contagem de tal caractere na palavra 1
            inc bl
            ;e continuamos procurando
            jmp .examinate_1

        .next:
            mov si, buffer
            jmp .examinate_2

        .examinate_2:
            ;coloca o primeiro caractere em al
            lodsb
            ;primeiro, vemos se nao chegamos no final da frase
            cmp al, 0
            ;se chegamos, vamos processar o que achamos
            je .post_processing
            ;senão
            ;ve se al é o que estamos olhando na ascii agora
            cmp al, cl
            ;se nao for, vamos continuar procurando a palavra toda
            jne .examinate_2
            ;se for, incrementamos a contagem de tal caractere na palavra 2
            inc dl
            ;e continuamos procurando ate o final
            jmp .examinate_2

        .post_processing:
            ;aqui vamos ver o que encontramos nos exames anteriores
            ;primeiro nao vamos perder tempo. se qualquer um dos regs (bl, dl) for zero, nao existem caracteres em comum.
            cmp bl, 0
            je .lastcheck ;voltamos e iniciamos a busca de outro caractere
            cmp dl, 0
            je .lastcheck ;voltamos e iniciamos a busca de outro caractere

            ;se chegamos ate aqui, sabemos que o caractere cl é comum as duas palavras. Vamos mostrá-lo.
            mov al, cl
            mov ah, 0eh ;código da instrução para imprimir um caractere que está em al
            int 10h     ;interrupção de vídeo.

            ;vamos colocar o hifen
            mov si, hifen
            call printa_string

            ;agora vamos comparar os valores.
            sub dl, bl
            ;como o resultado está em dl, vamos ver se é negativo
            cmp dl, 0
            ;se for menor que zero
            jl .abs
            ;senao, continua
                .continue:
                    ;transformamos bl em ascii
                    add dl, 48
                    ;colocamos em al
                    mov al, dl
                    ;printamos
                    mov ah, 0eh ;código da instrução para imprimir um caractere que está em al
                    int 10h     ;interrupção de vídeo.
                    ;agora vamos ver se ja olhamos todos os caracteres

                    ;jmp .done

                    ;pula linha
                    mov AH, 0xe ;Número da chamada
                    mov AL, 10 ;Caractere em ASCII a se escrever
                    mov BH, 0 ;Número da página.
                    int 10h

                    mov AL, 13 ;Caractere em ASCII a se escrever
                    mov BH, 0 ;Número da página.
                    int 10h
                    ;volta

                    jmp .lastcheck

        .abs:
            ;nega o valor negativo
            neg dl
            ;continua
            jmp .continue

        .lastcheck:
            ;vemos se chegamos no fim da tabela ascii
            cmp cl, 126
            ;se sim, acabamos
            je .done

            ;senão, incrementamos cl
            inc cl

            ;e voltamos para a main para repetir o processo
            jmp .main

        .done:
            popa
            ret





store_frase1:
    pusha
    ;coloca o apontador de origem em buffer
    mov si, buffer
    ;coloca o apontador de destino em frase1
    mov di, frase1

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


done:
    jmp $       ;$ = linha atual
 
times 510 - ($ - $$) db 0
dw 0xaa55       ;assinatura de boot