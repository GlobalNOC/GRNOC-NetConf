#!/usr/bin/perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Data::Dumper;
use GRNOC::NetConf::Device::Brocade::MLXe::5_8_0;
use GRNOC::NetConf::Device;
use Test::More tests => 2;
use XML::Simple;

my $parser = XML::Simple->new();

my $device;
my $response;

$device = GRNOC::NetConf::Device->new( host => '156.56.6.220', auto_connect => 0,
                                       port => 830,
                                       username => '',
                                       password => '',
                                       type => 'Brocade',
                                       model => 'MLXe',
                                       version => '5.8.0' );

# Validate get_interfaces when it receives a response with multiple
# interfaces.
my $multi_interface_resp = '<nc:rpc-reply xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0" xmlns:brcd="http://brocade.com/ns/netconf/config/netiron-config/" message-id="1">
 <nc:data>
<netiron-statedata xmlns="http://brocade.com/ns/netconf/config/netiron-config/">
<brcd:interface-statedata>
 <brcd:interface>
  <brcd:interface-id>ethernet 15/8</brcd:interface-id>
  <brcd:link-state>
   <brcd:disabled></brcd:disabled>
  </brcd:link-state>
  <brcd:l2-state>
   <brcd:none></brcd:none>
  </brcd:l2-state>
  <brcd:duplex>
   <brcd:none></brcd:none>
  </brcd:duplex>
  <brcd:speed>None</brcd:speed>
  <brcd:tag-mode>
   <brcd:no></brcd:no>
  </brcd:tag-mode>
  <brcd:priority-level>
   <brcd:level0></brcd:level0>
  </brcd:priority-level>
  <brcd:mac-address>cc4e.240c.0aa7</brcd:mac-address>
 </brcd:interface>
 <brcd:interface>
  <brcd:interface-id>management 1</brcd:interface-id>
  <brcd:link-state>
   <brcd:up></brcd:up>
  </brcd:link-state>
  <brcd:l2-state>
   <brcd:forward></brcd:forward>
  </brcd:l2-state>
  <brcd:duplex>
   <brcd:full></brcd:full>
  </brcd:duplex>
  <brcd:speed>1G</brcd:speed>
  <brcd:tag-mode>
   <brcd:yes></brcd:yes>
  </brcd:tag-mode>
  <brcd:priority-level>
   <brcd:level0></brcd:level0>
  </brcd:priority-level>
  <brcd:mac-address>cc4e.240c.0800</brcd:mac-address>
 </brcd:interface>
</brcd:interface-statedata>
</netiron-statedata>
 </nc:data>
</nc:rpc-reply>';


*{GRNOC::NetConf::Device::Brocade::MLXe::5_8_0::send} = sub { return 1 };
*{GRNOC::NetConf::Device::Brocade::MLXe::5_8_0::recv} = sub { return $parser->XMLin($multi_interface_resp) };

$response = $device->get_interfaces();
ok(scalar @{$response} == 2, 'Number of interfaces parsed is correct');


# Validate get_interfaces when it receives a response with a single
# interface.
my $single_interface_resp = '<nc:rpc-reply xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0" xmlns:brcd="http://brocade.com/ns/netconf/config/netiron-config/" message-id="1">
 <nc:data>
<netiron-statedata xmlns="http://brocade.com/ns/netconf/config/netiron-config/">
<brcd:interface-statedata>
 <brcd:interface>
  <brcd:interface-id>management 1</brcd:interface-id>
  <brcd:link-state>
   <brcd:up></brcd:up>
  </brcd:link-state>
  <brcd:l2-state>
   <brcd:forward></brcd:forward>
  </brcd:l2-state>
  <brcd:duplex>
   <brcd:full></brcd:full>
  </brcd:duplex>
  <brcd:speed>1G</brcd:speed>
  <brcd:tag-mode>
   <brcd:yes></brcd:yes>
  </brcd:tag-mode>
  <brcd:priority-level>
   <brcd:level0></brcd:level0>
  </brcd:priority-level>
  <brcd:mac-address>cc4e.240c.0800</brcd:mac-address>
 </brcd:interface>
</brcd:interface-statedata>
</netiron-statedata>
 </nc:data>
</nc:rpc-reply>';

*{GRNOC::NetConf::Device::Brocade::MLXe::5_8_0::recv} = sub { return $parser->XMLin($single_interface_resp) };

$response = $device->get_interfaces();
ok(scalar @{$response} == 1, 'Reponse with single interface parsed correctly');
