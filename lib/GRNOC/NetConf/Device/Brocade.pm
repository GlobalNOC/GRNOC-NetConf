#!/usr/bin/perl

package GRNOC::NetConf::Device::Brocade;

use strict;
use warnings;

use GRNOC::NetConf::Device::Brocade::MLXe;

use Moo;

has logger => ( is => 'rwp');
has ssh => ( is => 'rwp');
has model => (is => 'rwp');
has version => (is => 'rwp');
has model_inst => (is => 'rwp');

=head2 BUILD

=cut
sub BUILD{
    my ($self) = @_;
    
    my $logger = GRNOC::Log->get_logger("GRNOC::NetConf::Device::Brocade");
    $self->_set_logger($logger);

    $self->_connect_to_model_version();
    
    return $self;
}

sub _connect_to_model_version{
    my $self = shift;

    if($self->model eq 'MLXe'){
        $self->logger->debug("Creating Device MLXe");
        my $model = GRNOC::NetConf::Device::Brocade::MLXe->new( version => $self->version, ssh => $self->ssh);
        $self->_set_model_inst($model);
    }else{
        $self->logger->error("Unsupported Model: " . $self->model);
        return;
    }
}

=head2 send

=cut
sub send{
    my $self = shift;
    return $self->model_inst->send(@_);
}

=head2 recv

=cut
sub recv{
    my $self = shift;
    return $self->model_inst->recv();
}

=head2 get_interfaces

=cut
sub get_interfaces{
    my $self = shift;
    my %params = @_;
    return $self->model_inst->get_interfaces();
}

=head2 get_configuration

=cut
sub get_configuration{
    my $self = shift;
    my %params = @_;
    return $self->model_inst->get_configuration( %params );
}

=head2 edit_configuration

=cut
sub edit_configuration{
    my $self = shift;
    my %params = @_;
    return $self->model_inst->edit_configuration( %params );
}

1;
