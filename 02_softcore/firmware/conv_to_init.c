#include <stdio.h>

#define BYTES  65536
#define OUTPUT "memory.ini"

int main(int argc, char **argv) {
    FILE *fp_in = fopen(argv[1], "rb");
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

    while(byte_count < BYTES) {
        fprintf(fp_out, "00000000\n");
        byte_count += 4;
    }

    fclose(fp_in);
    fclose(fp_out);

    return 0;
}
