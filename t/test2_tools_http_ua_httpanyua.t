use Test2::V0 -no_srand => 1;
use Test2::Tools::HTTP::UA::HTTPAnyUA;
use Test2::Tools::HTTP qw( :short );
use HTTP::AnyUA;
use LWP::UserAgent;
use HTTP::Request::Common;

app_add 'http://foo.test' => sub { 
  [ 200, [ 'Content-Type' => 'text/plain' ], [ "Decepticon\n" ] ];
};

ua( HTTP::AnyUA->new( LWP::UserAgent->new ) );

req
  GET('http://foo.test'),
  res {
    code 200;
    content_type 'text/plain';
    content "Decepticon\n";
  };
  

done_testing
