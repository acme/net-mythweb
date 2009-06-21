package Net::MythWeb::Channel;
use Moose;
use MooseX::StrictConstructor;

has 'id' => ( isa => 'Int' );

has 'number' => ( isa => 'Int' );

has 'name' => ( isa => 'Str' );

__PACKAGE__->meta->make_immutable;

1;

