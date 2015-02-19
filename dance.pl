#!/usr/bin/perl

# USAGE: nohup ./dance.pl > dance.log &
#        Listens for Beeminder webhooks and updates Beeminder goals
#        Add your own subs into %handler 
#        Inspired by PJF's Exobrain
#
# AUTHOR:  Philip Hellyer, www.hellyer.net
# URL:     https://github.com/pjjh/bmndr
# FILE:    dance.pl
# LICENSE: Creative Commons BY-NC-SA
#          http://creativecommons.org/licenses/by-nc-sa/4.0/
#          Copyright 2015 Philip Hellyer

# DEPENDENCIES & LIMITATIONS
use Try::Tiny;
use Data::Dumper;
use Dancer qw(get set post warning debug status error dance params param);
use WebService::Beeminder;
use LWP::Protocol::https; 

## CONFIG ##

# Your user token from https://www.beeminder.com/api/v1/auth_token.json
our $bmndr = WebService::Beeminder->new(
		token => 'PASTE_TOKEN_HERE' 
		);

# Update this goal every time a callback is processed, undef for no action
our $callback_audit = undef;

# Dancer config
# This is part of the URL to set on the Terrifyingly Advanced Settings tab
# TODO There's a qr{*} way down the code that specifies the URL slug to handle
set port     => 3000;
set logger   => 'console';
set log      => 'warning'; # 'warning' or 'debug'
set warnings => 1;

# Set to a true value if you want to include the JSON in the Debug output
our $debug_packet = 0; 


# hash of code references to handle webhook callbacks 
# keys are checked in this order: 
#      'user/goal', to match the source of the callback
#      'comment',   to match the exact comment of the added datapoint
our %handler;


#
# Add your own handlers here:
#

# Runkeeper => Sweat
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

# Copy email from one Beeminder account to the other
$handler{'pandf/gmailzero'} = sub {
	my $comment = param('comment');
	my $value   = param('value');
	$bmndr->add_datapoint( goal => 'emailzero', value => $value, comment => "$comment (pandf/gmailzero)");
	debug("Added related Datapoint" );
};


#
# Foursquare checkins pushed by Zapier onto a single Beeminder goal, then handled here...
# 

# Salsa dance night
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


## END CONFIG ##



post qr{.*} => sub {

        print STDERR qx(date);

        if ( $debug_packet ) {
          my $pktdump = Dumper ({ params() });
          debug("Receieved packet: $pktdump");
        }

	# If we see what could be a valid response, but it's not
	# an 'ADD', then ignore it.
	if( (param('action')||"") ne 'ADD') {
            warning("Non-add packet received: " . param('action') . " on " . param('source'));
            return "IGNORED";
        }


        try {
		my $source  = param('source');
		my $comment = param('comment');
		debug("About to handle $source packet...");
                if ( $callback_audit ) {
                  $bmndr->add_datapoint( goal => "$callback_audit",  value => 1,  comment => "$source" ); 
                }
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


dance;

1;

__END__
