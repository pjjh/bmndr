#!/usr/bin/perl

# USAGE: nohup ./dance.pl > dance.log &
#        Listens for Beeminder webhooks and updates Beeminder goals
#        Add your own subs into %handler with key 'user/goal'
#
# AUTHOR:  Philip Hellyer 
# URL:     https://github.com/pjjh/bmndr
# FILE:    dance.pl
# LICENSE: Creative Commons BY-NC-SA
#          Copyright 2014 Philip Hellyer

# DEPENDENCIES & LIMITATIONS
# Inspired by PJF's Exobrain
use Try::Tiny;
use Data::Dumper;
use Dancer qw(get set post warning debug status error dance params param);
use WebService::Beeminder;

## CONFIG ##
our $bmndr = WebService::Beeminder->new(
		token => 'FIXME TODO' 
		);


# hash of code references, keys as 'user/goal' source
our %handler;


# This is all Dancer configuration, because we run a little
# Dancer micro-instance.

set port     => 3000;
set logger   => 'console';
set log      => 'warning';
set warnings => 1;

post qr{.*} => sub {

	# If we see what could be a valid response, but it's not
	# an 'ADD', then ignore it.
	if( (param('action')||"") ne 'ADD') {
            warning("Non-add packet received: " . param('action') . " on " . param('source'));
            return "IGNORED";
        }

        #my $pktdump = Dumper ({ params() });
        #debug("Receieved packet: $pktdump");

        try {
		my $source  = param('source');
		my $comment = param('comment');
		debug("About to handle $source packet...");
		if ( exists $handler{$source} ) {
			$handler{$source}->() ;
			warning("Packet from $source handled");
		} elsif( exists $handler{$comment} ) {
			$handler{$comment}->() ;
			warning("Packet from $source handled via '$comment'");
		} else {
			warning("No handler for $source or '$comment'" );
		}
        }
        catch {
		status 'error';
		return "Invalid packet";
        };

        return "OK";
    };


$handler{'pjh/drink'} = sub {
	# not drinking implies zero units
	# (technically, the inverse, but this is easier to manage)
	debug("Received: Datapoint of " . param('value') );
	return unless param('value') == 1;

	$bmndr->add_datapoint(
		goal    => 'units',
		value   => 0,
		comment => 'implied by pjh/drink'
		);
	debug("Added related Datapoint" );
};

$handler{'pjh/lola'} = sub {
        # running and walking counts as sweating if for enough distance (km)
	my $comment = param('comment');
	my $value   = param('value');

        if ( $comment =~ /^Running/ && $value >= 2 or
             $comment =~ /^Walking/ && $value >= 5 ) {
		$bmndr->add_datapoint( goal => 'sweat', value => 1, comment => $comment);
		debug("Added related Datapoint" );
	}
};

# Copy email from one account to the other
$handler{'pandf/gmailzero'} = sub {
	my $comment = param('comment');
	my $value   = param('value');
	$bmndr->add_datapoint( goal => 'emailzero', value => $value, comment => "$comment (pandf/gmailzero)");
	debug("Added related Datapoint" );
};



# Salsa night
$handler{'Checkin at Drayton Court Pub'} = sub {
	$bmndr->add_datapoint( goal => 'sweat', value => 1, comment => 'Salsa Caleña' );
	debug("Added related Datapoint" );
};

# Gym, Swim & Stretch
$handler{'Checkin at Eden Fitness'} = sub {
	$bmndr->add_datapoint( goal => 'flex',  value => 1, comment => 'Checkin at Eden Fitness' );
	$bmndr->add_datapoint( goal => 'gym',   value => 1, comment => 'Checkin at Eden Fitness' );
	$bmndr->add_datapoint( goal => 'sweat', value => 1, comment => 'Checkin at Eden Fitness' );
	debug("Added related Datapoints" );
};

# Gorilla Circus
$handler{'Checkin at Gorilla Circus Flying Trapeze'} = sub {
	$bmndr->add_datapoint( goal => 'flex',  value => 1, comment => 'Gorilla Circus Regents Park' );
	$bmndr->add_datapoint( goal => 'sweat', value => 1, comment => 'Gorilla Circus Regents Park' );
	debug("Added related Datapoints" );
};
$handler{'Checkin at Battersea Park Tennis Courts'} = sub {
	$bmndr->add_datapoint( goal => 'flex',  value => 1, comment => 'Gorilla Circus Battersea' );
	$bmndr->add_datapoint( goal => 'sweat', value => 1, comment => 'Gorilla Circus Battersea' );
	debug("Added related Datapoints" );
};
$handler{'Checkin at Hangar Arts Trust'} = sub {
	$bmndr->add_datapoint( goal => 'flex',  value => 1, comment => 'Gorilla Circus Woolwich' );
	$bmndr->add_datapoint( goal => 'sweat', value => 1, comment => 'Gorilla Circus Woolwich' );
	debug("Added related Datapoints" );
};



dance;

1;

__END__
