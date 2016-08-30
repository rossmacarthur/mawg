#!/usr/bin/python

from __future__ import division
import click


def mod(x):
    if x >= 0:
        return x
    else:
        return -1 * x


@click.group()
def cli():
    pass


@cli.command()
@click.argument('start', type=float)
@click.argument('end', type=float)
@click.argument('length', type=float)
@click.option('--clock', '-c', default=100000000)
def chirp_control(start, end, length, clock):
    print 'Specifications:'
    print '    start freq: {} Hz'.format(start)
    print '    end freq:   {} Hz'.format(end)
    print '    length:     {} s'.format(length)

    print 'Requirements'
    start_ctrl = int(round(start * 2**32 / clock))
    end_ctrl = int(round(end * 2**32 / clock))
    print '    start_ctrl: {} (or 0x{:X})'.format(start_ctrl, start_ctrl)
    print '    end_ctrl:   {} (or 0x{:X})'.format(end_ctrl, end_ctrl)

    best = 0, 0
    c = (end_ctrl - start_ctrl) * length / clock
    if c < 1:
        p = 1
        i = int(round(1 / c))
        best = p, i
        while i < 2**16:
            i += 1
            p = int(round(c * i))
            e_best = mod(best[0]/best[1] - c)
            e_now = mod(p/i - c)
            if e_now < e_best and e_best > 10**(-10):
                best = p, i

    print '    prp_rate:   {} (or 0x{:X})'.format(best[0], best[0])
    print '    inv_rate:   {} (or 0x{:X})'.format(best[1], best[1])


@cli.command()
@click.argument('freq', type=float)
@click.option('--clock', '-c', default=100000000)
def nco_control(freq, clock):
    control = int(round(freq * 2**32 / clock))

    print 'Specifications:\n    freq: {} Hz\n    clock: {} Hz'.format(freq, clock)
    if 2**32 > control >= 1:
        print 'Requirements:\n    control: {} (or 0x{:X})'.format(control, control, control)
    else:
        print 'Requirements:\n    Unfortunately no control word can satisfy these specifications'

if __name__ == "__main__":
    cli()
