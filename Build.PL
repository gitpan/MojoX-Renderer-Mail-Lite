use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'MojoX::Renderer::Mail::Lite',
    license             => 'perl',
    dist_author         => 'Anatoly Sharifulin <sharifulin@gmail.com>',
    dist_version_from   => 'lib/MojoX/Renderer/Mail/Lite.pm',
	dist_abstract       => 'Simple mail renderer for Mojo and Mojolicious through sendmail without prerequires',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
		'Carp' => 0,
		'Encode' => 0,
		'Mojo::ByteStream' => 0,
    },
	meta_merge => {
		resources => {
			repository => 'git://github.com/sharifulin/MojoX-Renderer-Mail-Lite.git',
		},
		keywords => ['mojo', 'mojolicious', 'lite', 'mail', 'renderer'],
	},
    add_to_cleanup      => [],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
