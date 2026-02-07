import sys

BYTES = 65536
OUTPUT = "memory.ini"
ALIGN = 4

with open(sys.argv[1], "rb") as input:
    with open(OUTPUT, "w") as output:
        count = 0

        while True:
            bytes = input.read(ALIGN)
            if not bytes:
                break

            bytes += (b'\x00' * (ALIGN - len(bytes)))

            output.write(''.join(f"{b:02X}" for b in reversed(bytes)))
            output.write('\n')

            count += ALIGN

        while count < BYTES:
            output.write("00000000\n")
            count += ALIGN
