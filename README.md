# Net::Domain::TLD::Validate #

Validates specified top level domain against a predefined list of TLDs.

```
use Net::Domain::TLD::Validate 'tld_exists';

for my $domain ( qw(org net dog god) )
{
	print $domain, (tld_exists($domain) ? ' ' : ' not '), "exists\n";
}

```

The list of TLDs can be updated at any time
```
$ bin/update-net-domain-tld-validate.pl > lib/Net/Domain/TLD/Validate.pm
```

## TODO

* timemachine (get data from https://www.iana.org/domains/root/db)
