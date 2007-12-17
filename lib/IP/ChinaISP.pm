package IP::ChinaISP;

use strict;
use Socket qw/inet_aton/;
use Carp qw/croak/;

use vars qw/$VERSION/;

$VERSION = '0.04';

sub new {

    my $caller = shift;
    my $class = ref $caller || $caller;
    my (@ips,$data_version);

    my $module_dir = $INC{'IP/ChinaISP.pm'};
    $module_dir =~ s/\.pm$//;

    open IPDB,"$module_dir/cnip.dat" or croak "Can't open ip database file: $!";
    while (<IPDB>) {
        if (/^#\s*(data updated.+)$/) {
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

    my $ipint = _ip2int($ip);

    my $isp = 'unknown';
    for (@{$self->{ips}}) {
        if ($ipint >= $_->[0] and $ipint <= $_->[1]) {
            $isp = $_->[2];
            last;
        }
    }

    return $isp;
}

sub is_tel {

    my $self = shift;
    $self = $self->new unless ref $self;
    my $ip = shift;

    my $ipint = _ip2int($ip);
    my $is_tel = 0;

    for (@{$self->{ips}}) {
        if ($ipint >= $_->[0] and $ipint <= $_->[1] and 
            $_->[2] =~ /CHINANET|telecom/i ) {
            $is_tel =1;
            last;
        }
    }

    return $is_tel;
}

sub is_cnc {

    my $self = shift;
    $self = $self->new unless ref $self;
    my $ip = shift;

    my $ipint = _ip2int($ip);
    my $is_cnc = 0;

    for (@{$self->{ips}}) {
        if ($ipint >= $_->[0] and $ipint <= $_->[1] and 
            $_->[2] =~ /CNC|wangtong/) {  # I didn't use '/i' modifier here
            $is_cnc =1;
            last;
        }
    }

    return $is_cnc;
}

sub is_edu {

    my $self = shift;
    $self = $self->new unless ref $self;
    my $ip = shift;

    my $ipint = _ip2int($ip);
    my $is_edu = 0;

    for (@{$self->{ips}}) {
        if ($ipint >= $_->[0] and $ipint <= $_->[1] and 
            $_->[2] =~ /UT?-CN|CERNET|university|school/i and $_->[2] !~ /GUANGZ/) {
            $is_edu =1;
            last;
        }
    }

    return $is_edu;
}

sub data_version {
    
    my $self = shift;
    $self = $self->new unless ref $self;

    return $self->{dv};
}

sub _ip2int {

    my $ip = shift;
    my $nl = inet_aton($ip);
    croak "wrong ip $!" unless defined $nl;

    return unpack('N',$nl);
}

1;



=head1 NAME

IP::ChinaISP - Retrieve an ISP in China from the given IP

=head1 VERSION

Version 0.04

=cut


=head1 SYNOPSIS

    use IP::ChinaISP;

    my $ip = '202.96.128.86';
    my $cnisp = IP::ChinaISP->new;

    my $isp = $cnisp->ip_isp($ip);
    print "the isp for ip $ip is:", $isp;

    my $is_tel = $cnisp->is_tel($ip);
    print "the ip $ip is ", $is_tel ? '' : 'not ', 'a telecom ip';

    my $is_cnc = $cnisp->is_cnc($ip);
    print "the ip $ip is ", $is_cnc ? '' : 'not ', 'a CNC ip';

    my $is_edu = $cnisp->is_edu($ip);
    print "the ip $ip is ", $is_edu ? '' : 'not ', 'an education-net ip';

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


=head2 is_tel(ip)

Whether the given IP belongs to China Telecom or not.

Note: This method and below two are used for reference only.

The returned results are:

        1 - yes
        0 - no


=head2 is_cnc(ip)

Whether the given IP belongs to China CNC Group or not.

The returned results are:

        1 - yes
        0 - no


=head2 is_edu(ip)

Whether the given IP belongs to China education networks or not.

The returned results are:

        1 - yes
        0 - no


=head2 data_version()

Retrieve the IP-ISP data version and updated date.

=cut


=head1 AUTHOR

Jeff Pang <pangj@earthlink.net>

=head1 BUGS/LIMITATIONS

Only works with IPv4 addresses.

If you have found bugs,please send mail to <pangj@earthlink.net>

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

