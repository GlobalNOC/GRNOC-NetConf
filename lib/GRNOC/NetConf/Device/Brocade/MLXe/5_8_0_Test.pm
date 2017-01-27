#!/usr/bin/perl

package GRNOC::NetConf::Device::Brocade::MLXe::5_8_0_Test;

use strict;
use warnings;

use Moo;
use AnyEvent;
use XML::Writer;
use XML::Simple;

extends 'GRNOC::NetConf::Device::Brocade::MLXe::5_8_0';

has responseChan => (is => 'rwp');

=head2 send

Overrides the default send method that would otherwise send the
request over SSH.

=cut
sub send {
    my $self    = shift;
    my $payload = shift;

    $self->_set_responseChan(AnyEvent->condvar);
    $self->responseChan->send($payload);
}

=head2 recv

Overrides the default recv method that would otherwise receive the
request over SSH.

=cut
sub recv {
    my $self   = shift;

    my $chan   = $self->responseChan;
    my $string = $chan->recv();

    my $parser = XML::Simple->new();
    my $xml    = $parser->XMLin($string);
    return $xml;
}

1;
