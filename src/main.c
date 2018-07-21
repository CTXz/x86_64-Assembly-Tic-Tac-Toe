/*

 * Copyright (c) 2018 Patrick Pedersen <ctx.xda@gmail.com>

 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.

 * Author: Patrick Pedersen <ctx.xda@gmail.com>
 * Description: Tic-Tac-Toe main code built on top of the core assembly library.

 */

#include <stdio.h>
#include <ctype.h>
#include "core.h"

#define clear() printf("\033[H\033[J")

/* Convert field return to its appropraite grid char */
char field_to_char(uint8_t field_ret) {
  switch(field_ret) {
    case EMPTY:
      return ' ';
    case CROSS:
      return 'X';
  }

  return 'O';
}

/* Render text-based 3x3 grid */
void draw_grid() {
  for (uint8_t y = 0; y < 3; y++) {

    for (uint8_t x = 0; x < 3; x++) {
      printf("%c", field_to_char(get_field(x, y)));

      if (x != 2) {
        printf("|");
      }
    }

    if (y != 2) {
      printf("\n------\n");
    }
  }

  puts("");
}

int main() {
  int x, y;
  char new_game;

  /* Main game loop */
  do
  {
    init_grid();

    bool cross      = false;

    /* Round loop */
    do
    {
      clear();
      draw_grid();
      puts("");

      if ((cross = (!cross))) { // Toggles between X and O
        printf("Its player X's turn!\n\n");
      } else {
        printf("Its player O's turn!\n\n");
      }

      do
      {
        /* Provide Y cords */
        do
        {
          printf("Y: ");
          scanf("%i", &y);

          if (y > 0 && y <= 3) {
            break;
          }

          printf("Y value must be in range 1-3\n");

        } while (true);

        /* Provide X cords */
        do
        {
          printf("X: ");
          scanf("%i", &x);

          if (x > 0 && x <= 3) {
            break;
          }

          printf("X value must be in range 1-3\n");

        } while(true);

        if (get_field(x-1, y-1) == EMPTY) {
          set_field(x-1, y-1, cross);
          break;
        }

        printf("Field at (%i, %i) already taken!\n", x, y);

      } while(true);
    } while(!eval_grid(cross));

    /* Prompt whether to quit or restart */
    clear();
    printf("Player %s won!\n\n", cross ? "X" : "O");
    printf("New Game? [Y/n]: ");
    scanf("%s", &new_game);

  } while (tolower(new_game) != 'n');

  return 0;
}
