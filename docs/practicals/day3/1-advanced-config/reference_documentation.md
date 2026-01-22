# Advanced configuration

## Where configuration comes from?

1. `nextflow.config` file in the project directory (where `main.nf` is located) is always loaded by Nextflow when running a pipeline.
2. `nextflow.config` file in the current working directory (where you launch the `nextflow run` command) is also loaded if present. This allows you to have project-specific configuration when running the same pipeline from different locations.
3. additional configuration files can be included specifically using the `-c` argument of `includeConfig` command.

**IMPORTANT LOGIC**:

Nextflow merge your configuration following the above order strictly, hence any conflicting setting is overwritten following the above priority.

When the same configuration setting is defined in multiple places HAVING THE SAME PRIORITY (see the label example later), Nextflow load them in order, hence the last definition wins and overwrites the previous ones.

## The basic principles

A Nextflow configuration file is composed of different sections called scopes. Each scope controls a specific aspect of the pipeline execution, for example defining parameters, process execution settings, container options, etc.

When defining values for your settings, you can include environmental variables using the `${VAR_NAME}` or `${env('VAR_NAME')}` syntax. Note that you need to specify the value using double quotes `"` for the variable interpolation to work.

You can define configuration settings within a scope using either dot notation (`scope.property = value`) or curly braces notation (`scope { property = value }`). The following example shows both styles:

```groovy
// Pipeline parameters
params {
    input = 'data/*.fastq'
    outdir = 'results'
}

// Process configuration using curly braces notation
process {
    executor = 'slurm'
    cpus = 4
    memory = '8.GB'
    
    withLabel: big_mem {
        memory = '64.GB'
    }
    
    withName: 'ALIGN' {
        cpus = 16
    }
}

// Container configuration using dot notation
singularity.enabled = true
singularity.runOptions = '--cleanenv'
// We double quotes for env var interpolation
singularity.cacheDir = "/scratch/${USER}/singularity_cache" 
// This works as well: singularity.cacheDir = "/scratch/${env('USER')}/singularity_cache"

// Profiles, more about this later
profiles {
    standard {
        process.executor = 'local'
    }
    cluster {
        process.executor = 'slurm'
        process.queue = 'batch'
    }
}
```

### Inspect the resolved configuration

You can inspect the final resolved configuration used by Nextflow (after applying all the `includeConfig` statements) by using the `config` command. The `-output` option allows you to specify the output format (default is grouped by scope). Unfortunately, the `-c` option is not supported with the `config` command.

```bash
nextflow config my/pipeline/main.nf
nextflow config my/pipeline/main.nf -output flat
nextflow config my/pipeline/main.nf -output json
```

### Make configuration modular

Additional configuration files can be included in any point using the `includeConfig` command. Imagine this as a copy-paste of the included file at that point in the configuration.

Example 1: Include at the top level

```
includeConfig 'root_config.config'
```

Example 2: Include inside a profile

The content of `cluster_config.config` will only be applied when the `-profile cluster` option is used.

```
profiles {
    cluster {
        includeConfig 'cluster_config.config'
   }
}
```

**Important note**: Relative paths in `includeConfig` are resolved against the location of the including file (i.e., the config file where the `includeConfig` statement is written), **NOT** from the project directory.

You can also import an external configuration file at run time using the `-c` command line option:

```
nextflow run my_pipeline -c custom_config.config
```

In this case the content of `custom_config.config` will be applied with higher priority and overwrite equivalent settings from your configuration files if present. 

This can be useful when you want to quickly complement settings from an existing configuration without modifying the original files, for example to add a new profile specific for your environment.

## Main configuration scopes

Scopes in bold will be covered in more detail later.

### 🔧 Core Settings

| Scope          | Purpose                                           |
| -------------- | ------------------------------------------------- |
| **`params`**   | Pipeline parameters (inputs, options)             |
| `env`          | Environment variables for task execution          |
| **`process`**  | Process execution directives (cpus, memory, etc.) |
| **`executor`** | Executor behavior (local, cluster, cloud)         |
| **`workDir`**  | Working directory path (default: ./work)          |

### 📦 Container Technologies

