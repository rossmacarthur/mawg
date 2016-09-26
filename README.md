# MAWG: Modulation and Arbitrary Waveform Generator for an FPGA

Designed for my undergraduate thesis. The implementation is targeted to a Nexys4 DDR Artix-7 FPGA.

The MAWG provides three modes of operation:

* Generate standard waveforms at specified frequencies, including sinusoidal, sawtooth, pulse and chirp signals.
* Modulate an arbitrary signal using frequency modulation with a specified carrier frequency and frequency deviation.
* Demodulate the frequency modulated signal.

A single signal is output at the audio jack and is setup to output to a PmodDA4 attached to JA Pmod connector. The `cfg_cli.py` script is provided to fully configure the device over UART.
