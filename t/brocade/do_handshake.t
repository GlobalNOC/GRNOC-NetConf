#!/usr/bin/perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../../lib";

use Data::Dumper;
use GRNOC::Log;
use GRNOC::NetConf::Device;
use GRNOC::NetConf::Device::Brocade::MLXe::5_8_0;
use Test::More tests => 1;
use XML::Simple;


my $device;
my $parser = XML::Simple->new();
my $response;

$device = GRNOC::NetConf::Device::Brocade::MLXe::5_8_0->new( host => '156.56.6.220', auto_connect => 0,
                                                             port => 830,
                                                             username => '',
                                                             password => '',
                                                             type => 'Brocade',
                                                             model => 'MLXe',
                                                             version => '5.8.0' );

*{GRNOC::NetConf::Device::Brocade::MLXe::5_8_0::send} = sub { return 1 };
*{GRNOC::NetConf::Device::Brocade::MLXe::5_8_0::recv} = sub { return 1 };

$response = $device->do_handshake();

ok(defined $response, 'Get was successful');
