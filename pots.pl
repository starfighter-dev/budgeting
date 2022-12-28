#!/usr/bin/perl
#
# Add them to ledger like this:
#    2018-04-28 | 2018-04-28 |   40.00 | pot | Les Paul [G2000]


my @input = `cat ledger`;
my @pots;


print "-" x 80;

foreach my $l ( @input ) {
   chomp $l;
   if ( $l =~ /\| pot \|/ && $l !~ /^\*/ ) {
      my (@bits) = split(/\|/, $l);
      my $amount = $bits[2];
      my ($reason, $goal) = $bits[4] =~ /(.+)\[G(.+)\]/;
      $reason =~ s/^\s+|\s+$//g;
      my $perc = ($amount / $goal ) * 100;
      if ( $l =~ /FULL/ ) {
         $perc = 100;
      }


      chomp $reason;
      while ( length ( $reason ) < 30 ) {
         $reason.=' ';
      }

      print sprintf("\n %s        Goal:    \£%.2f", $reason, $goal);
      print sprintf("\n                                     Now:     \£%.2f", $amount);
      print sprintf("\n                                     Percent complete:                \%.2f\%\n", $perc);
      print "-" x 80;
   }
}

print "\n";
