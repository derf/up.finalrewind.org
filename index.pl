#!/usr/bin/perl
use Mojolicious::Lite;
use Mojolicious::Static;
use 5.010;

push( @{ app->static->paths }, $ENV{UPLOAD_BASE_DIR} // 'cache' );

post '/add' => sub {
	my $self = shift;
	if ( my $upload = $self->req->upload('file') ) {
		my $name = $upload->filename;

		my $prefix = $ENV{UPLOAD_BASE_DIR} // 'cache';
		my $url;

		if ( not -d $prefix ) {
			mkdir($prefix);
		}

		my $user = $self->req->headers->header('X-Remote-User') // 'dev';

		$user =~ tr{[a-zA-z0-9]}{_}c;

		if ( not -d "$prefix/$user" ) {
			mkdir("$prefix/$user");
		}

		$upload->move_to("${prefix}/${user}/${name}");
		$url = "https://up.finalrewind.org/${user}/${name}";

		$self->stash(
			filename => $name,
			size     => $upload->size,
			url      => $url,
		);
		$self->render('ok');
	}
	else {
		$self->render('form');
	}
};

any '/'    => 'forbidden';
get '/add' => 'form';

app->config(
	hypnotoad => {
		listen => [ $ENV{LISTEN} // 'http://*:8097' ],
		pid_file => '/tmp/upload.pid',
		workers  => $ENV{WORKERS} // 1,
	},
);

app->defaults( layout => 'default' );

$ENV{MOJO_MAX_MESSAGE_SIZE} = 5242880000;

app->start;
