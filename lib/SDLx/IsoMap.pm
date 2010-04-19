package SDLx::IsoMap;
use Mouse;
use Math::Trig;
use Carp;
use POSIX qw/floor/;

use SDL;
use SDL::Surface;
use SDL::Image;
use SDL::Color;
use Imager;
use Imager::Fill;

use SDLx::IsoMap::Tile;

# origin (0,0) is at top of screen
# x goes from sw<->ne

#somecolor weird
my $colorkey = Imager::Color->new("#C63431");
my $colorkey_fill = Imager::Fill->new(solid=>$colorkey);
my $sdl_colorkey = SDL::Color->new( 0xc6,0x34, 0x31 );

my $green = Imager::Color->new("#22aa22");

# key: 'texname~0,1,1,0',
# value: an SDL::Surface
has _tile_surfs => (
   is => 'ro',
   isa => 'HashRef',
   default => sub{{}},
);

# This is just a constructor parameter infodump for pre-existing tiles
has tiles => (
   is => 'ro',
   isa => 'ArrayRef',
);

# distance in pixels from (1,0) to (0,1)
has _tile_drawn_w => (
   is => 'ro',
   isa => 'Int',
   requred => 1,
   default => 64,
);

has _tile_drawn_h => (
   is => 'ro',
   isa => 'Int',
   lazy => 1,
   default => sub { $_[0]->_tile_drawn_w * cos($_[0]->angle_of_incidence) }
);

has step_height => (
   is => 'ro',
   isa => 'Int',
   lazy => 1,
   #default => sub{ int ($_[0]->tile_drawn_w / 5) },
   default => 8,
);

has angle_of_incidence => (
   is => 'ro',
   isa => 'Num',
   default => pi/4, #45 degrees in radians
);

has _tiles => ( # '$x-$y' => $tile
   is => 'ro',
   isa => 'HashRef',
   lazy => 1,
   default => sub{{}},
   #default => \&_construct_tiles,
);

sub _construct_tile {
   my ($self, $x, $y) = @_;
   my $info = $self->tiles->[0][0];
   my $key = 'green~0,0,0,0';
   unless ($self->_tile_surfs->{$key}) {
      $self->_tile_surfs->{$key} = $self->_construct_tile_surf($key);
   }
   
   my $tile = SDLx::IsoMap::Tile->new(
      key => $key,
      base => 0,
      surf => $self->_tile_surfs->{$key},
   );
   $self->_tiles->{"$x-$y"} = $tile;
}

sub _construct_tile_surf{
   my ($self, $tilekey) = @_;
   $tilekey =~ m/^([^~]*)~(.*)$/;
   my $texname = $1;
   my @corner_heights = split ',', $2;
   my $image = Imager->new (xsize=>$self->_tile_drawn_w, ysize=>$self->_tile_drawn_h);
   #I want imager to draw on an SDL surface. Using $surface->get_pixels_ptr();
   $image->box (fill=>$colorkey_fill);
   $image->polygon (color => $green, points => [[32,0], [64,$self->_tile_drawn_h/2],[32,$self->_tile_drawn_h],[0,$self->_tile_drawn_h/2]]);
   
   my $filename = '/tmp/' . rand() . '.png';
   warn $filename;
   $image->write (file=>$filename) or die "Cannot write: ",$image->errstr;
   
   my $surf = SDL::Image::load($filename);
   SDL::Video::set_color_key( $surf, SDL_SRCCOLORKEY, $sdl_colorkey );
   $surf = SDL::Video::display_format_alpha($surf);
   return $surf;
}

sub _tile_at {
   my ($self, $x, $y) = @_;
   my $tile = $self->_tiles->{"$x-$y"};
   unless ($tile) {
      $self->_construct_tile($x,$y);
      $tile = $self->_tiles->{"$x-$y"};
   }
   die unless $tile;
   return $tile;
}

sub draw{
   my ($self, %params) = @_;
   my @tile_coordinates = $self->get_tile_coordinates_in_area 
      ($params{x},$params{y}, $params{x}+$params{w}, $params{y}+$params{h});
   for (@tile_coordinates){
      $self->_draw_tile ($params{surf}, $_->[0], $_->[1], $params{u}, $params{v},$params{x}, $params{y},$params{w}, $params{h} );
   }
}

sub _draw_tile {
   my ($self, $onto_surf, $tile_x, $tile_y, $u, $v, $x, $y, $w, $h) = @_;
   my $tile = $self->_tile_at($tile_x,$tile_y);
   my $u_offset = floor((-$tile_x+$tile_y-1) * $self->_tile_drawn_w/2);
   my $v_offset = floor( ($tile_x+$tile_y)  *  $self->_tile_drawn_h/2);
   warn $u_offset;
   SDL::Video::blit_surface (
      $tile->surf,
      SDL::Rect->new( 0,0,100,100),
      $onto_surf,
      SDL::Rect->new($u+$u_offset ,$v+$v_offset, $w,$h),
   );
}

#returned tiles must be ordered so near stuff comes last.
#negative axes are up, x axis is sw<->ne

sub get_tile_coordinates_in_area {
   my ($self,$x1,$y1,$x2,$y2) = @_;
   my @tile_coordinates;
   my $first_tile_row = floor ( ($x1-$self->_tile_drawn_h/2) / $self->_tile_drawn_h);
   my $last_tile_row =  floor ( ($x2+$self->_tile_drawn_h/2) / $self->_tile_drawn_h);
   for my $row ($first_tile_row .. $last_tile_row){
      push @tile_coordinates, $self->_get_tile_row_coordinates_bounded ($row, $x1, $x2);
   }
   return @tile_coordinates;
}

sub _get_tile_row_coordinates_bounded {
   my ($self,$row,$x1,$x2) = @_;
   my @tile_coordinates;
   my $first_tile_x = floor (($x1 + ($row+1)*$self->_tile_drawn_w/2) / $self->_tile_drawn_w);
   my $last_tile_x  = floor (($x2 + ($row+1)*$self->_tile_drawn_w/2) / $self->_tile_drawn_w);
   for my $tile_x ($first_tile_x..$last_tile_x){
      push @tile_coordinates, [$tile_x, $row-$tile_x];
   }
   return @tile_coordinates;
}

'i despise turtles'
