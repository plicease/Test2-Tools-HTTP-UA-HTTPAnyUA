package Test2::Tools::HTTP::UA::HTTPAnyUA;

use strict;
use warnings;
use 5.008001;
use parent 'Test2::Tools::HTTP::UA';

# ABSTRACT: HTTP::AnyUA user agent wrapper for Test2::Tools::HTTP
# VERSION

sub new
{
  my($class, $ua) = @_;
  my $self = $class->SUPER::new($ua);
  $self->{wrapper} = Test2::Tools::HTTP::UA->new($ua->ua);
  $self;
}

sub wrapper
{
  shift->{wrapper};
}

sub instrument
{
  my($self) = @_;
  $self->wrapper->instrument;
}

sub request
{
  my($self, $req, %options) = @_;
  $self->wrapper->request($req, %options);
}

__PACKAGE__->register('HTTP::AnyUA', 'instance');

1;
