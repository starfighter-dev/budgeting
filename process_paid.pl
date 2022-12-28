#!/usr/bin/perl

my $base = '2000.00'; # PA II
$base = 0;

my @input = `cat ledger`;
my @final;

my (@now) = localtime;
my $day   = $now[3];
my $mon   = $now[4] + 1;
my $year  = $now[5] + 1900;
if ( length($day) < 2 ) {
   $day = '0'.$day;
}
if ( length($mon) < 2 ) {
   $mon= '0'.$mon;
}

my $total = 0;
foreach my $l ( @input ) {
   if ( $l =~ /\| pot \|/ ) {
      next;
   }
   if ( $l =~ /PAID|SEND/ && $l !~ /\|.+\|/ ) { $l =~ s/\s+$//;
      $l = sprintf("%s %0.2f\n",$l,$l =~ /PAID/ ? $base-$total : $total);
      $total = 0;

      if ( $l =~ /  (\d\d\d\d)-(\d\d)-(\d\d) / ) {
         my $this_year = $1;
         my $this_mon = $2;
         my $this_day = $3;
         if ( $this_year.$this_mon.$this_day < $year.$mon.$day ) {
            last;
         }
      }
   }

   if ( $l =~ /[0-9]{2}-[0-9]{2}/ && $l !~ /PAID|SEND/ ) {
      my ( $date, $another_date, $amount ) = split(/\|/, $l);
      $total += $amount if ( $date !~ /^\*/ );
   }

   push ( @final , $l );
}

foreach my $l ( @final ) {
   print $l;
}
