package Module::Use::Debug;

use strict;
use vars qw($VERSION);

$VERSION = 0.04;


package Module::Use;

sub log {
    my($self) = shift;

    # dump to STDERR...
    print STDERR "Modules used:\n  ", join("\n  ", sort @_), "\n";
}

sub _query_modules { };

1;

__END__

=head1 NAME

Module::Use::Debug

=head1 SYNOPSIS

use Module::Use (Logger => 'Debug');

=head1 DESCRIPTION

C<Module::Use::Debug> provides a dump to STDERR of the modules used in a script.

=head1 OPTIONS

There are no options.

=head1 SEE ALSO

L<Module::Use>.

=head1 AUTHOR

James G. Smith <jsmith@cpan.org>

=head1 COPYRIGHT

Copyright (C) 2002 Texas A&M University.  All Rights Reserved.

Released under the same license as Perl itself.
