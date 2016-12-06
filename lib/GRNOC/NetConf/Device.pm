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

my $VERSION = '0.0.1';

sub BUILD{
    my ($self) = @_;

    my $logger = GRNOC::Log->get_logger("GRNOC::NetConf::Device");

    $self->_set_logger( $logger );

    my $ssh2 = Net::SSH2->new();
    $ssh2->connect($self->{'host'}, $self->{'port'});
    $ssh2->auth(username => $self->{'username'},
                password => $self->{'password'});
    
    $self->{'ssh'} = $ssh2;

    $self->_create_type_object();

    return $self;
}

sub _create_type_object{
    my $self = shift;

    if($self->type eq 'JUNOS'){
        my $junos = GRNOC::NetConf::Device::JUNOS->new(ssh => $self->{'ssh'}, model => $self->model, version => $self->version);
        $self->_set_device( $junos );
    }elsif($self->type eq 'Brocade'){
        $self->logger->debug("Creating Brocade");
        my $mlxe = GRNOC::NetConf::Device::Brocade->new(ssh => $self->{'ssh'}, model => $self->model, version => $self->version);
        $self->_set_device( $mlxe );
    }else{
        $self->logger->error("Unsupported type: " . $self->type);
        return;
    }
    
}

sub send{
    my $self = shift;
    $self->logger->debug("Calling Send");
    return $self->device->send( @_ );
}

sub recv{
    my $self = shift;
    return $self->device->recv();
}

sub get_interfaces{
    my $self = shift;
    my %params = @_;
    $self->logger->debug("Fetching Interfaces");
    return $self->device->get_interfaces( %params );
}

sub get_configuration{
    my $self = shift;
    my %params = @_;
    $self->logger->debug("Fetching Configuration");
    return $self->device->get_configuration( %params );
}

sub edit_configuration{
    my $self = shift;
    my %params = @_;
    $self->logger->debug("Editing Configuration");
    return $self->device->edit_configuration( %params );
}

1;
