org 0x100
jmp start

next: db 3
apple: db 0
;Initializzed the snake body
snake: dw 3,1, 2,1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1 , -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1 ,-1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1, -1,-1
way: dw 0,0
score: dw 0
score_msg: db 0Dh, 0Ah, "Score: ", 0
;Template for the snake to play the game 
temp_matrix: db 1,1,1,1,1,1,1,1,1,0, 1,3,3,3,3,3,3,3,1,0, 1,3,3,3,3,3,3,3,1,0, 1,3,3,3,3,3,3,3,1,0, 1,3,3,3,3,3,3,3,1,0, 1,3,3,3,3,3,3,3,1,0, 1,3,3,3,3,3,3,3,1,0, 1,3,3,3,3,3,3,3,1,0, 1,1,1,1,1,1,1,1,1,0
matrix: db 1,1,1,1,1,1,1,1,1,0, 1,3,3,3,3,3,3,3,1,0, 1,3,3,3,3,3,3,3,1,0, 1,3,3,3,3,3,3,3,1,0, 1,3,3,3,3,3,3,3,1,0, 1,3,3,3,3,3,3,3,1,0, 1,3,3,3,3,3,3,3,1,0, 1,3,3,3,3,3,3,3,1,0, 1,1,1,1,1,1,1,1,1,0
msg: db "   Press 1 to Restart or 0 to Exit.", 0
;Adding Delay of 500 ms
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
;Pushing the starting x,y, color, drawing main game board then clearing teh stack, then taking input
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
; game over
over:
    mov ah,0
    mov al,3
    int 10h
;For printing score
show:
    call print
;for printing the restart or exit menu
show_msg:
    mov ah,0Eh
    mov si, msg
;loads next character, checks for null, if end then waits for input then prints
loop_msg:
    lodsb
    or al,al
    je waits
    int 10h
    jmp loop_msg
;wait for player input, 1 for restart, 0 for exit
waits:
    mov ah,0
    int 16h
    cmp al,'1'
    je restart
    cmp al,'0'
    je exit
    jmp waits
;restores the original values in the labels for restarting the game
restart:
    mov al, 0
    mov [apple], al
    xor ax, ax
    mov [way], ax
    mov [way+2], ax
    mov al, 3
    mov [next], al
    mov word [score], 0
    mov di, snake
    mov word [di], 3
    mov word [di+2], 1
    mov word [di+4], 2
    mov word [di+6], 1
    mov cx, 47
    lea di, [snake+8]
    mov ax, -1
;resets the board for playing the game
reset:
    mov [di], ax
    add di, 2
    loop reset
    lea si, [temp_matrix]
    lea di, [matrix]
    mov cx, 90
;loads the matrix for playing the game after reset
copy:
    mov al, [si]
    mov [di], al
    inc si
    inc di
    loop copy
    jmp start
;gets inout and saves the return address
input:
    pop dx
    mov ah, 0x1
    int 0x16
    jz skip
    mov ah, 0x0
    int 0x16
;Right check
skip:
    cmp ah, 0x4D
    jnz left_check
;+1 in x and y = 0 as moving right 
right:
    mov word [way], 1
    mov word [way+2], 0
    jmp end
;left check
left_check:
    cmp ah, 0x4B
    jnz down_check
;-1 in x and 0 in y as moving left
left:
    mov word [way], -1
    mov word [way+2], 0
    jmp end
;down check
down_check:
    cmp ah, 0x50
    jnz up_check
;x is 0 and y +1 as moves down
down:
    mov word [way+2], 1
    mov word [way], 0
    jmp end
;up check
up_check:
    cmp ah, 0x48
    jnz end
;y is -1 and x is 0
up:
    mov word [way+2], -1
    mov word [way], 0
end:
    push dx
    ret
;draws rectanle by getting colors, and caalculating right and bottom edges
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
;checking and filling pixels to the bottom edge
rect_y:
;checking and filling pixels to the right edge
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
;drawing the main game board
draw:
    push matrix
;draws the game board cell by cell by getting, loading, and setting color
draw_loop:
    mov bp, sp
    mov bx, word [bp]
    mov al, [bx]
    cmp al, 1
    jnz check0
    mov word [bp+10], 15
    jmp next_cell
;check for boundaries
check0:
    cmp al, 0
    jnz c2
    inc word [bp]
    mov ax, word [bp+8]
	inc ax
	add word [bp+4], ax
	mov word [bp+6], 0
	jmp draw_loop
