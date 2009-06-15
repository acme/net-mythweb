#!/home/acme/perl-5.10.0/bin/perl
use strict;
use warnings;
use lib 'lib';
use Net::MythWeb;
use Perl6::Say;

my $mythweb = Net::MythWeb->new( hostname => 'owl.local', port => 80 );

foreach my $recording ( $mythweb->recordings ) {
    say $recording->channel->id, ', ', $recording->channel->number, ', ',
        $recording->channel->name;
    say $recording->title, ', ', $recording->subtitle, ', ',
        $recording->description;
}
