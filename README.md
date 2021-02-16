# MAWG

_Modulation and Arbitrary Waveform Generator for an FPGA_

My final undergraduate thesis project. The Verilog source code is accompanied by a Vivado project file and a Xilinx Design Constraint (XDC) file targeted to a Nexys4 DDR Artix-7 FPGA.

This project involves developing efficient, flexible and parameterisable cores that would be used for larger FPGA projects, specifically SDR applications such as radar, telecommunications, and cognitive radio.

View the write up [here →][thesis].

[thesis]: https://mega.nz/file/y9kgjZwa#wicZXJYcp9pGFkvCjlcnuW-tQZew453F6RFk3n2VrGw

## Modes of operation

The MAWG currently provides the following modes of operation:

* Generate standard waveforms at specified frequencies, including sinusoidal, sawtooth, pulse, and chirp signals.
* Modulate an arbitrary signal using frequency modulation with a specified carrier frequency and frequency deviation.

The top level driver module provides a UART interface for real-time configuration of the MAWG. The `cfg_cli.py` script implements a Python serial side of the interface.

A single signal is output at the audio jack of the Nexys4 board and at a PmodDA4 attached to the JA Pmod connector.


## Module structure

The module structure is represented below:
```
|-- Main
|   |-- UART_RX
|   |-- MAWG
|   |   |-- WaveGenerator
|   |   |   |-- NCO
|   |   |   |-- Chirp
|   |   |   |-- Sawtooth
|   |   |   |-- Pulse
|   |   |-- FMModulator
|   |   |   |-- NCO_fm
|   |   |-- FMDemodulator
|   |   |   |-- NCO_fm
|   |   |   |-- BlockAverager
|   |-- PmodDA4_Control
|   |-- Audio_Control
```
