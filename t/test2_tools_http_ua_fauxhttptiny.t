use Test2::V0 -no_srand => 1;
use Test2::Tools::HTTP::UA::FauxHTTPTiny qw( :faux );
use Test2::Tools::HTTP::UA;
use Test2::Tools::HTTP qw( psgi_app_add );
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

done_testing
