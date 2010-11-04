use strict;
use warnings;
use Log::Minimal;
use Term::ANSIColor;

our $COLOR = {
    info  => { text => 'green', },
    debug => {
        text       => 'red',
        background => 'white',
    },
    'warn' => {
        text       => 'black',
        background => 'yellow',
    },
    'critical' => {
        text       => 'black',
        background => 'red'
    }
};

local $Log::Minimal::PRINT = sub {
    my ( $time, $type, $message, $trace) = @_;
    $message = color($COLOR->{lc($type)}->{text}) . $message . color("reset") if $COLOR->{lc($type)}->{text};
    $message = color("on_".$COLOR->{lc($type)}->{background}) . $message . color("reset") if $COLOR->{lc($type)}->{background};
    print "$time [$type] " . color($COLOR->{lc($type)}->{text}) . $message . color("reset") . " at $trace\n";
};

debugf("debug");
infof("info");
warnf("warn");
critf("critical");
