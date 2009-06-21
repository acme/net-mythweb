package Net::MythWeb::Programme;
use Moose;
use MooseX::StrictConstructor;

has 'id' => ( isa => 'Int' );

has 'title' => ( isa => 'Str' );

has 'subtitle' => ( isa => 'Str' );

has 'channel' => ( isa => 'Str' );

has 'start' => ( isa => 'DateTime' );

has 'stop' => ( isa => 'DateTime' );

has 'description' => ( isa => 'Str' );

has 'channel' => ( isa => 'Net::MythWeb::Channel' );

has 'mythweb' => ( isa => 'Net::MythWeb' );

__PACKAGE__->meta->make_immutable;

sub download {
    my ( $self, $filename ) = @_;
    $self->mythweb->_download_programme( $self, $filename );
}

sub delete {
    my ($self) = @_;
    $self->mythweb->_delete_programme($self);
}

sub record {
    my ( $self, $start_extra, $stop_extra ) = @_;
    $self->mythweb->_record_programme( $self, $start_extra, $stop_extra );
}

1;

__END__

=head1 NAME

Net::MythWeb::Programme - A MythWeb programme

=head1 METHODS

=head2 delete

=head2 download

=head2 record

=head1 SEE ALSO

L<Net::MythWeb>, L<Net::MythWeb::Channel>.

=head1 AUTHOR

Leon Brocard <acme@astray.com>.

=head1 COPYRIGHT

Copyright (C) 2009, Leon Brocard

=head1 LICENSE

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.
