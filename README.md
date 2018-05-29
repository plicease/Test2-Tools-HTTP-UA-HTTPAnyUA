# Test2::Tools::HTTP::UA::HTTPAnyUA [![Build Status](https://secure.travis-ci.org/plicease/Test2-Tools-HTTP-UA-HTTPAnyUA.png)](http://travis-ci.org/plicease/Test2-Tools-HTTP-UA-HTTPAnyUA)

HTTP::AnyUA user agent wrapper for Test2::Tools::HTTP

# SYNOPSIS

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

# DESCRIPTION

This module is a user agent wrapper for [Test2::Tools::HTTP](https://metacpan.org/pod/Test2::Tools::HTTP) that allows you
to use [HTTP::AnyUA](https://metacpan.org/pod/HTTP::AnyUA) as a user agent for testing.

# CAVEATS

The underlying user agent used by the [HTTP::AnyUA](https://metacpan.org/pod/HTTP::AnyUA) must be supported by
an installed [Test2::Tools::HTTP](https://metacpan.org/pod/Test2::Tools::HTTP) wrapper.  Since that module comes with a wrapper
that works with [LWP::UserAgent](https://metacpan.org/pod/LWP::UserAgent) that should always work.  If you have the Mojo
user agent wrapper installed you can also use [Mojo::UserAgent](https://metacpan.org/pod/Mojo::UserAgent).  As of this
writing there are no others that are supported.

# SEE ALSO

- [Test2::Tools::HTTP](https://metacpan.org/pod/Test2::Tools::HTTP)
- [Test2::Tools::HTTP::UA::FauxHTTPTiny](https://metacpan.org/pod/Test2::Tools::HTTP::UA::FauxHTTPTiny)
- [HTTP::AnyUA](https://metacpan.org/pod/HTTP::AnyUA)

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2018 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
