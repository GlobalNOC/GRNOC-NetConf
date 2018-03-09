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
has auto_connect => ( is => 'rwp', default => 1 );
has error => ( is => 'rwp', default => '' );

=head1 GRNOC::NetConf::Device::Brocade::MLXe

=cut

=over 4

=item auto_connect

=item error

=item logger

=item ssh

=item version

=item version_inst

=back

=head2 BUILD

=cut
sub BUILD{
    my ($self) = @_;

    my $logger = GRNOC::Log->get_logger("GRNOC::NetConf::Device::Brocade::MLXe");
    $self->_set_logger($logger);

    my $_version = $self->_connect_to_version();
    if ($self->error ne '') {
        return undef;
    }

    $self->_set_version_inst($_version);
    return $self;
}

sub _connect_to_version{
    my $self = shift;

    my $_version;
    if ($self->{'version'} =~ /5.8.0/) {
        $self->logger->debug("Creating 5.8.0 version");
        $_version = GRNOC::NetConf::Device::Brocade::MLXe::5_8_0->new(ssh => $self->ssh, auto_connect => $self->auto_connect);
    } else {
        my $error = "Unsupported version " . $self->version . " specified.";
        $self->logger->error($error);
        $self->_set_error($error);
    }

    
    if (defined $_version && $_version->error ne '') {
        $self->_set_error($_version->error);
        $_version = undef;
    }

    return $_version;
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
