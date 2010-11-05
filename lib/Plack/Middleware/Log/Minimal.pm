package Plack::Middleware::Log::Minimal;
use strict;
use warnings;
use parent qw(Plack::Middleware);
use Log::Minimal;
use Term::ANSIColor qw//;

our $VERSION = '0.01';

our $DEFAULT_COLOR = {
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

sub build_logger {
    my ($self, $env) = @_;
    return sub {
        my ( $time, $type, $message, $trace) = @_;
        if ( $ENV{PLACK_ENV} && $ENV{PLACK_ENV} eq 'development' ) {
             $message = Term::ANSIColor::color($DEFAULT_COLOR->{lc($type)}->{text}) 
                 . $message . Term::ANSIColor::color("reset")
                 if $DEFAULT_COLOR->{lc($type)}->{text};
             $message = Term::ANSIColor::color("on_".$DEFAULT_COLOR->{lc($type)}->{background}) 
                 . $message . Term::ANSIColor::color("reset")
                 if $DEFAULT_COLOR->{lc($type)}->{background};
        }
        $env->{'psgi.errors'}->print("$time [$type] [$env->{REQUEST_URI}] $message at $trace\n");
    };
}


sub prepare_app {
    my $self = shift;
}

sub call {
    my ($self, $env) = @_;
    local $Log::Minimal::PRINT = $self->build_logger($env);
    local $ENV{$Log::Minimal::ENV_DEBUG} = ($ENV{PLACK_ENV} && $ENV{PLACK_ENV} eq 'development') ? 1 : 0;
    $self->app->($env);
}

1;
__END__

=head1 NAME

Plack::Middleware::Log::Minimal - Log::Minimal middleware to prints to psgi.errors

=head1 SYNOPSIS

  use Log::Minimal;
  use Plack::Builder;

  builder {
      enable "Plack::Middleware::Log::Minimal";
      sub {
          my $env = shift;
          debugf("debug message");
          infof("infomation message");
          warnf("warning message");
          critf("critical message");
          ["200",[ 'Content-Type' => 'text/plain' ],["OK"]];
      };
  };

  # print "2010-10-20T00:25:17 [INFO] infomation message at example.psgi" to psgi.errors stream

=head1 DESCRIPTION

Plack::Middleware::Log::Minimal is middleware that integrates with L<Log::Minimal>.
When Log::Minimal log functions like warnf, infof or debugf were used in PSGI Application,
this middleware adds requested URI to messages and prints that to psgi.errors stream.

IF $ENV{PLACK_ENV} is "development", Plack::Middleware::Log::Minimal attach color to log using L<Term::ANSIColor>.


=head1 AUTHOR

Masahiro Nagano E<lt>kazeburo {at} gmail.comE<gt>

=head1 SEE ALSO

L<Log::Minimal>, L<Term::ANSIColor>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


