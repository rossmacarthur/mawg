#!/usr/bin/python

from __future__ import division
import click
from math import sin, pi


def signed(x, bits):
    if x >= 0:
        return x
    else:
        return int('1{:0{}b}'.format(2**(bits-1)+x, bits-1), 2)


@click.group()
def cli():
    pass


@cli.command()
@click.argument('samples', type=click.IntRange(1, 16))
@click.argument('resolution', type=click.IntRange(1, 128))
@click.option('--padding', '-p', type=int, default=0)
@click.option('--name', '-n', type=str, default='value')
@click.option('--full', '-f', is_flag=True)
@click.option('--unsigned', '-u', is_flag=True)
def sine_lut(samples, resolution, padding, name, full, unsigned):
    """
    Prints a sine wave LUT in Verilog.

    SAMPLES is the number of bits to use to represent the number of samples.
    RESOLUTION is the number of bits to represent the resolution (including the sign bit).
    """
    S = 2**samples

    for s in range((S if full else S//4)):
        if unsigned:
            v = int(round((2**(resolution)-1) * (sin(2*pi*s/S)+1)/2))
        else:
            v = int(round(((2**(resolution-1)-1))*sin(2*pi*s/S)))

        if full:
            print ' '*padding + '{:d}\'h{:0{}X} : {} <= {:d}\'h{:0{}X};'.format(
                    samples, s, samples//4, name, resolution, signed(v, resolution), resolution//4)
        else:
            print ' '*padding + '{:d}\'h{:0{}X} : {} <= {:d}\'h{:0{}X};'.format(
                    samples-2, s, (samples+1)//4, name, resolution, signed(v, resolution), (resolution+3)//4)


if __name__ == "__main__":
    cli()
