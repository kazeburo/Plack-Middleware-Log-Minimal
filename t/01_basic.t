use strict;
use Test::More;

use Plack::Builder;
use Plack::Test;
use Log::Minimal;

my $app = builder {
  enable 'Log::Minimal';
  sub {
    my $env = shift;
    debugf("debug");
    infof("info");
    warnf("warn");
    critf("crit");
    ["200",[ 'Content-Type' => 'text/plain' ],["OK"]];
  }
};

{
    my $warn = "";
    $SIG{__WARN__} = sub { $warn .= join "", @_ };
    test_psgi
        app => $app,
        client => sub {
            my $cb = shift;
            my $req = HTTP::Request->new(GET => "http://localhost/bar");
            my $res = $cb->($req);
            ok( $res->is_success );
       };
    unlike $warn, qr/\[DEBUG\] \[\/bar\] debug/;
    like $warn, qr/\[INFO\] \[\/bar\] info/;
    like $warn, qr/\[WARN\] \[\/bar\] warn/;
    like $warn, qr/\[CRITICAL\] \[\/bar\] crit/;
}


{
    $ENV{PLACK_ENV} = "development";
    my $warn = "";
    $SIG{__WARN__} = sub { $warn .= join "", @_ };
    test_psgi
        app => $app,
        client => sub {
            my $cb = shift;
            my $req = HTTP::Request->new(GET => "http://localhost/bar");
            my $res = $cb->($req);
            ok( $res->is_success );
       };
    like $warn, qr/\[DEBUG\] \[\/bar\] .+?debug/;
    like $warn, qr/\[INFO\] \[\/bar\] .+?info/;
}



done_testing();
