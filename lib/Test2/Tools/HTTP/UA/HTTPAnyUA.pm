package Test2::Tools::HTTP::UA::HTTPAnyUA;

use strict;
use warnings;
use 5.008001;
use parent 'Test2::Tools::HTTP::UA';

# ABSTRACT: HTTP::AnyUA user agent wrapper for Test2::Tools::HTTP
# VERSION

=head1 SYNOPSIS

 use Test2::Tools::HTTP;
 use HTTP::AnyUA;
 use LWP::UserAgent;
 
 http_ua( HTTP::AnyUA->new(LWP::UserAgent->new) )
 
 http_request(
   GET('http://example.test'),
   http_response {
     http_code 200;
     http_response match qr/something/;
     ...
   }
 );;
 
 done_testing;

=head1 DESCRIPTION

This module is a user agent wrapper for L<Test2::Tools::HTTP> that allows you
to use L<HTTP::AnyUA> as a user agent for testing.

=head1 CAVEATS

The underlying user agent used by the L<HTTP::AnyUA> must be supported by
an installed L<Test2::Tools::HTTP> wrapper.  Since that module comes with a wrapper
that works with L<LWP::UserAgent> that should always work.  If you have the Mojo
user agent wrapper installed you can also use L<Mojo::UserAgent>.  As of this
writing there are no others that are supported.

=cut

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

=head1 SEE ALSO

=over 4

=item L<Test2::Tools::HTTP>

=item L<Test2::Tools::HTTP::UA::FauxHTTPTiny>

=item L<HTTP::AnyUA>

=back

=cut
