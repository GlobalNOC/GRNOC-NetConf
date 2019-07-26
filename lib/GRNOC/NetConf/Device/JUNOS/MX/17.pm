#!/usr/bin/perl

package GRNOC::NetConf::Device::JUNOS::MX::17;

use strict;
use warnings;

use Moo;
use GRNOC::Log;
use XML::Writer;
use XML::Simple;
use Data::Dumper;

has logger => (is => 'rwp');
has ssh => (is => 'rwp');
has chan => (is => 'rwp');
has msg_id => (is => 'rwp');
has auto_connect => (is => 'rwp', default => 1);
has error => (is => 'rwp', default => '');

use constant NETCONF => "urn:ietf:params:xml:ns:netconf:base:1.0";
use constant JUNOS => "http://xml.juniper.net/junos/17.3R3/junos";
=head1 GRNOC::NetConf::Device::JUNOS::MX::17.3R3

=cut

sub BUILD{

    my ($self) = @_;

    my $logger = GRNOC::Log->get_logger("GRNOC::NetConf::Device::JUNOS::MX::17");
    $self->_set_logger($logger);
    $self->logger->info("Creating device: Juniper MX 17");

    if ($self->auto_connect == 1) {
        $self->_connect();
    }
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


=head2 send

=cut

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
        $self->logger->debug("Written: $nbytes Total Written: $written Total Expected: $len");
        substr($xml, 0, $nbytes) = '';
    }

    return 1;
}

=head2 recv
=cut
sub recv{
    my $self = shift;

    $self->chan->blocking(0);

    my ($resp, $buf);
    my $read;
    my $timeout = time() + 15;
    do {
        # Wait up to 10 seconds for data to become available before attempting
        # to read anything (in order to avoid busy-looping on $chan->read())
        my @poll = ({ handle => $self->chan, events => 'in' });
        $self->ssh->poll(10000, \@poll);

        my $nbytes = $self->chan->read($buf, 65536);
        if (!defined $nbytes || time() > $timeout) {
            $self->logger->error("Failed to read from SSH channel!");
            return;
        }

        if ($nbytes > 0) {
            $timeout = time() + 15;
            $self->logger->debug("Read: $nbytes Total Read: $read");
        }

        $read += $nbytes;
        $resp .= $buf;
    } until($resp =~ s/]]>]]>$//);

    $self->logger->debug("Received: $resp");

    my $xs = XML::Simple->new();
    my $doc = undef;

    eval {
        $doc = $xs->XMLin($resp);
    };
    if ($@) {
        $self->logger->error("$@");
    }

    return $doc;
}


=head2 do_handshake
=cut
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

sub get_vlans{
    my $self = shift;
    my %params = @_;

    my $xml = "";
    my $writer = XML::Writer->new( OUTPUT => \$xml,
                                   NAMESPACES => 1,
                                   PREFIX_MAP => { NETCONF => 'nc',
                                                   JUNOS => 'junos' },
                                   FORCED_NS_DECLS => [NETCONF, JUNOS] );

    $writer->startTag([NETCONF, "rpc"], "message-id" => $self->_get_msg_id() );
    $writer->startTag([JUNOS, "get-bridge-instance-information"]);
    $writer->endTag();
    $writer->endTag();
    $writer->end();

    $self->send($xml);

    my $resp = $self->recv();

    #response
#<rpc-reply xmlns:junos="http://xml.juniper.net/junos/17.3R3/junos">
#    <l2ald-bridge-instance-information xmlns="http://xml.juniper.net/junos/17.3R3/junos-l2al" junos:style="brief">
#        <l2ald-bridge-instance-group>
#            <l2rtb-brief-summary/>
#            <l2rtb-name>default-switch</l2rtb-name>
#            <l2rtb-bridging-domain>vlan10</l2rtb-bridging-domain>
#            <l2rtb-bridge-vlan>10</l2rtb-bridge-vlan>
#            <l2rtb-interface-name/>
#        </l2ald-bridge-instance-group>
#    </l2ald-bridge-instance-information>
#    <cli>
#        <banner></banner>
#    </cli>
#</rpc-reply>


    my $vlans = $resp->{'l2ald-bridge-instance-information'}->{'l2ald-bridge-instance-group'}
    my @vlans;
    foreach my $vlan (@{$vlans}){
	my $obj = {};
	$obj->{'vlan'} = $vlan->{'l2rtb-bridge-vlan'};
	$obj->{'name'} = $vlan->{'l2rtb-bridging-domain'};
	$obj->{'ports'} = [];
	push(@vlans, $obj);
    }

    return \@vlans;
}

sub get_bridge_domain_interfaces{
    
}

