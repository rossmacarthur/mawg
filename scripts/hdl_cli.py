#!/usr/bin/python

from __future__ import division, print_function
from hdl_util import chirp_util, nco_util, create_lut
import click


@click.group()
def cli():
    """
    Command line script for calculating various things for the MAWG.
    """
    pass


@cli.command()
@click.argument('min_freq', type=float)
@click.argument('max_freq', type=float)
@click.argument('length', type=float)
@click.option('--clk', '-c', help='Set the clock value in Hz (default 100 MHz).', default=100000000)
@click.option('--verilog', '-v', help='Prints out Verilog instantiation code.', is_flag=True)
def chirp_values(min_freq, max_freq, length, clk, verilog):
    """
    Calculates input port values for the Chirp module.

    MIN_FREQ is the minimum frequency of the sweep.\t\t\t\t
    MAX_FREQ is the maximum frequency of the sweep.\t\t\t\t
    LENGTH is the time taken to sweep.
    """
    chirp_util(min_freq, max_freq, length, clk=clk, verilog=verilog)


@cli.command()
@click.argument('freq', type=float)
@click.option('--clk', '-c', help='Set the clock value in Hz (default 100 MHz).', default=100000000)
@click.option('--verilog', '-v', help='Prints out Verilog instantiation code.', is_flag=True)
def nco_values(freq, clk, verilog):
    """
    Calculates input port values for the NCO module.

    FREQ is the output frequency of the NCO.
    """
    nco_util(freq, clk=clk, verilog=verilog)


@cli.command()
@click.argument('sample_bits', type=click.IntRange(1, 16))
@click.argument('res_bits', type=click.IntRange(1, 128))
@click.argument('wave', type=click.Choice(['sin', 'cos']))
@click.option('--padding', '-p', type=int, default=8)
@click.option('--name', '-n', type=str, default='value')
@click.option('--unsigned', '-u', is_flag=True)
@click.option('--full', '-f', is_flag=True)
def generate_lut(sample_bits, res_bits, wave, padding, name, signed, full):
    """
    Prints out a sinusoidal LUT in Verilog

    SAMPLE_BITS is the number of bits used to represent the samples.
    RESOLUTION_BITS is the number of bits used to represent the resolution.
    WAVE is the sinusoidal waveform (sin or cos)
    """
    create_lut(sample_bits, res_bits, wave, padding=padding, name=name, signed=signed, full=full)


if __name__ == "__main__":
    cli()