| Scope             | Purpose                          |
| ----------------- | -------------------------------- |
| **`docker`**      | Docker container execution       |
| **`singularity`** | Singularity/Apptainer containers |
| `podman`          | Podman container execution       |
| `charliecloud`    | Charliecloud containers          |
| `sarus`           | Sarus containers                 |
| `shifter`         | Shifter containers               |

### 🧬 Software Management

| Scope       | Purpose                             |
| ----------- | ----------------------------------- |
| **`conda`** | Conda environment configuration     |
| `spack`     | Spack package manager               |
| `wave`      | Wave container provisioning         |
| `fusion`    | Fusion file system (fast cloud I/O) |

### ☁️ Cloud Platforms

| Scope    | Purpose                                 |
| -------- | --------------------------------------- |
| `aws`    | AWS-specific settings (Batch, S3, etc.) |
| `azure`  | Azure configuration                     |
| `google` | Google Cloud settings (Batch, Storage)  |
| `k8s`    | Kubernetes cluster deployment           |

### 📊 Reports & Monitoring

| Scope              | Purpose                     |
| ------------------ | --------------------------- |
| `report`           | HTML execution report       |
| `timeline`         | Timeline visualization      |
| `trace`            | Task execution trace file   |
| `dag`              | Workflow DAG diagram        |
| `tower` / `seqera` | Seqera Platform integration |
| `notification`     | Email notifications         |

### 📝 Metadata & Workflow

| Scope           | Purpose                                   |
| --------------- | ----------------------------------------- |
| **`manifest`**  | Pipeline metadata (name, version, author) |
| `workflow`      | Workflow-level settings                   |
| `profiles`      | Named configuration profiles              |
| `includeConfig` | Include other config files                |

### ⚙️ Advanced

| Scope      | Purpose                                     |
| ---------- | ------------------------------------------- |
| `nextflow` | Nextflow runtime behavior & retry policies  |
| `mail`     | SMTP server configuration for notifications |
| `plugins`  | Plugin configuration                        |
| `secrets`  | Secure credential management                |

## Use variables in configuration 

| Variable | Type | Description |
| -------- | ---- | ----------- |
| `projectDir` | Path | Directory where the running nf script (usually `main.nf`) is located |
| `launchDir` | Path | Directory where the workflow was launched (current working directory) |
| `env('VAR_NAME')` | Function | Get environment variable value from Nextflow launch environment |

When using environmental variables in the configuration file, it is recommended to use the `env('VAR_NAME')`, but you can also include them directly using the `${}` syntax.

```
// Assuming your main.nf file is located at /my/workflow/dir
// And you launch the nextflow run command from /my/current/dir
params.data_dir = "${projectDir}/data" // sets params.data_dir to /my/workflow/dir/data
params.result_dir = "${launchDir}/results" // sets params.result_dir to /my/current/dir/results

// ✅ All of these work to set a parameter to the user's home directory using the HOME environment variable
params.home1 = "$HOME"
params.home2 = env('HOME')
```

## Container & environment management scopes

In general, you can activate support for a specific environmen§t/container technology by setting its `enabled` flag to `true` in the configuration file.

### Useful points to keep in mind

- Singularity and conda directives have `cacheDir` settings to specify where images/environments are stored. If this is not set, they default to the pipeline work directory. It's useful to set this to a shared location on clusters to avoid re-downloading/re-creating them for each run.
- Container based execution (singularity or docker) can be customised using the `runOptions` and `engineOptions` settings to pass extra command line options to the container engine.
- Conda based execution can be customised using the `createOptions` setting to pass extra command line options to the `conda/mamba create` command.
- If mamba or micromamba is installed on the system, conda environments can be created faster by enabling the respective `useMamba` or `useMicromamba` flags.

###  Singularity scope

| Setting         | Description                                                                                                             |
| --------------- | ----------------------------------------------------------------------------------------------------------------------- |
| `enabled`       | Execute tasks with Apptainer containers (default: `false`)                                                              |
| `autoMounts`    | Automatically mount host paths in the executed container (default: `true`)                                              |
| `engineOptions` | Additional options supported by the Apptainer engine (i.e., `apptainer [OPTIONS]`)                                      |
| `runOptions`    | Extra command line options supported by `apptainer exec`                                                                |
| `cacheDir`      | Directory where remote Apptainer images are stored. Must be a shared folder accessible to all compute nodes on clusters |
| `libraryDir`    | Directory where remote Apptainer images are retrieved. Must be shared on clusters                                       |
| `envWhitelist`  | Comma-separated list of environment variable names to include in the container environment                              |

