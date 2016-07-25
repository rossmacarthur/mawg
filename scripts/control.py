#!/usr/bin/python

from __future__ import division
import click


@click.command()
@click.argument('freq', type=float)
@click.option('--clock', '-c', default=100000000)
@click.option('--samples', type=click.IntRange(1, 16), default=10)
def main(freq, clock, samples):
    control = int(clock / (freq * 2**samples) + .5)
    if control > 65536 or control < 1:
        print 'Frequency out of range'
    else:
        print 'A frequency of {} with a clock of {} requires a control word of {} ({:b})'.format(
            freq, clock, control, control)

if __name__ == "__main__":
    main()
