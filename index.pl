#!/usr/bin/perl
use Mojolicious::Lite;
use Mojolicious::Static;
use 5.010;

push(@{ app->static->paths }, $ENV{UPLOAD_BASE_DIR} // 'cache');

post '/ok' => sub {
	my $self = shift;
	if (my $upload = $self->req->upload('file')) {
		my $name = $upload->filename;

		my $prefix = $ENV{UPLOAD_BASE_DIR} // 'cache';
		my $url;

		$upload->move_to("${prefix}/${name}");
		$url = "https://up.finalrewind.org/${name}";

		$self->stash(
			filename => $name,
			size => $upload->size,
			url => $url,
		);
	}
	else {
		$self->render('form');
	}
};

any '/' => 'forbidden';
any '/add' => 'form';

any '/get/:file' => sub {
	my $self = shift;
	my $file = $self->stash('file');
	my $static = $self->app->static;
	$self->app->log->debug("serve $file");
	$static->serve($self, $file);
	$self->rendered;
};

app->config(
	hypnotoad => {
		listen => [ $ENV{LISTEN} // 'http://*:8097'],
		pid_file => '/tmp/upload.pid',
		workers => $ENV{WORKERS} // 1,
	},
);

app->defaults( layout => 'default' );

$ENV{MOJO_MAX_MESSAGE_SIZE} = 5242880000;

app->start;
