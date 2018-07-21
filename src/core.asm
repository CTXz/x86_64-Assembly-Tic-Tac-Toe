; Copyright (c) 2018 Patrick Pedersen <ctx.xda@gmail.com>
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
;
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

; Author      : Patrick Pedersen
; Description : A memory optimized tic-tac-toe core operating on a 18 bit grid

; A 3x3 tic-tac-toe grid consits of a total of 9 fields, where each field can maintain
; a total of three different states:

; - Empty
; - Circle
; - Cross

; The least required amount of bits to display three different states is two.
; As a result, we can create a very primitive 2 bit data structure that represents
; a single tic-tac-toe field:

; ---------------------------
; | bool cross | bool Empty |
; ---------------------------

; Possible states:

; 00 - Empty
; 10 - Empty
; 01 - Circle
; 11 - Cross

; The low/right bit defines whether the field is empty or not.
; The left/hight bit defines whether the field is filled with a cross or circle

; Using a primitive data structure as such, we may create a 1 dimensional 18 bit wide
; tic-tac-toe grid. The lowest two bits are mapped to the top left field and the
; highest two bits are mapped to the bottom right field

; The following one dimensional grid:
; 010111001111010011

; Would translate into the following 2d grid:
; X |   | O
; --|---|--
; X | X |
; --|---|--
; X | O | O

; A field is set through OR operations using bit masks.
; The following example sets the top left field to X:

; OR
; 000000000000000000
; 000000000000000011
; =
; 000000000000000011

; In assembly, the operation above would translate to the following instruction
; XOR ebx, ebx
; OR  ebx, 0x30000

; To fetch the state of a field, the AND operator comes in handy.
; The following example fetches the state of the first field:

; AND
; 000000000000000011
; 000000000000000011
; =
; 000000000000000011

; In assembly, the operation above would translate to the following instruction
; AND  ebx, 0x30000

section .data

section .bss

  ; Reserve 24 bits for field and turn counter
  grid: resd 0x1

