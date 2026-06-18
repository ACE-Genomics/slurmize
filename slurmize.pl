#!/usr/bin/perl
use strict;
use warnings;
use SLURMACE qw(send2slurm);
use File::Basename qw(basename);
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
# Si no estas seguro, dejarlo en blanco
my $partition = '';
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

my %ptask = ( 'job_name' => basename($ifile),
	'cpus' => $cpus_per_proc,
	'mem_per_cpu' => $mem_per_cpu,
	'time' => $time, 
	'mail_type' => 'FAIL,TIME_LIMIT,STAGE_OUT',
	'partition' => $partition,
	'debug' => $debug,	
);

while (<IPDF>) {
	unless (/^#.*/ or /^\s*$/){
		$count++;
		my $ofile = sprintf ("%s_%04d", 'sorder', $count);
		$ptask{'filename'} = $wdir.'/'.$ofile.'.sh';
		$ptask{'output'} = $wdir.'/'.basename($ifile).'.out'; 
		$ptask{'command'} = $_;
		send2slurm(\%ptask);
	}
}
close IPDF;
unless ($debug) {
	my %warn = ('job_name' => basename($ifile),         
		'filename' => $wdir.'/tasks_end.sh',         
		'mailtype' => 'END',         
		'output' => $wdir.'/tasks_end',
		'dependency' => 'singleton', 
	); 
	send2slurm(\%warn);
}
