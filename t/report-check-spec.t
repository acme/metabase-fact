# Copyright (c) 2008 by Ricardo Signes. All rights reserved.
# Licensed under terms of Perl itself (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License was distributed with this file or you may obtain a 
# copy of the License from http://dev.perl.org/licenses/

use strict;
use warnings;

use Test::More;
use Test::Exception;

plan tests => 9;

require_ok( 'CPAN::Metabase::Report' );
require_ok( 'CPAN::Metabase::Fact::TestFact' );

#--------------------------------------------------------------------------#
# fixtures
#--------------------------------------------------------------------------#    

my ($obj, $err);

my %params = (
    dist_author => "JOHNDOE",
    dist_file => "Foo-Bar-1.23.tar.gz",
);

#--------------------------------------------------------------------------#
# create some test facts
#--------------------------------------------------------------------------#

package FactOne;
our @ISA = ('CPAN::Metabase::Fact::TestFact');

package FactTwo;
our @ISA = ('CPAN::Metabase::Fact::TestFact');

package main;

my %facts = (
    FactOne     => FactOne->new( %params, content => "FactOne" ),
    FactTwo     => FactTwo->new( %params, content => "FactTwo" ),
);

#--------------------------------------------------------------------------#
# define some test reports
#--------------------------------------------------------------------------#

package JustOneFact;
our @ISA = ('CPAN::Metabase::Report');
sub report_spec { return {'CPAN::Metabase::Fact' => 1} }

package OneOrMoreFacts;
our @ISA = ('CPAN::Metabase::Report');
sub report_spec { return {'CPAN::Metabase::Fact' => '1+'} }

package OneOfEach;
our @ISA = ('CPAN::Metabase::Report');
sub report_spec { 
  return {
    'FactOne' => '1',
    'FactTwo' => '1',
  }
}

package OneSpecificAtLeastThreeTotal;
our @ISA = ('CPAN::Metabase::Report');
sub report_spec { 
  return {
    'FactOne' => '1',
    'CPAN::Metabase::Fact' => '3',
  }
}

package main;

#--------------------------------------------------------------------------#
# report that takes 1 fact
#--------------------------------------------------------------------------#

lives_ok { 
    $obj = JustOneFact->new( %params, content => [ $facts{FactOne} ] );
} "lives: new() takes 1 fact, and given 1 fact";

dies_ok { 
    $obj = JustOneFact->new( %params, content => [ ] );
} "dies: new() takes 1 fact, but given none";

dies_ok { 
    $obj = JustOneFact->new( %params, 
        content => [ @facts{qw/FactOne FactTwo/} ] 
    );
} "dies: new() takes 1 fact, but given 2 facts";

#--------------------------------------------------------------------------#
# report that takes 1+ facts
#--------------------------------------------------------------------------#

lives_ok { 
    $obj = OneOrMoreFacts->new( %params, 
        content => [ @facts{qw/FactOne FactTwo/} ] 
    );
} "lives: new() takes 1+ fact, and given 2 facts";

#--------------------------------------------------------------------------#
# report that takes 1 of each
#--------------------------------------------------------------------------#

lives_ok { 
    $obj = OneOfEach->new( %params, 
        content => [ @facts{qw/FactOne FactTwo/} ] 
    );
} "lives: new() takes 1 of each, given 1 of each";

dies_ok { 
    $obj = OneOfEach->new( %params, 
        content => [ @facts{qw/FactOne FactOne/} ] 
    );
} "dies: new() takes 1 of each, given 2 of one kind";

#--------------------------------------------------------------------------#
# report that takes 1 of each
#--------------------------------------------------------------------------#

lives_ok { 
    $obj = OneSpecificAtLeastThreeTotal->new( %params, 
        content => [ @facts{qw/FactOne FactTwo FactTwo/} ] 
    );
} "lives: new() takes 1 specific 3 total, given correctly";

