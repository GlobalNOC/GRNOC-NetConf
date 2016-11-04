#!/usr/bin/perl

package GRNOC::NetConf::Device::Brocade::MLXe::5_8_0;

use strict;
use warnings;

use Moo;
use XML::Writer;
use XML::Simple;

has logger => (is => 'rwp');
has ssh => (is => 'rwp');
has chan => (is => 'rwp');
has msg_id => (is => 'rwp');


use constant NETCONF => "urn:ietf:params:xml:ns:netconf:base:1.0";
use constant BROCADE => "http://brocade.com/ns/netconf/config/netiron-config/";

sub BUILD{
    my ($self) = @_;

    my $logger = GRNOC::Log->get_logger("GRNOC::NetConf::Device::Brocade::MLXe::5_8_0");
    $self->_set_logger($logger);

    $self->_connect();
    $self->_set_msg_id(0);

    return $self;
}

sub _connect{
    my $self = shift;
    $self->logger->debug("Creating SSH Channel");
    my $chan = $self->ssh->channel();
    $self->_set_chan($chan);
    
    $self->logger->debug("starting subsystem netconf");
    my $subsystem = $self->chan->subsystem('netconf');
    
    $self->do_handshake();

}

sub _get_msg_id{
    my $self = shift;
    $self->_set_msg_id( $self->msg_id +1 );
    return $self->msg_id;
}

sub send{
    my $self = shift;
    my $xml = shift;

    $self->logger->debug("Sending: " . $xml);

    $xml .= ']]>]]>';

    my $len = length($xml);

    $self->chan->blocking(1);

    my $written = 0;
    while($written != $len) {
        my $nbytes = $self->chan->write($xml);
        if(!defined($nbytes)){
            $self->logger->error("Error writing to Channel\n");
            return 0;
        }
        $written += $nbytes;
        $self->logger->debug("Wrote $nbytes bytes (total written: $written).");
        substr($xml, 0, $nbytes) = '';
    }
    $self->logger->debug("Successfully wrote $written bytes to SSH channel!");

    return 1;
}

sub recv{
    my $self = shift;

    $self->chan->blocking(0);

    $self->logger->debug("Reading XML response from Netconf server...");
    my ($resp, $buf);
    do {
        # Wait up to 10 seconds for data to become available before attempting
        # to read anything (in order to avoid busy-looping on $chan->read())
        my @poll = ({ handle => $self->chan, events => 'in' });
        $self->ssh->poll(10000, \@poll);

        my $nbytes = $self->chan->read($buf, 65536) || 0;
        $self->logger->debug("Read $nbytes bytes from SSH channel: '$buf'");
        $resp .= $buf;
    } until($resp =~ s/]]>]]>$//);
    $self->logger->debug("Received XML response '$resp'");
    
    my $xs = XML::Simple->new();
    my $doc = $xs->XMLin($resp);

    return $doc;

}

sub do_handshake{
    my $self = shift;
    $self->logger->debug("Sending Handshake");
    my $res = $self->send($self->_hello());

    $self->logger->debug("Waiting for handshake response");
    my $handshake = $self->recv();
    
    return 1;
}

sub _hello{
    my $self = shift;
    
    my $hello = "<hello xmlns=\"urn:ietf:params:xml:ns:netconf:base:1.0\"><capabilities><capability>urn:ietf:params:netconf:base:1.0</capability></capabilities></hello>";
                      
    return $hello;
}

sub get_interfaces{
    my $self = shift;
    my %params = @_;

    my $xml = "";
    my $writer = XML::Writer->new( OUTPUT => \$xml,
                                   NAMESPACES => 1,
                                   PREFIX_MAP => { NETCONF => 'nc',
                                                   BROCADE => 'brcd' },
                                   FORCED_NS_DECLS => [NETCONF, BROCADE] );
    
    $writer->startTag([NETCONF, "rpc"], "message-id" => $self->_get_msg_id() );
    $writer->startTag([NETCONF, "get"]);
    $writer->startTag([NETCONF, "filter"]);
    $writer->startTag([BROCADE, "netiron-statedata"]);
    $writer->startTag([BROCADE, "interface-statedata"]);
    $writer->endTag();
    $writer->endTag();
    $writer->endTag();
    $writer->endTag();
    $writer->endTag();
    $writer->end();

    $self->send($xml);
    my $resp = $self->recv();

    my @interfaces;
    foreach my $int (@{$resp->{'nc:data'}->{'netiron-statedata'}->{'brcd:interface-statedata'}->{'brcd:interface'}}){
        my $obj = {};
        $obj->{'mac-address'} = $int->{'brcd:mac-address'};
        $obj->{'speed'} = $int->{ 'brcd:speed'};
        if(defined($int->{'brcd:duplex'}->{'brcd:full'})){
            $obj->{'duplex'} = "full";
        }else{
            $obj->{'duplex'} = "half";
        }

        $obj->{'name'} = $int->{'brcd:interface-id'};
        if(defined($int->{'brcd:tag-mode'}->{'brcd:yes'})){
            $obj->{'tag_mode'} = "enabled";
        }else{
            $obj->{'tag_mode'} = "disabled";
        }

        if(defined($int->{'brcd:l2-state'}->{'brcd:forward'})){
            $obj->{'l2-state'} = "forward";
        }else{
            $obj->{'l2-state'} = "blocked";
        }

        if(defined($int->{'brcd:link-state'}->{'brcd:up'})){
            $obj->{'link_state'} = "up";
        }else{
            $obj->{'link_state'} = "down";
        }
        push(@interfaces, $obj);
    }
    
    return \@interfaces;
}

sub get_configuration{
    my $self = shift;
    my %params = @_;
    
    my $xml = "";
    my $writer = XML::Writer->new( OUTPUT => \$xml,
                                   NAMESPACES => 1 );

    $writer->addPrefix(NETCONF, 'nc');
    $writer->addPrefix(BROCADE, 'brcd');

    $writer->startTag([NETCONF, "rpc"], "message-id" => $self->_get_msg_id());
    $writer->startTag([NETCONF, "get-config"]);
    $writer->startTag([NETCONF, "source"]);
    $writer->emptyTag([NETCONF, "running"]);
    $writer->endTag();
    $writer->startTag([NETCONF, "filter"], [NETCONF, "type"] => "subtree");
    $writer->startTag([BROCADE, "netiron-config"]);
    $writer->endTag();
    $writer->endTag();
    $writer->endTag();
    $writer->endTag();
    $writer->end();

    $self->send($xml);
    my $resp = $self->recv();
    
    return $resp->{'nc:data'}->{'brcd:netiron-config'};
}


1;

