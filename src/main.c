#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "raylib.h"

void insertionSort(void *data, size_t dlen, int (*compare)(void *, void *),
                   size_t sizeOfElem) {
  void *tmpBuf = malloc(sizeOfElem);
  if (tmpBuf == NULL) {
    printf("malloc failed\n");
    return;
  }

  for (int i = 1; i < dlen; i++) {
    if (compare(&data[i], &data[i - 1]) == 1)
      continue;

    int original_i = i;
    for (int j = i - 1; j >= 0; j--) {
      if (compare(&data[j], &data[i]) == 1)
        continue;

      memcpy(tmpBuf, &data[i], sizeOfElem);
      memmove(&data[j + 1], &data[j], (i - 1 - j) * sizeOfElem);
      memcpy(&data[j], tmpBuf, sizeOfElem);
      i--;
    }

    i = original_i;
  }

  free(tmpBuf);
}

int compareUInt(void *x, void *y) { return *(uint *)x > *(uint *)y ? 1 : 0; }

int main() {
  uint list[6] = {10, 9, 20, 23, 15, 3};
  for (int i = 0; i < 6; i++) {
    printf("%d\t", list[i]);
  }
  printf("\n");

  insertionSort(list, 6, &(compareUInt), sizeof(uint));

  for (int i = 0; i < 6; i++) {
    printf("%d\t", list[i]);
  }
  printf("\n");

  InitWindow(800, 600, "Raylib Example");
  while (!WindowShouldClose()) {
    BeginDrawing();
    ClearBackground(RAYWHITE);
    DrawText("Congrats! You created your first window!", 190, 200, 20,
             LIGHTGRAY);
    EndDrawing();
  }
  CloseWindow();

  return 0;
}
