#!/usr/bin/python

from __future__ import division
import click


@click.command()
@click.argument('freq', type=float)
@click.option('--clock', '-c', default=100000000)
def main(freq, clock):
    control = int(round(freq * 2**32 / clock))
    print 'A frequency of {} with a clock of {} requires a control word of {} (0b{:b}, 0x{:X})'.format(
            freq, clock, control, control, control)

if __name__ == "__main__":
    main()
