use Plack::Builder;
use Log::Minimal;

my $response = [
    "200",
    [ 'Content-Type' => 'text/plain' ],
    ["OK"],
];

builder {
  enable 'Log::Minimal';
  mount '/debug' => sub { debugf("debug"); $response };
  mount '/info'  => sub { infof("info"); $response };
  mount '/warn'  => sub { warnf("warn"); $response };
  mount '/crit'  => sub { critf("crit"); $response };
};



