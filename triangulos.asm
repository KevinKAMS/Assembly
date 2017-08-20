WORD_SIZE equ 2

org 0x7c00        ;endereço de memória em que o programa será carregado
jmp 0x0000:start  ;far jump - seta cs para 0
 
;espaço para os lados do triangulo
l1 times WORD_SIZE db 0
l2 times WORD_SIZE db 0
l3 times WORD_SIZE db 0

;frases necessarias
naotriangulo db 'Nao forma triangulo', 13, 10, 0
escaleno db 'Escaleno', 13, 10, 0
isoceles db 'Isoceles', 13, 10, 0
equilatero db 'Equilatero', 13, 10, 0

start:
    xor ax, ax  ;zera ax, xor é mais rápido que mov
    mov ds, ax  ;zera ds (não pode ser zerado diretamente)
    mov es, ax  ;zera es
 

    ;LADO 1
    mov di, l1 ;faz di apontar para início de 'l1'
    ;mov si, l1 ;faz di apontar para início de 'l1'

    ;le o primeiro lado
    call ler_string
    ;leu o primeiro numero e armazenou em l1
    ;mov di, l1
    mov si, l1
    call str_to_int ;
    ;transformou o que tinha em l1 em um inteiro, e armazena em dl
    mov di, l1
    ;mov si, l1
    mov al, dl
    stosb
    ;e salvei em l1, agora o numero em binario, nao mais o caracter


    ;LADO 2
    mov di, l2 ;faz di apontar para início de 'l2'
    ;mov si, l2 ;faz di apontar para início de 'l2'
    ;le o segundo lado
    call ler_string

    ;mov di, l2
    mov si, l2
    call str_to_int
    ;transformou o que tinha em l2 em um inteiro, e armazena em dl
    mov di, l2
    ;mov si, l2
    mov al, dl
    stosb
    ;salva em l2, agora o numero binario, nao mais o caracter


    ;LADO 3
    mov di, l3 ;faz di apontar para início de 'l3'
    ;mov si, l3 ;faz di apontar para início de 'l3'
    ;le o terceiro lado
    call ler_string

    ;mov di, l3
    mov si, l3
    call str_to_int
    ;transformou o que tinha em l3 em um inteiro, e armazena em dl
    mov di, l3
    ;mov si, l3
    mov al, dl 
    stosb
    ;salva em l3, agora o numero binario, nao mais o caracter


    ;---------------------------- calculo para descobrir o triangulo------------------------------

    ;AGORA, temos que testar se os lados formam um triangulo, p/ isso temos que testar se
    ;| l2 - l3 | < l1 < l2 + l3
    ;| l1 - l3 | < l2 < l1 + l3
    ;| l1 - l2 | < l3 < l1 + l2
    jmp e_triangulo?
    ;caso não seja devemos encerrar o programa

    ;caso seja, temos que testar agora, qual triangulo é
    jmp qual_triangulo?

    ;FIM
    jmp done

e_triangulo?:
    ;mov di, l2
    mov si, l2
    lodsb
    mov bl, al
    ;bl guarda l2
    ;mov di, l3
    mov si, l3
    lodsb
    ;al guarda l3
    add bl, al
    ;bl recebe l2+l3
    ;mov di, l1
    mov si, l1
    lodsb
    ;al recebe l1

    cmp al, bl
    jl .continua ;l1<l2+l3
    ;call print_escaleno ;---------------------------------------------------------------------------------
    jmp print_naotriangulo;l1>l2+l3
        .continua:
            ;mov di, l2
            mov si, l2
            lodsb
            mov bl, al
            ;bl recebe l2
            ;mov di, l3
            mov si, l3
            lodsb
            ;al recebe l3
         
                ;subtracao
            
                    sub al,bl ; al= al-bl
                    
                            ;bl recebe resultado da sub
                    mov bl, al
                    
                    ;compara pra ver se é negativo
                    cmp bl, 0
                    
                    jl .modulo ;se for negativo
                    jmp .ok      ;se nao for
                    
                    .modulo:        ;se for negativo, deixa positivo
                        neg bl;
                                        
                    .ok:                ;senao, continua normalmente
                        ;mov di, l1
                        mov si, l1
                    
                        ;al recebe l1
                        lodsb
                      cmp bl,al; compara l3-l2 com l1
                        jl .parte2;l3-l2<l1 condicao satisfeita 
                        ;call print_equilatero ;------------------------------------------------------
                        jmp print_naotriangulo;l3-l2>l1  deu merda

            .parte2:
                ;mov di, l1
                mov si, l1
                lodsb
                mov bl, al

                ;mov di, l3
                mov si, l3
                lodsb

                add bl,al

                ;mov di, l2
                mov si, l2
                lodsb
                cmp al,bl
                jl .continua2
                ;call print_isoceles ;---------------------------------------------------
                jmp print_naotriangulo
                .continua2:
                    ;mov di, l1
                    mov si, l1
                    lodsb
                    mov bl, al

                    ;mov di, l3
                    mov si, l3
                    lodsb
                    cmp bl, al
                    jl .sub21 ;l1<l3 bl<al
                    ;jmp .sub22;l3<l1 al<bl
                    .sub21:
                        sub al,bl
                        mov bl, al
                      
                       ;compara pra ver se é negativo
                    cmp bl, 0
                    
                    jl .modulo2 ;se for negativo
                    jmp .ok2      ;se nao for
                    
                    .modulo2:        ;se for negativo, deixa positivo
                        neg bl;
                                        
                    .ok2:                ;senao, continua normalmente
                        ;mov di, l1
                        mov si, l1
                      
                        ;mov di, l2
                        mov si, l2
                        lodsb
                        cmp bl,al
                        jl .parte3
                        jmp print_naotriangulo

                .parte3:
                ;mov di, l1
                mov si, l1
                lodsb
                mov bl, al

                ;mov di, l2
                mov si, l2
                lodsb

                add bl,al

                ;mov di, l3
                mov si, l3
                lodsb
                cmp al,bl
                jl .continua3
                jmp print_naotriangulo
                .continua3:
                    ;mov di, l1
                    mov si, l1
                    lodsb
                    mov bl, al

                    ;mov di, l2
                    mov si, l2
                    lodsb
                    cmp bl, al
                    jl .sub31 ;l1<l2 bl<al
                    ;jmp .sub32;l2<l1 al<bl
                    .sub31:
                    sub al,bl
                    mov bl, al
                    
                     ;compara pra ver se é negativo
                    cmp bl, 0
                    
                    jl .modulo3 ;se for negativo
                    jmp .ok3     ;se nao for
                    
                    .modulo3:        ;se for negativo, deixa positivo
                        neg bl;
                                        
                    .ok3:                ;senao, continua normalmente
                        ;mov di, l1
                        mov si, l1
                    
                    ;mov di, l3
                    mov si, l3
                    lodsb
                    cmp bl,al
                    jl  qual_triangulo?
                    jmp print_naotriangulo
                    
  ;| l2 - l3 | < l1 < l2 + l3   
    ;| l1 - l3 | < l2 < l1 + l3
    ;| l1 - l2 | < l3 < l1 + l2



