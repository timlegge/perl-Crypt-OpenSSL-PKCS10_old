use 5.008000;
use ExtUtils::MakeMaker;
use Crypt::OpenSSL::Guess qw(openssl_inc_paths openssl_lib_paths);

use Config;
use File::Spec;
use Crypt::OpenSSL::Guess;
my %args;

my ($major, $minor, $patch) = openssl_version();
print "Installed OpenSSL: $major.$minor.$patch\n";

$args{INC} =  openssl_inc_paths();
$args{LIBS} = [openssl_lib_paths() . ' -lssl -lcrypto'];

my $cc_option_flags;
#my $cc_option_flags = $major ge 3 ? ' -DOPENSSL_API_COMPAT=30000' : ' -DOPENSSL_API_COMPAT=10100';
#my $cc_option_flags = $major ge 3 ? ' -DOPENSSL_API_COMPAT=10100' : ' -DOPENSSL_API_COMPAT=10100';

if ($Config::Config{cc} =~ /gcc/i) {
  $cc_option_flags .= $ENV{AUTHOR_TESTING} ? ' -Wall -Werror' : ' -Wall';
} else {
  $cc_option_flags .= '';
}

if ($Config{gccversion} =~ /llvm/i) {
  if ( $^O eq 'darwin' && (
    $Config{gccversion} =~ /LLVM 1[2-9].\d.[5-9]/ ||
    $Config{gccversion} =~ /LLVM 1[3-9]/ ))
  {
    $cc_option_flags .= ' -Wno-deprecated-declarations -Wno-compound-token-split-by-macro';
  } else {
    $cc_option_flags .= ' -Wno-deprecated-declarations';
  }

  if ($Config{gccversion} =~ /llvm 13/i) {
      $cc_option_flags .= ' -Wno-compound-token-split-by-macro';
  }

  if ($Config{perl_version} <= 20) {
    $cc_option_flags .= ' -Wno-error=pointer-bool-conversion';
  }
}

if ($Config{myuname} =~ /sunos|solaris/i) {
  $args{OPTIMIZE} = $cc_option_flags;
} else {
  $args{OPTIMIZE} = $cc_option_flags;
}

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Crypt::OpenSSL::PKCS10',
    VERSION_FROM      => 'PKCS10.pm',
    PREREQ_PM         => { Crypt::OpenSSL::RSA => 0}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'PKCS10.pm',
       AUTHOR         => 'JoNO <jonozzz@yahoo.com>') : ()),
    INC               => openssl_inc_paths(),
    
    'dist'  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    'clean' => { FILES    => 'Crypt-OpenSSL-PKCS10-*' },
    ( $ExtUtils::MakeMaker::VERSION >= 6.3002 ? ( 'LICENSE' => 'perl', ) : () ),
    (
        $ExtUtils::MakeMaker::VERSION >= 6.46
        ? (
            'META_MERGE' => {
                recommends => {
                    'Crypt::OpenSSL::Bignum' => 0,
                },
                configure_requires => {
                    'Crypt::OpenSSL::Guess' => '0.11',
                },
                build_requires => {
                    'Test' => 0,    # For testing
                },
                resources => {
                    'license'    => 'http://dev.perl.org/licenses/',
                    'homepage'   => 'https://metacpan.org/pod/Crypt::OpenSSL::PKCS10',
                    'bugtracker' => 'https://rt.cpan.org/Public/Dist/Display.html?Name=Crypt-OpenSSL-PKCS10',
                }
            }
          )
        : ()
    ),
    %args,
);
