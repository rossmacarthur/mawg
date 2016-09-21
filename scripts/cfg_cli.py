#!/usr/bin/python

import click
import serial
import time
from math import log
from hdl_util import freq_to_ctrl, chirp_constants, disc


class BasedInt(click.ParamType):
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


class FloatRange(click.ParamType):
    name = 'float range'

    def __init__(self, min=None, max=None):
        self.min = min
        self.max = max

    def convert(self, value, param, ctx):
        try:
            rv = float(value)
        except (UnicodeError, ValueError):
            self.fail('%s is not a valid floating point value' %
                      value, param, ctx)
        if self.min is not None and rv < self.min or \
           self.max is not None and rv > self.max:
            if self.min is None:
                self.fail('%s is bigger than the maximum valid value '
                          '%s.' % (rv, self.max), param, ctx)
            elif self.max is None:
                self.fail('%s is smaller than the minimum valid value '
                          '%s.' % (rv, self.min), param, ctx)
            else:
                self.fail('%s is not in the valid range of %s to %s.'
                          % (rv, self.min, self.max), param, ctx)
        return rv

    def __repr__(self):
        return 'FloatRange(%r, %r)' % (self.min, self.max)


def configure(cmd, data, port='/dev/ttyUSB1'):
    ser = serial.Serial(port=port, baudrate=62500)
    ords = [cmd] + [(data >> 8*i) & 0xFF for i in range(3, -1, -1)]
    for x in ords:
        ser.write(chr(x))
        # time.sleep(0.05)


@click.group()
def cli():
    pass


@cli.command()
@click.argument('output', type=click.Choice(['message', 'modulated', 'demodulated']))
def sel_out(output):
    configure(0x0, ['message', 'modulated', 'demodulated'].index(output))


@cli.command()
@click.argument('wave', type=click.Choice(['sine', 'chirp', 'sawtooth', 'pulse']))
def set_wave(wave):
    configure(0x1, ['sine', 'chirp', 'sawtooth', 'pulse'].index(wave))


@cli.command()
@click.argument('freq', type=float)
def set_freq(freq):
    configure(0x2, freq_to_ctrl(freq))


@cli.command()
@click.argument('freq', type=float)
def sine(freq):
    configure(0x2, freq_to_ctrl(freq))
    configure(0x1, 0x0)


@cli.command()
@click.argument('min_freq', type=float)
@click.argument('max_freq', type=float)
@click.argument('length', type=float)
@click.option('--delay', '-d', type=click.IntRange(0, 15), default=0)
@click.option('--reverse', '-r', is_flag=True)
def chirp(min_freq, max_freq, length, delay, reverse):
    min_ctrl = freq_to_ctrl(min_freq)
    max_ctrl = freq_to_ctrl(max_freq)
    configure(0x3, (1 if reverse else 0))
    configure(0x4, delay)
    configure(0x5, min_ctrl)
    configure(0x6, max_ctrl)
    constants = chirp_constants(min_ctrl, max_ctrl, length)
    configure(0x7, constants[2])
    configure(0x8, constants[3])
    configure(0x1, 0x1)


@cli.command()
@click.argument('freq', type=float, default=0)
def sawtooth(freq):
    if freq:
        configure(0x2, freq_to_ctrl(freq))
    configure(0x1, 0x2)


@cli.command()
@click.argument('freq', type=float)
@click.option('--duty', '-d', type=FloatRange(0, 1), default=0.5)
def pulse(freq, duty):
    configure(0x2, freq_to_ctrl(freq))
    configure(0x9, disc(duty * (2**32-1)))
    configure(0x1, 0x3)


@cli.command()
@click.argument('ctr_freq', type=float)
@click.argument('dev_freq', type=float)
def fm(ctr_freq, dev_freq):
    ctr_ctrl = freq_to_ctrl(ctr_freq)
    dev_ctrl = freq_to_ctrl(dev_freq)
    configure(0xA, ctr_ctrl)
    configure(0xB, int(log(dev_ctrl/127, 2)))


@cli.command()
def reset():
    configure(0xF, 0x0)


@cli.command()
@click.argument('cmd', type=BasedInt())
@click.argument('data', type=BasedInt())
def manual(cmd, data):
    configure(cmd, data)


if __name__ == "__main__":
    cli()
