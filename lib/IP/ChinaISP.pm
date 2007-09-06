package IP::ChinaISP;

use strict;
use Socket qw/inet_aton/;
use Carp qw/croak/;

our $VERSION = '0.02';

sub new {

    my $caller = shift;
    my $class = ref $caller || $caller;
    my (@ips,$data_version);

    my $module_dir = $INC{'IP/ChinaISP.pm'};
    $module_dir =~ s/\.pm$//;

    open IPDB,"$module_dir/cnip.dat" or croak "Can't open ip database file: $!";
    while (<IPDB>) {
        if (/^#\s*(data version.+)$/) {
            $data_version = $1;
            next;
        }
        next if /^#|^$/;
        chomp;
        push @ips,[split];
    }
    close IPDB;

    bless { ips => \@ips, dv => $data_version },$class;
}
       
sub ip_isp {

    my $self = shift;
    $self = $self->new unless ref $self;
    my $ip = shift;

    my $nl = inet_aton($ip);
    croak "wrong ip $ip" unless defined $nl;

    my $ipint = unpack('N',$nl);

    my $isp = 'unknown';
    for (@{$self->{ips}}) {
        if ($ipint >= $_->[0] and $ipint <= $_->[1]) {
            $isp = $_->[2];
            last;
        }
    }

    return $isp;
}

sub data_version {
    
    my $self = shift;
    $self = $self->new unless ref $self;

    return $self->{dv};
}


1;



=head1 NAME

IP::ChinaISP - Retrieve an ISP in China from the given IP

=head1 VERSION

Version 0.02

=cut


=head1 SYNOPSIS

    use IP::ChinaISP;

    my $cnisp = IP::ChinaISP->new;
    my $isp = $cnisp->ip_isp('202.96.128.86');
    print $isp;

    print $cnisp->data_version;

=head1 METHODS

=head2 new()

Create a new object. 

Once an object has been created, you should always keep and use this 
same object throughout your program. Because when new() is invoked, 
the IP-ISP data is tied to the object and is somewhat expensive. 
If you run this module in a web environment, maybe mod_perl is a 
better choice since mod_perl always try to keep the object persistent 
in memory. 

=head2 ip_isp(ip)

Retrieve an ISP in China from the given IP.

The results returned are similar to: 

        CNCGROUP-JL

        - CNCGROUP Jilin Province 

        CHINANET-GD

        - CHINANET Guangdong Province 

        UNICOM

        - China United Telecommunications 

        JLU-CN

        - Jilin University China

        ...

        unknown

        - This IP is not in our database, maybe non-China IP? 


=head2 data_version()

Retrieve the IP-ISP data version and updated date.

=cut


=head1 AUTHOR

Jeff Pang <rwwebs@gmail.com>

=head1 BUGS/LIMITATIONS

Only works with IPv4 addresses.

If you have found bugs,please send mail to <rwwebs@gmail.com>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc IP::ChinaISP

=head1 ACKNOWLEDGMENTS

In China there are two primary ISPs, China Telecom (CHINANET) and China
CNC Group (CNCGROUP). The internet connection between these two ISPs is 
very slow and therefore causes trouble for those web service providers. 
They need to make two suites of systems for the same application, each 
for each ISP. Moreover, they need to make CDN systems based on different 
provinces in China. So the module will provide a convenient way for 
their purpose.

Many thanks to Derek Smith <derekbellnersmith@yahoo.com> who documented this module.

=head1 COPYRIGHT & LICENSE

Copyright 2007 Jeff Pang, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

