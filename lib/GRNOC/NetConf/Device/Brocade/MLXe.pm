#!/usr/bin/perl

package GRNOC::NetConf::Device::Brocade::MLXe;

use strict;
use warnings;

use GRNOC::NetConf::Device::Brocade::MLXe::5_8_0;

use Moo;

has logger => (is => 'rwp');
has version => (is => 'rwp');
has ssh => (is => 'rwp');
has version_inst => (is => 'rwp');

=head2 BUILD

=cut
sub BUILD{
    my ($self) = @_;

    my $logger = GRNOC::Log->get_logger("GRNOC::NetConf::Device::Brocade::MLXe");
    $self->_set_logger($logger);

    $self->_connect_to_version();

    return $self;
}

sub _connect_to_version{
    my $self = shift;

    if($self->{'version'} =~ /5.8.0/){
        $self->logger->debug("Creating 5.8.0 version");
        my $version = GRNOC::NetConf::Device::Brocade::MLXe::5_8_0->new( ssh => $self->ssh);
        $self->_set_version_inst($version);

    }else{
        $self->logger->error("Unsupported Version: " . $self->version);
        return;
    }
}

=head2 send

=cut
sub send{
    my $self = shift;
    return $self->version_inst->send(@_);
}

=head2 recv

=cut
sub recv{
    my $self = shift;
    return $self->version_inst->recv();
}

=head2 get_interfaces

=cut
sub get_interfaces{
    my $self = shift;
    my %params = @_;
    return $self->version_inst->get_interfaces( %params );
}

=head2 get_configuration

=cut
sub get_configuration{
    my $self = shift;
    my %params = @_;
    return $self->version_inst->get_configuration( %params );
}

=head2 edit_configuration

=cut
sub edit_configuration{
    my $self = shift;
    my %params = @_;

    return $self->version_inst->edit_configuration( %params );
}

1;
