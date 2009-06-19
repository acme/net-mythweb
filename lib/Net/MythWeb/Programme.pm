package Net::MythWeb::Programme;
use Moose;
use MooseX::StrictConstructor;

has 'id' => (
    is  => 'rw',
    isa => 'Int',
);

has 'title' => (
    is  => 'rw',
    isa => 'Str',
);

has 'subtitle' => (
    is  => 'rw',
    isa => 'Str',
);

has 'channel' => (
    is  => 'rw',
    isa => 'Str',
);

has 'start' => (
    is  => 'rw',
    isa => 'DateTime',
);

has 'stop' => (
    is  => 'rw',
    isa => 'DateTime',
);

has 'description' => (
    is  => 'rw',
    isa => 'Str',
);

has 'channel' => (
    is  => 'rw',
    isa => 'Net::MythWeb::Channel',
);

has 'mythweb' => (
    is  => 'rw',
    isa => 'Net::MythWeb',
);

__PACKAGE__->meta->make_immutable;

sub download {
    my ( $self, $filename ) = @_;
    $self->mythweb->_download_programme( $self, $filename );
}

1;

