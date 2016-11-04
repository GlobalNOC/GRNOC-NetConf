#!/usr/bin/perl

use strict;
use warnings;

use GRNOC::NetConf::Device;
use GRNOC::CLI;
use GRNOC::Log;

use Data::Dumper;

sub main{

    my $grnoc_logger = GRNOC::Log->new( level => 'INFO');
    my $logger = GRNOC::Log->get_logger();

    my $cli = GRNOC::CLI->new();
    my $username = $cli->get_input("Username");
    my $password = $cli->get_password("Password");

    my $device = GRNOC::NetConf::Device->new( username => $username,
                                              password => $password,
                                              host => '156.56.6.220',
                                              port => 830,
                                              type => 'Brocade',
                                              model => 'MLXe',
                                              version => '5.8.0');
                                              
    my $interfaces = $device->get_interfaces();

    my $config = $device->get_configuration();

    open(my $foo, ">", "/tmp/foo.txt");
    print $foo Data::Dumper::Dumper($interfaces);
    print $foo Data::Dumper::Dumper($config);
    close($foo);
}
    
main();