### Docker scope

| Setting         | Description                                                           |
| --------------- | --------------------------------------------------------------------- |
| `enabled`       | Enable Docker execution (default: `false`)                            |
| `engineOptions` | Additional Docker engine options                                      |
| `runOptions`    | Extra command line options for `docker run` command                   |
| `envWhitelist`  | Comma-separated list of environment variables to include in container |

### Conda scope

| Setting         | Description                                                                                                           |
| --------------- | --------------------------------------------------------------------------------------------------------------------- |
| `enabled`       | Execute tasks with Conda environments (default: `false`).                                                             |
| `cacheDir`      | Path where Conda environments are stored. Should be accessible from all compute nodes when using a shared file system |
| `channels`      | List of Conda channels for resolving Conda packages. Channel priority decreases from left to right                    |
| `createOptions` | Extra command line options for the `conda create` command                                                             |
| `useMamba`      | Use Mamba instead of conda to create Conda environments (default: `false`)                                            |
| `useMicromamba` | Use Micromamba instead of conda to create Conda environments (default: `false`)                                       |

## Executor scope and executor control

### 1. executor Scope (Root-level configuration)

- Purpose: Controls the executor behavior and sets system-level limits for resource management.
- Use case: Define what the executor itself can use (e.g., total available resources on the system).

Key Settings:

```
executor {
    cpus = 16                   // MAX CPUs available to the executor (system limit)
    memory = '64.GB'            // MAX memory available to the executor (system limit)
    queueSize = 100             // Max number of parallel tasks
    pollInterval = '5s'         // How often to check job status
    perCpuMemAllocation = true  // SLURM-specific: use --mem-per-cpu
    account = 'my-project'      // Cloud/HPC account for billing
}
```

**Important:**

`executor.cpus` and `executor.memory` are upper bounds for the `local` executor only.
They tell Nextflow: "Don't use more than X CPUs/memory total across all running tasks".

They are **NOT** applicable to cluster/cloud executors (SLURM, AWS Batch, etc.) - those use process directives

### 2. process Directives (Task-level configuration)

Purpose: Define the executor to use and the resource requests for individual tasks/processes - what each job submission asks for.

Use case: Specify how much each process needs when it runs.

Key Settings:

```
process {
    executor = 'slurm'          // Which executor each process uses
    cpus = 4                    // Request 4 CPUs for each task
    memory = '8.GB'             // Request 8GB memory for each task
    queue = 'batch'             // Which queue/partition to submit to
    clusterOptions = '--account=myproject'  // Extra scheduler options
    time = '2h'                 // Max walltime for the job
}
```

**Important:**

These are per-task resource requests

- For cluster executors: translated to scheduler commands (e.g., `SLURM --cpus-per-task=4`)
- For local executor: determines parallelization (but bounded by `executor.cpus`)

### What Happens When Both Are Set?

Scenario: Local Executor

```
executor {
    cpus = 16        // System has 16 CPUs total
    memory = '64.GB' // System has 64GB total
}

process {
    cpus = 4         // Each task wants 4 CPUs
    memory = '8.GB'  // Each task wants 8GB
}
```

Result:

Nextflow will run at most 4 tasks in parallel (16 CPUs / 4 CPUs per task = 4)
Total memory usage won't exceed 64GB (8 tasks max: 64GB / 8GB = 8)
The more restrictive constraint (CPUs) wins → 4 parallel tasks

Scenario: Cluster Executor (SLURM, SGE, etc.)

```
executor {
    queueSize = 50      // Submit up to 50 jobs at once
    account = 'myproject'
}

process {
    executor = 'slurm'
    cpus = 8           // Each job requests 8 CPUs
    memory = '32.GB'   // Each job requests 32GB
    queue = 'batch'    // Submit to 'batch' partition
    clusterOptions = '--gres=gpu:1'  // Extra options
}
```
Result:

Nextflow will use the SLURM executor to submit jobs to the 'batch' queue, requesting 8 CPUs and 32GB memory per job. It will limit the number of simultaneously submitted jobs to 50. 

