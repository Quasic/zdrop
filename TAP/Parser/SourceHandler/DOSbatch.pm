package TAP::Parser::SourceHandler::DOSbatch;

use strict;
use warnings;

use TAP::Parser::IteratorFactory   ();
use TAP::Parser::Iterator::Process ();

use base 'TAP::Parser::SourceHandler::Executable';

TAP::Parser::IteratorFactory->register_handler(__PACKAGE__);

=head1 NAME

TAP::Parser::SourceHandler::DOSbatch - Stream TAP from a DOS BATch script

=head1 VERSION

Version 1

=head1 Reason

TAP::Parser::SourceHandler::Executable has support for DOS BATch, at least on Windows, but doesn't seem to work on all my Windows test machines. I made this to work on my test machines, and skip if non-Windows.

=head1 BUGS

Report bugs to https://github.com/Quasic/TAP/issues

=head1 LICENSE

Released under Creative Commons Attribution (BY) 4.0 license

=cut

my$hasDOS;

sub can_handle {
  my ( $class, $src ) = @_;
  my $meta = $src->meta;
  return 0 unless $meta->{is_file};
  my $file = $meta->{file};
  return 0 if$file->{shebang}=~/^#/;
  return 0.9 if $file->{lc_ext}=~/^\.(bat|cmd|nt)$/;
}

sub make_iterator {
  my ( $class, $source ) = @_;
  my $meta        = $source->meta;
  my $batch_script = ${ $source->raw };

  $class->_croak("Cannot find ($batch_script)") unless $meta->{is_file};
  if(!defined$hasDOS){
    $hasDOS=`bash -c 'command -v cmd.exe||command -v command.com'`;
    chomp($hasDOS);
  }
  return TAP::Parser::Iterator::Array->new(["1..0 #Skipped: no DOS"])if!$hasDOS;
  return TAP::Parser::Iterator::Array->new(["1..0 #Skipped: only command.com batch files supported"])if$hasDOS=~/command.com$/&&$meta->{file}{lc_ext}ne'.bat';

  $class->_autoflush( \*STDOUT );
  $class->_autoflush( \*STDERR );
  
  $batch_script=~s~^/([a-zA-Z])/~$1:\\~;
  $batch_script=~s~/~\\~g;

  return TAP::Parser::Iterator::Process->new(
      {   command  => [$hasDOS,'//c',$batch_script],
      }
  );
}
1;
