package Net::MythWeb;
use Moose;
use MooseX::StrictConstructor;
use DateTime;
use DateTime::Format::Strptime;
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

sub channels {
    my $self = shift;
    my @channels;

    my $response = $self->_request('/mythweb/settings/tv/channels');

    my $tree = HTML::TreeBuilder::XPath->new;
    $tree->parse_content( $response->content );

    foreach
        my $tr ( $tree->findnodes('//tr[@class="settings"]')->get_nodelist )
    {
        my @tr_parts     = $tr->content_list;
        my $number_input = ( $tr_parts[3]->content_list )[0];
        my $id           = $number_input->attr('id');
        $id =~ s/^channum_//;
        my $number     = $number_input->attr('value');
        my $name_input = ( $tr_parts[4]->content_list )[0];
        my $name       = $name_input->attr('value');
        push @channels,
            Net::MythWeb::Channel->new(
            id     => $id,
            number => $number,
            name   => $name,
            );
    }
    return @channels;
}

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

    my ( $channel_id, $programme_id ) = $path =~ m{(\d+)/(\d+)};

    my $tree = HTML::TreeBuilder::XPath->new;
    $tree->parse_content( $response->content );

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

    my @title_parts
        = $tree->findnodes('//td[id("x-title")]/a')->pop->content_list;
    my $title = $title_parts[0];
    my $subtitle = $title_parts[2] || '';

    my $year = DateTime->from_epoch( epoch => $programme_id )->year;

    my $strptime = DateTime::Format::Strptime->new(
        pattern  => '%Y %a, %b %d, %I:%M %p',
        locale   => 'en_GB',
        on_error => 'croak',
    );

    # Sun, Jun 14, 10:00 PM to 11:00 PM (75 mins)
    my @time_parts
        = $tree->findnodes('//div[id("x-time")]')->pop->content_list;
    my $time_text = $time_parts[0];
    my ( $start_text, $stop_text ) = split ' to ', $time_text;
    $start_text = "$year $start_text";
    my $start = $strptime->parse_datetime($start_text);

    $stop_text =~ s/ \(.+$//;
    my $strptime2 = DateTime::Format::Strptime->new(
        pattern  => '%I:%M %p',
        locale   => 'en_GB',
        on_error => 'croak',
    );
    my $time = $strptime2->parse_datetime($stop_text);
    my $stop = DateTime->new(
        year   => $start->year,
        month  => $start->month,
        day    => $start->day,
        hour   => $time->hour,
        minute => $time->minute,
    );

    # programme runs over midnight
    if ( $stop < $start ) {
        $stop->add( days => 1 );
    }

    my @description_parts
        = $tree->findnodes('//td[id("x-description")]')->pop->content_list;
    my $description = $description_parts[0];
    $description =~ s/^ +//;
    $description =~ s/ +$//;

    return Net::MythWeb::Programme->new(
        id          => $programme_id,
        channel     => $channel,
        start       => $start,
        stop        => $stop,
        title       => $title,
        subtitle    => $subtitle,
        description => $description,
        mythweb     => $self,
    );
}

sub _download_programme {
    my ( $self, $programme, $filename ) = @_;
    my $uri
        = $self->_uri( '/mythweb/pl/stream/'
            . $programme->channel->id . '/'
            . $programme->id );
    my $mirror_response
        = $self->user_agent->get( $uri, ':content_file' => $filename );
    confess( $mirror_response->status_line )
        unless $mirror_response->is_success;
}

sub _delete_programme {
    my ( $self, $programme ) = @_;

    $self->_request( '/mythweb/tv/recorded?delete=yes&chanid='
            . $programme->channel->id
            . '&starttime='
            . $programme->id );
}

sub _request {
    my ( $self, $path ) = @_;
    my $uri = $self->_uri($path);

    my $response = $self->user_agent->get($uri);
    confess("Error fetching $uri: $response->status_line")
        unless $response->is_success;

    return $response;
}

sub _uri {
    my ( $self, $path ) = @_;
    return 'http://' . $self->hostname . ':' . $self->port . $path;
}
