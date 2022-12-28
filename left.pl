#!/usr/bin/perl
#
#  Super simple is the goal here.

my $compare  = 0;

my @input = `cat ledger`;
my $total = 0;

if ( @ARGV ) {
   $compare = $ARGV[0];
}

for ( my $i = scalar(@input) ; $i >= 0 ; $i-- ) {
  my $l = $input[$i];

  #if ( $l =~ /\| pot \|/ ) { next; }

  if ( $l =~ /^  \d{2}/ || $l =~ /^  --/ ) {
     if ( ( $l =~ /\| (PAID|SEND)/ && $total != 0 ) || $i == 0 ) {
        print $l;
        print "\nTotal going out: £".sprintf("%.2f",$total)."\n";
        if ( $compare ) {
           print "\nYou have £".sprintf("%.2f left.\n",$compare - $total);
        }
        exit;
     }
     next if ( $l =~ /\| (PAID|SEND)/ );
     my ($date, $date2, $amount) = split(/\|/, $l);
     $total += $amount;
     print $l;
  }
}
