#!/usr/bin/perl
use strict;
use Module::Build;

my $builder = Module::Build->new(
   module_name       => 'SDLx::IsoMap',
   license           => 'perl',
   dist_author       => 'Zach Morgan <zpmorgan@cpan.org>',
   dist_version_from => 'lib/SDLx/IsoMap.pm',
   dist_abstract     => 'Versatile isometric maps for SDL',
   requires          => {
      'Carp' => 0,
      'Test::More' => 0,
#      'Test::Number::Delta' => 0,
#      'List::AllUtils' => 0,
#      'POSIX' => 0,
#      'Set::Object' => 0,
   },
   #create_makefile_pl => 'traditional', #any reason?
#   include_dirs => 'inc',
);

$builder->create_build_script();
