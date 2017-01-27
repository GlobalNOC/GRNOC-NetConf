#!/usr/bin/perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Data::Dumper;
use GRNOC::NetConf::Device::Brocade::MLXe::5_8_0_Test;
use Test::More tests => 1;


my $device;
$device = GRNOC::NetConf::Device::Brocade::MLXe::5_8_0_Test->new( host => '127.0.0.1',
                                                                  port => 22,
                                                                  username => '',
                                                                  password => '',
                                                                  type => 'PC',
                                                                  model => 'notta',
                                                                  version => '0.0.0',
                                                                  auto_connect => 0 );

my $response;

$response = $device->do_handshake();
ok($response == 1, "Device completed handshake.");
