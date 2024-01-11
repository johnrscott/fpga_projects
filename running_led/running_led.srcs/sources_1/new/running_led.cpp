#include <iostream>
#include "Vrunning_led.h"
#include <verilated.h>

int main(int argc , char **argv) {
    Verilated::commandArgs(argc, argv);
    Vrunning_led *tb = new Vrunning_led;
}
