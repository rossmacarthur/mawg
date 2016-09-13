#!/usr/bin/python

from __future__ import division, print_function
import click

RESETCLR = '\033[0m'
FADEDCLR = '\033[33m'
THEMECLR = '\033[95m'
WARNCLR = '\033[90m'


class BasedIntParamType(click.ParamType):
    name = 'integer'

    def convert(self, value, param, ctx):
        try:
            if value[:2].lower() == '0x':
                return int(value[2:], 16)
            elif value[:2].lower() == '0b':
                return int(value[2:], 2)
            elif value[:1] == '0':
                return int(value, 8)
            return int(value, 10)
        except ValueError:
            self.fail('%s is not a valid integer' % value, param, ctx)

BASED_INT = BasedIntParamType()


def mod(x):
    if x >= 0:
        return x
    else:
        return -1 * x


def print_theme(x):
    print(THEMECLR, '\n', x, RESETCLR, sep='')


def print_faded(x):
    print(FADEDCLR, x, RESETCLR, sep='')


def print_warning(x):
    print(WARNCLR, x, RESETCLR, sep='')


@click.group()
def cli():
    pass


@cli.command()
@click.argument('center_freq', type=float)
@click.option('--clk', '-c', help='Set the clock value in Hz (default 100 MHz).', default=100000000)
def fm_modulation(center_freq, clk):
    center_ctrl = int(round(center_freq * 2**32 / clk))
    min_freq = (center_ctrl-(127 << 8)) * clk / 2**32
    max_freq = (center_ctrl+(127 << 8)) * clk / 2**32
    print('  center_ctrl: 0x{:X}'.format(center_ctrl))
    print('  min_freq:    {} Hz'.format(min_freq))
    print('  max_freq:    {} Hz'.format(max_freq))


@cli.command()
@click.argument('min_freq', type=float)
@click.argument('max_freq', type=float)
@click.argument('length', type=float)
@click.option('--clk', '-c', help='Set the clock value in Hz (default 100 MHz).', default=100000000)
@click.option('--verilog', '-v', help='Prints out Verilog instantiation code.', is_flag=True)
def chirp(min_freq, max_freq, length, clk, verilog):
    """
    Calculates input port values for the Chirp module.

    MIN_FREQ is the minimum frequency of the sweep.\t\t\t\t
    MAX_FREQ is the maximum frequency of the sweep.\t\t\t\t
    LENGTH is the time taken to sweep.
    """

    print_theme('Chirp module output specifications:')
    print('  Minimum frequency of sweep: {} Hz'.format(min_freq))
    print('  Maximum frequency of sweep: {} Hz'.format(max_freq))
    print('  Length of sweep:            {} s'.format(length))

    print_theme('Chirp module input ports:')

    min_ctrl = int(round(min_freq * 2**32 / clk))
    max_ctrl = int(round(max_freq * 2**32 / clk))

    best = 0, 0
    c = (length * clk) / (max_ctrl - min_ctrl)  # d/i
    d, i = int(round(c)), 1

    print_faded('  minimize inc_rate for a smoother frequency sweep')
    print_faded('  maximize div_rate for better chirp length accuracy\n')
    print_faded('  div_rate / inc_rate needs to be {}\n'.format(c))
    print_faded('  0x{:X} / 0x{:X} = {}'.format(d, i, d/i))
    best = d, i
    while d < 2**32 and i < 2**32:
        i += 1
        d = int(round(c * i))
        e_best = mod(best[0]/best[1] - c)
        e_now = mod(d/i - c)
        if e_now < e_best:
            best = d, i
            print_faded('  0x{:X} / 0x{:X} = {}'.format(d, i, d/i))
        if e_best < 10**(-6):
            print()
            break

    print('  min_ctrl: 0x{:X}'.format(min_ctrl, min_ctrl))
    print('  max_ctrl: 0x{:X}'.format(max_ctrl, max_ctrl))
    print('  div_rate: 0x{:X}'.format(best[0], best[0]))
    print('  inc_rate: 0x{:X}'.format(best[1], best[1]))

    if not 2**32 > min_ctrl >= 1:
        print_warning('\n  Warning: min_ctrl is outside the range of [1 : 2^32).')
    if not 2**32 > max_ctrl >= 1:
        print_warning('\n  Warning: max_ctrl is outside the range of [1 : 2^32).')

    if verilog:
        print_theme('Chirp module Verilog instantiation code:')
        i = max(11, len(hex(min_ctrl))+2, len(hex(max_ctrl))+2, len(hex(best[0]))+2, len(hex(best[1]))+2)
        print('  Chirp Chirp0 (')
        print('     .clk       ( {:<{}} ),'.format('chirp_clk', i))
        print('     .delay     ( {:<{}} ),'.format('chirp_delay', i))
        print('     .min_ctrl  ( {:<{}} ),'.format('32\'h{:X}'.format(min_ctrl), i))
        print('     .max_ctrl  ( {:<{}} ),'.format('32\'h{:X}'.format(max_ctrl), i))
        print('     .div_rate  ( {:<{}} ),'.format('32\'h{:X}'.format(best[0]), i))
        print('     .inc_rate  ( {:<{}} ),'.format('32\'h{:X}'.format(best[1]), i))
        print('     .nco_reset ( {:<{}} ),'.format('nco_reset', i))
        print('     .nco_ctrl  ( {:<{}} )'.format('nco_ctrl', i))
        print('  );')
    print()


