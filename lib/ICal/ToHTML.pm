package ICal::ToHTML;

use strict;
use warnings;
use 5.010;
use version; our $VERSION = version->new('0.01');

use iCal::Parser;
use DateTime;
use Moose;
use Moose::Util::TypeConstraints;
use Path::Class;

with qw(MooseX::Getopt);


has 'ical' => (required=>1, is=>'ro', isa=>'ArrayRef');
has 'outdir' => (required=>1, is=>'ro', isa=>'Str',default=>'.');
has 'dtf_long' => (is=>'ro', isa=>'Str',default=>'%A, %d.%m.%Y');
has '_data' => (is=>'rw',isa=>'HashRef');

no Moose;
__PACKAGE__->meta->make_immutable;


sub run {
    my $self = shift;

    my $parser = iCal::Parser->new(
        no_todos=>1,
        start=>DateTime->now->subtract(days=>14),
    );
    my $data = $parser->parse_files(@{$self->ical});
    $self->_data($data); 
    foreach my $year (sort keys %{$data->{events}}) {
        foreach my $month (sort keys %{$data->{events}{$year}}) {
            foreach my $day (sort keys %{$data->{events}{$year}{$month}}) {
                $self->render_day($year, $month, $day);
            }
        }
    }
}

sub render_day {
    my ($self, $y, $m, $d ) = @_;
    
    my $outfile = dir($self->outdir)->file(sprintf("%04d_%02d_%02d.html",$y,$m,$d));
    my $fh = $outfile->openw;
    my $this_day=DateTime->new(year=>$y,month=>$m,day=>$d);

    say $fh "<h4>".$this_day->strftime($self->dtf_long)."</h4>\n<dl>";

    my $events = $self->_data->{events}{$y}{$m}{$d};
    foreach my $event (values %$events) {
        say keys %$event;
        say $fh "<dt>".$event->{DTSTART}->strftime("%H:%M").": ".$event->{SUMMARY}."</dt>";
        say $fh "<dd>".$event->{DESCRIPTION}."</dd>";
    }

    say $fh "</dl>";

}


=head1 NAME

ICal::ToHTML - convert one or several iCal files to a collection of HTML files

=head1 SYNOPSIS

  use ICal::ToHTML;

=head1 DESCRIPTION

ICal::ToHTML is

=cut



1;
__END__


=head1 AUTHOR

Thomas Klausner E<lt>domm {at} cpan.orgE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
