#!/usr/bin/perl
use strict;
use warnings;
#use SLURMACE qw(send2slurm);
use File::Basename qw(basename);
use FindBin;
use lib "$FindBin::Bin";
use slurmExec;
############################################
###### Variables de ejecucion ##############
############################################
# Tiempo maximo de ejecucion de cada proceso
my $time = '24:0:0';
# Numero de CPUs de cada proceso
my $cpus_per_proc = 4;
# Memoria a usar por cada CPU 
# Si no estas seguro de lo que haces no lo toques
my $mem_per_cpu = '4G';
# Particion del cluster a usar
my $partition = 'fast';
# Directorio para almacenar los scripts y logs
my $wdir = 'slurm';
############################################
##### No editar a partir de aqui ###########
############################################
my $debug = 0;
@ARGV = ("-h") unless @ARGV;
while (@ARGV and $ARGV[0] =~ /^-/) {
	$_ = shift;
	last if /^--$/;
	if (/^-g/) { $debug = 1;}
	if (/^-h/) {print "usage: $0 [-g] input_file\n"; exit;}
}
my $ifile = shift;
die "Should supply input file\n" unless $ifile;
mkdir $wdir;
my $count = 0;
open IPDF, "<$ifile" or die "Could not open input file\n$!\n";

my %ptask = ( 'job-name' => basename($ifile),
	'-c' => $cpus_per_proc,
	'mem-per-cpu' => $mem_per_cpu,
	'time' => $time, 
	'mail-type' => 'FAIL,TIME_LIMIT,STAGE_OUT',
	'debug' => $debug,	
);

while (<IPDF>) {
	unless (/^#.*/ or /^\s*$/){
		$count++;
		my $ofile = sprintf ("%s_%04d", 'sorder', $count);
		$ptask{'filename'} = $wdir.'/'.$ofile.'.sh';
		$ptask{'output'} = $wdir.'/'.basename($ifile).'.out'; 
		$ptask{'command'} = $_;
		slurmexec(\%ptask);
	}
}
close IPDF;
unless ($debug) {
	my %warn = ('job-name' => basename($ifile),         
		'filename' => $wdir.'/tasks_end.sh',         
		'mail-type' => 'END',         
		'output' => $wdir.'/tasks_end',
		'dependency' => 'singleton', 
	); 
	slurmexec(\%warn);
}
