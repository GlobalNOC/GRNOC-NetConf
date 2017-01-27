#!/usr/bin/perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Data::Dumper;
use GRNOC::NetConf::Device::Brocade::MLXe::5_8_0_Test;
use GRNOC::NetConf::Device;
use Test::More tests => 2;


my $device;
my $response;

$device = GRNOC::NetConf::Device::Brocade::MLXe::5_8_0_Test->new( host => '156.56.6.220', auto_connect => 0,
                                                                  port => 830,
                                                                  username => '',
                                                                  password => '',
                                                                  type => 'Brocade',
                                                                  model => 'MLXe',
                                                                  version => '5.8.0' );

# Validate edit_config when it receives a response indicating success.
my $good_edit_resp = '<nc:rpc-reply xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0" xmlns:brcd="http://brocade.com/ns/netconf/config/netiron-config/" message-id="1"><nc:ok></nc:ok></nc:rpc-reply>';

$device->set_response($good_edit_resp);

$response = $device->edit_configuration();
ok($response == 1, 'Edit was successful');


# Validate edit_config when it receives a response indicating failure.
my $bad_edit_resp = '<nc:rpc-reply xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0" xmlns:brcd="http://brocade.com/ns/netconf/config/netiron-config/" message-id="1"></nc:rpc-reply>';

$device->set_response($bad_edit_resp);

$response = $device->edit_configuration();
ok($response == 0, 'Edit was not successful');
