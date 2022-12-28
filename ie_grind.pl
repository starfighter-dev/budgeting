#!/usr/bin/perl
#
# Import/Export grind from GTA IRL
#
# sudo apt-get install libdatetime-perl

use DateTime;

my $start   = DateTime->now( time_zone  => 'Europe/London' );
$start = DateTime->new(
   day => 25,
   month => 01,
   year => 2023
);

# Set an end date
my $stop = DateTime->new(
    day   => 31,
    month => 01,
    year  => 2024,
);

if ( @ARGV ) {
   if ( $ARGV[0] =~ /^([0-9]{4})-([0-9]{2})-([0-9]{2})$/ ) {
      if ( $1 < 1 || $2 < 1 || $3 < 1 || $2 > 12 || $3 > 31 ) {
         die("Something silly.");
      }
      $stop = DateTime->new(
         day   => $3,
         month => $2,
         year  => $1,
      );
      if ( $start > $stop ) {
         die("End is before start.");
      }
   }
}

# Set base to be your net weekly income
my $base    = 2500;

# Set these up for monthly things. They get applied to the 1st (KISS?).
my $monthly = {
   'Tax Withholding' => {
      'amount' => 1000,
      'day'    => 25,
   },
   # Car related
   'Car Insurance' => {
      'amount' => 20.00,
      'day'    => 27,
   },
   'Garage' => {
      'amount' => 75,
      'day'    => 21,
   },

   # Debt repayment
   'TSB Payoff' => {
      'amount' => 60,
      'day'    => 1,
      'paidoff' => 500
   },

   # Hobbies
   'Archery' => {
      'amount' => 15,
      'day'    => 15,
   },

   'Spotify' => {
      'amount' => 16.99,
      'day'    => 25,
   },
   'Netflix' => {
      'amount' => 13.99,
      'day'    => 25,
   },
};

my $total   = 0;
my $net     = 0;
my $paydays = 0;
my $cards   = {};
my $months  = 0;

print "Report started: " . $start->ymd('-') . "\n";

while ( $start < $stop ) {

   # Is it a payday? If so add some money.
   my $payday = 0;
   # Any past payday, to see if the current day is one too
   my $a_past_payday = DateTime->new(
      day   => 3,
      month => 12,
      year  => 2020,
   );
   while ( $a_past_payday->add(days => 7) <= $start ) {
      if ( $a_past_payday->ymd('-') eq $start->ymd('-') ) {
         $payday++;
         $total += $base;
         $net   += $base;
         $paydays++;
         print "-" x 80;
         printf "\n%s : PAYDAY\n", $start->ymd('-');
      }
   }

   # Loop until we get to the first payday
   # Because you've already paid this stuff
   unless ( $paydays ) {
      $start->add(days => 1);
      next;
   }

   if ( $start->day == 1 ) {
      $months++;
   }

   # First day of a month.. apply all montly expenses
   foreach my $k ( keys %$monthly ) {
      my $amt = $monthly->{$k}{amount} || 0;

      if ( $monthly->{$k}{var} ) {
         if ( scalar(@{$monthly->{$k}{var}}) != 12 ) {
            die("Variable month amounts missing for $k\n");
         }
         $amt = $monthly->{$k}{var}[ $start->mon -1 ];
      }

      my $day = $monthly->{$k}{day} || 1;
      if ( $day == $start->day ) {
         my $skip_reason;

         # Is this something that only happens on certain months?
         if ( $monthly->{$k}{only_these_months} ) {
            $skip_reason = join(',', @{$monthly->{$k}{only_these_months}});
            foreach my $mon ( @{$monthly->{$k}{only_these_months}} ) {
               if ( $start->month == $mon ) {
                  $skip_reason = undef;
               }
            }
         }

         # Is it on a card?
         if ( $monthly->{$k}{card} ) {
            if ( !defined($cards->{$monthly->{$k}{card}}) ) {
               $cards->{$monthly->{$k}{card}} = 0;
            }
            $cards->{$monthly->{$k}{card}} += $monthly->{$k}{amount};
         }

         # Perhaps it's paidoff?
         if ( $monthly->{$k}{paidoff} && $monthly->{$k}{total} ) {
            if ( $monthly->{$k}{total} >= $monthly->{$k}{paidoff} ) {
               $skip_reason = "Is now paid off";
               unless ( defined $monthly->{$k}{paidoff_date} ) {
                  $monthly->{$k}{paidoff_date} = $start->ymd('-');
               }
            }
         }

         if ( $monthly->{$k}{start} ) {
            my $s = $monthly->{$k}{start};
            $s =~ s/-//g;
            if ( $s > $start->ymd('') ) {
               $skip_reason = "Not started yet";
            }
         }

         if ( $skip_reason ) {
            printf "%s : %-15s %6.2f %s (%s)\n", $start->ymd('-'), 'MONTHLY *SKIP*', $amt, $k, $skip_reason;
         } else {
            $total -= $amt;
            $monthly->{$k}{total} += $amt;
            printf "%s : %-15s %6.2f %s\n", $start->ymd('-'), 'MONTHLY', $amt, $k;
         }
      }
   }

   $start->add(days => 1);
}

# Output a bunch of shit.
print "\n";
print "-" x 80;
print "\n\nMonthly\n";
foreach my $k ( sort keys %$monthly ) {
   printf "%30s %9.2f %s\n", $k, $monthly->{$k}{total} || 0, $monthly->{$k}{paidoff_date} ? "[Cleared: " . $monthly->{$k}{paidoff_date} . "]" : '';
}
print "\n";
print "-" x 80;
printf "\n\n%30s %9.2f\n", "Net Total", $net;
printf "\n\n%30s %9.0f\n", "Paydays", $paydays;
printf "\n\n%30s %9.2f\n", "Projected", $total;

if ( keys %$cards && $months ) {
   foreach my $k ( sort keys %$cards ) {
      printf "\n\n%30s %9.2f\n", $k.' average', $cards->{$k} / $months;
   }
}

