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

