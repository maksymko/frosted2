/*
    GNU linker script for STM32F405
*/

/* Specify the memory areas */
MEMORY
{
    FLASH (rx)      : ORIGIN = 0x08000000, LENGTH = 128K /* entire flash, 1 MiB */
    RAM (xrw)       : ORIGIN = 0x20000000, LENGTH = 0x020000 /* 128 KiB */
}
 
/* top end of the stack */
/*_stack_end = ORIGIN(RAM) + LENGTH(RAM);*/
_estack = ORIGIN(RAM) + LENGTH(RAM) - 1;

/* RAM extents for the garbage collector */
_ram_end = ORIGIN(RAM) + LENGTH(RAM);
_heap_end = 0x2001c000; /* tunable */

/* define output sections */
SECTIONS
{
    /* Not exceptions yet, discard this to prevent linker errors */
    /DISCARD/ :
    {
        *(.ARM.extab*)
        *(.ARM.exidx*)
    }
    
    /* Meta-data, discard */
    /DISCARD/ :
    {
        *(.ARM.attributes*)
        *(.comment)
    }    

    /* The startup code goes first into FLASH */
    .isr_vector :
    {
        . = ALIGN(4);
        LONG(_estack);       /* Initial stack pointer */
        KEEP(*(.isr_vector)) /* Startup code */
        KEEP(*(.syscall_vector))
        . = ALIGN(4);
    } >FLASH
   
    /* The program code and other data goes into FLASH */
    .text :
    {
        . = ALIGN(4);
        *(.text)           /* .text sections (code) */
        *(.text*)          /* .text* sections (code) */
        *(.rodata)         /* .rodata sections (constants, strings, etc.) */
        *(.rodata*)        /* .rodata* sections (constants, strings, etc.) */
        . = ALIGN(4);
        _etext = .;        /* define a global symbol at end of code */
    } >FLASH

    /* Code can explicitly ask for data to be 
       placed in these higher RAM banks where
       they will be left uninitialized. 
    */
    .task_stack (NOLOAD):
    {
        task_stack_start = . ;
        *(.task)
        task_stack_end = . ;
    } > RAM
     
    /* used by the startup to initialize data */
    _sidata = LOADADDR(.data);
        
    /* This is the initialized data section
    The program executes knowing that the data is in the RAM
    but the loader puts the initial values in the FLASH (inidata).
    It is one task of the startup to copy the initial values from FLASH to RAM. */
    .data :
    {
        . = ALIGN(4);
        _sdata = .;        /* create a global symbol at data start; used by startup code in order to initialise the .data section in RAM */
        _ram_start = .;    /* create a global symbol at ram start for garbage collector */
        *(.data)           /* .data sections */
        *(.data*)          /* .data* sections */

        . = ALIGN(4);
        _edata = .;        /* define a global symbol at data end; used by startup code in order to initialise the .data section in RAM */
    } >RAM AT> FLASH
            
    /* Uninitialized data section */
    .bss :
    {
        . = ALIGN(4);
        /* define a global symbol at bss start; used by startup code */
        __bss_start__ = .;
        _sbss = .;
        *(.bss)
        *(.bss*)
        *(COMMON)

        . = ALIGN(4);
        /* define a global symbol at bss end; used by startup code and GC */
        __bss_end__ = .;
        _ebss = .;
    } >RAM

    /* this is to define the start of the heap, and make sure we have a minimum size */
    .heap :
    {
        . = ALIGN(4);
	PROVIDE ( end = . );
	PROVIDE ( _end = . );
    } >RAM

    /* Remove information from the standard libraries */
    /*
    /DISCARD/ :
    {
        libc.a ( * )
        libm.a ( * )
        libgcc.a ( * )
    }
    */

    .ARM.attributes 0 : { *(.ARM.attributes) }
}