### Configure multiple executors

It is also possible to set different executor settings for different executors in the executor scope:

```
executor {
    // Defaults for all executors
    pollInterval = '5sec'
    
    // Local development
    $local {
        cpus = 8              // System has 8 CPUs
        memory = '32.GB'      // System has 32GB RAM
    }
    
    // SLURM cluster
    $slurm {
        queueSize = 200       // Can handle 200 jobs
        pollInterval = '30sec'  // Check less frequently
        submitRateLimit = '50/1min'  // Don't overwhelm scheduler
        queueStatInterval = '2min'
        perCpuMemAllocation = true  // This cluster uses --mem-per-cpu
    }
    
    // AWS Batch
    $awsbatch {
        queueSize = 1000      // Cloud can handle many jobs
        pollInterval = '10sec'
    }
}
```

## process configuration scope

### Main directives to control resource usage

Using specific directive you can have a fine-grained control of the resources allocated to that process. You can specifiy them directly in the process definition or in the configuration file.

Here is an example defining resource requirements directly in the process:

```groovy
process ALIGN_READS {
    cpus 8
    memory 32.GB
    time 4.h
    
    script:
    """
    bwa mem -t ${task.cpus} reference.fa reads.fq
    """
}

process GPU_ANALYSIS {
    accelerator 1, type: 'nvidia-tesla-v100'
    memory 16.GB
    
    script:
    """
    cuda_program --gpu
    """
}
```

Similarly you can define these directives in the `nextflow.config` configuration file under the `process` scope to apply them globally.

```groovy
process { // applies to all your processes
    cpus = 4
    memory = '8.GB'
    time = '2.h'
}
```

#### Core Resource Directives

| Directive | Description | Example | Units/Values | Notes |
| --------- | ----------- | ------- | ------------ | ----- |
| `cpus` | Number of (logical) CPUs required | `cpus 8` | Integer | Use `${task.cpus}` in script to reference allocated CPUs |
| `memory` | Amount of RAM required | `memory 16.GB` | B, KB, MB, GB, TB | Automatically converted to executor-specific format |
| `time` | Maximum execution time | `time 2.h` | s, m, h, d | Job killed if exceeded; use with retry strategies |
| `queue` | Cluster queue/partition name | `queue 'long'` | String | Executor-specific (e.g., SLURM partition) |
| `accelerator` | GPU/TPU requirements | `accelerator 1, type: 'nvidia-tesla-v100'` | Integer, type | For GPU-enabled processes |
| `maxForks` | Max parallel instances | `maxForks 4` | Integer | Limit concurrency (default: available CPUs - 1) |

#### Memory Unit Reference

| Unit | Size | Example |
| ---- | ---- | ------- |
| B    | Bytes | `memory 1000000.B` |
| KB   | Kilobytes (1000 B) | `memory 1000.KB` |
| MB   | Megabytes (1000 KB) | `memory 512.MB` |
| GB   | Gigabytes (1000 MB) | `memory 16.GB` |
| TB   | Terabytes (1000 GB) | `memory 2.TB` |

#### Time Unit Reference

| Unit | Duration | Example |
| ---- | -------- | ------- |
| s    | Seconds  | `time 300.s` |
| m    | Minutes  | `time 30.m` |
| h    | Hours    | `time 6.h` |
| d    | Days     | `time 2.d` |

### Directives to control the computational environment

#### Configure the execution space

| Directive | Description | Example | Use Case |
| --------- | ----------- | ------- | -------- |
| `clusterOptions` | Pass native scheduler options | `clusterOptions '--gres=gpu:2 --constraint=v100'` | Scheduler-specific flags (SLURM, PBS, SGE) |
| `beforeScript` | Execute command BEFORE main script | `beforeScript 'source /etc/profile.d/modules.sh'` | Initialize cluster environment, load modules, set env vars |
| `afterScript` | Execute command AFTER main script | `afterScript 'cleanup_temp_files.sh'` | Cleanup, logging, notifications |

#### Container & Environment Directives

