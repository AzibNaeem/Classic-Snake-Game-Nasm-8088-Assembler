org 0x100
jmp start

next: db 3
apple: db 0
snake: dw 3,1, 2,1
		times 46 dw -1
way: dw 0,0
matrix: db 1,1,1,1,1,1,1,1,1,0, 1,3,3,3,3,3,3,3,1,0, 1,3,3,3,3,3,3,3,1,0, 1,3,3,3,3,3,3,3,1,0, 1,3,3,3,3,3,3,3,1,0, 1,3,3,3,3,3,3,3,1,0, 1,3,3,3,3,3,3,3,1,0, 1,3,3,3,3,3,3,3,1,0, 1,1,1,1,1,1,1,1,1,0

delay:
    mov cx, 500
outer:
    mov dx, 500
inner:
    dec dx
    jnz inner
    dec cx
    jnz outer
    ret

main:
    call move
    push 0
    push 0
    push 18
    push 1
    push 0
    call draw
    add sp, 10
    call input
    call delay
    jmp main

over:
    mov ah,0
    mov al,3
    int 10h
	
input:
    pop dx
    mov ah, 0x1
    int 0x16
    jz skip
    mov ah, 0x0
    int 0x16
skip:
    cmp ah, 0x4D
    jnz left_check
right:
    mov word [way], 1
    mov word [way+2], 0
    jmp end
left_check:
    cmp ah, 0x4B
    jnz down_check
left:
    mov word [way], -1
    mov word [way+2], 0
    jmp end
down_check:
    cmp ah, 0x50
    jnz up_check
down:
    mov word [way+2], 1
    mov word [way], 0
    jmp end
up_check:
    cmp ah, 0x48
    jnz end
up:
    mov word [way+2], -1
    mov word [way], 0
end:
    push dx
    ret

draw_rect:
    mov bh, 0
    mov bp, sp
    mov ax, word [bp+8]
    mov cx, word [bp+4]
    mov dx, word [bp+2]
    mov si, cx
    add si, word [bp+6]
    mov di, dx
    add di, word [bp+6]
    mov ah, 0xC
rect_y:
    rect_x:
        int 0x10
        inc cx
        cmp cx, si
        jnz rect_x
    mov cx, word [bp+4]
    inc dx
    cmp dx, di
    jnz rect_y
    ret

draw:
    push matrix
draw_loop:
    mov bp, sp
    mov bx, word [bp]
    mov al, [bx]
    cmp al, 1
    jnz check0
        mov word [bp+10], 0
        jmp next_cell
check0:
    cmp al, 0
    jnz c2
        inc word [bp]
        mov ax, word [bp+8]
        inc ax
        add word [bp+4], ax
        mov word [bp+6], 0
        jmp draw_loop
c2:
    cmp al, 2
    jnz c3
        mov word [bp+10], 12
        jmp next_cell
c3:
    cmp al, 3
    jnz check4
        mov word [bp+10], 14
        jmp next_cell
check4:
    cmp al, 4
    jnz check5
        mov word [bp+10], 1
        jmp next_cell
check5:
    mov word [bp+10], 5
next_cell:
    push word [bp+10]
    push word [bp+8]
    push word [bp+6]
    push word [bp+4]
    call draw_rect
    add sp, 8
    mov bp, sp
    inc word [bp+12]
    mov ax, word [bp+8]
    inc ax
    add word [bp+6], ax
    inc word [bp]
    inc word [bp+10]
    cmp word [bp+12], 81
    jnz draw_loop
    add sp, 2
    ret

change:
    pop bp
    mov di, 10
    pop cx
    pop si
    pop ax
mult:
    add si, di
    loop mult
    mov bx, matrix
    mov byte [bx+si], al
    push bp
    ret

check:
    pop bp
    mov di, 10
    pop cx
    pop si
check_loop:
    add si, di
    loop check_loop
    mov bx, matrix
    mov dl, byte [bx+si]
    xor dh, dh
    push dx
    push bp
    ret

draw_snake:
    push 0
