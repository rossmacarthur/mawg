#!/usr/bin/python

from __future__ import division
from math import sin, pi
import click


@click.command()
@click.argument('samples', type=click.IntRange(1, 16))
@click.argument('resolution', type=click.IntRange(1, 128))
@click.option('--padding', '-p', type=int, default=0)
@click.option('--full', '-f', is_flag=True)
def main(samples, resolution, padding, full):
    """
    Generates a sine wave in positive integer values between zero and a max resolution value.

    SAMPLES is the number of bits to use to represent the number of samples.
    RESOLUTION is the number of bits to represent the amount of resolution.
    """

    S = 2**samples
    R = 2**resolution-1

    rng = S if full else S//4

    for s in range(rng):
        v = (sin(2*pi*s/S)+1)/2
        print " "*padding + "{:d}'h{:0{}X} : value <= {:d}'h{:0{}X};".format(
            samples-2, s, (samples+1)//4, resolution, int(R*v+.5), (resolution+3)//4)

if __name__ == "__main__":
    main()