sub get_interfaces{
    my $self = shift;
    my %params = @_;

#<rpc-reply xmlns:junos="http://xml.juniper.net/junos/17.3R3/junos">
#    <rpc>
#        <get-interface-information>
#        </get-interface-information>
#    </rpc>
#    <cli>
#        <banner></banner>
#    </cli>
#</rpc-reply>


    my $xml = "";
    my $writer = XML::Writer->new( OUTPUT => \$xml,
                                   NAMESPACES => 1,
                                   PREFIX_MAP => { NETCONF => 'nc',
                                                   JUNOS => 'junos' },
                                   FORCED_NS_DECLS => [NETCONF, JUNOS] );
    
    $writer->startTag([NETCONF, "rpc"], "message-id" => $self->_get_msg_id() );
    $writer->startTag([JUNOS, "get-interface-information"]);
    $writer->endTag();
    $writer->endTag();
    $writer->end();

    $self->send($xml);
    my $resp = $self->recv();


    my $ints = $resp->{'interface-information'}->{'physical-interface'};
    
    my @interfaces;
    foreach my $int (keys (%{$ints})){
	my $i = $ints->{$int};

	my $obj = {};	
	$obj->{'speed'} = $i->{'speed'};
	$obj->{'duplex'} = 'full';
	$obj->{'name'} = $int;
	$obj->{'status'} = $i->{'oper-status'};
	$obj->{'mac_addr'} = $i->{'current-physical-address'};
	$obj->{'description'} = $i->{'description'};
	$obj->{'mtu'} = $i->{'mtu'};
	$obj->{'hardware_type'} = $i->{'speed'};
	$obj->{'id'} = $i->{'snmp-index'};
	$obj->{'admin_status'} = $i->{'admin-status'}->{'content'};
	$obj->{'name'} = $int;
	$obj->{'input'} = { bytes => $i->{'traffic-statistics'}->{'input-bps'}, packets => $i->{'traffic-statistics'}->{'input-pps'}};
	$obj->{'output'} ={ bytes => $i->{'traffic-statistics'}->{'output-bps'}, packets => $i->{'traffic-statistics'}->{'output-pps'}};

	foreach my $key (keys (%{$obj})){
	    $obj->{$key} =~ s/\R//g;
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
    $writer->addPrefix(JUNOS, 'junos');

    $writer->startTag([NETCONF, "rpc"], "message-id" => $self->_get_msg_id());
    $writer->startTag([NETCONF, "get-config"]);
    $writer->startTag([NETCONF, "source"]);
    $writer->emptyTag([NETCONF, "running"]);
    $writer->endTag();
    $writer->endTag();
    $writer->endTag();
    $writer->end();

    $self->send($xml);
    my $resp = $self->recv();

    return $resp->{'data'}->{'configuration'};
}

sub edit_configuration{
    my $self = shift;
    my %params = @_;

    my $config = $params{'config'};
    
    my $xml = "";
    my $writer = XML::Writer->new( OUTPUT => \$xml,
				   UNSAFE => 1,
                                   NAMESPACES => 1);

    $writer->addPrefix(NETCONF, 'nc');
    $writer->addPrefix(JUNOS, 'junos');

    $writer->startTag([NETCONF, "rpc"], "message-id" => $self->_get_msg_id());
    $writer->startTag([NETCONF, "edit-config"]);
    $writer->startTag([NETCONF, "target"]);
    $writer->emptyTag([NETCONF, "candidate"]);
    $writer->endTag();

    $writer->startTag([NETCONF, "config"]);

    ##CONFIG GOES IN HERE
    $writer->raw($config);

    $writer->endTag();

    $writer->startTag([NETCONF, "default-operation"]);
    $writer->characters("merge");
    $writer->endTag();
    $writer->endTag();
    $writer->endTag();
    $writer->end();

    warn "XML: $xml\n";

    $self->send($xml);
    my $resp = $self->recv();

    #check for success

    my $res = $self->commit();
    
    return $resp;
}

sub commit{
    my $self = shift;
    my %params = @_;


    my $xml = "";
    my $writer = XML::Writer->new( OUTPUT => \$xml,
                                   NAMESPACES => 1 );

    $writer->addPrefix(NETCONF, 'nc');
    $writer->addPrefix(JUNOS, 'junos');

    $writer->startTag([NETCONF, "rpc"], "message-id" => $self->_get_msg_id());
    $writer->startTag([NETCONF, "commit"]);
    $writer->endTag();
    $writer->endTag();
    $writer->end();


    warn "XML: $xml\n";

    $self->send($xml);
    my $resp = $self->recv();
    return $resp;
}


1;