print_naotriangulo:
        ;mov di, naotriangulo
        mov si, naotriangulo
        call printa_string
        ret

qual_triangulo?:

        .l1_igual_l2:         ;Vamos testar se o lado 1 é igual o lado 2
            ;mov di, l1
            mov si, l1
            lodsb       ;carrega o lado 1 em al
            mov bl, al  ;reserva o lado 1 em bl
            ;mov di, l2
            mov si, l2
            lodsb       ;carrega o lado 2 em al
            cmp al, bl  ;compara o lado 1 com o 2
            je .l1_dif_l3? ;se o lado 1 for igual ao lado 2, comparamos agora se ele é diferente ao lado 3,
                        ;se for diferente, ele é isoceles ((l1 = l2) != l3)
                        ;se não for diferente, ele é equilatero (l1 = l2 = l3)
            jne .l1_igual_l3? ;se o lado 1 for diferente do lado 2, comparamos agora se ele é igual ao lado 3,
                        ;se for igual, ele é isoceles ((l1 = l3) != l2)
                        ;se não for igual, ele pode ser escaleno (l1 != l2 != l3)
                        ;ou pode ser isoceles (l1 != (l2 = l3))

        .l1_dif_l3?:        ;vamos testar se o lado 1 é diferente do lado 3
            ;mov di, l1
            mov si, l1
            lodsb       ;carrega o lado 1 em al
            mov bl, al  ;reserva o lado 1 em bl
            ;mov di, l3
            mov si, l3
            lodsb       ;carrega o lado 3 em al
            cmp al, bl  ;compara o lado 1 com o 3
            jne print_isoceles  ;((l1 = l2) != l3)
            jmp print_equilatero;(l1 = l2 = l3)

        .l1_igual_l3?:         ;vamos testar se o lado 1 é igual ao lado 3
            ;mov di, l1
            mov si, l1
            lodsb       ;carrega o lado 1 em al
            mov bl, al  ;reserva o lado 1 em bl
            ;mov di, l3
            mov si, l3
            lodsb       ;carrega o lado 2 em al
            cmp al, bl  ;compara o lado 1 com o 2
            je print_isoceles   ;((l1 = l3) != l2)
            jne .l2_igual_l3?         ;ele ainda pode ser isoceles ou escaleno

        .l2_igual_l3?:         ;testa se o lado 2 é igual ao lado 3
            ;mov di, l2
            mov si, l2
            lodsb       ;carrega o lado 1 em al
            mov bl, al  ;reserva o lado 1 em bl
            ;mov di, l3
            mov si, l3
            lodsb       ;carrega o lado 2 em al
            cmp al, bl  ;compara o lado 1 com o 2
            je print_isoceles   ;(l1 != (l2 = l3))
            jne print_escaleno  ;(l1 != l2 != l3)

print_isoceles:
        ;mov di, isoceles
        mov si, isoceles
        call printa_string
        ret

print_escaleno:
        ;mov di, escaleno
        mov si, escaleno
        call printa_string
        ret

print_equilatero:
        ;mov di, equilatero
        mov si, equilatero
        call printa_string
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

 
done:
    jmp $       ;$ = linha atual
 
times 510 - ($ - $$) db 0
dw 0xaa55       ;assinatura de boot