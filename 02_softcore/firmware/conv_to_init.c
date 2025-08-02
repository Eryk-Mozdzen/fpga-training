#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BYTES  16384
#define OUTPUT "../../src/mem_init.ini"

int main(int argc, char **argv) {
    if(argc != 2) {
        fprintf(stderr, "Usage: conv_to_init filename\n");
        exit(EXIT_FAILURE);
    }

    FILE *fp_in = fopen(argv[1], "rb");

    if(fp_in == NULL) {
        fprintf(stderr, "Could not open %s\n", argv[1]);
        exit(EXIT_FAILURE);
    }

    FILE *fp_out = fopen(OUTPUT, "wb");

    int next = 1;
    int byte_count = 0;

    while(next) {
        int bytes[4] = {0, 0, 0, 0};
        int count = 0;

        for(int i = 0; i < 4; i++) {
            int v;
            if((v = fgetc(fp_in)) != EOF) {
                bytes[i] = v;
                count++;
            } else {
                next = 0;
                break;
            }
        }

        for(int i = 0; i < (4 - count); i++) {
            fprintf(fp_out, "00");
        }
        for(int i = 0; i < count; i++) {
            fprintf(fp_out, "%02X", bytes[count - i - 1]);
        }
        fprintf(fp_out, "\n");
        byte_count += 4;
    }

    while((byte_count % 16) != 0) {
        fprintf(fp_out, "00000000\n");
        byte_count += 4;
    }

    fclose(fp_in);
    fclose(fp_out);

    if(byte_count > BYTES) {
        fprintf(stderr, "ERROR: PROGRAM IS TOO LARGE: %d bytes is greater than %d bytes\n",
                byte_count, BYTES);
        fprintf(stderr, "And don't forget to leave room for the stack\n");
        return (EXIT_FAILURE);
    }

    return EXIT_SUCCESS;
}
