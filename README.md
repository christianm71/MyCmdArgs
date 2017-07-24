# MyCmdArgs
manage command line arguments

# Name
MyCmdArgs.md

# SYNOPSYS

```
use MyCmdArgs;

my $cmd_args=MyCmdArgs->new();

$cmd_args->add(
  "name"=>"version",
  "opt"=>["-v", "--version"],
  "default"=>12102,
  "allow"=>[11204, 12102, 12201]
);

$cmd_args->add(
  "name"=>"pds",
  "opt"=>["-pds"],
  "mandatory"=>"yes",
  "allow"=>["PAD/i", "L2LE/i"]
);

$cmd_args->check(@ARGV);
```
