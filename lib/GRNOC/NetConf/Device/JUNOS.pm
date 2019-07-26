#!/usr/bin/perl

package GRNOC::NetConf::Device::JUNOS;

use strict;
use warnings;

use GRNOC::NetConf::Device::JUNOS::MX;

use Moo;

has logger => ( is => 'rwp');
has ssh => ( is => 'rwp');
has model => (is => 'rwp');
has version => (is => 'rwp');
has model_inst => (is => 'rwp');
has auto_connect => ( is => 'rwp', default => 1 );
has error => ( is => 'rwp', default => '' );

=head1 GRNOC::NetConf::Device::JUNOS

=cut

=over 4

=item auto_connect

=item error

=item logger

=item model

=item model_inst

=item ssh

=item version

=back

=head2 BUILD

=cut
sub BUILD{
    my ($self) = @_;
    
    my $logger = GRNOC::Log->get_logger("GRNOC::NetConf::Device::JUNOS");
    $self->_set_logger($logger);

    my $_model = $self->_connect_to_model_version();
    if ($self->error ne '') {
        return undef;
    }

    $self->_set_model_inst($_model);
    return $self;
}

sub _connect_to_model_version{
    my $self = shift;

    my $_model;
    if ($self->model eq 'MX') {
        $_model = GRNOC::NetConf::Device::JUNOS::MX->new(version => $self->version, ssh => $self->ssh, auto_connect => $self->auto_connect);
    } else {
        my $error = "Unsupported model $self->model specified.";
        $self->logger->error($error);
        $self->_set_error($error);
    }

    if (defined $_model && $_model->error ne '') {
        $self->_set_error($_model->error);
        $_model = undef;
    }

    return $_model;
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