| Directive | Description | Example | Use Case |
| --------- | ----------- | ------- | -------- |
| `container` | Container image to use | `container 'biocontainers/bwa:v0.7.17_cv1'` | Specify Docker/Singularity image |
| `containerOptions` | Pass custom flags to container engine | `containerOptions '--gpus all --shm-size 8g'` | Mount volumes, GPU access, memory settings |
| `conda` | Specify Conda packages/environment | `conda 'bwa=0.7.15 samtools=1.9'` | Manage software dependencies |
| `module` | Load environment modules | `module 'blast/2.2.27:java/11'` | Use HPC module system |

When using containers, these directives are combined with the `runOptions` and `engineOptions` settings in the respective container/environment scopes in the configuration file. This allows fine-grained control on the container execution.

The final resulting command will be like 

```bash
singularity [engineOptions] exec [runOptions] [containerOptions] image.sif command
docker [engineOptions] run [runOptions] [containerOptions] image command
```

### Dynamic resource allocation

Resources (and in general any directive) in a process can be defined dynamically using a closure (a piece of code within curly brackets `{}` that returns a compatible value). This allows you to set resources based on input file size, task attempt number, or any other logic.

The most common use case is to adapt computational resources of environment based on:
1. Retry attempts (`task.attempt`) - Scale resources when tasks fail and retry
2. Exit status (`task.exitStatus`) - Previous failure reason (more on point 1 and 2 later)
3. Input characteristics - Size, count, or type of input files
4. Task metadata - Sample characteristics, parameters, etc.

Few important notes:
- closures are always enclosed in curly braces `{}` and must return a value compatible with the directive type
- inside the closure you can access special `task` properties like `task.attempt` and any value from input channels
- you can not access variables defined in the `script` block.

For example, the following process uses static resource allocations

```nextflow
process ALIGNMENT {
    cpus 8              // Always uses 8 CPUs
    memory 16.GB        // Always uses 16 GB
    time 2.h            // Always uses 2 hours
    
    script:
    """
    bwa mem -t ${task.cpus} ref.fa reads.fq > aligned.sam
    """
}
```

Can be made dynamic to adapt based on the input size:

```nextflow
process ADAPTIVE_ANALYSIS {
    input:
    tuple val(sample_id), path(bam)
    
    // Scale memory by BAM file size
    memory { bam.size() < 1.GB ? 4.GB : bam.size() * 2 }
    
    // Scale CPUs by file size
    cpus { bam.size() < 500.MB ? 2 : 8 }
    
    // Scale time by file size
    time { bam.size() < 1.GB ? 1.h : 4.h }

    // Change queue based on file size
    queue { bam.size() > 10.GB ? 'long' : 'short' }
    
    script:
    """
    samtools sort -@ ${task.cpus} -m ${task.memory.toGiga() / task.cpus}G ${bam} > sorted.bam
    """
}
```

Similarly, you can define a logic based on some sample metadata present in your input channel

```nextflow
process VARIANT_CALLING {
    input:
    tuple val(meta), path(bam), path(bai)
    
    // Scale by sequencing depth
    memory {
        def depth = meta.coverage ?: 30
        if (depth < 10) {
            4.GB
        } else if (depth < 50) {
            16.GB
        } else {
            32.GB
        }
    }
    
    // Scale by genome size
    cpus {
        def genomeSize = meta.genome_size ?: 3000000000  // Default human
        genomeSize > 3e9 ? 16 : 8
    }
    
    script:
    """
    gatk HaplotypeCaller \\
        -I ${bam} \\
        -R ${params.reference} \\
        -O ${meta.sample_id}.vcf \\
        --native-pair-hmm-threads ${task.cpus}
    """
}
```

#### IMPORTANT - resourceLimits

The `resourceLimits` directive defines the maximum resources available in your system. This allows you to set upper bounds for resources so that your dynamic logic does not exceed the available resources.

You can define it in your process or globally in the `process` scope in your configuration file like in the example below.

```nextflow
process {
    resourceLimits = [
        cpus: 32,
        memory: 128.GB,
        time: 1.d
    ]
}
```

### Control error strategy and retry

Nextflow provides several directives to control how task failures are handled and how many times to retry failed tasks.

