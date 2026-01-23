# Day 1 - Section 1 - Nextflow run introduction

Assuming you followed our setup instructions, you should have prepared a working space for the training (let's say `/group/mygroup/myuser/nextflow_training/`) and cloned the training materials repository there.
Your working space should then contain a folder named `nextflow-zero2hero` with all the training materials.

The following instructions assume you are in your working space folder.

## Before you start

1. Ensure you are in your working space folder:

```bash
cd /group/mygroup/myuser/nextflow_training/
```

2. Ensure you have the training materials repository cloned in a dedicated folder `nextflow-zero2hero` in your working space. Othrwise, if you don't have it yet, you can clone it by running:

```bash
git clone https://github.com/Nextstrain/nextflow-zero2hero.git
```

1. Start an interactive session on a compute node with sufficient resources:

```bash
srun --wait=0 --pty -p cpu-interactive -c 1 --mem 4G -J nxf_training /bin/bash
```

4. Load the Nextflow modules:

```bash
module load nextflow/25.04.3
```

## Core concepts

- In its simplest form a nextflow pipeline is just a single script file with `.nf` extension, containing the workflow definition and operational logic.
- At the core of Nextflow usage is the `nextflow run` command, which allows you to execute a Nextflow pipeline by specifying the path to the script file or to a directory containing a `main.nf` file.
- Often, the pipeline script is complemented by a configuration file named `nextflow.config`, which allows you to set parameters and options for the pipeline execution. When this file is present in the same directory as the pipeline script, it is automatically loaded by Nextflow during execution.
- You should execute each pipeline from a dedicated working directory, where Nextflow will create dedicated files, your results and various logs. You can repeat / resume the same pipeline in the same working directory, but **it's not recommended to run different pipelines from the same working directory**.

## 1. Run your first pipeline

It's general good practice to create a dedicated working directory for each pipeline you execute, so that the parameters, logs and outputs are organized and do not interfere with each other.

In general, we suggest to create a dedicated folder for each practical exercise. So assuming you configured a working folder for this course in `/group/mygroup/myuser/nextflow_training/` you can create a dedicate `practicals_outputs` folder in there and then create a for each specific practical exercise as we progress. 

For example:

```bash
# Create the dedicated folder for practicals outputs and navigate to it
mkdir -p practicals_outputs/day1/1-nextflow_run_introduction
cd practicals_outputs/day1/1-nextflow_run_introduction

# Run the example workflow
nextflow run nextflow-zero2hero/practicals/day1/1-nextflow_run_introduction/code_example_1/hello-nextflow.nf 
```

When a file named `main.nf` is present in a directory, you can run Nextflow by specifying only the directory.
Try making a copy of the `code_example_1` folder and renaming `hello-nextflow.nf` to `main.nf`.

You can do so by running:

```bash
cp -r nextflow-zero2hero/practicals/day1/1-nextflow_run_introduction/code_example_1 nextflow-zero2hero/practicals/day1/1-nextflow_run_introduction/code_example_1_main_nf
mv nextflow-zero2hero/practicals/day1/1-nextflow_run_introduction/code_example_1_main_nf/hello-nextflow.nf nextflow-zero2hero/practicals/day1/1-nextflow_run_introduction/code_example_1_main_nf/main.nf
```

Then you can run:

```bash
nextflow run nextflow-zero2hero/practicals/day1/1-nextflow_run_introduction/code_example_1_main_nf
```

## 2. Understanding the outputs

### The main log

```bash
 N E X T F L O W   ~  version 25.04.3

Launching `nextflow-zero2hero/practicals/day1/1-nextflow_run_introduction/code_example_1/hello-nextflow.nf` [ridiculous_spence] DSL2 - revision: a6973a2a05

executor >  local (1)
[d7/d2432a] sayHello [100%] 1 of 1 ✔
```

You will see a log similar to the one above printed in your terminal. Note

- `[ridiculous_spence]` which defined the run unique name. This is a unique random identifier of the current execution generate by Nextflow. You can use it to refer to this specific run in future commands.
- `[d7/d2432a] sayHello [100%] 1 of 1 ✔` which identifies the task(s) that is being executed. In this case, the task is named `sayHello`.

### The work folder

When you run a workflow, Nextflow creates a distinct 'task directory' for every single invocation of each process in the workflow (=every step in the pipeline).
For each one, it will stage the necessary inputs, execute the relevant instruction(s) and write outputs and log files within that one directory, which is named automatically using a hash in order to make it unique.

By default, all of these task directories will live under a directory called `work` within your current directory (where you're running the command).
Within the `work` folder, the task directories are organized in unique folders using hash strings. Specifically, they are organized in a two-level structure based on the hashing.

If you look at the log of the previous execution, you will see something like this:

```bash
[1c/e93a48] sayHello | 1 of 1 ✔
```

This lines identify the execution of a process names `sayHello`. See how the line starts with `[1c/e93a48]`. This means that the task directory for this execution is located under `work/1c/e93a48*`.
If you execute `ls work/1c/e93a48*`, you will see the full task directory path.

If you browse the contents of the task subdirectory in the VSCode file explorer, you'll see all the files right away. However, the log files are set to be invisible in the terminal, so if you want to use ls or tree to view them, you'll need to set the relevant option (`-a`) for displaying invisible files.

If you display the full content of the task directory, you will see something like this:

```bash
tree -a ./work/1c/e93a488bf225e531f3aa65367b74d2/
├── .command.begin
├── .command.err
├── .command.log
├── .command.out
├── .command.run
├── .command.sh
├── .exitcode
└── output.txt
```

#### Nextflow helper files

For all task executions, Nextflow creates the following helper and log files in the task directory:

- `.command.begin`: Sentinel file created as soon as the task is launched.
- `.command.err`: Error messages (stderr) emitted by the process call
- `.command.log`: Complete log output emitted by the process call
- `.command.out`: Regular output (stdout) by the process call
- `.command.run`: Full script run by Nextflow to execute the process call
- `.command.sh`: The command that was actually run by the process call
- `.exitcode`: The exit code resulting from the command

### The results folder

If your pipeline is configured to do so, it will create also one or more folders where relevant result files of the workflow are collected. In the following examples, this folder is named `results`.
Note that this can be configured differently in each pipeline or you can even do not create any results folder at all (you will see how this is controlled later in the training).

In our example the `results` folder will contain a single file named `output.txt`, which is the output of the pipeline execution.

```bash
results
└── output.txt
```

This file simply contain the message `Hello, Nextflow!`

### An important note

Nextflow creates a new task directory under the `work` folder, with a different hash string, for each task execution across runs. 
Hence, files in the work folder are never overwritten when you run the a pipeline from the same working folder multiple times.
On the other hand, the final result file `results/output.txt` is overwritten with the new output.

## 4. Change execution behavior using command line options

When using the `nextflow run` command, you can specify a series of options to customize the execution behavior. As general rule

- options starting with `--` are used to specify parameters defined in the pipeline script and define variables used in the execution of the various tasks
- options starting with `-` are used to specify Nextflow execution options, that will modify how nextflow itself runs. You can modify settings such as additional configuration files, work directory location, execution resumption, etc.

### Specify parameters using the command line

Here we use `--message` to specify a custom message to be printed by the pipeline. This will internally change the value of the `message` parameter.

```bash
nextflow run nextflow-zero2hero/practicals/day1/1-nextflow_run_introduction/code_example_1/hello-nextflow.nf --message 'Hello, from command line!'
```

Notice how Nextflow creates a new tasks directories under the `work` folder, with a different hash string.
On the other hand, the final result file `results/output.txt` is overwritten with the new output and it will now contain the message `Hello, from command line!`

### Specify custom parameters using a JSON/YAML file

We can obtain the same result by specifying a JSON or YAML file containing the parameters to be used in the execution. In this case we use the `-params-file` option to point to a JSON file containing the custom parameters.
Notice the single dash before `params-file` which tells you that this is a Nextflow execution option.

```bash
nextflow run nextflow-zero2hero/practicals/day1/1-nextflow_run_introduction/code_example_1/hello-nextflow.nf -params-file nextflow-zero2hero/practicals/day1/1-nextflow_run_introduction/code_example_1/custom_params.json
```

### Specify a custom work directory

By default, Nextflow stores the task execution folder in the `work` folder in the directory where you run the command. You can change this behavior by specifying a custom work directory using the `-work-dir` option.
Again, notice the single dash before `work-dir` which tells you that this is a Nextflow execution option.

```bash
nextflow run nextflow-zero2hero/practicals/day1/1-nextflow_run_introduction/code_example_1/hello-nextflow.nf -work-dir custom_work_dir
```

### Complement/override configuration using the command line

You can also specify a custom configuration file to complement or override the default pipeline configuration from `nextflow.config`. In this case we use the `-c` option to point to a custom configuration file.

```bash
nextflow run nextflow-zero2hero/practicals/day1/1-nextflow_run_introduction/code_example_1/hello-nextflow.nf -c nextflow-zero2hero/practicals/day1/1-nextflow_run_introduction/code_example_1/custom_config.config
```

## Useful additional nextflow commands

Besides the `nextflow run` command, Nextflow provides a series of additional commands to manage and monitor your workflow executions.

### Inspect previous runs

Using the `nextflow log` command you can inspect the history of your previous Nextflow runs executed from the current directory.

```bash
nextflow log
```

This will display a list of previous runs, including their unique run names, start and end times, status, and the command used to execute them.

```bash
TIMESTAMP          	DURATION	RUN NAME        	STATUS	REVISION ID	SESSION ID                          	COMMAND                       
2026-01-23 09:01:43	2.1s    	gigantic_hilbert	OK    	a6973a2a05 	caf25bf7-d8f2-4dbb-8b45-3e2d07e7a7d7	nextflow run hello-nextflow.nf
2026-01-23 09:01:50	1.5s    	jovial_miescher 	OK    	a6973a2a05 	b9e5e458-27a0-47e6-9f5c-964dcdc27b7e	nextflow run hello-nextflow.nf
```

Useful trick: Given a specific run name, you can use `nextflow log` also to get the exact execution folder of all the executed tasks in that run.

```bash
nextflow log silly_feynman -f name,workdir
```

This will return a list of all task names and their corresponding work directories like this:

```bash
sayHello	/project/nextflow_zero2hero/practicals/day1/1-nextflow_run_introduction/code_example_1/work/ad/03f92ac8338ebf141c413ed3bdff8e
```

### Clean a previous run working data

In case you want to clean intermediate files generate by tasks execution of a previous run, you can use the `nextflow clean` command followed by the run name.

First you can use `-n` to perform a dry-run and see which files would be deleted:

```bash
nextflow clean -n nasty_varahamihira
```

When you're sure, you can run the actual clean command to remove the files in the task directories of the correspionding run.

```bash
nextflow clean -f nasty_varahamihira
```

### Resume a previous run

In case one of the pipeline steps failed, it is possible to resume the execution from the point of failure using the `-resume` option with the `nextflow run` command.
In this case, Nextflow will reuse the existing task directories for the steps that were already successfully completed in the previous run, and it will only re-execute the failed or pending steps.

First try to execute the pipeline in `code_example_2`:

```bash
nextflow run nextflow-zero2hero/practicals/day1/1-nextflow_run_introduction/code_example_2/hello-nextflow.nf
```

You will see that one of the steps fails intentionally.

Now open the file `nextflow-zero2hero/practicals/day1/1-nextflow_run_introduction/code_example_2/hello-nextflow.nf` in a text editor and remove the this line `exit 1`.

Now try to resume the execution using the `-resume` option:

```bash
nextflow run nextflow-zero2hero/practicals/day1/1-nextflow_run_introduction/code_example_2/hello-nextflow.nf -resume
```

You will see a log like this:

```bash
executor >  local (1)
[1c/e93a48] process > sayHello  [100%] 1 of 1, cached: 1 ✔
[ac/989d24] process > saveHello [100%] 1 of 1 ✔
```

As you can see the results of the first step `sayHello` were reused from the previous execution (it is marked as `cached: 1`), while the second step `saveHello` was executed successfully this time.
