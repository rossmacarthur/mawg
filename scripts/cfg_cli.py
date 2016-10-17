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
    bytes = [cmd] + [(data >> 8*i) & 0xFF for i in range(3, -1, -1)]
    for x in bytes:
        ser.write(chr(x))


def note(freq, length):
    configure(0x2, freq_to_ctrl(freq))
    time.sleep(0.3*length)


@click.group(context_settings=dict(help_option_names=['-h', '--help']))
def cli():
    """
    Command line script for configuring the MAWG.
    """
    pass


@cli.command()
@click.argument('output',
                type=click.Choice(['message', 'modulated', 'demodulated']))
def select(output):
    """
    Select output wave.

    OUTPUT is one of: message, modulated, demodulated
    """
    configure(0x0, ['message', 'modulated', 'demodulated'].index(output))


@cli.command()
@click.argument('wave',
                type=click.Choice(['sine', 'chirp', 'sawtooth', 'pulse']))
def set_wave(wave):
    """
    Set modulating wave.

    WAVE is one of: sine, chirp, sawtooth, pulse
    """
    configure(0x1, ['sine', 'chirp', 'sawtooth', 'pulse'].index(wave))


@cli.command()
@click.argument('freq', type=float)
def set_freq(freq):
    """
    Set the frequency of the output.

    FREQ is the frequency in Hertz.
    """
    configure(0x2, freq_to_ctrl(freq))


@cli.command()
@click.argument('freq', type=float)
def sine(freq):
    """
    Configure and output a sine wave.

    FREQ is the frequency in Hertz.
    """
    configure(0x2, freq_to_ctrl(freq))
    configure(0x1, 0x0)


@cli.command()
@click.argument('min_freq', type=float)
@click.argument('max_freq', type=float)
@click.argument('length', type=float)
@click.option('--delay', '-d', type=click.IntRange(0, 15), default=0,
              help='Number of chirp lengths to delay.')
@click.option('--length_optimize', '-o', is_flag=True,
              help='Optimize for chirp length instead of smoothness.')
@click.option('--reverse', '-r', is_flag=True, help='Down chirp')
def chirp(min_freq, max_freq, length, delay, length_optimize, reverse):
    """
    Configure and output a chirp.

    \b
    MIN_FREQ is the minimum frequency of the sweep in Hertz.
    MAX_FREQ is the maximum frequency of the sweep in Hertz.
    LENGTH is the length of the chirp in seconds.
    """
    min_ctrl = freq_to_ctrl(min_freq)
    max_ctrl = freq_to_ctrl(max_freq)
    configure(0x3, (1 if reverse else 0))
    configure(0x4, delay)
    configure(0x5, min_ctrl)
    configure(0x6, max_ctrl)
    constants = chirp_constants(min_ctrl, max_ctrl, length)
    if length_optimize:
        configure(0x7, constants[2])
        configure(0x8, constants[3])
    else:
        configure(0x7, constants[0])
        configure(0x8, constants[1])
    configure(0x1, 0x1)


@cli.command()
@click.argument('freq', type=float, default=0)
def sawtooth(freq):
    """
    Configure and output a sawtooth.

    FREQ is the frequency in Hertz.
    """
    if freq:
        configure(0x2, freq_to_ctrl(freq))
    configure(0x1, 0x2)


@cli.command()
@click.argument('freq', type=float)
@click.argument('duty', '-d', type=FloatRange(0, 1),
                required=False, default=0.5)
def pulse(freq, duty):
    """
    Configure and output a pulse wave.

    \b
    FREQ is the frequency in Hertz.
    DUTY is the duty cycle.
    """
    configure(0x2, freq_to_ctrl(freq))
    configure(0x9, disc(duty * (2**32-1)))
    configure(0x1, 0x3)


@cli.command()
@click.argument('ctr_freq', type=float)
@click.argument('dev_freq', type=float)
@click.option('--demod_rate', '-r', type=BasedInt(), default='0x1d')
def fm(ctr_freq, dev_freq, demod_rate):
    """
    Configure frequency modulation settings.

    \b
    CTR_FREQ is the center frequency in Hertz
    DEV_FREQ is the maximum frequency deviation in Hertz
    """
    ctr_ctrl = freq_to_ctrl(ctr_freq)
    dev_ctrl = freq_to_ctrl(dev_freq)
    configure(0xC, demod_rate)
    configure(0xB, int(log(dev_ctrl, 2))+1)
    configure(0xA, ctr_ctrl)
    configure(0x0, 0x1)


@cli.command()
def reset():
    """
    Reset all configuration values.
    """
    configure(0xF, 0x0)


@cli.command()
@click.argument('cmd', type=BasedInt())
@click.argument('data', type=BasedInt())
def manual(cmd, data):
    """
    Manually send a command.

    \b
    CMD is the 8-bit command.
    DATA is the 32-bit data word to transmit.
    """
    configure(cmd, data)


@cli.command()
def fun():
    """
    Plays a song.
    """
    configure(0x1, 0x2)

    N = 0
    C1 = 523.25
    D1 = 587.33
    E1 = 659.25
    F1 = 698.46
    G1 = 783.99
    A1 = 880.00
    B1 = 987.77
    C2 = 1046.50
    D2 = 1174.66
    E2 = 1318.51
    F2 = 1396.91
    G2 = 1567.98
    A2 = 1760.00

    while True:
        note(C2, 2)
        note(C1, 2)

        note(D1, 0.66)
        note(E1, 0.333)
        note(F1, 0.666)
        note(E1, 0.333)
        note(D1, 2)

        note(E1, 0.666)
        note(F1, 0.333)
        note(G1, 0.666)
        note(F1, 0.333)
        note(E1, 2)

        note(F1, 0.666)
        note(G1, 0.333)
        note(A1, 0.666)
        note(G1, 0.333)
        note(F1, 0.666)
        note(G1, 0.333)
        note(A1, 0.666)
        note(B1, 0.333)

        note(C2, 1)
        note(N, 0.0001)
        note(C2, 1)
        note(N, 0.0001)
        note(C2, 2)

        note(C2, 0.666)
        note(N, 0.0001)
        note(C2, 0.333)
        note(B1, 0.666)
        note(A1, 0.333)
        note(B1, 0.666)
        note(C2, 0.333)
        note(D2, 1)

        note(E2, 1)
        note(N, 0.0001)
        note(E2, 1)
        note(N, 0.0001)
        note(E2, 2.666)
        note(N, 0.0001)
        note(E2, 0.333)

        note(D2, 0.666)
        note(C2, 0.333)
        note(D2, 0.666)
        note(E2, 0.333)
        note(F2, 1)

        note(G2, 2)
        note(C2, 2)

        note(C2, 0.666)
        note(A2, 0.333)
        note(G2, 0.666)
        note(F2, 0.333)
        note(E2, 1)
        note(D2, 1)


if __name__ == "__main__":
    cli()
