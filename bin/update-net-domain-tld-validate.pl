#!/usr/bin/env perl

use utf8;

use strict;
use warnings;

use POSIX qw(strftime);
use File::Temp qw(tempfile);
use File::Basename;
use Getopt::Long;

use LWP::UserAgent;

use constant TLD_DATA_SOURCE         => 'https://data.iana.org/TLD/tlds-alpha-by-domain.txt';
use constant USER_AGENT              => 'Net::Domain::TLD::Validate (update script)/1.0';

use constant RESPONSE_MAX_SIZE_BYTES => 100 * 1024; # 100Kb
use constant RESPONSE_EXPECTED_TYPE  => 'text/plain';

use constant NO_ERROR      => 0;

use constant ERROR_INIT    => 1;
use constant ERROR_FETCH   => 2;
use constant ERROR_PROCESS => 3;

use constant DEFAULT_OUT_FILE => '-';

my $src_url  = TLD_DATA_SOURCE;
my $src_file;
my $src_fh;
my $dst_file = DEFAULT_OUT_FILE;
my $dst_fh   = *STDOUT;

GetOptions ( 'source-url|u|url=s'    => \$src_url,
             'source-file|f|file=s'  => \$src_file,
             'out|to|dst|out-file=s' => \$dst_file

) or die("Invalid command line arguments\n");

sub get_fh_from_remote
{
    my $url = shift;

    my ($response_fh, $response_file) = tempfile(basename($0, '.pl') . '__XXXXXXXX', UNLINK => 1, TMPDIR => 1);

    my %params = (

        'agent'    => USER_AGENT,
        'max_size' => RESPONSE_MAX_SIZE_BYTES
    );

    my $useragent = LWP::UserAgent->new(%params);
    my $response  = $useragent->get($src_url, ':content_file' => $response_file);

    unless ( $response->is_success )
    {
        warn 'network request failed: unable to fetch data from `' . TLD_DATA_SOURCE . "'\n";
        warn 'error is `' . $response->status_line . "'\n";

        exit ERROR_FETCH;
    }

    # Content-Type: text/plain; charset=UTF-8
    my $content_type = [ split(/;/, $response->header('Content-Type') || '', 2) ]->[0] || '';
    unless ( RESPONSE_EXPECTED_TYPE eq $content_type )
    {
        warn "invalid content type, expected `" . RESPONSE_EXPECTED_TYPE . "' got `$content_type'\n";

        exit ERROR_FETCH;
    }

    # если превысили свои ограничения
    if ( my $aborted = $response->header('Client-Aborted') )
    {
        if ( 'max_size' eq $aborted )
        {
            warn "data fetched but response size limit exceeded, see/tune MAX_FILESIZE_BYTES\n";
        }
        else
        {
            warn "data fetched but something is wrong: `$aborted'\n";
        }

        exit ERROR_FETCH;
    }

    return $response_fh;
}

sub get_fh_from_local
{
    my $file = shift;
    my $fh;

    unless ( open($fh, '<', $file) )
    {
        warn "unable to open file `$file' is not readable\n";
        exit ERROR_FETCH;
    }

    return $fh;
}

$src_fh = ( $src_file ) ? get_fh_from_local($src_file) : get_fh_from_remote($src_url);

if ( $dst_file and $dst_file ne DEFAULT_OUT_FILE )
{
    unless ( open($dst_fh, '>', $dst_file) )
    {
        warn "unable to open file $dst_file for write: `$!'";
        exit ERROR_PROCESS;
    }
}

my $data_version = $src_fh->getline;

unless ( $data_version and $data_version =~ /^# Version \d{2}(\d{2})(\d{2})(\d{1,3})\d?, Last Updated/ and $1 and $2 and $3 )
{
    warn "data version info / file header not found\n",
         "expected `/^# Version (\\d+), Last Updated/' got `",
         defined $data_version ? $data_version : 'undef',
         "'\n";

    exit ERROR_PROCESS;
}

printf $dst_fh join('', <DATA>, "\n"), strftime("%Y-%m-%d %T UTC", gmtime), $1, $2, $3;

unless ( $dst_fh->print(<$src_fh>) )
{
    warn "unable to write: `$!'";
    exit ERROR_PROCESS;
}

__DATA__
# NOTE DO NOT EDIT THIS FILE
# this file is autogenerated by update-net-domain-tld-validate.pl at %s

package Net::Domain::TLD::Validate v%d.%02d.%d;

use utf8;

use strict;
use warnings;

use parent 'Exporter';

our @EXPORT_OK = qw(tld_exists);

our $tld_list;

sub tld_exists
{
    my $domain = shift || return 0;
    my $tld    = uc( [ split(/\./, $domain) ]->[-1] || '' ) || return 0;

    __init_tld_list() unless $tld_list;

    return exists $tld_list->{$tld} ? 1 : 0;
}

sub __init_tld_list
{
    $tld_list = {

        map  { $_ => '1' }

            grep { $_ }

                map  { s/^\s+//s; s/\s+$//s; $_ } <DATA> ## no critic
    };

    close(DATA);
}

1;

__DATA__