@cli.command()
@click.argument('freq', type=float)
@click.option('--clk', '-c', help='Set the clock value in Hz (default 100 MHz).', default=100000000)
@click.option('--verilog', '-v', help='Prints out Verilog instantiation code.', is_flag=True)
def nco_ctrl(freq, clk, verilog):
    """
    Calculates input port values for the NCO module.

    FREQ is the output frequency of the NCO.
    """

    print_theme('NCO module output specifications:')
    print('  Output frequency: {} Hz'.format(freq))

    print_theme('NCO module input ports:')

    ctrl = int(round(freq * 2**32 / clk))

    print('  clk:  {} Hz (given)'.format(clk))
    # print_faded('  ctrl = freq * 2^32 / clk')
    # print_faded('  ctrl of 0x{:X} will result in a freq of {}'.format(ctrl-1, (ctrl-1)*clk/2**32))
    print('  ctrl of 0x{:X} will result in a freq of {}'.format(ctrl, ctrl * clk / 2**32))
    # print_faded('  ctrl of 0x{:X} will result in a freq of {}'.format(ctrl+1, (ctrl+1)*clk/2**32))

    if not 2**32 > ctrl >= 1:
        print_warning('  Warning: this control word is outside the range of [1 : 2^32).')

    if verilog:
        print_theme('NCO module Verilog instantiation code:')
        i = max(9, len(hex(ctrl))+2)
        print('  NCO NCO0 (')
        print('     .clk     ( {:<{}} ),'.format('nco_clk', i))
        print('     .reset   ( {:<{}} ),'.format('nco_reset', i))
        print('     .ctrl    ( {:<{}} ),'.format('32\'h{:X}'.format(ctrl), i))
        print('     .sin_out ( {:<{}} ),'.format('sin_out', i))
        print('     .cos_out ( {:<{}} )'.format('cos_out', i))
        print('  );')
    print()


@cli.command()
@click.argument('ctrl', type=BASED_INT)
@click.option('--clk', '-c', help='Set the clock value in Hz (default 100 MHz).', default=100000000)
def nco_freq(ctrl, clk):
    """
    Calculates the NCO frequency based on the input control word.

    CTRL is the frequency control word to the NCO.
    """

    print_theme('NCO module input ports:')
    print('  clk:  {} Hz'.format(clk))
    print('  ctrl: 0x{:X}'.format(ctrl))

    print_theme('NCO module output specifications:')
    print_faded('  freq = ctrl * clk / 2^32')
    print('  ctrl of 0x{:X} will result in a freq of {} Hz'.format(ctrl, ctrl * clk / 2**32))

if __name__ == "__main__":
    cli()