| Directive/Property | Type | Description | Example | Notes |
| ------------------ | ---- | ----------- | ------- | ----- |
| `task.exitStatus` | Task property | Contains the exit code from the task's script (read-only) | `task.exitStatus == 137` | Available in dynamic directives to check previous failure reason |
| `errorStrategy` | Process directive | Defines how to handle task failures | `errorStrategy 'retry'` | Options: `'terminate'`, `'finish'`, `'ignore'`, `'retry'` |
| `maxRetries` | Process directive | Maximum retries per task instance | `maxRetries 3` | Works with `errorStrategy 'retry'`; default is 0 |
| `maxErrors` | Process directive | Maximum errors across all tasks in a process | `maxErrors 5` | Pipeline continues until this limit is reached across all task instances |
| `validExitStatus` | Process directive | Define which exit codes are considered "success" | `validExitStatus 0,1,2` | By default only 0 is success; useful for tools with non-zero success codes |

#### Common Exit Codes

| Exit Code | Meaning | Source |
| --------- | ------- | ------ |
| 0         | Success | Task completed normally |
| 1         | General error | Script/command failure |
| 104      | General error | Indicating resource issues like Out Of Memory or timeout in cloud platforms |
| 127       | Command not found | Tool not in PATH |
| 130       | SIGINT (Ctrl+C) | User interrupt |
| 137       | SIGKILL (OOM) | Out of memory / killed by system |
| 139       | SIGSEGV | Segmentation fault |
| 140       | SIGTERM + 128 | Terminated by scheduler (often still OOM, or similar) |
| 141       | SIGPIPE | Broken pipe |
| 143       | SIGTERM | Walltime exceeded (HPC) |
| 255       | Exit status out of range | Unknown error |

#### errorStrategy directive

Defines the action to take when a task returns a non-zero exit status.

Available Strategies:

| Strategy | Behavior | Workflow Exit Code | Use Case |
| -------- | -------- | ------------------ | -------- |
| `'terminate'` (default) | Stop immediately, kill running jobs | Non-zero | Production - fail fast |
| `'finish'` | Wait for running tasks, then stop | Non-zero | Save partial results before failing |
| `'ignore'` | Continue pipeline, log error | Zero (or non-zero with `workflow.failOnIgnore=true`) | Optional analyses |
| `'retry'` | Re-submit task (up to `maxRetries`) | Depends on final outcome | Transient failures (OOM, network) |

⚠️ **Important**: With `errorStrategy 'ignore'`, the workflow exits with code 0 by default. To make the workflow fail, but continue execution you have to set in your configuration file `workflow.failOnIgnore = true`

The `errorStrategy` directive can be set dynamically based on the exit code using a closure:

```nextflow
process SMART_RETRY {
    // Retry on OOM/timeout, terminate on other errors
    errorStrategy { task.exitStatus in 137..143 ? 'retry' : 'terminate' }
    
    maxRetries 2
    
    script:
    """
    analysis_tool input.bam
    """
}
```

#### task.exitStatus property

This is a read-only property available within the process script that contains the exit code of the last executed command. This is particularly useful, in combination with `task.attempt` (which tracks the number of retries), to implement dynamic resource usage that will increase resources based on the exit code of the previous attempt.

Example

```nextflow
process ANALYSIS {
    // Retry only on specific exit codes (OOM, timeout)
    errorStrategy { task.exitStatus in 137..143 ? 'retry' : 'terminate' }
    
    // Increase memory when the processed fails due to OOM (exit code 137)
    memory { 
        if (task.exitStatus == 137) {
            4.GB * task.attempt // the 2nd attempt will have 8GB, 3rd 12GB, etc.
        } else {
            4.GB // default memory
        }
    }

    time { 
        if (task.exitStatus == 143) {
            2.h * task.attempt // increase time on timeout
        } else {
            2.h
        }
    }
    
    maxRetries 3 // maximum 3 retries
    
    script:
    """
    intensive_tool input.bam
    """
}
```

### Fine-grained process configuration using labels and names

You can define specific configuration settings for individual processes or groups of processes using the `withName` and `withLabel` selectors inside the `process` scope in your configuration file.

- Use `withName` to assign resources
- Use `withLabel` to assign resources to multiple process based on a shared label

**Important notes:**

- The configuration defined using process `withLabel` and `withName` overrides the global configuration defined in the config file (root process scope) and also the configuration defined directly in the process definition. 
- The `withName` configuration has higher priority than the `withLabel` configuration when there are conflicting settings.
- When multiple labels are assigned to a process, the corresponding settings are collapsed in the order the labels appear. Hence, the last label takes precedence in case of conflicting settings.

