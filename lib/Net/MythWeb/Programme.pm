package Net::MythWeb::Programme;
use Moose;
use MooseX::StrictConstructor;

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

__PACKAGE__->meta->make_immutable;

1;

