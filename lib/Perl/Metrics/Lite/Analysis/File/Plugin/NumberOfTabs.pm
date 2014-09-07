package Perl::Metrics::Lite::Analysis::File::Plugin::NumberOfTabs;
use strict;
use warnings;

sub init {}

sub measure {
    my ( $class, $context, $file ) = @_;
    my $tab_count = (() = $file =~ /\t/g);
    return $tab_count;
}

1;
