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
@click.argument('min_freq', type=float)
@click.argument('max_freq', type=float)
@click.argument('length', type=float)
@click.option('--clk', '-c', default=100000000)
def chirp(min_freq, max_freq, length, clk):
    print '\nCHIRP SPECIFICATIONS:\n'
    print '  min freq: {} Hz'.format(min_freq)
    print '  max freq: {} Hz'.format(max_freq)
    print '  length:   {} s'.format(length)

    print '\nCHIRP MODULE REQUIREMENTS:'

    min_ctrl = int(round(min_freq * 2**32 / clk))
    max_ctrl = int(round(max_freq * 2**32 / clk))

    if not 2**32 > min_ctrl >= 1:
        print '  Unfortunately no min_ctrl word can satisfy these specifications.'
        return
    if not 2**32 > max_ctrl >= 1:
        print '  Unfortunately no max_ctrl word can satisfy these specifications.'
        return

    best = 0, 0
    c = (length * clk) / (max_ctrl - min_ctrl)  # d/i

    d = int(round(c))
    i = 1

    print '\033[33m'
    print '  minimize inc_rate for a smoother frequency sweep'
    print '  maximize div_rate for better chirp length accuracy'
    print
    print '  div_rate / inc_rate needs to be {}'.format(c)
    print
    print '  {} => 0x{:X} / 0x{:X} = {}'.format(c, d, i, d/i)
    best = d, i
    while d < 2**32:
        d += 1
        i = int(round(d/c))
        e_best = mod(best[0]/best[1] - c)
        e_now = mod(d/i - c)
        if e_now < e_best:
            best = d, i
            print '  {} => 0x{:X} / 0x{:X} = {}'.format(c, d, i, d/i)
        if e_best < 10**(-6):
            break
    print '\033[0m'
    print '  min_ctrl: 0x{:X}'.format(min_ctrl, min_ctrl)
    print '  max_ctrl: 0x{:X}'.format(max_ctrl, max_ctrl)
    print '  inc_rate: 0x{:X}'.format(best[1], best[1])
    print '  div_rate: 0x{:X}\n'.format(best[0], best[0])


@cli.command()
@click.argument('freq', type=float)
@click.option('--clock', '-c', default=100000000)
def nco(freq, clock):
    print '\nNCO SPECIFICATIONS:\n'
    print '  clk:  {} Hz'.format(clock)
    print '  freq: {} Hz'.format(freq)

    print '\nNCO MODULE REQUIREMENTS:'

    control = int(round(freq * 2**32 / clock))

    print '\033[33m'
    print '  {} => 0x{:X} * clk / 2^32 = {}'.format(freq, control, (control * clock / 2**32))
    print '\033[0m'
    if 2**32 > control >= 1:
        print '  ctrl: 0x{:X}'.format(control, control)
    else:
        print '  Unfortunately no control word can satisfy these specifications.'
    print

if __name__ == "__main__":
    cli()
