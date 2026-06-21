#!/bin/sh
curl -O https://raw.githubusercontent.com/ACE-Genomics/tool-slurmize/refs/heads/main/slurmExec.pm
mkdir -p $HOME/.local/lib/perl5
mv slurmExec.pm $HOME/.local/lib/perl5/
export PERL5LIB=$PERL5LIB:$HOME/.local/lib/perl5/
echo 'export PERL5LIB=$PERL5LIB:$HOME/.local/lib/perl5/' >> $HOME/.bash_profile
