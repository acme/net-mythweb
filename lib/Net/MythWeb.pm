package Net::MythWeb;
use Moose;
use MooseX::StrictConstructor;
use HTML::TreeBuilder::XPath;
use Net::MythWeb::Channel;
use Net::MythWeb::Programme;
use LWP;
use URI::URL;

our $VERSION = '0.33';

has 'hostname' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'localhost',
);

has 'port' => (
    is      => 'rw',
    isa     => 'Int',
    default => 80,
);

has 'user_agent' => (
    is      => 'rw',
    isa     => 'LWP::UserAgent',
    default => sub {
        my $ua = LWP::UserAgent->new;
        $ua->default_header( 'Accept-Language' => 'en' );
        return $ua;
    },
);

__PACKAGE__->meta->make_immutable;

sub recordings {
    my $self = shift;

    my @recordings;

    my $response = $self->_request('/mythweb/tv/recorded');

    my $tree = HTML::TreeBuilder::XPath->new;
    $tree->parse_content( $response->content );

    my %seen;
    foreach my $link ( $tree->findnodes('//a')->get_nodelist ) {
        my $href = $link->attr('href');
        next unless $href;
        next unless $href =~ m{/detail/};
        next if $seen{$href}++;
        push @recordings, $self->_programme($href);
    }
    return @recordings;
}

sub _programme {
    my ( $self, $path ) = @_;
    my $response = $self->_request($path);

    my ( $channel_id, $start_epoch ) = $path =~ m{(\d+)/(\d+)};

    my $tree = HTML::TreeBuilder::XPath->new;
    $tree->parse_content( $response->content );

    #$tree->findnodes('//td[@class="x-channel"]/a')->pop->content_list;

    my @channel_parts
        = $tree->findnodes('//td[@class="x-channel"]/a')->pop->content_list;
    my $channel_number = $channel_parts[3]->content->[0];
    my $channel_name   = $channel_parts[5];
    $channel_name =~ s/^ +//;
    $channel_name =~ s/ +$//;

    my $channel = Net::MythWeb::Channel->new(
        id     => $channel_id,
        number => $channel_number,
        name   => $channel_name
    );

    # warn "[$channel_id, $channel_number, $channel_name]";

    my @title_parts
        = $tree->findnodes('//td[id("x-title")]/a')->pop->content_list;
    my $title = $title_parts[0];
    my $subtitle = $title_parts[2] || '';
    # warn "[$title / $subtitle]";

    my @description_parts
        = $tree->findnodes('//td[id("x-description")]')->pop->content_list;
    my $description = $description_parts[0];
    $description =~ s/^ +//;
    $description =~ s/ +$//;
    # warn "[$description]";

    return Net::MythWeb::Programme->new(
        channel     => $channel,
        title       => $title,
        subtitle    => $subtitle,
        description => $description,
    );
}

sub _request {
    my ( $self, $path ) = @_;
    my $uri = 'http://' . $self->hostname . ':' . $self->port . $path;

    my $response = $self->user_agent->get($uri);
    confess("Error fetching $uri: $response->status_line")
        unless $response->is_success;

    return $response;

}
