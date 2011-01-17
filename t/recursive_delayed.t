use strict;
use warnings;
use Test::More;
use Plack::Test::Suite;

use HTTP::Request;
use HTTP::Request::Common;

local @Plack::Test::Suite::TEST = (
  [
    'Recursive delay',
    sub {
      my $cb = shift;
      my $req = HTTP::Request->new(GET => "http://localhost/hello");
      my $res = $cb->($req);
      is $res->code, 200;
    },
    sub {
      my $env = shift;
      return sub {
        shift->(sub {
          shift->([
            200,
            ["Content-Type" => "text/plain"],
            ["hello!"]
          ]);
        });
      };
    }
  ]
);

# prevent Lint middleware from being used
Plack::Test::Suite->run_server_tests(sub {
    my($port, $app) = @_;
    my $server = Plack::Loader->load("Twiggy", port => $port, host => "127.0.0.1");
    $server->run($app);
});

done_testing();
