# #!/usr/bin/python

from __future__ import division, print_function
from math import sin, cos, pi


def disc(x):
    """
    Returns 'x' rounded to the nearest integer.
    """
    return int(round(x))


def to_signed(x, bits):
    """
    Returns a signed representation of 'x'.
    """
    if x >= 0:
        return x
    else:
        return int('1{:0{}b}'.format(2**(bits-1)+x, bits-1), 2)


def hexlen(x):
    """
    Returns the string length of 'x' in hex format.
    """
    return len(hex(x))+2


def freq_to_ctrl(freq, clk=100000000, phase_bits=32):
    """
    Returns a frequency control value from a frequency in Hertz.
    """
    return disc(freq * 2**phase_bits / clk)


def ctrl_to_freq(ctrl, clk=100000000, phase_bits=32):
    """
    Returns a frequency in Hertz from a frequency control value.
    """
    return ctrl * clk / 2**phase_bits


def create_lut(sbits, rbits, wave, padding=4, name='lut_value',
               unsigned=False, full=False):
    """
    Returns a string of Verilog code for a sinusoidal LUT.
    """
    S = 2**sbits

    func = sin if wave == 'sin' else cos

    result = ''

    for s in range((S if full else S//4)):
        if unsigned:
            v = disc((2**(rbits)-1) * (func(2*pi*s/S)+1)/2)
        else:
            v = disc((2**(rbits-1)-1) * (func(2*pi*s/S)))

        if full:
            result += ' '*padding+'{:d}\'h{:0{}X} : {} <= {:d}\'h{:0{}X};\n' \
                      .format(sbits, s, sbits//4, name, rbits,
                              to_signed(v, rbits), rbits//4)
        else:
            result += ' '*padding+'{:d}\'h{:0{}X} : {} <= {:d}\'h{:0{}X};\n' \
                      .format(sbits-2, s, (sbits+1)//4, name, rbits,
                              to_signed(v, rbits), (rbits+3)//4)

    return result[:-1]


def chirp_constants(min_ctrl, max_ctrl, T, clk=100000000, max_error=0.000001):
    """
    Calculate the chirp constants.
    """
    ratio = (T * clk) / (max_ctrl - min_ctrl)
    div_rate, inc_rate = disc(ratio), 1
    error = abs(div_rate / inc_rate - ratio)

    d, i = div_rate, inc_rate
    while div_rate < 2**32 and inc_rate < 2**32 and error > max_error:
        i += 1
        d = disc(ratio * i)
        e = abs(d / i - ratio)
        if e < error:
            div_rate, inc_rate, error = d, i, e

    return disc(ratio), 1, div_rate, inc_rate