;check for snake
c2:
    cmp al, 2
    jnz c3
    mov word [bp+10], 12
    jmp next_cell
;check for empty
c3:
    cmp al, 3
    jnz check4
	mov word [bp+10], 14
	jmp next_cell
;check for food
check4:
    cmp al, 4
    jnz check5
	mov word [bp+10], 1
	jmp next_cell
;default color check
check5:
    mov word [bp+10], 5
;drawing all the cells after pushing their characteristics and comparing with the total size
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
;changing the cell value
change:
    pop bp
    mov di, 10
    pop cx
    pop si
    pop ax
;calculating row offset then mult y with by that
mult:
    add si, di
    loop mult
    mov bx, matrix
    mov byte [bx+si], al
    push bp
    ret
;getting vals
check:
    pop bp
    mov di, 10
    pop cx
    pop si
;calculating row offset then mult y with by that, clearing higher byte of dx and then saving the val
check_loop:
    add si, di
    loop check_loop
    mov bx, matrix
    mov dl, byte [bx+si]
    xor dh, dh
    push dx
    push bp
    ret
;drawing snake by initializing index
draw_snake:
    push 0
;setting up stack and then checking for segment end
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
;clean up stack
exit_snake:
    add sp, 2
    ret
;to place new food
place_apple:
;checks x and y from 1-7 if occupied through check then jumps to place again if empty then calls change to place apple
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
;First checks the total size, after that finds empty in snake_str marked as -1, copies x and y to that that spot then generates
;apple and then update's score
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
    mov ax, [score]
    add ax, 10
    mov [score], ax
    ret
;checks x and y to see where the head is and then checks if its apple then grow otherwise see's if its a wall or head
collision:
    mov bp, sp
    push word [bp+4]
    push word [bp+2]
    call check
    pop cx
    cmp cx, 4
    jnz not_apple
    call grow
;to check if its the snake itself -'2', then gameover
not_apple:
    cmp cx, 2
    jz over
    ret
;Checks snake's y ie head and then adds to si then compares with the wall coordinates first with upper wall
move:
    mov si, word [snake]
    add si, word [way]
    cmp si, 0 ; upper wall
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
;To see if snake hit bottom wall
check1:
    cmp si, 8 ; lower wall
    jnz check2
    pusha
    push 1
    push word [snake+2]
    call collision
    add sp, 4
    popa
    jmp over
;Now adds x coordinate to see if it hits the left wall
check2:
    mov si, word [snake+2]
    add si, word [way+2]
    cmp si, 0; left wall
    jnz check3
    pusha
    push word [snake]
    push 7
    call collision
    add sp, 4
    popa
    jmp over
;Now adds x coordinate to see if it hits the right wall
check3:
    cmp si, 8; right wall
    jnz move_it
    pusha
    push word [snake]
    push 1
    call collision
    add sp, 4
    popa
    jmp over
;check if the snake is moving by storing x and y coordinates, if x and y are zero means no coordinates jump to done
move_it:
    mov si, word [way+2]
    cmp si, 0
    jnz moving
    mov si, word [way]
    cmp si, 0
    jz done
;calculates next head pos then checks for collision with apple or wall or itself otherwise move the snake
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
;start at offset 4 as snake's head and body is at 0 and 2
next_seg:
    mov si, 4
;checks if reached -1 ie snake end, saves the segments for later, then pushes registers as we cahnge them later.
;update the current segment with old x and yie for following the head then checks if snake has ended then repeats
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
;redraw the snake, if apple is 1 then place a new apple and if 0 then return
done:
    call draw_snake
    cmp byte [apple], 1
    jnz nap
    call place_apple
    mov byte [apple], 0
nap:
    ret
;gets the next label to multiply by 9 then adds 3 for making it odd then mods by 128 so the rng will be between 0-127
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
;To print the score 
print:
    mov ah, 0Eh
    mov si, score_msg
score_loop:
    lodsb
    or al, al
    je show_score
    int 10h
    jmp score_loop
;coverts the digits as hund, ten, units by dividing by specific numbers and then directly prints using int 10h
show_score:
    mov ax, [score]
    xor dx, dx
    mov cx, 100
    div cx
    add al, '0'
    mov ah, 0Eh
    int 10h
    mov ax, dx
    xor dx, dx
    mov cx, 10
    div cx
    add al, '0'
    mov ah, 0Eh
    int 10h
    mov al, dl
    add al, '0'
    mov ah, 0Eh
    int 10h
    ret
;sets to graphics mode, then calls functions
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