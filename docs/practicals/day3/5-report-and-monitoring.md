# Day 3 - Section 5 - Nextflow Monitoring and Reporting

This section explains how to **monitor, analyze, and optimize** a Nextflow pipeline using built-in reports and Seqera Tower.

The objective is not only to see what happened, but to **learn how to improve pipeline performance and resource usage**.

---

## Why monitoring matters

Without monitoring you cannot answer:

* Which process is slow?
* Which process wastes memory?
* Which process is CPU-limited?
* Which step should be optimized?
* Why did a job fail on HPC?

Nextflow provides **four local reports** and one **remote monitoring system (Tower)**.

---

## Exercise 1 – Enable local Nextflow reports

Add the following block to `nextflow.config`:

```nextflow
// Set filename and location for timeline, report, trace and dag
def trace_timestamp = new java.util.Date().format('yyyy-MM-dd_HH-mm-ss')

timeline {
    enabled = true
    file    = "${params.outdir}/pipeline_info/execution_timeline_${trace_timestamp}.html"
}

report {
    enabled = true
    file    = "${params.outdir}/pipeline_info/execution_report_${trace_timestamp}.html"
}

trace {
    enabled = true
    file    = "${params.outdir}/pipeline_info/execution_trace_${trace_timestamp}.txt"
}

dag {
    enabled = true
    file    = "${params.outdir}/pipeline_info/pipeline_dag_${trace_timestamp}.html"
}
```

Then run the pipeline again.

---

## Output directory

After execution you will find:

```text
pipeline_info/
  execution_timeline_YYYY-MM-DD_HH-MM-SS.html
  execution_report_YYYY-MM-DD_HH-MM-SS.html
  execution_trace_YYYY-MM-DD_HH-MM-SS.txt
  pipeline_dag_YYYY-MM-DD_HH-MM-SS.html
```

Each file has a different purpose.

---

## File 1 – Execution Timeline

### File

```text
execution_timeline_*.html
```

### What it shows

A graphical timeline of all processes:

* When each task started and ended
* Parallel execution
* Queue waiting time vs execution time
* Bottlenecks

### How to interpret

If you see:

* Long gaps before execution → scheduler queue delay
* Very long bars → slow process
* Many short bars → lightweight tasks

### What you learn

* Which process dominates runtime
* Where parallelization is poor
* Whether resources are underutilized

---

## File 2 – Execution Report

### File

```text
execution_report_*.html
```

### What it shows

A structured summary:

* Total pipeline duration
* Success / failure
* Resource usage per process
* Retry counts
* Exit codes

### Key sections

| Section        | Meaning                |
| -------------- | ---------------------- |
| Workflow       | Global pipeline status |
| Resource Usage | Execution statistics   |
| Tasks          | CPU, memory, time      |

### What you learn

* Which processes failed
* Which processes were retried
* Which processes consumed the most resources

---

## File 3 – Execution Trace

### File:

```text
execution_trace_*.txt
```

This is the **most important file for optimization**.

It contains one row per task with columns such as:

| Column    | Meaning                    |
| --------- | -------------------------- |
| task_id   | Internal task ID           |
| hash      | Unique task hash           |
| native_id | Scheduler / system task ID |
| name      | Task name                  |
| status    | Task final status          |
| exit      | Exit code                  |
| submit    | Submission time            |
| duration  | Execution duration         |
| realtime  | Wall clock time            |
| %cpu      | Average CPU utilization    |
| peak_rss  | Peak resident memory usage |
| peak_vmem | Peak virtual memory usage  |
| rchar     | Bytes read (I/O)           |
| wchar     | Bytes written (I/O)        |


---

## Exercise 2 – Resource Optimization

In this exercise, you will use a **Nextflow execution report** (`execution_report_*.html`) to analyze resource usage, identify inefficient processes, adjust their resource requests, and validate the improvements.

The objective is to **optimize CPU and memory allocation per process** based on real execution metrics.

---

### 1. Inspect resource usage

For each process, focus on:

* **CPU efficiency**

  * Compare `% CPU` to the number of CPUs requested

* **Memory efficiency**

  * Compare *peak memory usage* to the requested memory
  
* **Runtime**

  * Short-running tasks with large resource requests are often inefficient

---

### 2. Correct resource definitions

Once inefficient processes are identified, update the pipeline configuration to **match observed usage**.

#### Step 2.1 – Edit `nextflow.config`

```groovy
process {

  withName: 'PREPARE_GENOME:SAMTOOLS_FAIDX' {
    cpus   = 1
    memory = '128 MB'
  }

  withName: 'FASTP' {
    cpus   = 4
    memory = '1 GB'
  }

  withName: 'PREPARE_GENOME:GATK4_CREATESEQUENCEDICTIONARY' {
    cpus   = 1
    memory = '4 GB'
  }

  withName: 'ALIGNMENT:BWA_MEM' {
    cpus   = 4
    memory = '6 GB'
  }

  withName: 'ALIGNMENT:SAMTOOLS_MERGE' {
    cpus   = 3
    memory = '512 MB'
  }
}
```

---

### 3. Relaunch the pipeline and validate

Re-run the workflow using the updated configuration:

```bash
nextflow run main.nf -resume
```

After completion, generate a **new execution report**.

---

### 4. Compare before and after

Open the new HTML report and compare:

* CPU utilization closer to optimal values
* Reduced memory over-allocation
* No task failures due to insufficient resources
* Similar or improved wall-clock time