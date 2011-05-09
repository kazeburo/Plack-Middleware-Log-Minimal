use strict;
use Test::More;

use Plack::Builder;
use Plack::Test;
use Log::Minimal;

my $app = builder {
  enable 'Log::Minimal',
    autodump => 1,
    loglevel => 'WARN',
    formatter => sub {
        my ($env, $time, $type, $message, $trace, $raw_message) = @_;
        ok( ! Encode::is_utf8($message) );
        "$time|$type|$message|$trace";
    };
  sub {
    my $env = shift;
    debugf("debug");
    infof("info");
    warnf("warn");
    critf("crit %s",{foo=>'bar'});
    warnf("あ");
    warnf("\x{306b}");
    ["200",[ 'Content-Type' => 'text/plain' ],["OK"]];
  }
};

{
    my $warn;
    test_psgi
        app => sub {
            my $env = shift;
            $env->{'psgi.errors'} = do { open my $io, ">", \$warn; $io };
            $app->($env)
        },
        client => sub {
            my $cb = shift;
            my $req = HTTP::Request->new(GET => "http://localhost/bar");
            my $res = $cb->($req);
            ok( $res->is_success );
       };
    unlike $warn, qr/INFO\|info\|/;
    like $warn, qr/WARN\|warn\|/;
    like $warn, qr/CRITICAL\|crit {'foo'\s*=>\s*'bar'}\|/;
}




done_testing();

