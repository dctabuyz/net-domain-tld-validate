# Net::Domain::TLD::Validate #

Validates specified top level domain against a predefined list of TLDs.

```
use Net::Domain::TLD::Validate 'tld_exists';

print "org exists\n"    if     ( tld_exists('org')      );
print "net exists\n"    if     ( tld_exists('net')      );
print "dog exists\n"    if     ( tld_exists('good.dog') );
print "god not found\n" unless ( tld_exists('dead.god') );

```

The list of TLDs can be updated at any time with command
```
$ bin/update-net-domain-tld-validate.pl > lib/Net/Domain/TLD/Validate.pm
```
