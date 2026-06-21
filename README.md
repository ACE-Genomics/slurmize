# slurmize.pl

This is a very simple perl script that try to expose a very simple way to launch jobs into a SLURM cluster. It uses a perl module (slurmExec.pm) so we also provide a shell script to download and install it into your system. However if you can download and put all togheter, the script should just works.

## Install
- Download and run the *install\_slurmExec.sh* script and put the slurmize.pl script wherever you need it an run it
- Or, download the full repository and add to your bin path
- enjoy

## Usage

This script just read a simple plain text file that contains the orders that you want to parallelize inthe cluster. Let's say that you want to run Freesurfer recon-all procedure over 15 subjects. Then you write a file like this,

	recon-all -autorecon-all -subjid subject01
	recon-all -autorecon-all -subjid subject02
	...
	...
	...
	recon-all -autorecon-all -subjid subject15

and save it as *recon_subject.txt*. Now you just simple do,

	./slurmize.pl recon_subject.txt

and the script automagicallly make a directory named _slurm_, creates a separate sbatch script for each subject and launch it into the schedule manager and creates a warning script that send an email to warn you when the execution of all subjects is over. Output for each separate job it is stored in the _slurm_ directory also, so in case something goes wrong, you can check the output by the job id.

### Customize to your needs

The script should run in any SLURM cluster but maybe you want to adjust some behaviour like the partition, the execution time or something similar. Notice that you can edit some default variables at the beginning of the script that can change the parallelization queue. 

However this cover only a few posibilities. For a depper customization you should see the [slurmExec documentation](https://github.com/ACE-Genomics/tool-slurmize/blob/main/slurmExec.md) and edit the definition of the *%ptask* hash inside the script. Notice that you can add any option valid for your sbatch script and it will be simply written to the running script. It should be easy if the documented syntax is followed. By example, if you want to add an email address different from the local user email you can add something like,

```
	'mail-user' => 'another_email@myserver.com',
```

at the end of the definition of the parallelization hash as,

```
my %ptask = ( 'job-name' => basename($ifile), 
	'cpus-per-tasks' => $cpus_per_proc, 
	'mem-per-cpu' => $mem_per_cpu, 
	'time' => $time,  
	'mail-type' => 'FAIL,TIME_LIMIT,STAGE_OUT', 
	'partition' => $partition, 
	'debug' => $debug,
	'mail-user' => 'another_email@myserver.com', 
);

``` 

### Debugging your runs

Sometimes things go wrong when you generate the list of jobs to send into the cluster. So, to provide a way to check if everything it is OK before you run your jobs, we added the *-g* option. If you run,

	./slurmize.pl -g recon_subject.txt 

the script generates all the structure inside the *slurm* directory but runs nothing. This way you can review what is going to be executed into your nodes.