section .text

  global init_grid
  global eval_grid

  global set_field
  global get_field

  ; init_grid
  ; ---------------------------------------------------------
  ; C Call: void init_grid()
  ; ---------------------------------------------------------
  ; Description:
  ; Initializes/Empties the tic-tac-toe field
  ; ---------------------------------------------------------

  init_grid:

  lea rax, [rel grid]
  mov [rax], dword 0x0

  ret

  ; field_index
  ; ---------------------------------------------------------
  ; Parameters:
  ; RDI       - x cordinates of field
  ; [RE]C[XL] - y cordinates of field
  ; ---------------------------------------------------------
  ; [RE]AX:
  ; Poisition of the field bit pair in the 1d grid
  ; corresponding to the provided 2d cords.
  ; ---------------------------------------------------------
  ; Description:
  ; Computes the index of the field bit pair in the 1d grid
  ; corresponding to the field at position (x, y) in the 2d
  ; grid
  ;
  ; offset = 3 * y + x
  ; ---------------------------------------------------------

  field_index:

  xor rax, rax                  ; Clear RAX
  jecxz .addition               ; Skip multiplication if y == 0

  mov   rax, 0x3
  mul   cl

  .addition:
  add   rax, rdi

  ret

  ; set_field
  ; ---------------------------------------------------------
  ; C Call: void set_field(uint8_t x, uint8_t y, bool state)
  ; ---------------------------------------------------------
  ; Parameters:
  ;  uint8_t x     - x cordinates of field    | RDI
  ;  uint8_t y     - y cordinates of field    | RSI
  ;  bool state    - Circle - 0 | Cross - 1   | RDX
  ; ---------------------------------------------------------
  ; Description:
  ; Set the state of a tic-tac-toe field
  ; ---------------------------------------------------------

  set_field:

  ; Stash registers

  push  rax
  push  rbx
  push  rcx

  ; Prepare registers

  mov   rbx, 0x1                ; Prepare for exponential

  ; Calculate index

  mov   rcx, rsi
  call  field_index             ; offset = 3 * cl + rdi
  jz    .check_shape            ; (0, 0), skip exponential

  ; Calculate OR operand to set field

  .power:
  lea   ebx, [ebx * 4]          ; Calculate 4^n
  dec   eax
  jnz   .power

  ; Check if we're dealing with a cross or circle

  .check_shape:
  cmp   edx, 0x0                ; cross == false
  jz    .circle

  .cross:
  mov   eax, 0x3                ; start = 3
  jmp   .multiplication

  .circle:
  mov   eax, 0x1                ; start = 1

  .multiplication:
  mul   ebx                     ; EAX = EAX * EBX | operand = start * (4^n)

  ; Set field

  lea   rbx, [rel grid]         ; Fetch grid
  or    dword [rbx], eax        ; Apply OR operation

  ; Restore registers

  pop   rcx
  pop   rbx
  pop   rax

  ret

  ; get_field
  ; ---------------------------------------------------------
  ; C Call: uint8_t get_field(uint8_t x, uint8_t y)
  ; ---------------------------------------------------------
  ; Parameters:
  ;  uint8_t x     - x cordinates of field    | EDI
  ;  uint8_t y     - y cordinates of field    | ESI
  ; ---------------------------------------------------------
  ; RAX:
  ; 0 - Cross
  ; 1 - Circle
  ; 2 - Empty
  ; ---------------------------------------------------------
  ; Description:
  ; Retrieve the state of a tic-tac-toe field
  ; ---------------------------------------------------------

  get_field:

  ; Stash registers

  push  rbx
  push  rcx

  ; Calculate index

  mov   rcx, rsi
  call  field_index
  mov   ebx, 0x1
  jz    .multiplication

  ; Calculate AND operand to test grid for field

  .power:
  lea   ebx, [ebx * 4]          ; Calculate 4^n
  dec   eax
  jnz   .power

  .multiplication:
  mov   eax, 0x3
  mul   ebx

  ; Test Field

  lea   rbx, [rel grid]         ; Fetch grid
  and   eax, dword [rbx]        ; Compare grid to bit maks and store result in EAX

  ; Return if field is empty

  jnz   .modulo
  mov   rax, 0x2                ; Return 2, field is empty
  jmp   .return

  ; Get modulo

  .modulo:
  mov   ebx, 0x3
  div   ebx                     ; EDX = eax % ebx

  mov   rax, rdx                ; Move modulo to eax

  ; Restore registers

  .return:
  pop  rcx
  pop  rdx

  ret

  ; eval_grid
  ; ---------------------------------------------------------
  ; C Call: bool eval_grid(bool cross)
  ; ---------------------------------------------------------
  ; Parameters:
  ;  bool state - Circle - 0, Cross - 1 | RDI
  ; ---------------------------------------------------------
  ; RAX:
  ; 0  - Player hasn't won yet or didn't win!
  ; !0 - Player won!
  ; ---------------------------------------------------------
  ; Description:
  ; Evaluates if the player for bool state has won the game
  ; ---------------------------------------------------------

  eval_grid:

  ; Stash registers

  push  rbx
  push  rcx
  push  rdx
  push  rsi
  push  rbp

  ; Load grid into edx

  lea   rdx, [rel grid]   ; Obtain position independent address (PIC) grid address
  mov   edx, dword [rdx]  ; Load grid into edx

  ; Horizontal

  mov   rsi, 0x3f         ; AND operator for horizontal testing
  mov   rcx, 0x6          ; Required shifts to test with AND operator

  ; Test first arg for X or O

  test   edi, edi         ; edi == false
  je    .horizontal_circle

  ; Cross
  mov   rax, 0x3f
  jmp   .test_grid

  ; Circle
  .horizontal_circle:
  mov   rax, 0x15

  ; Test grid

  .test_grid:

  ; Test for each row

  mov   rbp, 0x3

  .test_row:
  mov   rbx, rsi          ; Make mutable duplicate of AND operator
  and   ebx, edx          ; Test fields
  cmp   rbx, rax          ; Check for victory
  je    .win
  ror   edx, cl          ; Shift grid so that the last 3 fields are represented by the lowest 6 bits. This way we only need a single shift, rather than a shift on RSI AND RAX!
  dec   rbp
  jnz .test_row

  cmp   rax, 0x3f         ; Check if vertical check has completed, if so start diagonal check
  jbe   .vertical         ; Vertical check hasn't completed yet, check vertically first

  ; Diagonal
  rol   edx, 0x6          ; Reset grid to its initial position
  mov   rax, 0x30303      ; Set AND operand for vertical tests ( \ left to right )
  mov   rbx, 0x3330       ; Set AND operand for vertical tests ( / right to left )
  test  edi, edi
  jz    .diagonal_circle

  ; Cross

  ; left to right
  and   eax, edx
  cmp   eax, 0x30303
  je    .win

  ; right to left
  and   ebx, edx
  cmp   ebx, 0x3330
  je    .win

  ; Circle

  .diagonal_circle:

  ; left to right
  and   eax, edx
  cmp   eax, 0x10101
  je    .win

  ; right to left
  and   ebx, edx
  cmp   ebx, 0x1110
  je    .win

  ; No victory

  xor   rax, rax          ; Return 0
  jmp   .return

  ; Check vertical

  .vertical:
  rol   edx, 0x12         ; Reset grid to its initial position
  mov   rcx, 0x2          ; Shift by two
  mov   rsi, 0x30C3       ; Set AND operand for vertical tests
  test  edi, edi
  jz    .vertical_circle  ; Even

  ; Cross

  mov   rax, 0x30C3       ; 000011000011000011
  jmp   .test_grid

  ; Circle

  .vertical_circle:
  mov   rax, 0x1041       ; 000001000001000001
  jmp   .test_grid

  .win:
  mov   rax, 0x1          ; Return true

  ; Restore registers

  .return:
  pop   rbp
  pop   rsi
  pop   rdx
  pop   rcx
  pop   rbx

  ret
