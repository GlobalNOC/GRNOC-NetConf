#!/usr/bin/perl
use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../../lib";

use Data::Dumper;
use GRNOC::Log;
use GRNOC::NetConf::Device;
use Test::More tests => 1;

my $logger = GRNOC::Log->new(config => '/etc/grnoc/logging.conf');
my $log    = $logger->get_logger('GRNOC.Demo');

my $device;
$device = GRNOC::NetConf::Device->new( host => '156.56.6.220',
                                       port => 830,
                                       username => '',
                                       password => '',
                                       type => 'Brocade',
                                       model => 'MLXe',
                                       version => '5.8.0',
                                       auto_connect => 0 );

ok(defined $device, "Device created.");
