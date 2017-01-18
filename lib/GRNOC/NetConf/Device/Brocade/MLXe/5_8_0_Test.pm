#!/usr/bin/perl

package GRNOC::NetConf::Device::Brocade::MLXe::5_8_0_Test;

use strict;
use warnings;

use Moo;
use AnyEvent;
use Data::Dumper;
use XML::Writer;
use XML::Simple;

extends 'GRNOC::NetConf::Device::Brocade::MLXe::5_8_0';

has responseChan      => (is => 'rwp');
has responseXmlString => (is => 'rwp', default => '');

=head2 set_response

Gives user the ability to create responses that the device might
return for a given request. After the response has been received it is
discarded; In otherwords if you want to get the same response twice
you'll need to call this method twice.

=cut
sub set_response {
    my $self    = shift;
    my $payload = shift;

    $self->_set_responseXmlString($payload);
    return 1;
}

=head2 _connect

Makes the device think it's connected via SSH.

=cut
sub _connect {
    my $self = shift;
    return 1;
}

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
    if ($self->responseXmlString ne '') {
        $string = $self->responseXmlString;
        $self->_set_responseXmlString('');
    }

    my $parser = XML::Simple->new();
    my $xml    = $parser->XMLin($string);
    return $xml;
}

1;
