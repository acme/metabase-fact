package Metabase::Fact::TestFact;
use 5.006;
use strict;
use warnings;
use base 'Metabase::Fact';

use JSON ();
use Carp ();

sub validate_content {
  my ($self) = @_;
  Carp::croak "plain scalars only please" if ref $self->content;
  Carp::croak "non-empty scalars please"  if ! length $self->content;
}

sub content_as_bytes {
  my ($self) = @_;

  JSON->new->encode({ payload => $self->content });
}

sub content_from_bytes { 
  my ($class, $string) = @_;

  $string = $$string if ref $string;

  JSON->new->decode($string)->{payload};
}

1;
