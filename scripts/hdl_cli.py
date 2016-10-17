#!/usr/bin/python

from hdl_util import create_lut, freq_to_ctrl, hexlen, chirp_constants
from math import log
import click


@click.group(context_settings=dict(help_option_names=['-h', '--help']))
def cli():
    """
    Command line script for generating Verilog code and calculating various
    things for the MAWG.
    """
    pass


@cli.command()
@click.argument('sbits', type=click.IntRange(1, 16))
@click.argument('rbits', type=click.IntRange(1, 128))
@click.option('--output', '-o', type=click.Path(),
              help='The output file path.')
def generate_nco(sbits, rbits, output):
    """
    Generates a Verilog NCO.

    \b
    SBITS is the number of bits used to represent the samples.
    RBITS is the number of bits used to represent the resolution.
    """
    generic = open('nco_generic.v', 'r').read()
    generic = generic[generic.find('\n')+1:]
    sin_lut = create_lut(sbits, rbits, 'sin', name='sin_lut_val')
    cos_lut = create_lut(sbits, rbits, 'cos', name='cos_lut_val')
    sin_min = '{:d}\'b{:0{}b}'.format(rbits, 2**(rbits-1)+1, rbits)
    sin_max = '{:d}\'b{:0{}b}'.format(rbits, 2**(rbits-1)-1, rbits)
    cos_zero = '{:d}\'b0'.format(rbits)
    verilog = generic.format(MM=rbits, M=rbits-1, K=sbits-3,
                             sin_lut=sin_lut, sin_min=sin_min, sin_max=sin_max,
                             cos_lut=cos_lut, cos_zero=cos_zero)
    if output:
        click.echo('NCO written to "{}".'.format(output))
        click.echo(verilog, file=open(output, 'w'))
    else:
        click.echo(verilog)


@cli.command()
@click.argument('freq', type=float)
@click.option('--clk', '-c', default=100000000,
              help='Set the clock value in Hz (default 100 MHz).')
@click.option('--verilog', '-v', is_flag=True,
              help='Prints out Verilog instantiation code.')
def nco_values(freq, clk, verilog):
    """
    Calculates NCO input port values.

    FREQ is the output frequency of the NCO in Hertz.
    """
    click.echo('NCO module output specifications:')
    click.echo('  Frequency at output: {} Hz'.format(freq))

    click.echo('\nNCO module input ports:')
    ctrl = freq_to_ctrl(freq, clk=clk)
    click.echo('  clk:  {} Hz (given)'.format(clk))
    click.echo('  ctrl: 0x{:X}'.format(ctrl))

    if verilog:
        click.echo('\nNCO module Verilog instantiation code:\n')
        i = max(8, hexlen(ctrl))
        click.echo('NCO NCO0 (')
        click.echo('   .clk     ( {:<{}} ),'.format('nco_clk', i))
        click.echo('   .rst     ( {:<{}} ),'.format('nco_rst', i))
        click.echo('   .ctrl    ( {:<{}} ),'.format('32\'h{:X}'.format(ctrl),
                                                    i))
        click.echo('   .sin_out ( {:<{}} ),'.format('sin_out', i))
        click.echo('   .cos_out ( {:<{}} )'.format('cos_out', i))
        click.echo(');')


@cli.command()
@click.argument('min_freq', type=float)
@click.argument('max_freq', type=float)
@click.argument('length', type=float)
@click.option('--clk', '-c', default=100000000,
              help='The clock value in Hz (default 100 MHz).')
@click.option('--verilog', '-v', is_flag=True,
              help='Prints out Verilog instantiation code.')
@click.option('--length_optimize', '-o', is_flag=True,
              help='Optimize for chirp length instead of smoothness.')
def chirp_values(min_freq, max_freq, length, clk, verilog, length_optimize):
    """
    Calculates Chirp input port values.

    \b
    MIN_FREQ is the minimum frequency of the sweep in Hertz.
    MAX_FREQ is the maximum frequency of the sweep in Hertz.
    LENGTH is the time taken to sweep in seconds.
    """
    click.echo('Chirp module output specifications:')
    click.echo('  Minimum frequency of sweep: {} Hz'.format(min_freq))
    click.echo('  Maximum frequency of sweep: {} Hz'.format(max_freq))
    click.echo('  Length of sweep: {} s'.format(length))

    click.echo('\nChirp module input ports:')
    min_ctrl = freq_to_ctrl(min_freq, clk=clk)
    max_ctrl = freq_to_ctrl(max_freq, clk=clk)

    click.echo('  min_ctrl: 0x{:X}'.format(min_ctrl, min_ctrl))
    click.echo('  max_ctrl: 0x{:X}'.format(max_ctrl, max_ctrl))

    div, inc, div_o, inc_o = chirp_constants(min_ctrl, max_ctrl, length,
                                             clk=clk)
    if length_optimize:
        div = div_o
        inc = inc_o

    click.echo('  div_rate: 0x{:X}'.format(div))
    click.echo('  inc_rate: 0x{:X}'.format(inc))

    if verilog:
        click.echo('\nChirp module Verilog instantiation code:\n')
        i = max(11, hexlen(min_ctrl), hexlen(max_ctrl),
                hexlen(div), hexlen(inc))
        click.echo('Chirp Chirp0 (')
        click.echo('   .clk       ( {:<{}} ),'.format('chirp_clk', i))
        click.echo('   .rst       ( {:<{}} ),'.format('chirp_rst', i))
        click.echo('   .delay     ( {:<{}} ),'.format('chirp_delay', i))
        click.echo('   .min_ctrl  ( {:<{}} ),'.format('32\'h{:X}'.format(
                                               min_ctrl), i))
        click.echo('   .max_ctrl  ( {:<{}} ),'.format('32\'h{:X}'.format(
                                               max_ctrl), i))
        click.echo('   .div_rate  ( {:<{}} ),'.format('32\'h{:X}'.format(
                                               div), i))
        click.echo('   .inc_rate  ( {:<{}} ),'.format('32\'h{:X}'.format(
                                               inc), i))
        click.echo('   .nco_reset ( {:<{}} ),'.format('nco_reset', i))
        click.echo('   .nco_ctrl  ( {:<{}} )'.format('nco_ctrl', i))
        click.echo(');')


@cli.command()
@click.argument('ctr_freq', type=float)
@click.argument('dev_freq', type=float)
def fm_values(ctr_freq, dev_freq):
    """
    Calculates FM input port values.

    \b
    CTR_FREQ is the center frequency in Hertz.
    DEV_FREQ is the maximum frequency deviation in Hertz.
    """
    click.echo('FM module output specifications:')
    print('  Center frequency of modulation: {:.2f} Hz'.format(ctr_freq))
    print('  Maximum frequency deviation: {:.2f} Hz'.format(dev_freq))
    ctr_ctrl = freq_to_ctrl(ctr_freq)
    dev_ctrl = freq_to_ctrl(dev_freq)
    dev = int(log(dev_ctrl, 2))+1

    click.echo('\nFM module input ports:')
    print('  ctr_ctrl:  0x{:X}'.format(ctr_ctrl))
    print('  deviation: 0x{:X}\n'.format(dev))


if __name__ == "__main__":
    cli()
