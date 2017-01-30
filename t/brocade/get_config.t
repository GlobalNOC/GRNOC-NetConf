#!/usr/bin/perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../../lib";

use GRNOC::NetConf::Device;
use GRNOC::NetConf::Device::Brocade::MLXe::5_8_0;
use Test::More tests => 4;
use XML::Simple;


my $device;
my $parser = XML::Simple->new();
my $response;

$device = GRNOC::NetConf::Device->new( host => '156.56.6.220', auto_connect => 0,
                                       port => 830,
                                       username => '',
                                       password => '',
                                       type => 'Brocade',
                                       model => 'MLXe',
                                       version => '5.8.0' );

my $good_config_resp = '<nc:rpc-reply xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0" xmlns:brcd="http://brocade.com/ns/netconf/config/netiron-config/" message-id="1"><nc:data><brcd:netiron-config><brcd:vlan-config><brcd:vlan><brcd:vlan-id>1</brcd:vlan-id><brcd:vlan-name>DEFAULT-VLAN</brcd:vlan-name><brcd:untagged>ethernet 1/1 to 1/2 </brcd:untagged><brcd:untagged>ethernet 3/1 to 3/2 </brcd:untagged><brcd:untagged>ethernet 5/1 to 5/2 </brcd:untagged><brcd:untagged>ethernet 7/1 to 7/2 </brcd:untagged><brcd:untagged>ethernet 9/1 to 9/2 </brcd:untagged><brcd:untagged>ethernet 11/1 to 11/2 </brcd:untagged><brcd:untagged>ethernet 13/1 to 13/2 </brcd:untagged><brcd:untagged>ethernet 15/1 to 15/8 </brcd:untagged></brcd:vlan><brcd:vlan><brcd:vlan-id>14</brcd:vlan-id><brcd:vlan-name></brcd:vlan-name><brcd:tagged>ethernet 15/2 </brcd:tagged><brcd:router-interface>ve 14</brcd:router-interface></brcd:vlan><brcd:vlan><brcd:vlan-id>101</brcd:vlan-id><brcd:vlan-name></brcd:vlan-name><brcd:tagged>ethernet 1/1 to 1/2 </brcd:tagged></brcd:vlan><brcd:vlan><brcd:vlan-id>112</brcd:vlan-id><brcd:vlan-name></brcd:vlan-name><brcd:tagged>ethernet 15/2 </brcd:tagged><brcd:tagged>ethernet 15/4 </brcd:tagged></brcd:vlan></brcd:vlan-config><brcd:interface-config><brcd:interface><brcd:interface-id>ethernet 15/2</brcd:interface-id><brcd:alarm-monitoring></brcd:alarm-monitoring><brcd:enable></brcd:enable><brcd:loop-detection></brcd:loop-detection><brcd:flow-control></brcd:flow-control><brcd:priority></brcd:priority></brcd:interface><brcd:interface><brcd:interface-id>ethernet 15/3</brcd:interface-id><brcd:alarm-monitoring></brcd:alarm-monitoring><brcd:disable></brcd:disable><brcd:loop-detection></brcd:loop-detection><brcd:flow-control></brcd:flow-control><brcd:priority></brcd:priority></brcd:interface><brcd:interface><brcd:interface-id>ethernet 15/4</brcd:interface-id><brcd:alarm-monitoring></brcd:alarm-monitoring><brcd:enable></brcd:enable><brcd:loop-detection></brcd:loop-detection><brcd:flow-control></brcd:flow-control><brcd:priority></brcd:priority></brcd:interface><brcd:interface><brcd:interface-id>ve 14</brcd:interface-id><brcd:enable></brcd:enable><brcd:ip><brcd:address>198.169.70.7/31</brcd:address></brcd:ip><brcd:ipv6><brcd:address>2001:468:ff:3::2/64</brcd:address><brcd:enable></brcd:enable></brcd:ipv6></brcd:interface><brcd:interface><brcd:interface-id>loopback 1</brcd:interface-id><brcd:enable></brcd:enable><brcd:ip><brcd:address>198.169.70.252/32</brcd:address></brcd:ip><brcd:ipv6><brcd:address>2001:468:fc:1::3/128</brcd:address></brcd:ipv6></brcd:interface></brcd:interface-config><brcd:mpls-config></brcd:mpls-config></brcd:netiron-config></nc:data></nc:rpc-reply>';

*{GRNOC::NetConf::Device::Brocade::MLXe::5_8_0::send} = sub { return 1 };
*{GRNOC::NetConf::Device::Brocade::MLXe::5_8_0::recv} = sub { return $parser->XMLin($good_config_resp) };

$response = $device->get_configuration();

ok(defined $response, 'Get was successful');
ok(defined $response->{'brcd:mpls-config'},      'Got mpls-config');
ok(defined $response->{'brcd:interface-config'}, 'Got interface-config');
ok(defined $response->{'brcd:vlan-config'},      'Got vlan-config');
