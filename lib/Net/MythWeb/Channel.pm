package Net::MythWeb::Channel;
use Moose;
use MooseX::StrictConstructor;

has 'id' => (
    is  => 'rw',
    isa => 'Int',
);

has 'number' => (
    is  => 'rw',
    isa => 'Int',
);

has 'name' => (
    is  => 'rw',
    isa => 'Str',
);

__PACKAGE__->meta->make_immutable;

1;

