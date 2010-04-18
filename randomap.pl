#!/usr/bin/perl
use warnings;
use strict;
use lib 'lib';

use SDL;
use SDL::Video;
use SDL::Event;
use SDL::Events;
use SDL::Rect;
use SDLx::IsoMap;
use Carp;

my $app = SDL::Video::set_video_mode( 850, 500, 32, SDL_SWSURFACE );
   croak 'Cannot init video mode 800x500x32: ' . SDL::get_error() unless $app;


my $map = new SDLx::IsoMap (tile_diag => 50, w=>1, h=>1, tiles => [[{type=>0}]]);

my $dest_rect = SDL::Rect->new (100,100,100,100);


# Get an event object to snapshot the SDL event queue
my $event = SDL::Event->new();
for(1..100){
   while ( SDL::Events::poll_event($event) ){
   #Get all events from the event queue in our event
      exit if ($event->type == SDL_QUIT) ;
   }
   my ($u,$v,$w,$h) = (100,100,300,150);
   $map->draw (surf=>$app, rect=>$dest_rect, u=>$u,v=>$v, x=>0,y=>0, w=>$w, h=>$h);
   
   SDL::Video::flip($app);
}
#sleep(1);
