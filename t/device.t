#!/usr/bin/perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../../lib";

use GRNOC::NetConf::Device;
use Test::More tests => 4;


my $device;
$device = GRNOC::NetConf::Device->new( host => '156.56.6.220',
                                       port => 830,
                                       username => '',
                                       password => '',
                                       type => 'ACME',
                                       model => 'Switch1',
                                       version => '1.0.0',
                                       auto_connect => 0 );
ok($device->error ne '', "Bad device types results in error");


$device = GRNOC::NetConf::Device->new( host => '156.56.6.220',
                                       port => 830,
                                       username => '',
                                       password => '',
                                       type => 'Brocade',
                                       model => 'Switch1',
                                       version => '1.0.0',
                                       auto_connect => 0 );
ok($device->error ne '', "Bad device model results in error");


$device = GRNOC::NetConf::Device->new( host => '156.56.6.220',
                                       port => 830,
                                       username => '',
                                       password => '',
                                       type => 'Brocade',
                                       model => 'MLXe',
                                       version => '1.0.0',
                                       auto_connect => 0 );
ok($device->error ne '', "Bad device version results in error");

$device = GRNOC::NetConf::Device->new( host => '156.56.6.220',
                                       port => 830,
                                       username => '',
                                       password => '',
                                       type => 'Brocade',
                                       model => 'MLXe',
                                       version => '5.8.0',
                                       auto_connect => 0 );
ok($device->error eq '', "Device created.");
