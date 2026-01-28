# Advanced configuration exercises

## Before you start

- An input example file is provided in `inputs/input_data.tsv`. This file contains paths to FASTQ files for two samples, each split into multiple parts.
- A simple Nextflow pipeline is provided in `workflow` directory. This pipeline reads the input TSV file, processes each FASTQ file part, and generates output files.
- An alternative version of this Nextflow pipeline is provided in `workflow_gpu` directory. This will be used in some exercises to demonstrate how to configure GPU resources.

Before start with the exercises, require an interactive session on the HPC with 4 threads and 12G of RAM and load the Nextflow and Singularity modules:

```bash
srun --pty -c 4 -p cpu-interactive --mem 12G -J nextflow_training /bin/bash
module load nextflow/25.04.3 singularityce/3.10.3
```

It can also be convenient to store the full path of the example pipeline in an environment variable, so that you don't have to type it every time. You can do this with the following command:

```bash
export PIPELINE_PATH=/my/work/folder/practicals/day3/1-advanced_config/workflow
export PIPELINE_GPU_PATH=/my/work/folder/practicals/day3/1-advanced_config/workflow_gpu
```

### How we will customise the configuration

For each exercise, 

1. create a new folder in your working space. 
2. in this folder you can customise the configuration by
	- creating a new `nextflow.config` file. Remember that if a file named `nextflow.config` is present in the same directory where you run Nextflow, it will be merged with any other configuration file present in the pipeline directory.
	- creating a new config file with a dedicate name (e.g. `my_config.config`) and passing it to Nextflow using the `-c` option.

### Inspect the example workflow and configuration

First, familiarise yourself with the example pipeline in the `workflow` directory. Notice how this is made by 3 modules: `bwa`, `samtools-merge` and `samtools-sort`, which are defined in separate files: `bwa.nf`, `samtools-merge.nf` and `samtools-sort.nf`. In each files you can notice we also defined some configuration settings to define the resource requirements for each process.

Before making any changes, run the following command to inspect the current configuration of the Nextflow pipeline. At the moment, the only configuration comes from the `nextflow.config` file located in the `workflow` directory.

```bash
nextflow config $PIPELINE_PATH
```

You should see output similar to the following:

```bash
params {
   input_file = ''
   reference_genome = ''
   outdir = 'results'
   publish_mode = 'copy'
}
```

### Inspecting configuration changes

During the exercises you are encourage to use the `nextflow config` command to inspect the resulting configuration before actually try to run the pipeline. 

If you decided to modify the configuration using a custom config file name (e.g. `my_config.config` instead of `nextflow.config`), remember to pass it to Nextflow using the `-c` option before the `config` command.

So, assuming you are in the folder you created for the exercise, where you created/modified your configuration file, you can run:

```bash
# In case you created nextflow.config in the current directory
nextflow config $PIPELINE_PATH
# In case you created a custom config file named my_custom_file.config
nextflow -c my_custom_file.config config $PIPELINE_PATH
```


## Exercise 1 - Activate singularity

Code to solve the exercise in: `practicals/day3/1-advanced_config/1-singularity`

The files `nextflow.config` and `singularity.config` in this folder provide a possible solution to this exercise. The content is the same in both files, as they represent two different ways to achieve the same goal (using `nextflow.config` or a custom config file named `singularity.config`).

### Setup

Make a new directory for this exercise and navigate into it:

```bash
mkdir my_work_dir/day3/1-advanced_config/1-singularity
cd my_work_dir/day3/1-advanced_config/1-singularity
```

### Goal

Prepare a config file to enable Singularity support for containerised execution. 

- To be sure we are not clogging our working directory with output files, change the cache directory to a subfolder in your scratch space, let's say `/scratch/$USER/nextflow_cache`.
- Additionally, add a Singularity run option to bind the `/localscratch` directory inside the container (required by our HPC setup).

### Execution

