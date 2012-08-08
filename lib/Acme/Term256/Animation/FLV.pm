package Acme::Term256::Animation::FLV;
use strict;
use warnings;
use parent qw(Acme::Term256::Animation::Base);
use Imager;
use Term::ProgressBar;
use File::Path qw(mkpath rmtree);

sub run {
    my $self = shift;
# data/の掃除
    my $gif_filenames = $self->flv2gif();
    my $asciis = $self->get_asciis( $gif_filenames );
    $self->do_animation( $asciis );
}

sub flv2gif {
    my $self = shift;
    $self->_check_ffmpeg();
    $self->tmpdir( $self->mk_tmpdir() );

    my $command = sprintf('ffmpeg -i %s -f image2 -r 15 %s%s.gif',$self->file, $self->tmpdir, '%10d');
    my $ret = system($command);
    my @filenames = glob $self->tmpdir . "*.gif";
    return \@filenames;
}

sub mk_tmpdir {
    my $self = shift;
    my $digest = $self->get_hexdigest();
    my $tmpdir = sprintf( sprintf('/tmp/%s/', $digest) );
    if( -d $tmpdir ) {
        eval{ rmtree($tmpdir); };
        die "$@" if $@;
    }
    mkpath($tmpdir) or die "can't make directory [$tmpdir]";
    return $tmpdir;
}

sub _check_ffmpeg {
    my $self = shift;
    if( $self->_hasnt_ffmpeg() ) {
        die 'This script needs ffmpeg! Please install and try later!!';
    }
}

sub _hasnt_ffmpeg {
    my $self = shift;
    my $command = 'ffmpeg -L > /dev/null 2>&1';
    my $ret = system($command);
    return $ret;
}

sub get_asciis {
    my $self = shift;
    my $filenames = shift;

    my $progress = Term::ProgressBar->new({ count => scalar @$filenames });
    my $count = 0;
    my @asciis;
    my $scale_ratio;
    for( @$filenames ) {
        my $img = Imager->new;
        my $gif = $img->read( file => $_ ) or die $img->errstr;
        unless( $scale_ratio ) {
            $scale_ratio = $self->get_scale_ratio({
                width  => $gif->getwidth(),
                height => $gif->getheight(),
            });
        }
        my $ascii = $self->gif2ascii( $gif, $scale_ratio );
        push( @asciis, $ascii );
        $count++;
        $progress->update($count);
    }
    return \@asciis;
}


1;
__END__

=head1 NAME

Acme::Term256::Animation::FLV -

=head1 SYNOPSIS

  use Acme::Term256::Animation::FLV;

=head1 DESCRIPTION

Acme::Term256::Animation::FLV is ugokuyo

=head1 AUTHOR

dameninngenn E<lt>dameninngenn.owata {at} gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