snake_loop:
    mov bp, sp
    mov si, word [bp]
    cmp word [snake+si], -1
    jz exit_snake
    push 2
    push word [snake+si]
    push word [snake+si+2]
    call change
    mov bp, sp
    add word [bp], 4
    jmp snake_loop
exit_snake:
    add sp, 2
    ret

place_apple:
place:
    call random
    pop ax
    mov bl, 7
    div bl
    inc ah
    mov al, ah
    xor ah, ah
    mov si, ax
    call random
    pop ax
    mov bl, 7
    div bl
    inc ah
    mov al, ah
    xor ah, ah
    mov di, ax
    push si
    push di
    push si
    push di
    call check
    pop ax
    pop di
    pop si
    cmp ax, 2
    jz place
    push 4
    push si
    push di
    call change
    ret

grow:
    mov bx, snake
    mov cx, 49
find:
    cmp word [bx], -1
    jz add
    add bx, 4
    loop find
add:
    mov si, word [bx-4]
    mov di, word [bx-2]
    mov word [bx], si
    mov word [bx+2], di
    mov byte [apple], 1
    ret

collision:
    mov bp, sp
    push word [bp+4]
    push word [bp+2]
    call check
    pop cx
    cmp cx, 4
    jnz not_apple
    call grow
not_apple:
    cmp cx, 2
    jz over
    ret

move:
    mov si, word [snake]
    add si, word [way]
    cmp si, 0
    mov ax, word [snake]
    mov bx, word [snake+2]
    jnz check1
    pusha
    push 7
    push word [snake+2]
    call collision
    add sp, 4
    popa
    jmp over
check1:
    cmp si, 8
    jnz check2
    pusha
    push 1
    push word [snake+2]
    call collision
    add sp, 4
    popa
    jmp over
check2:
    mov si, word [snake+2]
    add si, word [way+2]
    cmp si, 0
    jnz check3
    pusha
    push word [snake]
    push 7
    call collision
    add sp, 4
    popa
    jmp over
check3:
    cmp si, 8
    jnz move_it
    pusha
    push word [snake]
    push 1
    call collision
    add sp, 4
    popa
    jmp over
move_it:
    mov si, word [way+2]
    cmp si, 0
    jnz moving
    mov si, word [way]
    cmp si, 0
    jz done
moving:
    mov dx, word [way]
    mov si, word [snake]
    add si, dx
    push si
    mov si, word [snake+2]
    mov dx, word [way+2]
    add si, dx
    push si
    call collision
    add sp, 4
    mov ax, word [snake]
    mov bx, word [snake+2]
    mov dx, word [way]
    add word [snake], dx
    mov dx, word [way+2]
    add word [snake+2], dx
next_seg:
    mov si, 4
seg_loop:
    cmp word [snake+si], -1
    jz done
    mov dx, word [snake+si]
    mov di, word [snake+si+2]
    pusha
    push 3
    push word [snake+si]
    push word [snake+si+2]
    call change
    popa
    mov word [snake+si], ax
    mov word [snake+si+2], bx
    cmp word [snake+si+4], -1
    jz done
    mov ax, word [snake+si+4]
    mov bx, word [snake+si+6]
    pusha
    push 3
    push word [snake+si+4]
    push word [snake+si+6]
    call change
    popa
    mov word [snake+si+4], dx
    mov word [snake+si+6], di
    add si, 8
    jmp seg_loop
done:
    call draw_snake
    cmp byte [apple], 1
    jnz nap
    call place_apple
    mov byte [apple], 0
nap:
    ret

random:
    pop bp
    mov al, byte [next]
    mov bl, 9
    mul bl
    add ax, 3
    mov bl, 128
    div bl
    mov byte [next], ah
    xor dx, dx
    mov dl, ah
    push dx
    push bp
    ret

start:
    mov ah, 0x0
    mov al, 0x13
    int 0x10
    mov ah, 0x0
    int 0x1a
    mov byte [next], dl
    call draw_snake
    call place_apple
    jmp main
exit:
    mov ah, 0x0
    mov al, 0x3
    int 0x10
    mov ax, 4Ch
    int 21h