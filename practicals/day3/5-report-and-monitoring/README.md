# Nextflow Monitoring and Reporting

This section explains how to **monitor, analyze, and optimize** a Nextflow pipeline using built-in reports and Seqera Tower.

The objective is not only to see what happened, but to **learn how to improve pipeline performance and resource usage**.

---

# Why monitoring matters

Without monitoring you cannot answer:

* Which process is slow?
* Which process wastes memory?
* Which process is CPU-limited?
* Which step should be optimized?
* Why did a job fail on HPC?

Nextflow provides **four local reports** and one **remote monitoring system (Tower)**.

---

# Exercise 1 – Enable local Nextflow reports

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

# File 1 – Execution Timeline

### File:

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

# File 2 – Execution Report

### File:

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

| Section   | Meaning                |
| --------- | ---------------------- |
| Workflow  | Global pipeline status |
| Processes | Execution statistics   |
| Resources | CPU, memory, time      |
| Errors    | Failed processes       |

### What you learn

* Which processes failed
* Which processes were retried
* Which processes consumed the most resources

---

# File 3 – Execution Trace

### File:

```text
execution_trace_*.txt
```

This is the **most important file for optimization**.

It contains one row per task with columns such as:

| Column      | Meaning            |
| ----------- | ------------------ |
| task_id     | Internal task id   |
| process     | Process name       |
| status      | COMPLETED / FAILED |
| cpus        | CPUs requested     |
| memory      | Memory requested   |
| realtime    | Wall clock time    |
| rss         | Real memory used   |
| vmem        | Virtual memory     |
| read_bytes  | Disk read          |
| write_bytes | Disk write         |

---

## How to use it

Example:

```text
BWA_MEM   cpus=8   memory=16 GB   rss=4.2 GB
```

### Interpretation

You requested 16 GB but only used 4.2 GB → memory is over-allocated.

---

## Optimization strategy

| Observation             | Action               |
| ----------------------- | -------------------- |
| rss << memory           | Reduce memory        |
| rss ≈ memory            | Good allocation      |
| rss > memory            | Increase memory      |
| realtime high, cpu low  | Increase CPUs        |
| realtime high, cpu high | Algorithm bottleneck |

---

# File 4 – Pipeline DAG

### File:

```text
pipeline_dag_*.html
```

### What it shows

The Directed Acyclic Graph:

* Process dependencies
* Data flow
* Parallel branches
* Join points

### Why it matters

It explains:

* Why some steps cannot run in parallel
* Where bottlenecks are structurally unavoidable
* Where workflow redesign could help

---

# Exercise 2 – Enable Seqera Tower monitoring

## Step 1 – Register on Tower

Go to:

```
https://tower.seqera.io
```

Create an account and generate an **access token**.

---

## Step 2 – Enable Tower in config

Add to `nextflow.config`:

```nextflow
tower {
  enabled = true
  accessToken = "YOUR_TOKEN_HERE"
}
```

---

## Step 3 – Run the pipeline

```bash
nextflow run main.nf -params-file params.yaml
```

Your pipeline will appear live in Tower.

---

# What Tower provides

Tower gives you:

* Live task monitoring
* Retry control
* Resource graphs
* Failure inspection
* History of runs
* Collaboration

---

# Tower resource optimization

Tower shows:

* CPU usage per task
* Memory usage per task
* Disk I/O
* Runtime

This allows **data-driven tuning**.

---

## Example tuning workflow

### Original:

```nextflow
process BWA_MEM {
  cpus 16
  memory '32 GB'
}
```

Tower shows:

| Metric      | Value |
| ----------- | ----- |
| CPU used    | 6     |
| Memory used | 8 GB  |

### Optimized:

```nextflow
cpus 8
memory '10 GB'
```

Now:

* Same performance
* Less wasted cluster resources
* Faster scheduling

---

# How to improve each module

For every process:

1. Open trace or Tower
2. Check:

   * CPU utilization
   * Memory RSS
   * Runtime
3. Adjust:

   * `cpus`
   * `memory`
4. Re-run
5. Compare

Repeat until stable.

---

# Performance tuning principles

| Problem          | Fix                     |
| ---------------- | ----------------------- |
| Waiting in queue | Lower resource requests |
| OOM kill         | Increase memory         |
| Low CPU usage    | Reduce cpus             |
| High runtime     | Increase cpus           |
| High I/O         | Use scratch             |

---

# Best practice example

```nextflow
process BWA_MEM {
    cpus 8
    memory '12 GB'
}
```

Only because trace proved it.

---

# Conceptual summary

| Tool     | Purpose                |
| -------- | ---------------------- |
| Timeline | Visual execution       |
| Report   | Summary statistics     |
| Trace    | Precise optimization   |
| DAG      | Workflow structure     |
| Tower    | Live remote monitoring |

---

# Final takeaway

> Monitoring is not for debugging only.
> Monitoring is the foundation of performance engineering.

A pipeline without monitoring is a black box.

---

# Teaching conclusion

With these tools you can now:

* Understand pipeline behavior
* Justify resource requests
* Optimize HPC usage
* Improve reproducibility
* Improve scheduling fairness
* Improve runtime


