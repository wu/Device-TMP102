use strict;
use warnings;

package Device::TMP102;

# VERSION

use Moose;
use POSIX;

use Device::Temperature::TMP102;


has 'I2CBusDevicePath' => ( is => 'ro', );


has Temperature => (
    is         => 'ro',
    isa        => 'Device::Temperature::PCA9685',
    lazy_build => 1,
);

sub _build_Temperature {
    my ($self) = @_;
    my $obj = Device::Temperature::TMP102->new(
        I2CBusDevicePath => $self->I2CBusDevicePath,
        debug            => 0,
    );
    return $obj;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

Device::TMP102 - I2C interface to TMP102 temperature sensor

=head1 VERSION

=head1 ATTRIBUTES

=head2 I2CBusDevicePath

this is the device file path for your I2CBus that the PCA9685 is connected on e.g. /dev/i2c-1
This must be provided during object creation.

=head2 Temperature

    $self->Temperature->getTemp();

This is a object of L<Device::Temperature::TMP102>
