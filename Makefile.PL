use utf8;
use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'              => 'Net::Domain::TLD::Validate',
    'LICENSE'           => 'perl',
    'AUTHOR'            => 'dctabuyz@ya.ru',
    'VERSION_FROM'      => 'lib/Net/Domain/TLD/Validate.pm',

    'EXE_FILES'         => [ qw(bin/update-net-domain-tld-validate.pl) ],

    'NO_MYMETA'         => 1,

    'PREREQ_FATAL'      => 1,
    'PREREQ_PM'         => {
        'LWP::UserAgent'  => 0,
    },
);
