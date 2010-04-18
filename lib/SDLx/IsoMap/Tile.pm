package SDLx::IsoMap::Tile;
use Mouse;

# tile elevation at lowest corner.
has base => (
   isa => 'Int',
   is => 'ro',
);

#something like 'grass~0,1,2,1'
has key => (
   is => 'ro',
   isa => 'Str',
);

has surf => (
   is => 'rw',
   isa => 'SDL::Surface',
);

#also: something to contain trees,buildings, walls, etc????

'the_Lidless_Eye'
