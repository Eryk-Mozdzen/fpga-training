set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR riscv)

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(CMAKE_AR               riscv32-unknown-elf-ar)
set(CMAKE_ASM_COMPILER     riscv32-unknown-elf-as)
set(CMAKE_C_COMPILER       riscv32-unknown-elf-gcc)
set(CMAKE_CXX_COMPILER     riscv32-unknown-elf-g++)
set(CMAKE_LINKER           riscv32-unknown-elf-ld)
set(CMAKE_OBJDUMP          riscv32-unknown-elf-objdump CACHE INTERNAL "")
set(CMAKE_OBJCOPY          riscv32-unknown-elf-objcopy CACHE INTERNAL "")
set(CMAKE_RANLIB           riscv32-unknown-elf-ranlib CACHE INTERNAL "")
set(CMAKE_SIZE             riscv32-unknown-elf-size CACHE INTERNAL "")
set(CMAKE_STRIP            riscv32-unknown-elf-strip CACHE INTERNAL "")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
