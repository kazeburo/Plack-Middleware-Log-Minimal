package Plack::Middleware::Log::Minimal;
use strict;
use warnings;
use parent qw(Plack::Middleware);
use Plack::Util::Accessor qw(color);
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
        if ( $ENV{PLACK_ENV} eq 'development' ) {
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
    local $ENV{$Log::Minimal::ENV_DEBUG} = ($ENV{PLACK_ENV} eq 'development') ? 1 : 0;
    $self->app->($env);
}

1;
__END__

=head1 NAME

Plack::Middleware::Log::Minimal -

=head1 SYNOPSIS

  use Plack::Middleware::Log::Minimal;

=head1 DESCRIPTION

Plack::Middleware::Log::Minimal is

=head1 AUTHOR

Masahiro Nagano E<lt>kazeburo {at} gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
