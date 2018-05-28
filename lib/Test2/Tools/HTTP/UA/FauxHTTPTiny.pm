package Test2::Tools::HTTP::UA::FauxHTTPTiny;

use strict;
use warnings;
use 5.008001;
use Carp ();
use parent 'Test2::Tools::HTTP::UA::HTTPAnyUA';

# ABSTRACT: HTTP::AnyUA user agent wrapper for Test2::Tools::HTTP
# VERSION

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
          max_redirect
          max_size
          http_proxy
          https_proxy
          proxy
          no_proxy
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
