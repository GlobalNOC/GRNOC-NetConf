#!/usr/bin/perl

package GRNOC::NetConf::Device;

use strict;
use warnings;

use Net::SSH2;
use GRNOC::NetConf::Device::Brocade;
use GRNOC::NetConf::Device::JUNOS;
use GRNOC::Log;

use Moo;

has logger => ( is => 'rwp' );
has host => ( is => 'rwp' );
has port => ( is => 'rwp', default => 22 );
has username => ( is => 'rwp' );
has password => ( is => 'rwp' );
has type => ( is => 'rwp' );
has version => (is => 'rwp' );
has device => ( is => 'rwp' );
has model => ( is => 'rwp' );
has auto_connect => ( is => 'rwp', default => 1 );
has error => ( is => 'rwp', default => '' );

our $VERSION = '0.0.2';

=head1 GRNOC::NetConf::Device

=cut

=over 4

=item auto_connect

=item device

=item error

=item host

=item logger

=item model

=item password

=item port

=item type

=item username

=item version

=back

=head2 BUILD

=cut
sub BUILD{
    my ($self) = @_;

    my $logger = GRNOC::Log->get_logger("GRNOC::NetConf::Device");
    $self->_set_logger( $logger );

    my $ssh2 = Net::SSH2->new();
    if ($self->auto_connect == 1) {
        $self->logger->info("Connecting to Device via SSH");
        $ssh2->connect($self->{'host'}, $self->{'port'});
        $ssh2->auth(username => $self->{'username'},
                    password => $self->{'password'});
    }
    $self->{'ssh'} = $ssh2;

    my $_device = $self->_create_type_object();
    if ($self->error ne '') {
        return undef;
    }

    $self->_set_device($_device);
    return $self;
}

sub _create_type_object{
    my $self = shift;

    my $_device;
    if ($self->type eq 'JUNOS') {
        $_device = GRNOC::NetConf::Device::JUNOS->new(ssh => $self->{'ssh'}, model => $self->model, version => $self->version, auto_connect => $self->auto_connect);
    } elsif ($self->type eq 'Brocade') {
        $_device = GRNOC::NetConf::Device::Brocade->new(ssh => $self->{'ssh'}, model => $self->model, version => $self->version, auto_connect => $self->auto_connect);
    } else {
        my $error = "Unsupported type $self->type specified.";
        $self->logger->error($error);
        $self->_set_error($error);
    }

    if (defined $_device && $_device->error ne '') {
        $self->_set_error($_device->error);
        $_device = undef;
    }

    return $_device;
}

=head2 send

=cut
sub send{
    my $self = shift;
    return $self->device->send( @_ );
}

=head2 recv

=cut
sub recv{
    my $self = shift;
    return $self->device->recv();
}

=head2 get_interfaces

=cut
sub get_interfaces{
    my $self = shift;
    my %params = @_;
    $self->logger->debug("Fetching Interfaces");
    return $self->device->get_interfaces( %params );
}

=head2 get_configuration

=cut
sub get_configuration{
    my $self = shift;
    my %params = @_;
    $self->logger->debug("Fetching Configuration");
    return $self->device->get_configuration( %params );
}

=head2 edit_configuration

=cut
sub edit_configuration{
    my $self = shift;
    my %params = @_;
    $self->logger->debug("Editing Configuration");
    return $self->device->edit_configuration( %params );
}

1;
