# Day 4 - Section 1 - Configuring and Launching nf-core Pipelines

This section covers the practical steps to discover, configure, and execute nf-core pipelines on the cluster.

---

## Exercise 1: Exploring nf-core Pipelines

### Objective
Familiarize yourself with the nf-core website, understand pipeline formats, and identify available pipelines.

### 1.1: Visit the nf-core Website

Open your browser and navigate to:
```
https://nf-co.re/
```

**What to explore:**
- The **Pipelines** section (https://nf-co.re/pipelines)
- Browse available pipelines and their categories (RNA-seq, scRNA-seq, ChIP-seq, etc.)

### 1.2: Understanding Pipeline Documentation

For this course, we will work with **nf-core/rnaseq** (RNA-seq analysis pipeline).
Find and click on `nf-core/rnaseq` to access the detailed documentation, which includes:

- **Pipeline name and versions**
- **Introduction**: general README and overview
- **Usage**: detailed instructions on running the pipeline and structuring input files
- **Parameters**: comprehensive reference for all available pipeline parameters
- **Output**: expected structure of pipeline output directories

---

## Exercise 2: Pulling and Launching nf-core Pipelines

### Objective
Learn how to obtain nf-core pipelines using Nextflow's caching mechanism.

### Prerequisites

Ensure you have:

1. Access to a compute node on the cluster

```bash
srun --wait=0 --pty -p cpu-interactive -c 1 --mem 8G -J nxf_training /bin/bash
```

2. Activated your virtual environment (from preliminary steps) and loaded the OpenJDK and Singularity modules

```bash
source  /scratch/$USER/nf-core/bin/activate
module load openjdk/17.0.8.1_1
module load singularity/3.8.5
```

3. A work folder for the course in your home directory where you will create, clone, and modify pipelines

```bash
cd $HOME/nextflow_training/practicals_outputs/day4
```


### 2.1: Method 1 - Manual Cloning

To maintain a local copy of the pipeline, clone it using git:

```bash
git clone https://github.com/nf-core/rnaseq.git nf-core-rnaseq-3.22.0
cd nf-core-rnaseq-3.22.0
git checkout 3.22.0
cd ..
```

### 2.2: Method 2 - Direct Execution with Nextflow

To run a pipeline directly without manual cloning:

```bash
nextflow run nf-core/rnaseq --help
```

**What happens:**
- Nextflow downloads the pipeline from GitHub
- The pipeline is cached in `~/.nextflow/assets/nf-core/rnaseq/`
- `--help` displays all available parameters with descriptions, defaults, and types

**Verify the cached pipeline:**

```bash
ls ~/.nextflow/assets/nf-core/rnaseq/
```

**Expected output:**
```
CHANGELOG.md        LICENSE    bin   main.nf       nextflow.config       ro-crate-metadata.json  tower.yml
CITATIONS.md        README.md  conf  modules       nextflow_schema.json  subworkflows            workflows
CODE_OF_CONDUCT.md  assets     docs  modules.json  nf-test.config        tests
```

**Managing pipeline versions:**

Nextflow caches pipelines and reuses them for subsequent runs. To update to the latest version:

```bash
nextflow pull nf-core/rnaseq
```

To pull or run a specific release (identified by git tags):

```bash
nextflow pull nf-core/rnaseq -r 3.22.0
```

Verify that the cached pipeline is checked out at the correct tag:

```bash
cd  ~/.nextflow/assets/nf-core/rnaseq/
git status
cd -
```

Expected output:

```
Refresh index: 100% (677/677), done.
HEAD detached at 3.22.0
nothing to commit, working tree clean
```

The `-r` flag can be used directly with the run command:

```bash
nextflow run nf-core/rnaseq -r 3.22.0 --help
```

Use `-r` to specify any release, branch, or commit hash.

---

## Exercise 3: Pipeline Configuration with nf-core configs

### Objective
Learn how to use nf-core public profiles for HPC cluster configuration and understand profile structure.

### Background

**nf-core/configs** are pre-configured parameter sets that:
- Set maximum resource allocations (CPU, memory, time)
- Configure execution environments (Docker, Singularity, Conda)
- Optimize for specific compute systems (HPC clusters, cloud platforms)

nf-core maintains profiles for common systems in the `https://github.com/nf-core/configs/` repository.
These profiles are automatically sourced by nf-core pipelines and can be used with the `-profile` flag.

### 3.1: Explore Available Profiles

- Go to https://nf-co.re/configs/ and search for "Human Technopole"
- Select the `humantechnopole` profile
- Review the profile page (https://nf-co.re/configs/humantechnopole/) for general information, job file templates, and configuration details

### 3.2: Use the `humantechnopole` Profile

Apply the Human Technopole profile to configure Nextflow for the cluster:

```bash
nextflow config nf-core/sarek -profile humantechnopole > final_config
grep config_profile final_config
```

**Expected output:**
```
  config_profile_name = null
  config_profile_description = 'Human Technopole cluster profile provided by nf-core/configs.'
  config_profile_contact = 'Edoardo Giacopuzzi (@edg1983)'
  config_profile_url = 'https://humantechnopole.it/en/'
```

This confirms that Nextflow has successfully loaded the configuration from the nf-core/configs repository. The profile automatically configures:
- **Containerization**: Singularity containerization
- **Job scheduler**: SLURM integration for cluster job submission
- **Resource limits**: Maximum CPU, memory, and time allocations

---

## Exercise 4: Preparing Input and Configuring Parameters

### Objective
Learn how to prepare input data, generate parameter templates, and configure a pipeline run.

### 4.1: Prepare a Samplesheet

nf-core pipelines typically accept input sequences via a samplesheet with a common format:

**Samplesheet format:**
- CSV file with header row
- Columns: `sample`, `fastq_1`, `fastq_2`
- Paths can be absolute or relative to the working directory
- Multiple lanes per sample are automatically merged

For nf-core/rnaseq, an additional column specifies strandedness:
- `strandedness`: RNA sequence strandness in the corresponding FASTQ file

Create a folder named `rnaseq_test_01` and create `samplesheet.csv` with this content:

```csv
sample,fastq_1,fastq_2,strandedness
SRR6357070_2,https://raw.githubusercontent.com/nf-core/test-datasets/rnaseq/testdata/GSE110004/SRR6357070_1.fastq.gz,https://raw.githubusercontent.com/nf-core/test-datasets/rnaseq/testdata/GSE110004/SRR6357070_2.fastq.gz,reverse
SRR6357071_2,https://raw.githubusercontent.com/nf-core/test-datasets/rnaseq/testdata/GSE110004/SRR6357071_1.fastq.gz,https://raw.githubusercontent.com/nf-core/test-datasets/rnaseq/testdata/GSE110004/SRR6357071_2.fastq.gz,reverse
```

### 4.2: Generate Parameters Template

We recommend saving pipeline parameters in a YAML file to ensure reproducibility and easy recovery of settings.

Using nf-core tools, generate a full parameter template:

```bash
nf-core pipelines create-params-file nf-core/rnaseq
```

This command generates a `nf-params.yml` file containing all pipeline parameters with descriptions and default values (all commented by default).

For this exercise, create a custom `rnaseq_test_01/params.yaml` with minimal settings:

```yaml
# Input/Output
input: './samplesheet.csv'
outdir: './results'

# Genome references
fasta: 'https://raw.githubusercontent.com/nf-core/test-datasets/rnaseq/reference/genome.fasta'
gtf: 'https://raw.githubusercontent.com/nf-core/test-datasets/rnaseq/reference/genes.gtf.gz'
transcript_fasta: 'https://raw.githubusercontent.com/nf-core/test-datasets/rnaseq/reference/transcriptome.fasta'
salmon_index: 'https://raw.githubusercontent.com/nf-core/test-datasets/rnaseq/reference/salmon.tar.gz'

# Processing parameters
pseudo_aligner: 'salmon'
```

### 4.3: Add Configuration

As for any Nextflow run, other configuration options can be defined
in several places. For this test, we include a configuration file
from command line.

Create `rnaseq_test_01/custom.config` with the following content:

```groovy
// Custom nf-core/rnaseq configuration

singularity.cacheDir = "/scratch/matteo.bonfanti/nextflow/.singularity"
```

This option specifies the cache directory where Nextflow stores downloaded Singularity images.

### 4.4: Launch the Test

Run the pipeline with the command:

```bash
cd rnaseq_test_01
nextflow run nf-core/rnaseq \
  -profile humantechnopole,singularity \
  -params-file params.yaml \
  -c custom.config \
  -w ./work_test
```

If the pipeline version is stuck on a previous tag, you will encounter this error:

```
Project `nf-core/rnaseq` is currently stuck on revision: 3.22.0 -- you need to explicitly specify a revision with the option `-r` in order to use it
```

This happens because the pipeline version stored in the cache is in a detached state, pointing to a previous release tag.
As a safety measure, Nextflow requires pipelines in this state to be explicitly referenced on the command line using the `-r` option.

To update the cached pipeline and move it back to the latest
commit on the `master` branch, you can run:

```bash
nextflow pull nf-core/rnaseq -r master
```

Then re-run the pipeline:

```bash
nextflow run nf-core/rnaseq \
  -profile humantechnopole,singularity \
  -params-file params.yaml \
  -c custom.config \
  -w ./work_test
```

**Command-line flags explained:**
- `-profile humantechnopole,singularity`: apply HT profile with Singularity containers
- `-params-file params.yaml`: load parameters from the YAML file
- `-w`: specify the work directory
- `-c`: include an additional configuration file

**Note:** Run Nextflow from compute nodes, not the head node. While Nextflow itself is lightweight, certain steps (such as copying output files) can be I/O-intensive.

We recommend launching Nextflow via an sbatch script:

```bash
#!/bin/bash
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=8GB
#SBATCH --time=48:00:00
#SBATCH --partition=cpuq
#SBATCH --job-name=sarek_test
#SBATCH --mail-type=END
#SBATCH --output=%x_%j.log

echo; echo "Starting slurm job..."
echo "PWD:  $(pwd)"
echo "HOST: $(hostname)"
echo "DATE: $(date)"; echo

# Activate modules
module load openjdk/17.0.8.1_1
module load singularity/3.8.5
module load nextflow

# Run the pipeline
nextflow run nf-core/rnaseq \
  -profile humantechnopole,singularity \
  -params-file params.yaml \
  -c custom.config \
  -w ./work_test \
  -resume -ansi-log false

echo; echo "Terminating slurm job..."
echo "DATE: $(date)"; echo
exit
```

## Exercise 5: Understanding Pipeline Output Structure

### Objective
Learn how to interpret and navigate nf-core pipeline output directories.

### Steps

### 5.1: Explore Output Directory Structure

After a successful pipeline run, examine the output:

```bash
cd results
tree -L 2
```

**Expected directory structure:**

```
├── custom
│   └── out
├── fastqc
│   └── trim
├── fq_lint
│   ├── raw
│   └── trimmed
├── multiqc
│   ├── multiqc_report.html
│   ├── multiqc_report_data
│   └── multiqc_report_plots
├── pipeline_info
│   ├── execution_report_2026-01-22_12-10-41.html
│   ├── execution_timeline_2026-01-22_12-10-41.html
│   ├── execution_trace_2026-01-22_12-10-41.txt
│   ├── nf_core_rnaseq_software_mqc_versions.yml
│   ├── params_2026-01-22_12-11-14.json
│   └── pipeline_dag_2026-01-22_12-10-41.html
├── salmon
│   ├── SRR6357070_2
│   ├── SRR6357071_2
│   ├── deseq2_qc
│   ├── salmon.merged.gene.SummarizedExperiment.rds
│   ├── salmon.merged.gene_counts.tsv
│   ├── salmon.merged.gene_counts_length_scaled.tsv
│   ├── salmon.merged.gene_counts_scaled.tsv
│   ├── salmon.merged.gene_lengths.tsv
│   ├── salmon.merged.gene_tpm.tsv
│   ├── salmon.merged.transcript.SummarizedExperiment.rds
│   ├── salmon.merged.transcript_counts.tsv
│   ├── salmon.merged.transcript_lengths.tsv
│   ├── salmon.merged.transcript_tpm.tsv
│   └── tx2gene.tsv
└── trimgalore
    ├── SRR6357070_2_trimmed_1.fastq.gz_trimming_report.txt
    ├── SRR6357070_2_trimmed_2.fastq.gz_trimming_report.txt
    ├── SRR6357071_2_trimmed_1.fastq.gz_trimming_report.txt
    └── SRR6357071_2_trimmed_2.fastq.gz_trimming_report.txt
```

### 5.2: Review the MultiQC Report

Open the MultiQC report in a web browser for a comprehensive pipeline summary:

**What to examine:**
- General statistics across all samples
- Trimming metrics
- Salmon pseudo-alignment results
- Software versions used
- Methods description
- Workflow summary

### 5.3: Check Execution Metadata

The `pipeline_info` folder contains detailed execution information:

- `execution_report_*.html`: Summary of pipeline execution with performance metrics
- `execution_timeline_*.html`: Timeline visualization showing when jobs were executed
- `execution_trace_*.txt`: Detailed system metrics (CPU, memory, runtime) for each task
- `nf_core_rnaseq_software_mqc_versions.yml`: Software version inventory
- `params_*.json`: Complete parameter set used for the run (useful for reproducibility and debugging)
- `pipeline_dag_*.html`: Directed acyclic graph visualization of the workflow


## Exercise 6: Advanced Customization with Configuration Files

### Objective
Learn how to customize pipeline behavior using configuration files beyond public profiles.

### Background

Configuration files enable fine-grained control over pipeline execution:
- Override default parameters
- Customize resource allocation per process
- Add custom command-line arguments to individual tools
- Configure error handling and retry policies
- ...

### 6.1: Create a Custom Configuration File

Enhance the `custom.config` file with additional custom options:

```groovy
// Custom nf-core/rnaseq configuration

// Set singularity cache
singularity.cacheDir = "/scratch/matteo.bonfanti/nextflow/.singularity"

process {

  // Override resource allocation
  withLabel: 'process_high' {
    cpus = 4
    memory = '8.GB'
    time = '1.h'
  }

  withLabel: 'process_medium' {
    cpus = 2
    memory = '4.GB'
    time = '1.h'
  }

  withLabel: 'process_low' {
    cpus = 1
    memory = '2.GB'
    time = '1.h'
  }

  // Retry failed tasks
  maxRetries = 4

  // Customize the behaviour of a process
  withName: '.*:QUANTIFY_PSEUDO_ALIGNMENT:SALMON_QUANT' {
      ext.args = "--seqBias"
      publishDir = [
          path: { "${params.outdir}/pseudoalignment" },
          saveAs: { filename -> filename.equals('versions.yml') ? null : filename }
      ]
  }

}
```

### 6.2: Apply Custom Configuration

Re-run the pipeline with your custom configuration:

```bash
nextflow run nf-core/rnaseq \
  -profile humantechnopole,singularity \
  -params-file params.yaml \
  -c custom.config \
  -w ./work_test -resume
```

---

## Summary Checklist

By completing these exercises, you should be able to:

- [ ] Navigate the nf-core website and understand pipeline structure
- [ ] Pull and cache nf-core pipelines with version control
- [ ] Select and combine profiles appropriately
- [ ] Prepare input data and samplesheets
- [ ] Generate and customize parameter files
- [ ] Submit pipelines to HPC using batch scripts
- [ ] Interpret pipeline output directories
- [ ] Create custom configuration files

---

## Resources

- **nf-core website**: https://nf-co.re/
- **Nextflow documentation**: https://www.nextflow.io/docs/latest/