For this you will need to set relevant properties in the [`singularity` scope](reference_documentation.md#container--environment-management-scopes).

Basically, you have to create a new config file (e.g. `nextflow.config`) with the singularity block and configure it properly

```groovy
singularity {
	...
}
```

Once you have created your config file, run the `nextflow config` command to inspect the final configuration and verify that the Singularity settings are correctly applied. If you created a custom config file, remember to use the `-c` option:

```bash
# In case you created nextflow.config in the current directory
nextflow config practicals/day3/1-advanced_config/workflow

# In case you created a custom config file named my_custom_file.config
nextflow -c my_custom_file.config config practicals/day3/1-advanced_config/workflow
```

Verify that the pipeline is now able to run and containers are downloaded to the specified cache directory. You can run the pipeline with the following command:

```bash
# In case you created nextflow.config in the current directory
nextflow run practicals/day3/1-advanced_config/workflow 

# In case you created a custom config file named my_custom_file.config
nextflow run practicals/day3/1-advanced_config/workflow -c my_custom_file.config 
```

## Exercise 2 - Configure an executor

Code to solve the exercise in: `practicals/day3/1-advanced_config/2-executor`

### Setup

Make a new directory for this exercise and navigate into it:

```bash
mkdir my_work_dir/day3/1-advanced_config/2-executor
cd my_work_dir/day3/1-advanced_config/2-executor
```

**NB. From now on, we will build on top of the previous exercise, so make sure you have completed Exercise 1 and copied your config file from there into this new directory.**

For example, if you created a config file named `nextflow.config` in the previous exercise, copy it into this new directory:

```
cp my_work_dir/day3/1-advanced_config/1-singularity/nextflow.config .
```

### Goal

Modify your config file to set your processes to run using the SLURM executor and the cpuq queue, with a maximum of 3 concurrent jobs.

### Execution

For this you will need to set relevant properties in the [`executor` scope](reference_documentation.md#executor_scope) and [`process` scope](reference_documentation.md#process_configuration_scope).

Basically, you have to add new configuration blocks to your configuration file from the previous exercise (e.g. `nextflow.config`) and add the relevant settings:

- in which scope will you set the executor and the queue?
- in which scope will you set the maximum number of concurrent jobs to be submitted?

When you run the pipeline with the modified configuration, you will notice from the log that nextflow is now using SLURM to submit jobs to the specified queue. The logg will report `executor >  slurm (x)`. 

If you check your HPC queue using `squeue -u $USER`, you will see that nextflow is submitting jobs for yout and that only 3 jobs are queued at any one time, as per the configuration.

You can run the pipeline with the following command:

```bash
# In case you created nextflow.config in the current directory
nextflow run $PIPELINE_PATH 

# In case you created a custom config file named my_custom_file.config
nextflow run $PIPELINE_PATH -c my_custom_file.config 
```

## Exercise 3 - Basic process configuration

Code to solve the exercise in: `practicals/day3/1-advanced_config/3-process_config1`

### Setup

1. Before starting this exercise, please unload the singularity module using

```bash
module unload singularityce/3.10.3
```

Make sure that `which singularity` returns no output.

2. Make a new directory for this exercise and navigate into it:

```bash
mkdir my_work_dir/day3/1-advanced_config/3-process_config1
cd my_work_dir/day3/1-advanced_config/3-process_config1
```

For example, if you created a config file named `nextflow.config` in the previous exercise, copy it into this new directory:

```
cp my_work_dir/day3/1-advanced_config/2-executor/nextflow.config .
```

### Goal

Modify your config file to set resource usage for all processes in the main configuration.
We also want to ensure the singularityce/3.10.3 module is loaded before running any process.

### Execution

For this you will need to set relevant properties in the [`process` scope](reference_documentation.md#process_configuration_scope). Specifically, you will need to set [process resources parameters](reference_documentation.md#main-directives-to-control-resource-usage) and [configure the execution space]( reference_documentation.md#configure-the-execution-space)

Basically, you have to add new configuration settings in the `process` scope you already defined in your configuration file from the previous exercise (e.g. `nextflow.config`):

First, inspect the module files `bwa.nf`, `samtools-merge.nf` and `samtools-sort.nf` in the `workflow` directory to see the resource requirements for each process. If we want to define a single resource configuration that will work for all of them we have to take the maximum request and configure this in the `process` scope of our config file. 

- cpus = 4
- memory = 8 GB
- time = 2 h

Now you have to remove the resource requirements (`cpus`, `memory` and `time`) from each process definition in the module files, since they are now defined globally in the configuration file. **Make sure you are making changes to your local copy of the pipeline files, not the original ones in the `/project/nextflow_zero2hero/practicals` directory.**

If you run the pipeline with the modified configuration now, you will get an error! What's going on?

You can notice from the log that the execution failed because the `singularity` command is not available. This happens because singularity is not installed by default on the HPC nodes, and we need to load the singularity module before running any process.

How can you configure this in the configuration file?

Hint: `beforeScript` can likely help you here.

Once you added this additional setting to your configuration file, you can run the pipeline again. This time it should work fine. You can inspect one of the `.command.run` files in the work directory to verify that the singularity module is loaded before executing the actual command. 

If you load the tail of the file:

```bash
tail -n 29 work/<some_hash>/.command.run
```

You will notice the module load command has been added:

```bash
# beforeScript directive
module load singularityce/3.10.3
```

You can run the pipeline with the following command:

```bash
# In case you created nextflow.config in the current directory
nextflow run $PIPELINE_PATH 

# In case you created a custom config file named my_custom_file.config
nextflow run $PIPELINE_PATH -c my_custom_file.config 
```

## Exercise 4 - More on process configuration

Code to solve the exercise in: `practicals/day3/1-advanced_config/4-process_config2`

### Setup

Make a new directory for this exercise and navigate into it:

```bash
mkdir my_work_dir/day3/1-advanced_config/4-process_config2
cd my_work_dir/day3/1-advanced_config/4-process_config2
```

For example, if you created a config file named `nextflow.config` in the previous exercise, copy it into this new directory:

```
cp my_work_dir/day3/1-advanced_config/3-process_config1/nextflow.config .
```

### Goal

Modify the configuration in the `parabrick-haplotypecaller.nf` module to be able to run on GPU nodes in our HPC and use dedicated resources with 8 cpus and 32 GB of RAM.

**Priority concept:** The configuration defined within the process definition overrides the global configuration defined in the config file.

### Execution

For this you will need to set relevant properties directly in the process definition. Specifically, you will need to set relevant [process resources parameters](reference_documentation.md#main-directives-to-control-resource-usage) and [container parameters](reference_documentation.md##container--environment-directives)

To be able to use GPUs in our HPC, we need to modify the file `parabrick-haplotypecaller.nf` in `workflow_gpu` to 
- set the queue to `gpuq`
- request one GPU to the scheduler by passing `--gres=gpu:1` to the `sbatch` command
- enable GPU support in singularity by adding the `--nv` option to the `singularity exec` command

To solve this, remember you can fine tune configuration of your computational environment at the process level by using directives like `clusterOptions` and `containerOptions`.

Additionally, we need to configure the process to use more resources:
- 8 cpus
- 32 GB of RAM.

**Make sure you are making changes to your local copy of the pipeline files, not the original ones in the `/project/nextflow_zero2hero/practicals` directory.**

Once you modified and saved the module code, you can run the GPU pipeline. You can inspect one of the `.command.run` files in the work directory to verify that the `--gres=gpu:1` option has been added to the `sbatch` command and that we are now using the `gpuq` queue.

Note how the configuration defined in the process definition overrides the global configuration defined in the config file.

For example, if you load the head of the file:

```bash
head work/<some_hash>/.command.run
```

You will notice the `sbatch` command has been modified:

```bash
#SBATCH --gres=gpu:1
#SBATCH -p gpuq
```

You can run the pipeline with the following command:

```bash
# In case you created nextflow.config in the current directory
nextflow run $PIPELINE_PATH_GPU

# In case you created a custom config file named my_custom_file.config
nextflow run $PIPELINE_PATH_GPU -c my_custom_file.config 
```

## Exercise 5 - Dynamic resource allocation

Code to solve the exercise in: `practicals/day3/1-advanced_config/5-dynamic_resources`

### Setup

Make a new directory for this exercise and navigate into it:

```bash
mkdir my_work_dir/day3/1-advanced_config/5-dynamic_resources
cd my_work_dir/day3/1-advanced_config/5-dynamic_resources
```

For example, if you created a config file named `nextflow.config` in the previous exercise, copy it into this new directory.
```
cp my_work_dir/day3/1-advanced_config/4-process_config2/nextflow.config .
```

### Goal

Instead of setting the process resources statically, modify your configuration file to request `cpus`, `memory` and `time` dynamically based on the number of retry attempts. Use starting values

- cpus = 2
- memory = 4 GB
- time = 1 minute

**NB.** These values are intentionally low to trigger a failure and demonstrate the retry mechanism.

We want that when a process fails due to errors related to insufficient memory or time, or it is killed by the scheduler, it will be retried with increased resources for a maximum of 3 attempts.

### Execution

For this you will need to modify the `process` scope in your config file and replace the static definition of `cpus`, `memory` and `time` with a closure that return a dynamic value based on the number of retry attempts. Specifically, you will need to configure a [dynamic resource allocation](reference_documentation.md#dynamic_resource_allocation) based on the task attemp and ensure that your [error strategy](reference_documentation.md##error_strategy_directive) allows a process to be retried.

Suggestions:

- a value can be set dynamically using a closure like `{ ... }` that returns the desired value. 
- the `task.attempt` property can be used to get the current attempt number for a process (starting from 1)
- the `errorStrategy` directive can also be set dynamically using a closure that returns a valid mode (like `'retry'` or `'terminate'`) 
- the `task.exitStatus` property contains the exit code of the last executed command for a process.
- a list of error codes can be defined as `[ code1, code2, ... ]` to check if the last exit status is included in the list
- the `maxRetries` process directive control the maximum number of retry attempts for a process.

Once you modified and saved the module code, you can run the standard pipeline including this new configuration.

Note how the process BWA_MEM fails, but it is automatically retried with increased resources. The log notify you about this

```
[c3/cf932f] NOTE: Process `BWA_MEM (sample_1)` terminated with an error exit status (140) -- Execution is retried (1)
```

And at the end you can see that some tasks were retried:

```
[11/050994] BWA_MEM (sample_2)        [100%] 4 of 4, retries: 4 ✔
```

You can run the pipeline with the following command:

```bash
# In case you created nextflow.config in the current directory
nextflow run $PIPELINE_PATH

# In case you created a custom config file named my_custom_file.config
nextflow run $PIPELINE_PATH -c my_custom_file.config 
```

## Exercise 6 - Fine grained process settings

Code to solve the exercise in: `practicals/day3/1-advanced_config/6-fine_grained_process_config`

Specifically, updated versions of the modules are in: `practicals/day3/1-advanced_config/6-fine_grained_process_config/modified_modules`

### Setup

Make a new directory for this exercise and navigate into it:

```bash
mkdir my_work_dir/day3/1-advanced_config/6-fine_grained_process_config
cd my_work_dir/day3/1-advanced_config/6-fine_grained_process_config
```

For example, if you created a config file named `nextflow.config` in the previous exercise, copy it into this new directory.
```
cp my_work_dir/day3/1-advanced_config/5-dynamic_resources/nextflow.config .
```

### Goal

Instead of having the same resource settings for all processes, assign specific resources to each process by combining labels and name-based process configuration and use them to assign resources to each process as needed.

We want to define three labels:
- `process_low` for processes that require low resources (2 cpus, 4 GB memory, 1 hour time)
- `process_high` for processes that require high resources (8 cpus, 16 GB memory, 4 hours time)
- `process_high_memory` for processes that have special memory requirements with high memory (32 GB memory)

We want to keep this new configuration logic separate from the main configuration file.

**Priority concept:** The configuration defined using process labels and names overrides the global configuration defined in the config file and also the configuration defined directly in the process definition. Moreover, the name-based configuration has higher priority than the label-based configuration.

**Priority concept:** When multiple labels are assigned to a process, the corresponding settings are collapsed in the order the labels appear. Hence, the last label takes precedence in case of conflicting settings.

### Execution

For this you will need to create a new config file with a custom name (e.g. `process_labels.config`) and create a `process` scope in it where you will define the [label-based and name-based configuration settings](reference_documentation.md#fine-grained-process-configuration-using-labels-and-names). 

#### Part1

**NB.** For this part we will use the standard workflow in `practicals/day3/1-advanced_config/workflow`.

Create a new configuration file (let's say `process_labels.config`) that contains a `process` scope where you will define the three labels with the relevant resource settings.

- `process_low` for processes that require low resources (2 cpus, 4 GB memory, 5 minutes time)
- `process_high` for processes that require high resources (4 cpus, 8 GB memory, 30 minutes time)
- `process_high_memory` for processes that have special memory requirements with high memory (32 GB memory)

Suggestion: a label-based configuration can be defined using the `withLabel` selector inside the `process` scope.

Now modify your main configuration file (e.g. `nextflow.config`) to include the content of this new file by using the `includeConfig` directive in the root scope:

```groovy
includeConfig 'process_labels.config'
```

Finally, modify the modules and assign the appropriate labels to each process in the module files (`bwa.nf`, `samtools-merge.nf` and `samtools-sort.nf`) based on their resource requirements. In the end we want to have:
- `BWA_MEM` process should require 4 cpus, 32 GB memory and 30 minutes time
- `SAMTOOLS_MERGE` and `SAMTOOLS_SORT` processes should require 2 cpus, 4 GB memory and 5 minutes time

Suggestion: multiple labels can be assigned to a process repeating the `label` directive in the process definition and the resulting settings will be collapsed in the order the labels appear.

Once you modified and saved the module code, you can run the standard pipeline including this new configuration. You can inspect the `.command.run` files in the work directory to verify that the resource settings are correctly applied for each process based on the assigned labels.

You can run the pipeline with the following command:

```bash
# In case you created nextflow.config in the current directory
nextflow run $PIPELINE_PATH

# In case you created a custom config file named my_custom_file.config
nextflow run $PIPELINE_PATH -c my_custom_file.config 
```

#### Part2

**NB.** For this part we will use the GPU workflow in `practicals/day3/1-advanced_config/workflow_gpu`.

Now we have a new process named `HAPLOTYPECALLER_GPU` in the `parabrick-haplotypecaller.nf` module that requires special resource settings to enable GPU support. As we saw previously we need

- set the queue to `gpuq`
- request one GPU to the scheduler by passing `--gres=gpu:1` to the `sbatch` command
- enable GPU support in singularity by adding the `--nv` option to the `singularity exec` command

In addition, we want this process to use 8 cpus and 32 GB of RAM, with 30 minutes time.

First, consider which labels we should combine to configure resources in a way similar to the desired one, and specifically 32 GB of RAM and 30 minutes time. You likely want to combine the `process_high` and `process_high_memory` labels.

Modify and save the module file `parabrick-haplotypecaller.nf` in `workflow_gpu` to assign the appropriate labels to the `HAPLOTYPECALLER_GPU` process

Now how can we edit our additional configuration file (`process_labels.config`) to further customise settings specifically for the `HAPLOTYPECALLER_GPU` process to include GPU specific configuration and set 8 cpus? 

Basically we want a way to assign the following properties specifically to this process directly from our configuration file:

```
cpus = 8
queue = 'gpuq'
clusterOptions = '--gres=gpu:1'
containerOptions = '--nv'
```

Suggestion: you can define name-based configuration using the `withName` selector inside the `process` scope. Keep in mind that name-based configuration has higher priority than label-based configuration when there are conflicting settings.

Once you modified and saved the module code and your configuration file, you can run the gpu pipeline including this new configuration. You can inspect the `.command.run` files in the work directory to verify that the resource settings are correctly applied for each process based on the assigned labels.

You can run the pipeline with the following command:

```bash
# In case you created nextflow.config in the current directory
nextflow run $PIPELINE_PATH_GPU

# In case you created a custom config file named my_custom_file.config
nextflow run $PIPELINE_PATH_GPU -c my_custom_file.config 
```

## Exercise 7 - Profiles

Code to solve the exercise in: `practicals/day3/1-advanced_config/7-profiles`

### Setup

For this exercise please require an interactive session with 8 cpus and 32 GB of memeory

```bash
srun --pty -c 8 -p cpu-interactive --mem 32G -J nextflow_training /bin/bash
module load nextflow/25.04.3
```

Make a new directory for this exercise and navigate into it:

```bash
mkdir my_work_dir/day3/1-advanced_config/7-profiles
cd my_work_dir/day3/1-advanced_config/7-profiles
```

Copy all configuration files made in the previous exercise. We will likely have a `nextflow.config` file and a `process_labels.config` file. Copy them into this new directory.

```
cp my_work_dir/day3/1-advanced_config/6-fine_grained_process_config/nextflow.config .
cp my_work_dir/day3/1-advanced_config/6-fine_grained_process_config/process_labels.config .
```

**NB.** For this part we will use the gpu workflow in `practicals/day3/1-advanced_config/workflow_gpu`, with all the modifications you made so far.

### Goal

Create two profiles named `local` and `slurm` to quickly switch between local execution and HPC execution. Each profile will contain all the settings for `executor` and `process` scope needed for each environment. 

We also want to create a `singularity` profile to quickly enable singularity support when needed. This profiles will contain all the settings for the `singularity` scope needed to enable singularity support.

**Priority concept:** The configuration defined using profiles overrides the global configuration defined in the config file for the same scope when there are conflicting settings.

### Execution

For this you will need to restructure your main configuration file to create a [profile scope](reference_documentation.md#profiles-and-institutional-profiles) where we define multiple profiles to separate the configuration settings we added so far in multiple named profiles that will allows to quickly switch between computational environments (local or HPC) and activate Singularity support. 

Modify your main configuration file (e.g. `nextflow.config`) to create a `profiles` scope where you will define the following profile blocks:
- `local` profile for local execution that contains all the relevant settings for `executor` and `process` scope needed for local execution
- `slurm` profile for HPC execution that contains all the relevant settings for `executor` and `process` scope needed for HPC execution
- `singularity` profile to enable singularity support that contains all the relevant settings for the `singularity` scope needed to enable singularity support

```groovy
profiles {
   local {
      ...
   }
   slurm {
      ...
   }
   singularity {  
      ...
   }
}
```

- `local` profile should
   - set a maximum limit to the executor of 4 cpus and 16 GB of RAM
   - set the process executor to `local` 
   - set the process errorStrategy to `finish`
   - set static resource allocation for all processes to 2 cpus, 8 GB memory and 5 minutes time for all processes
   - ensure the `singularityce/3.10.3` module is loaded before running code in all processes
   - include special configuration for the `HAPLOTYPECALLER_GPU` process to enable GPU support as done in the previous exercise
- `singularity` profile should:
   - enable singularity support
   - set the singularity cache directory to `/project/nextflow_zero2hero/containers`
- `slurm` profile should allow us to submit job to the SLURM scheduler:
   - set a maximum limit to the executor queue size of 3
   - set the process executor to `slurm` and the queue to `cpuq`
   - set the resource limits of the system to 32 cpus, 550 GB memory and 30 days time
   - ensure the `singularityce/3.10.3` module is loaded before running code in all processes
   - set dynamic resource allocation for all processes based on the number of retry attempts as done in the previous exercise
   - set the process `errorStrategy` to retry tasks that fail due to OOM or preemption for a maximum of 3 retries
   - include special configuration for the `HAPLOTYPECALLER_GPU` process to enable GPU support as done in the previous exercise
   - add a Singularity run option to bind the `/localscratch` directory inside the container
   - add a Singularity run option to activate the `--cleanenv` flag


Suggestions: Remember that inside each profile block, you can define all the setting and scopes you usually use in the configuration, using the same syntax.

Once you modified and saved the configuration file, you can run the standard pipeline including this new configuration. You can now use the profile switches to decide if the processes will be executed on your local system or submitted to the HPC scheduler. 

You can run the pipeline with the following command:

```bash
# In case you created nextflow.config in the current directory
# For local execution
nextflow run $PIPELINE_PATH -profile local

# For HPC execution with SLURM
nextflow run $PIPELINE_PATH -profile slurm,singularity
```

Inspect the pipeline log and the `.command.run` files in the work directory to verify that the resource settings are correctly applied for each process based on the selected profile and the processes are executed either locally or on the HPC scheduler.

## Exercise 8 - Institutional profiles

Code to solve the exercise in: `practicals/day3/1-advanced_config/8-institutional_profiles`

### Setup

For this exercise please require an interactive session with 8 cpus and 32 GB of memeory

```bash
srun --pty -c 8 -p cpu-interactive --mem 32G -J nextflow_training /bin/bash
module load nextflow/25.04.3
```

Make a new directory for this exercise and navigate into it:

```bash
mkdir my_work_dir/day3/1-advanced_config/8-institutional_profiles
cd my_work_dir/day3/1-advanced_config/8-institutional_profiles
```

Copy all configuration files made in the previous exercise. We will likely have a `nextflow.config` file and a `process_labels.config` file. Copy them into this new directory.

```
cp my_work_dir/day3/1-advanced_config/7-profiles/nextflow.config .
cp my_work_dir/day3/1-advanced_config/7-profiles/process_labels.config .
```

**NB.** For this part we will use the gpu workflow in `practicals/day3/1-advanced_config/workflow`, with all the modifications you made so far.

### Goal

Incorporate the code necessary to access institutional profiles from nf-core and use this for the Human Technopole HPC.

### Execution

For this you will need to add some specific blocks to your configuration file to enable access to the [nf-core institutional profiles](reference_documentation.md#use-nf-core-institutional-profiles) which provide pre-defined configuration for various HPC systems around the world, including the Human Technopole HPC.

Modify your main configuration file (e.g. `nextflow.config`) to include the necessary settings to access nf-core institutional profiles.

```groovy
params {
    // nf-core profiles config options
    custom_config_version      = 'master'
    custom_config_base         = "https://raw.githubusercontent.com/nf-core/configs/${params.custom_config_version}"
    hostnames                  = [:]
    config_profile_description = null
    config_profile_contact     = null
    config_profile_url         = null
    config_profile_name        = null
}

// Load nf-core custom profiles from different Institutions
includeConfig (
    params.custom_config_base 
        ? "${params.custom_config_base}/nfcore_custom.config" 
        : '/dev/null'
)
```

Once you modified and saved the configuration file, you can run the standard pipeline including this new configuration. You can now use the profile switch to activate the Human Technopole HPC institutional profile named `humantechnopole` which will automatically set all the relevant configuration for this HPC system scheduler.

You can run the pipeline with the following command:

```bash
# In case you created nextflow.config in the current directory
# For HPC execution with SLURM using the institutional profile
nextflow run $PIPELINE_PATH -profile humantechnopole,singularity
```