# #!/usr/bin/python

from __future__ import division, print_function
from math import sin, cos, pi, log

RESETCLR = '\033[0m'
FADEDCLR = '\033[33m'
THEMECLR = '\033[95m'
WARNCLR = '\033[90m'


def disc(x):
    return int(round(x))


def mod(x):
    if x >= 0:
        return x
    else:
        return -1 * x


def to_signed(x, bits):
    if x >= 0:
        return x
    else:
        return int('1{:0{}b}'.format(2**(bits-1)+x, bits-1), 2)


def hexlen(x):
    return len(hex(x))+2


def print_theme(x):
    print(THEMECLR, '\n', x, RESETCLR, sep='')


def print_faded(x):
    print(FADEDCLR, x, RESETCLR, sep='')


def print_warning(x):
    print(WARNCLR, x, RESETCLR, sep='')


def freq_to_ctrl(freq, clk=100000000, phase_bits=32):
    return disc(freq * 2**phase_bits / clk)


def ctrl_to_freq(ctrl, clk=100000000, phase_bits=32):
    return ctrl * clk / 2**phase_bits


def create_lut(sbits, rbits, wave, padding=4, name='lut_value', signed=True, full=False):
    S = 2**sbits-2

    func = sin if wave == 'sin' else cos

    for s in range((S if full else S//4)):
        if signed:
            v = disc((2**(rbits-1)-1) * (func(2*pi*s/S)))
        else:
            v = disc((2**(rbits)-1) * (func(2*pi*s/S)+1)/2)

        if full:
            print(' '*padding + '{:d}\'h{:0{}X} : {} <= {:d}\'h{:0{}X};'.format(
                    sbits, s, sbits//4, name, rbits, to_signed(v, rbits), rbits//4))
        else:
            print(' '*padding + '{:d}\'h{:0{}X} : {} <= {:d}\'h{:0{}X};'.format(
                    sbits-2, s, (sbits+1)//4, name, rbits, to_signed(v, rbits), (rbits+3)//4))


def chirp_constants(min_ctrl, max_ctrl, T, clk=100000000, max_error=0.000001):
    ratio = (T * clk) / (max_ctrl - min_ctrl)
    div_rate, inc_rate = disc(ratio), 1
    error = mod(div_rate / inc_rate - ratio)

    d, i = div_rate, inc_rate
    while div_rate < 2**32 and inc_rate < 2**32 and error > max_error:
        i += 1
        d = disc(ratio * i)
        e = mod(d / i - ratio)
        if e < error:
            div_rate, inc_rate, error = d, i, e

    return disc(ratio), 1, div_rate, inc_rate


def chirp_util(min_freq, max_freq, length, clk=100000000, verilog=False):
    print_theme('Chirp module output specifications:')
    print('Minimum frequency of sweep: {} Hz'.format(min_freq))
    print('Maximum frequency of sweep: {} Hz'.format(max_freq))
    print('Length of sweep: {} s'.format(length))

    print_theme('Chirp module input ports:')
    min_ctrl = freq_to_ctrl(min_freq, clk=clk)
    max_ctrl = freq_to_ctrl(max_freq, clk=clk)

    if not 2**32 > min_ctrl >= 1:
        print_warning('\nWarning: min_ctrl is outside the range of [1 : 2^32).\n')
    if not 2**32 > max_ctrl >= 1:
        print_warning('\nWarning: max_ctrl is outside the range of [1 : 2^32).\n')

    print('min_ctrl: 0x{:X}'.format(min_ctrl, min_ctrl))
    print('max_ctrl: 0x{:X}'.format(max_ctrl, max_ctrl))

    min_d, min_i, max_d, max_i = chirp_constants(min_ctrl, max_ctrl, length, clk=clk)

    print('div_rate: 0x{:X}'.format(max_d))
    print('inc_rate: 0x{:X}'.format(max_i))

    print_faded('\nNote: when calculating the above rate values chirp length accuracy was optimized'
                ' at the slight cost of a smoother frequency sweep. To optimize for a smoother '
                'frequency sweep at the cost of chirp length accuracy the following values may be '
                ' used:')
    print_faded('div_rate: 0x{:X}'.format(min_d))
    print_faded('inc_rate: 0x{:X}'.format(min_i))

    if verilog:
        print_theme('Chirp module Verilog instantiation code:')
        i = max(11, hexlen(min_ctrl), hexlen(max_ctrl), hexlen(max_d), hexlen(max_i))
        print('Chirp Chirp0 (')
        print('   .clk       ( {:<{}} ),'.format('chirp_clk', i))
        print('   .delay     ( {:<{}} ),'.format('chirp_delay', i))
        print('   .min_ctrl  ( {:<{}} ),'.format('32\'h{:X}'.format(min_ctrl), i))
        print('   .max_ctrl  ( {:<{}} ),'.format('32\'h{:X}'.format(max_ctrl), i))
        print('   .div_rate  ( {:<{}} ),'.format('32\'h{:X}'.format(max_d), i))
        print('   .inc_rate  ( {:<{}} ),'.format('32\'h{:X}'.format(max_i), i))
        print('   .nco_reset ( {:<{}} ),'.format('nco_reset', i))
        print('   .nco_ctrl  ( {:<{}} )'.format('nco_ctrl', i))
        print(');')
    print()


def nco_util(freq, clk=100000000, verilog=False):
    print_theme('NCO module output specifications:')
    print('Frequency at output: {} Hz'.format(freq))

    print_theme('NCO module input ports:')
    ctrl = freq_to_ctrl(freq, clk=clk)
    print('clk: {} Hz (given)'.format(clk))
    print('ctrl: 0x{:X}'.format(ctrl))
    if not 2**32 > ctrl >= 1:
        print_warning('\nWarning: this control word is outside the range of [1 : 2^32).')

    if verilog:
        print_theme('NCO module Verilog instantiation code:')
        i = max(9, hexlen(ctrl))
        print('NCO NCO0 (')
        print('   .clk     ( {:<{}} ),'.format('nco_clk', i))
        print('   .reset   ( {:<{}} ),'.format('nco_reset', i))
        print('   .ctrl    ( {:<{}} ),'.format('32\'h{:X}'.format(ctrl), i))
        print('   .sin_out ( {:<{}} ),'.format('sin_out', i))
        print('   .cos_out ( {:<{}} )'.format('cos_out', i))
        print(');')
    print()


def fm_util(ctr_freq, dev_freq, clk=100000000):
    print_theme('FM modules output specifications:')
    print('Center frequency of modulation: {:.2f} Hz'.format(ctr_freq))
    print('Maximum frequency deviation from center: {:.2f} Hz'.format(dev_freq))
    ctr_ctrl = freq_to_ctrl(ctr_freq)
    dev_ctrl = freq_to_ctrl(dev_freq)
    dev = int(log(dev_ctrl/127, 2))

    min_freq = ctrl_to_freq(ctr_ctrl - (127 << dev))
    max_freq = ctrl_to_freq(ctr_ctrl + (127 << dev))

    print_theme('FM modules input ports:')
    print('ctr_ctrl: 0x{:X}'.format(ctr_ctrl))
    print('deviation: 0x{:X}\n'.format(dev))

    print_faded('Note: frequency modulation will between {:.2f} Hz and {:.2f} Hz. Resulting in a '
                'maximum frequency deviation from the center frequency {:.2f} by {:.2f} Hz.'.format(
                    min_freq, max_freq, ctr_freq, max_freq/2-min_freq/2))
    print()
