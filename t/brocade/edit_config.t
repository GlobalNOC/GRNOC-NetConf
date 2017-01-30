#!/usr/bin/perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Data::Dumper;
use GRNOC::NetConf::Device;
use GRNOC::NetConf::Device::Brocade::MLXe::5_8_0;
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

# Validate edit_config when it receives a response indicating success.
my $good_edit_resp = '<nc:rpc-reply xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0" xmlns:brcd="http://brocade.com/ns/netconf/config/netiron-config/" message-id="1"><nc:ok></nc:ok></nc:rpc-reply>';

*{GRNOC::NetConf::Device::Brocade::MLXe::5_8_0::send} = sub { return 1 };
*{GRNOC::NetConf::Device::Brocade::MLXe::5_8_0::recv} = sub { return $parser->XMLin($good_edit_resp) };

$response = $device->edit_configuration();
ok($response == 1, 'Edit was successful');


# Validate edit_config when it receives a response indicating failure.
my $bad_edit_resp = '<nc:rpc-reply xmlns:nc="urn:ietf:params:xml:ns:netconf:base:1.0" xmlns:brcd="http://brocade.com/ns/netconf/config/netiron-config/" message-id="1"></nc:rpc-reply>';

*{GRNOC::NetConf::Device::Brocade::MLXe::5_8_0::recv} = sub { return $parser->XMLin($bad_edit_resp) };

$response = $device->edit_configuration();
ok($response == 0, 'Edit was not successful');
