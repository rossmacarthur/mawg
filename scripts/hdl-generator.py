#!/usr/bin/python

from __future__ import division
import click
from math import sin, pi

CODE = """// Numerically Controlled Oscillator
// Author: Ross MacArthur
// Generates a synchronous discrete-time, discrete-valued sinusoid
// sine frequency = clock speed / (frequency control * 2^S)

module NCO (
    input clk,
    input reset,
    input [{:d}:0] control, // frequency control word
    output reg [{:d}:0] amplitude // output amplitude of wave
);

parameter S = {:d}; // 2**S samples (need to generate new LUT to change this)

// Phase Accumulator
reg [{:d}:0] count; // to divide clock down to sample freq
reg [S-1:0] phase; // current position in period
reg [S-3:0] select; // based on phase to pick amplitude value
reg [{:d}:0] value; // positive amplitude value

always @(posedge clk)
    if (reset) begin
        count <= 0;
        phase <= 0;
        amplitude <= 0;
    end else begin
        if (count >= control) begin
            count <= 1'b0;
            phase <= phase + 1'b1;
        end else
            count <= count + 1'b1;

        // To deal with only Quarter Sine LUT
        select <= phase[S-2] ? ~(phase[S-3:0]-1'b1) : phase[S-3:0];
        amplitude <= (phase[S-2] & ~|phase[S-3:0]) ? (phase[S-1] ? {} : {}) : (phase[S-1] ? ~value : value);
    end

// Quarter Sine Look-up Table
always @(*) begin
    case(select)"""
END = '    endcase\nend\n\nendmodule'


def _generate_sine_lut(samples, resolution, padding, full):
    S = 2**samples
    R = 2**resolution-1

    for s in range(S//4):
        v = (sin(2*pi*s/S)+1)/2
        print " "*8 + "{:d}'h{:0{}X} : value <= {:d}'h{:0{}X};".format(
            samples-2, s, (samples+1)//4, resolution, int(R*v+.5), (resolution+3)//4)


@click.group()
def cli():
    pass


@cli.command()
@click.argument('samples', type=click.IntRange(1, 16))
@click.argument('resolution', type=click.IntRange(1, 128))
@click.option('--padding', '-p', type=int, default=0)
@click.option('--full', '-f', is_flag=True)
def generate_sine_lut(samples, resolution, padding, full):
    """
    Prints a sine wave LUT in Verilog.

    SAMPLES is the number of bits to use to represent the number of samples.
    RESOLUTION is the number of bits to represent the amount of resolution.
    """
    _generate_sine_lut(samples, resolution, padding, full)


@cli.command()
@click.argument('samples', type=click.IntRange(1, 16))
@click.argument('resolution', type=click.IntRange(1, 128))
@click.argument('control', type=click.IntRange(1, 64))
def generate_nco(samples, resolution, control):
    """
    Prints an NCO in Verilog.

    SAMPLES is the number of samples where samples = 2**SAMPLES.
    RESOLUTION is the number of bits of resolution.
    CONTROL is the number of bits for the frequency control word.
    """

    minval = "{}'h0".format(resolution)
    maxval = "{}'h{:X}".format(resolution, 2**resolution-1)
    print CODE.format(control-1, resolution-1, samples, control-1, resolution-1, minval, maxval)
    _generate_sine_lut(samples, resolution, 8, full=False)
    print END


if __name__ == "__main__":
    cli()
