# Net::Domain::TLD::Validate #

Validates specified top level domain against a predefined list of TLDs.

```
use Net::Domain::TLD::Validate;

print "dog exists\n"    if ( Net::Domain::TLD::Validate::tld_exists('dog') );
print "god not found\n" if ( Net::Domain::TLD::Validate::tld_exists('god') );

```

The list of TLDs can be updated at any time with command
```
$ bin/update-net-domain-tld-validate.pl > lib/Net/Domain/TLD/Validate.pm
```
