package MojoX::Renderer::Mail::Lite;

use strict;
use warnings;

use Carp ();
use Encode ();
use Mojo::ByteStream 'b';

use constant TEST    => $ENV{'TEST' } || 0;
use constant DEBUG   => $ENV{'DEBUG'} || 0;
use constant CHARSET => 'UTF-8';

our $VERSION = '0.12';

sub build {
	my $self = shift;
	my $args = {@_};
	
	return sub {
		my($mojo, $ctx, $output) = @_;
		
		$ctx->app->log->debug('No address to send mail'), return unless $ctx->stash('to');
		$ctx->app->log->debug('No message to send mail'), return unless $ctx->stash('msg');
		
		my $msg     = _enc( $ctx->stash('msg'    ) );
		my $subject = _enc( $ctx->stash('subject') );
		
		my $mail    = join "\n",
			'From: '         . ($ctx->stash('from') || $args->{'from'}),
			'To: '           .  $ctx->stash('to'),
			
			$ctx->stash('cc' ) ? ('Cc:  ' .  $ctx->stash('cc' )) : (),
			$ctx->stash('bcc') ? ('Bcc: ' .  $ctx->stash('bcc')) : (),
			
			'Subject: '      . '=?' . CHARSET . '?B?' . [ grep { s/\n//g;1 } b( $subject )->b64_encode ]->[0] . '?=',
			'Content-Type: ' . ($ctx->app->types->type( $ctx->stash('format') ) || 'text/plain') . '; charset="' . CHARSET . '"',
			'Content-Transfer-Encoding: base64',
			'',
			b( $msg )->b64_encode,
		;
		
		DEBUG && warn $mail;
		
		unless (TEST) {
			open my $mh, '|-', ($args->{'sendmail'} || '/usr/sbin/sendmail -t -oi -oem') or Carp::croak "Can't open mail: $!";
			print   $mh $mail;
		}
		
		return 1;
	};
}

sub _enc($) {
	Encode::_utf8_off($_[0]) if $_[0] && Encode::is_utf8($_[0]);
	return $_[0];
}

1;

__END__

=encoding UTF-8

=head1 NAME

MojoX::Renderer::Mail::Lite - Simple mail renderer for Mojo and Mojolicious through sendmail without prerequires.

Сharset of subject and any data is UTF-8.

Transfer encoding is base64.


=head1 SYNOPSIS

  #!/usr/bin/perl
  
  use Mojolicious::Lite;
  use MojoX::Renderer::Mail::Lite;

  app->renderer->add_handler(
    mail => MojoX::Renderer::Mail::Lite->build(
      from => 'sharifulin@gmail.com',
    )
  );

  get '/simple' => sub {
    my $self = shift;

    $self->render(
      handler => 'mail',

      to      => 'sharifulin@gmail.com',
      subject => 'Тест',
      msg     => 'Привет!',
    );

    $self->render_text('OK');
  };

  get '/render' => sub {
    my $self = shift;

    $self->render(
      handler => 'mail',

      to      => 'sharifulin@gmail.com',
      subject => 'Тест render',
      msg     => $self->render_partial('render', format => 'mail'),
    );

    $self->render(format => 'html');
  } => 'render';

  app->start;

  __DATA__

  @@ render.html.ep
  <p>Привет render!</p>

  @@ render.mail.ep
  Привет render!


=head1 METHODS

=head2 build

This method returns a handler for the Mojo renderer.

Supported parameters:

=over 2

=item * from

Default from address

=item * sendmail 

Path to sendmail, default value is I</usr/sbin/sendmail -t -oi -oem>

=back


=head1 RENDER

  $self->render(
    handler => 'mail',
    
    from    => '...',
    to      => '...',
    cc      => '...',
    bcc     => '...',
    subject => '...',
    msg     => '...',
  );


Supported parameters:

=over 6

=item * from

From address

=item * to 

To addresses

=item * cc

Cc addresses

=item * bcc

Bcc addresses

=item * subject

Subject of mail

=item * msg

Data of mail

=back


=head1 ENVIROMENT VARIABLES

Module has two env variables:

=over 2

=item * DEBUG

Print mail, default value is 0

=item * TEST

No send mail, default value is 0

=back


=head1 TEST AND RUN

  TEST=1 DEBUG=1 PATH_INFO='/render' script/test cgi


=head1 SEE ALSO

=over 3

=item * L<MojoX::Renderer::Mail>

=item * L<MojoX::Renderer>

=item * L<Mojolicious>

=back


=head1 AUTHOR

Anatoly Sharifulin <sharifulin@gmail.com>

=head1 TODO

=over 2

=item * Compatible interface with MojoX::Renderer::Mail

=item * Tests

=back


=head1 BUGS

Please report any bugs or feature requests to C<bug-acme-cpanauthors-russian at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.htMail?Queue=MojoX-Renderer-Mail-Lite>.  We will be notified, and then you'll
automatically be notified of progress on your bug as we make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

  perldoc MojoX::Renderer::Mail::Lite

You can also look for information at:

=over 5

=item * Github

L<http://github.com/sharifulin/MojoX-Renderer-Mail-Lite/tree/master>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.htMail?Dist=MojoX-Renderer-Mail-Lite>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/MojoX-Renderer-Mail-Lite>

=item * CPANTS: CPAN Testing Service

L<http://cpants.perl.org/dist/overview/MojoX-Renderer-Mail-Lite>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MojoX-Renderer-Mail-Lite>

=item * Search CPAN

L<http://search.cpan.org/dist/MojoX-Renderer-Mail-Lite>

=back

=head1 COPYRIGHT & LICENSE

Copyright (C) 2010 by Anatoly Sharifulin.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

