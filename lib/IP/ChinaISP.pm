package IP::ChinaISP;

use strict;
use Socket qw/inet_aton/;
use Carp qw/croak/;

our $VERSION = '0.01';

sub new {

    my $caller = shift;
    my $class = ref $caller || $caller;
    my (@ips,$data_version);

    my $module_dir = $INC{'IP/ChinaISP.pm'};
    $module_dir =~ s/\.pm$//;

    open IPDB,"$module_dir/cnip.dat" or croak "Can't open ip database file: $!";
    while (<IPDB>) {
        if (/^#\s*(.+)$/) {
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

IP::ChinaISP - Querying China ISP from a given IP

=head1 VERSION

Version 0.01

=cut


=head1 SYNOPSIS

    use IP::ChinaISP;

    my $cnisp = IP::ChinaISP->new;
    my $isp = $cnisp->ip_isp('202.96.128.86');
    print $isp;

    print $cnisp->data_version;

=head1 METHODS

=head2 new()

    New an object.

=head2 ip_isp(ip)

    Get China ISP from the given IP.

    the results returned are like:
        CNCGROUP-JL: CNCGROUP Jilin Province
        CHINANET-GD: CHINANET Guangdong Province
        JLU-CN: Jilin University China
        ...
        unknown: This IP is not in our database,maybe non-China IP?

=head2 data_version()

    Get IP-ISP data's version and update date.

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

    Many thanks to Derek Smith <derekbellnersmith@yahoo.com> who documented this module.

=head1 COPYRIGHT & LICENSE

Copyright 2007 Jeff Pang, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

