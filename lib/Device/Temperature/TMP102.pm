package Device::Temperature::TMP102;
use Moose;

# VERSION

extends 'Device::SMBus';

use constant {
    TMP_RD    => 0x93,
    TMP_WR    => 0x92,
    TEMP_REG  => 0x00,
};

has '+I2CDeviceAddress' => (
    is      => 'ro',
    default => 0x48,
);

has debug => (
    is      => 'ro',
    default => 0,
);

sub getTemp {
    my ( $self ) = @_;

    # We want to write a value to the TMP
    $self->writeByte( TMP_WR );

    # Set pointer regster to temperature register (it's already there
    # by default, but you never know)
    $self->writeByte( TEMP_REG );

    my $results = $self->readWordData( 0x00 );

    return $self->convertTemp( $results );
}

sub convertTemp {
    my ( $self, $value ) = @_;

    my $lsb = ( $value & 0xff00 );
    $lsb = $lsb >> 8;

    my $msb = $value & 0x00ff;

    printf( "results: %04x\n", $value ) if $self->debug;
    printf( "msb:     %02x\n", $msb )   if $self->debug;
    printf( "lsb:     %02x\n", $lsb )   if $self->debug;

    my $temp = ( $msb << 8 ) | $lsb;

    # The TMP102 temperature registers are left justified, correctly
    # right justify them
    $temp = $temp >> 4;

    # test for negative numbers
    if ( $temp & ( 1 << 11 ) ) {

        # twos compliment plus one, per the docs
        $temp = ~$temp + 1;

        # keep only our 12 bits
        $temp &= 0xfff;

        # negative
        $temp *= -1;
    }

    # convert to a celsius temp value
    $temp = $temp / 16;

    return $temp;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

Device::Temperature::TMP102 - I2C interface to TMP102 temperature sensor using Device::SMBus

=head1 DESCRIPTION

Read temperature for a TMP102 temperature sensor over I2C.

This library correctly handles temperatures below freezing (0°C).

=head1 TROUBLESHOOTING

Refer to the documentation on L<Device::SMBus> for information on
enabling the i2c driver and finding the addresses of your i2c devices.

In the process of testing this on raspberry pi, I saw this error:

  perl: symbol lookup error: .../Device/SMBus/SMBus.so: undefined symbol: i2c_smbus_write_byte

The fix was to install the package libi2c-dev.


=head1 SEE ALSO

  https://www.sparkfun.com/products/9418

  https://www.sparkfun.com/datasheets/Sensors/Temperature/tmp102.pdf

  http://donalmorrissey.blogspot.com/2012/09/raspberry-pi-i2c-tutorial.html

=head1 SOURCE

With code and comments taken from example code for the ATmega328:

  https://www.sparkfun.com/products/11931

  http://www.sparkfun.com/datasheets/Sensors/Temperature/tmp102.zip

  /*
    TMP Test Code
	5-31-10
    Copyright Spark Fun Electronics© 2010
    Nathan Seidle

	Example code for the TMP102 11-bit I2C temperature sensor

	You will need to connect the ADR0 pin to one of four places. This
	code assumes ADR0 is tied to VCC.  This results in an I2C address
	of 0x93 for read, and 0x92 for write.

	This code assumes regular 12 bit readings. If you want the
	extended mode for higher temperatures, the code will have to be
	modified slightly.

  */

=head1 VERSION

=head1 ATTRIBUTES

=head2 I2CDeviceAddress

Contains the I2CDevice Address for the bus on which your TMP102 is
connected. The default value is 0x48.

=head1 METHODS

=head2 getTemp()

    $self->getTemp()

Returns the current temperature, in degrees Celsius.

=head2 convertTemp()

    $self->convertTemp( $reading )

Given a value read from the TMP102, convert the value to degrees
Celsius.

=cut
