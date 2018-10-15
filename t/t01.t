#!/usr/bin/env perl

use utf8;
use open qw(:std :utf8);

use strict;
use warnings;

use Test::More;
use File::Temp qw(tempfile);

use FindBin;
use lib ($FindBin::Bin . '/../lib');

BEGIN {

    use_ok('LWP::UserAgent');
}

my $script = $FindBin::Bin . '/../bin/update-net-domain-tld-validate.pl';

my ($fh, $filename) = tempfile('Net_Domain_TLD_Validate_TLD_XXXXXX', TMPDIR => 1, SUFFIX => '.pm', UNLINK => 1);

note('package file is ' . $filename);

print $fh qx{ $^X $script };

my $exit_code = $?;

is($exit_code, 0, 'package generated, exit code 0');

SKIP: {

    skip('generator failed', 9) if $exit_code;

    ok(-f $filename, 'package file exists');
    ok(-s $filename, 'package file is not empty');

    require_ok($filename);

    like($Net::Domain::TLD::Validate::VERSION, '/^\d+\.20\d+$/', 'version looks good');

    ok(Net::Domain::TLD::Validate::tld_exists('ru'),  '.ru  exists');
    ok(Net::Domain::TLD::Validate::tld_exists('com'), '.com exists');
    ok(Net::Domain::TLD::Validate::tld_exists('org'), '.org exists');

    ok( ! Net::Domain::TLD::Validate::tld_exists('cadabra'), '.cadabra not exists');
    ok( ! Net::Domain::TLD::Validate::tld_exists('test'),    '.test not exists');
}

done_testing();
