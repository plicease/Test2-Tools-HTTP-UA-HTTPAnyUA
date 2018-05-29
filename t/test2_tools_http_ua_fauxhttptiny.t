use Test2::V0 -no_srand => 1;
use Test2::Tools::HTTP::UA::FauxHTTPTiny qw( :faux );
use Test2::Tools::HTTP::UA;
use Test2::Tools::HTTP;
use HTTP::Request::Common;
use HTTP::Cookies;

my $env;

psgi_app_add 'http://fred.test' => sub {
  ($env) = @_;
  [ 200, [ 'Content-Type' => 'text/plain' ], [ "Autobots\n" ] ];
};

subtest 'basic' => sub {

  my $http = HTTP::Tiny->new;
  
  isa_ok $http, 'HTTP::Tiny';
  isa_ok $http, 'HTTP::AnyUA';

  my $wrapper = Test2::Tools::HTTP::UA->new($http->ua);
  $wrapper->instrument;
  
  is(
    $http->get('http://fred.test'),
    hash {
      field content => "Autobots\n";
      field reason  => 'OK';
      field status  => 200;
      field success => T();
      field url     => 'http://fred.test';
      field headers => hash {
        field 'content-type' => 'text/plain';
        etc;
      };
    },
    'response',
  );
  
  is(
    $env,
    hash {
      field HTTP_USER_AGENT => 'HTTP-Tiny/0.070';
      etc;
    },
    'env',
  );
  
};

subtest 'agent' => sub {

  my $http = HTTP::Tiny->new( agent => 'FooBar/1.1' );
  
  my $wrapper = Test2::Tools::HTTP::UA->new($http->ua);
  $wrapper->instrument;

  is(
    $http->get('http://fred.test'),
    hash {
      field success => T();
      etc;
    },
    'response',
  );  

  is(
    $env,
    hash {
      field HTTP_USER_AGENT => 'FooBar/1.1';
      etc;
    },
    'env',
  );
  
  $http->agent('FooBar/1.2');

  is(
    $http->get('http://fred.test'),
    hash {
      field success => T();
      etc;
    },
    'response',
  );  

  is(
    $env,
    hash {
      field HTTP_USER_AGENT => 'FooBar/1.2';
      etc;
    },
    'env',
  );  

};

subtest 'cookie_jar' => sub {

  my $http = HTTP::Tiny->new;

  is($http->cookie_jar, undef);
  
  $http->cookie_jar(HTTP::Cookies->new);
  
  isa_ok($http->cookie_jar, 'HTTP::Cookies');
  
  eval { $http->cookie_jar({}) };
  my $error = $@;
  like $error, qr/Cookie jar must be an object/;

  $http = HTTP::Tiny->new( cookie_jar => HTTP::Cookies->new );
  
  isa_ok($http->cookie_jar, 'HTTP::Cookies');  

};

subtest 'max_redirect' => sub {

  my $http = HTTP::Tiny->new;
  
  is($http->max_redirect, 5);
  is($http->ua->max_redirect, 5);
  
  $http->max_redirect(10);

  is($http->max_redirect, 10);
  is($http->ua->max_redirect, 10);

  $http = HTTP::Tiny->new( max_redirect => 8 );

  is($http->max_redirect, 8);
  is($http->ua->max_redirect, 8);

};

subtest 'prxoy' => sub {

  local $ENV{http_proxy} = '';
  local $ENV{https_proxy} = '';
  local $ENV{any_proxy} = '';
  
  delete $ENV{$_} for qw( http_proxy https_proxy any_proxy );

  subtest 'http_proxy' => sub {

    local $ENV{http_proxy} = 'http://localhost:3128';
  
    my $http = HTTP::Tiny->new;
    is( $http->http_proxy, 'http://localhost:3128');

    $http = HTTP::Tiny->new(http_proxy => 'http://localhost:5555');
    is( $http->http_proxy, 'http://localhost:5555');
    
    delete $ENV{http_proxy};
    
    $http = HTTP::Tiny->new;
    is( $http->http_proxy, undef);

    $http = HTTP::Tiny->new(http_proxy => 'http://localhost:5551');
    is( $http->http_proxy, 'http://localhost:5551');
  
  };

  subtest 'https_proxy' => sub {

    local $ENV{https_proxy} = 'https://localhost:3128';
  
    my $https = HTTP::Tiny->new;
    is( $https->https_proxy, 'https://localhost:3128');

    $https = HTTP::Tiny->new(https_proxy => 'https://localhost:5555');
    is( $https->https_proxy, 'https://localhost:5555');
    
    delete $ENV{https_proxy};
    
    $https = HTTP::Tiny->new;
    is( $https->https_proxy, undef);

    $https = HTTP::Tiny->new(https_proxy => 'https://localhost:5551');
    is( $https->https_proxy, 'https://localhost:5551');
  
  };
  
  subtest 'proxy' => sub {
  
    local $ENV{all_proxy} = 'http://localhost:6626';

    my $http = HTTP::Tiny->new;
    is( $http->http_proxy, 'http://localhost:6626' );
    is( $http->https_proxy, 'http://localhost:6626' );

    my $http = HTTP::Tiny->new( proxy => 'http://localhost:4544' );;
    is( $http->http_proxy, 'http://localhost:4544' );
    is( $http->https_proxy, 'http://localhost:4544' );
    
    delete $ENV{all_proxy};

    my $http = HTTP::Tiny->new;
    is( $http->http_proxy, undef );
    is( $http->https_proxy, undef );
  
  };

  subtest 'no_proxy' => sub {
  
    local $ENV{no_proxy} = 'foo.test,bar.test';
  
    my $http = HTTP::Tiny->new;
    
    is( $http->no_proxy, 'foo.test,bar.test' );
    
    delete $ENV{no_proxy};

    $http = HTTP::Tiny->new;
    
    is( $http->no_proxy, undef );

    $http = HTTP::Tiny->new( no_proxy => [ qw( foo.test bar.test ) ]);

    is( $http->no_proxy, [ qw( foo.test bar.test ) ] );

    $http = HTTP::Tiny->new( no_proxy => 'foo.test,bar.test');

    is( $http->no_proxy, 'foo.test,bar.test');

    $http->no_proxy('baz.test,gag.test');

    is( $http->no_proxy, 'baz.test,gag.test' );

    $http->no_proxy( [ qw( baz.test gag.test ) ] );

    is( $http->no_proxy, [ qw( baz.test gag.test ) ] );

  };

};

subtest 'works with Test2::Tools::HTTP' => sub {

  my $http = HTTP::Tiny->new;
  http_ua $http;
  
  http_request
    GET('http://fred.test'),
    http_response {
      http_code         200;
      http_message      'OK';
      http_content      "Autobots\n";
      http_content_type 'text/plain';
    };

  is(
    $env,
    hash {
      field HTTP_USER_AGENT => 'HTTP-Tiny/0.070';
      etc;
    },
    'env',
  );
};

done_testing
