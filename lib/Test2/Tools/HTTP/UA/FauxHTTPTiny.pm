package Test2::Tools::HTTP::UA::FauxHTTPTiny;

use strict;
use warnings;
use 5.008001;
use Carp ();
use parent 'Test2::Tools::HTTP::UA::HTTPAnyUA';

# ABSTRACT: HTTP::AnyUA user agent wrapper for Test2::Tools::HTTP
# VERSION

=head1 SYNOPSIS

 use Test2::Tools::HTTP::UA::FauxHTTPTiny qw( :faux );
 use HTTP::Tiny;
 
 # This is actually a HTTP::AnyUA pretending
 # to be a HTTP::Tiny
 my $http = HTTP::Tiny->new;
 my $res = $http->get("http://www.google.com");
 
 use Test2::Tools::HTTP;
 
 # Test2::Tools::HTTP doesn't work with a real HTTP::Tiny
 # but it can work with this faux HTTP::Tiny.
 http_ua($http);

=head1 DESCRIPTION

L<HTTP::Tiny> is pretty good for a number of reasons.  It is small, it is
bundled with modern versions of Perl and its implementation is correct.
One area that I find that it falls down though is testing.  It is impossible
to mock at the connection level without mucking with its internal privates.
So probably if you like to write tests without having to spin up a real HTTP
server for L<HTTP::Tiny> to talk to, then I recommend using something else,
like L<LWP::UserAgent> which is easy to mock.  This module provides a faux
L<HTTP::Tiny> that uses L<LWP::UserAgent> under the covers (via L<HTTP::AnyUA>)
for situations when you can't not use L<HTTP::Tiny>.  As the name might 
suggest, this class is designed to work with L<Test2::Tool::HTTP>.  Because
this overrides the L<HTTP::Tiny> that comes with your Perl, you need to
specifically opt-in by using this module with the C<:faux> tag.  You
also need to use it before any code that might use the real L<HTTP::Tiny>
first.

=head1 CAVEATS

In broad strokes this faux L<HTTP::Tiny> works similar to the real thing.
In some of the details it almost certainly is different.

=cut

sub import
{
  my $class = shift;
  foreach my $arg (@_)
  {
    if($arg eq ':faux')
    {
      if($INC{'HTTP/Tiny.pm'})
      {
        Carp::croak "Must load Test2::Tools::HTTP::UA::FauxHTTPTiny BEFORE HTTP::Tiny";
      }
      else
      {
        $INC{'HTTP/Tiny.pm'} = __FILE__;
        @HTTP::Tiny::ISA = qw( HTTP::AnyUA );
        
        package
          HTTP::Tiny;

        my @missing = qw(
          default_headers
          local_address
          keep_alive
          max_size
          timeout
          verify_SSL
          SSL_options
        );

        *new = sub {
          my($class, %attr) = @_;

          require LWP::UserAgent;
          my $lwp = LWP::UserAgent->new;
          
          require HTTP::AnyUA;
          my $self = HTTP::AnyUA::new(
            $class,
            ua => $lwp,
          );
          
          if(my $agent = delete $attr{agent} || 'HTTP-Tiny/0.070')
          {
            $lwp->agent($agent);
          }
          
          if(my $cookie_jar = delete $attr{cookie_jar})
          {
            $self->ua->cookie_jar($cookie_jar);
          }
          
          if(my $max_redirect = delete $attr{max_redirect} || 5)
          {
            $self->ua->max_redirect($max_redirect);
          }
          
          if(my $no_proxy = delete $attr{no_proxy} || $ENV{no_proxy})
          {
            $self->no_proxy($no_proxy);
          }
          
          if(my $http_proxy = delete $attr{http_proxy} || $ENV{http_proxy})
          {
            $self->http_proxy($http_proxy);
          }

          if(my $https_proxy = delete $attr{https_proxy} || $ENV{https_proxy})
          {
            $self->https_proxy($https_proxy);
          }
          
          if(my $proxy = delete $attr{proxy} || $ENV{all_proxy})
          {
            $self->proxy($proxy);
          }
          
          Carp::carp "attribute: $_ is not supported" for sort keys %attr;
          
          $self;
        };
        
        *agent = sub {
          my($self, $new) = @_;
          $self->ua->agent($new) if defined $new;
          $self->ua->agent;
        };
        
        *cookie_jar = sub {
          my($self, $new) = @_;
          if(defined $new)
          {
            if(ref($new) && ref($new) ne 'HASH')
            {
              $self->ua->cookie_jar($new);
            }
            else
            {
              Carp::croak "Cookie jar must be an object";
            }
          }
          $self->ua->cookie_jar;
        };
        
        *max_redirect = sub {
          my($self, $new) = @_;
          $self->ua->max_redirect($new) if defined $new;
          $self->ua->max_redirect;
        };

        *http_proxy = sub {
          my($self, $new) = @_;
          $self->ua->proxy(http => $new) if defined $new;
          $self->ua->proxy('http');
        };

        *https_proxy = sub {
          my($self, $new) = @_;
          $self->ua->proxy(https => $new) if defined $new;
          $self->ua->proxy('https');
        };
        
        *proxy = sub {
          my($self, $new) = @_;
          $self->ua->proxy( ['http','https'] => $new) if defined $new;
          return;
        };
        
        *no_proxy = sub {
          my($self, $new) = @_;
          if($new)
          {
            $self->{faux_no_proxy} = $new;
            $self->ua->no_proxy(ref $new ? @$new : split /,/, $new)
              if defined $new;
          }
          $self->{faux_no_proxy};
        };
        
        foreach my $name (@missing)
        {
          no strict 'refs';
          *{$name} = sub {
            Carp::carp "attribute: $name is not supported";
            undef;
          };
        }
      }
    }
    else
    {
      Carp::croak "Unknown mode: $arg";
    }
  }
}

1;

=head1 SEE ALSO

=over 4

=item L<Test2::Tool::HTTP>

=item L<Test2::Tool::HTTP::UA::HTTPAnyUA>

=back

=cut
