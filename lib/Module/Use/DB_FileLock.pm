package Module::Use::DB_FileLock;

use Tie::DB_FileLock;
use Carp;
use strict;

our $VERSION = 0.01;


=head1 NAME

Module::Use::DB_FileLock

=head1 SYNOPSIS

use Module::Use (Logger => 'DB_FileLock', File => '/my/file'[, Flags => $flags, Mode => $mode]);

=head1 DESCRIPTION

C<Module::Use::DB_FileLock> provides a DB File data store for C<Module::Use> via C<Tie::DB_FileLock>.

=head1 OPTIONS

The values for the options correspond directly to the same values used with the C<Tie::DB_FileLock> object.

=over 4

=item File

This is the base for the DB filename.

=item Flags

This is a string representing the read-write mode of the DB file.  The default
value is C<rw>.

=item Mode

This is a number representing the filesystem permissions of the DB file.  The default
is C<0660>.

=back

=head1 SEE ALSO

L<Module::Use>, L<Tie::DB_FileLock>.

=head1 AUTHOR

James G. Smith <jgsmith@jamesmith.com>

=head1 COPYRIGHT

Copyright (C) 2001 James G. Smith

Released under the same license as Perl itself.

=cut



package Module::Use;

sub log {
    my($self) = shift;

    my $file = $self -> {File} or croak "No DB file specified";
    my $flags= $self -> {Flags} || "rw";
    my $mode = $self -> {Mode} || 0660;

    tie my %hash, 'Tie::DB_FileLock', $file, $flags, $mode, $DB_BTREE or croak $!;

    foreach (@_) {
        $hash{$_}++;
    }
}

sub _query_modules {
    my($self) = shift;

    my $file = $self -> {File} || croak "No DB file specified";
    my $flags= $self -> {Flags} || "rw";
    my $mode = $self -> {Mode} || 0660;

    tie my %hash, 'Tie::DB_FileLock', $file, $flags, $mode, $DB_BTREE or croak $!;

    return \%hash;
}

1;
