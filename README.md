# titanasm
*titanasm* is an assembler written in Ruby that targets [bootnecklad](https://github.com/bootnecklad)'s homebrew CPU, [Titan](http://marc.cleave.me.uk/cpu/index.htm) ([specifications](https://github.com/bootnecklad/Titan-Specifications)). *titanasm* assembles code written in an assembly-like DSL, and can output machine code or spec-compliant assembly source code.

### Usage Examples
***
##### Assemble to machine code
    whipsch@spigot titanasm $ ./titanasm.rb -f examples/monitor.ttr # writes to ./monitor.tit
    whipsch@spigot titanasm $ ./titanasm.rb -f examples/monitor.ttr -o bin/monitor.bin
    whipsch@spigot titanasm $ ./titanasm.rb -f examples/monitor.ttr -s
    <unreadable>

##### Assemble and print a hex dump
    whipsch@spigot titanasm $ ./titanasm.rb -f examples/monitor.ttr -H
    0000 00 01 02 03 04 05 06 07 08 09 00 00 00 00 00 00
    0010 00 0A 0B 0C 0D 0E 0F 30 31 32 33 34 35 36 37 38
    0020 39 00 00 00 00 00 00 00 41 42 43 44 45 46 D0 0A
    0030 F0 FF FF D0 0D F0 FF FF D0 3E F0 FF FF D1 05 D2
    0040 01 E0 FF FF 15 00 A1 00 3D DF 1B 15 0F A1 00 2E
    ...

##### Convert to spec-compliant assembly
    whipsch@spigot titanasm $ ./titanasm.rb -f examples/monitor.ttr -m asm_src # writes to ./monitor.asm
    whipsch@spigot titanasm $ ./titanasm.rb -f examples/monitor.ttr -m asm_src -o src/monitor.asm
    whipsch@spigot titanasm $ ./titanasm.rb -f examples/monitor.ttr -m asm_src -s
    .WORD SERIAL_PORT_0 0xFFFF
    .DATA HASH_TABLE 0x00 0x01 0x02 0x03 0x04 0x05 0x06 0x07 0x08 0x09 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x0A 0x0B 0x0C 0x0D 0x0E 0x0F
    .DATA HASH_TABLE_BYTE 0x30 0x31 0x32 0x33 0x34 0x35 0x36 0x37 0x38 0x39 0x00 0x00 0x00 0x00 0x00 0x00 0x00 0x41 0x42 0x43 0x44 0x45 0x46


    BEGIN:
      LDC R0,0x0A
      STM R0,SERIAL_PORT_0
    ... 

### Syntax
***
*titanasm* does not currently support assembling from source files that are compliant with the assembly syntax defined in the specification.  The syntaxes are, however, mostly identical, with several differences:

* All instruction names are lowercase
* Comments start with `#`
* Number literals can be binary, decimal, hex, or anything else that Ruby allows
* Labels are Ruby `Symbol`s, and as such must be prefixed with a colon
* Labels are declared like `label :FOO`
* The data directives (`byte`, `word`, `data`, `asci`, `asciz`) can be used without declaring a label
* The `data` directive can be used with an arbitrary amount of mixed strings and numbers

Several example programs are included in the `example/` directory.

### License:
***
*titanasm* is not subject to any licensing restrictions.  You are free to use this software for any purpose.
