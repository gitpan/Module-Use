package Module::Use;

use Carp;
use strict;

our $VERSION = 0.03;



=head1 NAME

Module::Use

=head1 SYNOPSIS

=over 0

=item Perl

  use Module::Use (Logger => "Debug");

=item mod_perl

  <Perl>
  use Module::Use (Logger => "Debug");
  </Perl>

  PerlChildExitHandler Module::Use
  PerlCleanupHandler Module::Use
  PerlLogHandler Module::Use

=back

=head1 DESCRIPTION

Module::Use will record the modules used over the course of the 
Perl interpreter's lifetime.  If the logging module is able, the 
old logs are read and frequently used modules are automatically 
loaded.  Note that no symbols are imported into packages.

Under mod_perl, only one Perl*Handler should be selected, 
depending on when and how often logging should take place.

=head1 OPTIONS

The following options are available when C<use>ing this module.

=over 4

=item Count

This is the number of times a module has been used for it to be automatically loaded.

=item Decay

This number is subtracted from the count of all modules that are in the
data store but were not loaded.

=item Grow

This number is added to the count of all modules that were loaded.

=item Limit

Do not automatically load more than this many modules.

=item Logger

This is the logging module to use.  Configuration is specific to the module
chosen.  Please see the documentation for the module.

The module name is C<Module::Use::Logger> with C<Logger> replaced with the value of this option.

=item Percentage

The percentage of total module loads is used in the same manner as the C<Count>.  If both C<Percentage> and
C<Count> are given, the one with the greater counts is used.

=back

=head1 SEE ALSO

L<Module::Use::Debug>, L<Module::Use::DB_FileLock>.

=head1 AUTHOR

James G. Smith <jgsmith@jamesmith.com>

=head1 COPYRIGHT

Copyright (C) 2001 James G. Smith

Released under the same license as Perl itself.

=cut


# desired implementation (allows for counting times requested):
#sub use : immediate {
#    # if logging module loaded, use it
#    return &CORE::use(@_);
#}
#
#sub require {
#    # if logging module loaded, use it
#    return CORE::require(@_);
#}

# actual implementation:

sub import { 
    my($self, %config) = @_;

    croak "@{[ref $self]} not intended to be instanced" if ref $self;

    # load logging module - defines Module::Use::log
    if(defined $config{Logger}) {
        eval("use Module::Use::$config{Logger};");
        croak $@ if $@;
    }
    our $_object = bless { %config }, $self;

    my @ikeys = keys %INC;

    @{$_object -> {Ignore}}{@ikeys} = (1) x @ikeys;

    if(defined $INC{'Apache.pm'}) {
        $_object -> {log_at_end} = 0;
    } else {
        $_object -> {log_at_end} = 1;
    }

    if($_object -> can('_query_modules')) {
        my(@modules) = $_object -> query_modules();
        # the foreach loop is probably optional...
        foreach (@modules) {
            s{/}{::}g;
            s{\.pm$}{};
        }
	eval("use " . join("; use ", @modules), ";");
        croak $@ if $@;
    }
}

sub query_modules {
    my($self) = shift;

    my $hash = $self -> _query_modules();

    my @keys = keys %{$hash};
    my $total = 0;

    local($_);  # JIC

    foreach (@keys) {
        $total += $hash->{$_};
    }

    my $p = 0;
    if($self -> {Percentage}) {
        $p = $self -> {Percentage} * $total;
    }
    if($self -> {Count}) {
        if($p < $self -> {Count}) {
            $p = $self -> {Count};
        }
    }

    my $l;    
    if($self -> {Limit}) {
        $l = $self -> {Limit};
    } else {
        $l = scalar(@keys);
    }

    @keys = sort { $hash->{$a} <=> $hash->{$b} } @keys;

    $#keys = $l-1 if $l;


    @keys = grep { $hash->{$_} > $p } @keys if $p;   # could do a binary search at this point
                         
    return @keys;
}

sub _process_INC {
    our $_object;
    return grep { !defined($_object -> {Ignore} -> {$_}) }
               (grep { $_ !~ m{^Module/Use(/|\.pm)?} && $_ !~ m{^[a-z/]} } 
                   keys %INC);

}

sub handler {
    our $_object;
    no strict qw(subs);

    $_object -> log(_process_INC()) if $_object -> can("log");
    return Apache::Constants::OK;
}

END {
    # now log %INC
    our $_object;
    $_object -> log(_process_INC) if $_object -> {log_at_end} && $_object -> can("log");
}

1;