You can combine both `withName` and `withLabel` selectors in the same configuration file to have a fine-grained control of your process resource allocation.

1. Example referring to a process directly by name:

```groovy
// This is in your configuration file
process {
    withName: 'RSCRIPT' {
        cpus = 4
        memory = 16.GB
    }
    
    withName: 'ANOTHER_RSCRIPT' {
        cpus = 1
        memory = 8.GB
    }
}
```

Then in your process definition:

```groovy
process RSCRIPT {
    // This will use 4 cpus and 16 GB of memory
    
    script:
    """
    Rscript your_script.R
    """
}

process ANOTHER_RSCRIPT {
    // This will use 1 cpus and 8 GB of memory
    
    script:
    """    
    Rscript another_script.R
    """
}
```

2. Example using labels to group processes:

```groovy
// This is in your configuration file
process {
    withLabel: 'large_process' {
        memory = 64.GB
        cpus = 16
    }
}
```

Then in your process definition:

```groovy
// Both processes will use 64 GB and 16 CPUs as defined by the large_process label   
process LARGE_ANALYSIS {
    label 'large_process'  
    
    script:
    """
    big_memory_tool input.dat
    """
}

process ANOTHER_ANALYSIS {
    label 'large_process' 
    
    script:
    """
    big_memory_tool input.dat
    """
}
```

## Profiles (and institutional profiles)

Configuration profiles are named sets of configuration settings that allow you to define different execution environments for your Nextflow pipeline. They enable you to easily switch between configurations (e.g., local, cluster, cloud) without modifying your pipeline code. Essentially they are conditional configuration blocks that get applied when selected on the command-line via `-profile`. The settings inside a selected profile override non-profile settings at their respective level.

**Note:** As of Nextflow 25.02+, profiles are applied in the order defined in the config file (legacy behavior), but in future versions, they will be applied in command-line order.

### Basic Syntax

Profiles are defined within the profiles scope in `nextflow.config`:

```groovy
profiles {
    standard {
        process.executor = 'local'
    }
    
    cluster {
        process.executor = 'sge'
        process.queue = 'long'
        process.memory = '10GB'
    }
    
    cloud {
        process.executor = 'cirrus'
        process.container = 'cbcrg/imagex'
        docker.enabled = true
    }
}
```

### Main Use

Configuration profiles are mainly used to:

- Switch execution environments - Run the same pipeline on local machines, HPC clusters, or cloud platforms
- Customize resource allocations - Define different CPU, memory, and queue settings per environment
- Enable/disable features - Toggle containers, conda environments, or other execution options
- Maintain portability - Keep pipelines environment-agnostic while supporting multiple platforms

### Activate a profile

Profiles are activated at runtime using the `-profile` flag:

```bash
# Single profile
nextflow run pipeline.nf -profile cluster

# Multiple profiles (comma-separated)
nextflow run pipeline.nf -profile standard,docker
```

### Use nf-core institutional profiles

The nf-core community maintains a set of custom configuration profiles for different institutions and HPC environments. 
These are usually provided by your IT department and they can be imported in your pipeline to automatically set up the appropriate configuration for your HPC system.

To be able to use nf-core institutional profiles, you need to include the following code snippet in your `nextflow.config` file:

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

// Note this will not give you a warning if the selected institutional profile does not exist
// You may wnat to include a more complex logic to report a warning and exit when the file is not found
// includeConfig ({
//     def configPath = params.custom_config_base 
//         ? "${params.custom_config_base}/nfcore_custom.config" 
//         : '/dev/null'
    
//     // Check if file exists and warn if not
//     if (params.custom_config_base) {
//         def configFile = file(configPath)
//         if (!configFile.exists() && configPath != '/dev/null') {
//             System.err.println("WARNING: Could not find institutional config file: ${configPath}")
//             System.err.println("Please check that params.custom_config_base is set correctly.")
//             System.exit(1)
//         }
//     }
    
//     return configPath
// }())
```

Then you can import your institutional profile directly by name using the `-profile` command line option when launching your pipeline. For exame the `humantechnopole` profile for Human Technopole

```bash
nextflow run nf-core/my_pipeline -profile humantechnopole ...
```

You can consult the full list of available nf-core institutional profiles visiting the [nf-core configuration page](https://nf-co.re/configs/)

### HT institutional profile

This is the `humantechnopole` profile used at Human Technopole HPC cluster and available from the [nf-core/configs repository](https://nf-co.re/configs/humantechnopole/).

```
params {
    max_memory = 550.GB
    max_time   = 30.d
    max_cpus   = 32
}

process {
    resourceLimits = [
        cpus: 32,
        memory: 550.GB,
        time: 30.d
    ]
    executor = 'slurm'
    queue = 'cpuq'
    beforeScript = 'module load singularity'
    maxRetries = 5

    withLabel: gpu {
        resourceLimits = [
            cpus: 36,
            memory: 550.GB,
            time: 30.d
        ]
        queue = 'gpuq'
        containerOptions = '--nv'
        clusterOptions = { task.accelerator ? "--gres=gpu:${task.accelerator.request}" : '--gres=gpu:1' }
    }
}

executor {
    queueSize = 500
    pollInterval = '5 sec'
    submitRateLimit = '20 sec'
}

singularity {
    autoMounts = true
    runOptions = '--cleanenv --bind /localscratch'
}
```

## Configuration hierarchy

### Overall Configuration File Priority (lowest → highest):

1. `$HOME/.nextflow/config` (or `$NXF_HOME/config`)
2. `nextflow.config` in the project directory
3. `nextflow.config` in the launch directory
4. `-c <config-file>` command line option
5. Command line parameters (e.g., `--param value`)
   
### Process-Specific Settings Priority (lowest → highest):

When the same process directive is defined in multiple places the following order of precedence is applied:

1. Process scope (base settings) - No selector in nextflow.config:

```
process {
    cpus = 4  // Applied to ALL processes
}
```

2. Process definition directives - Inside the process itself:

```
process FOO {
    cpus 8  // Overrides base process scope
}
```

3. withLabel selectors - Matching process labels:

```
process {
    withLabel: big_mem {
        cpus = 16  // Overrides process directive
    }
}
```

4. withName selectors - Matching process name:

```
process {
    withName: FOO {
        cpus = 32  // Overrides withLabel
    }
}
```

5. withName with fully qualified name - workflow + name:

```
process {
    withName: 'WORKFLOW:SUBWORKFLOW:FOO' {
        cpus = 128  // HIGHEST PRIORITY
    }
}
```

### Configuration profiles 

Profiles are just conditional config blocks that get applied when selected via `-profile`. 
Settings inside a selected profile follow the same hierarchy above, but override non-profile settings at their respective level.

### Environment Variables & CLI:

- `-c` option: Adds config files to the hierarchy (#4 above)
- Command line params (`--param`): Highest priority for parameter values, override params in all config files

## Manifest scope

The manifest scope is a configuration block in Nextflow that allows you to define essential metadata about your pipeline project. 

```
manifest {
    name            = 'my-awesome-pipeline'
    author          = 'Jane Doe'
    homePage        = 'https://github.com/myorg/my-pipeline'
    description     = 'Pipeline for RNA-seq analysis'
    mainScript      = 'main.nf'
    nextflowVersion = '>=24.04'
    version         = '1.0.0'
    license         = 'MIT'
    doi             = '10.1234/example.doi'
}
```

### Why is it Important?

1. Version Compatibility & Safety 🛡️

- `manifest.nextflowVersion` = '>=24.04'  // Ensures users have compatible version (give a warning if not)
- `manifest.nextflowVersion` = '!>=24.04' // Stops execution if version doesn't match

This prevents users from running your pipeline with incompatible Nextflow versions, avoiding cryptic errors.

2. Reproducibility 🔬
By documenting version, contributors, and DOI, you enable proper scientific citation and ensure others can trace the exact pipeline version used in publications.

3. Publishing & Sharing 📦
When you share your pipeline via nf-core, GitHub, or the Nextflow Hub, manifest metadata is automatically displayed, making your pipeline discoverable and easier to understand.

4. User Experience 👥
Clear metadata helps users quickly understand what your pipeline does, who maintains it, and where to find help.
