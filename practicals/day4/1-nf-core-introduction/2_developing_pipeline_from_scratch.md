# 2. Developing an nf-core Pipeline from Scratch

This section covers the practical steps to develop a new nf-core pipeline using the standardized nf-core template and tools.

---

## Exercise 1: Creating a Pipeline with nf-core Template

### Objective
Learn how to initialize a new nf-core pipeline using the template generator and understand the project structure.

### Steps

#### 1.1: Prerequisites

Ensure you have:

1. Access to a compute node on the cluster:

```bash
srun --nodes=1 \
     --tasks-per-node=1 \
     --mem=8GB \
     --partition="cpu-interactive" \
     --pty /bin/bash
```

2. Activated your nf-core Conda environment:

```bash
conda activate /scratch/$USER/envs/nf-core
module load openjdk/17.0.8.1_1
module load singularity/3.8.5
```

3. A working directory for development:

```bash
cd $HOME/<COURSE FOLDER>/day4
```

4. Make sure you have a GitHub account!

#### 1.2: Create a New Pipeline

Use the nf-core template generator:

```bash
nf-core pipelines create
```

This will open an interactive prompt that you can use to
customize the new pipeline:

**Interactive prompts:**
- **Pipeline type**: "Custom"
- **GitHub organization**: your GitHub account
- **Workflow name**: "salmoquant"
- **Short Description**: a sentence on the pipeline purpose
- **Author**: Your name
- **Template features**: Toggle all feature
- **First version of the pipeline**: choose a version tag (use semantic versioning)
- **Path**: "."
- **Create GitHub repository**: "Finish without creating a repo"

Navigate to the created pipeline:

```bash
cd <YOUR_GH_ID>-salmoquant
```

#### 1.3: Explore the Template Structure

List the main directories:

```bash
ls -l
```

**Key directories and files:**

```
nf-core-salmoquant/
├── README.md                # Pipeline main documentation file
├── LICENSE                  # MIT license file
├── main.nf                  # Main workflow entry point
├── nextflow.config          # Main configuration file
├── nextflow_schema.json     # Parameter schema definition
├── modules.json             # Module and subworkflow installation file
├── nf-test.config           # nf-test configuration
├── assets/                  # Misc files that are used by the pipeline
├── bin/                     # Custom scripts
├── conf/                    # Additional configuration
├── docs/                    # Extended documentation
├── modules/                 # Modules
├── subworkflows/            # Subworkflows
├── templates/               # Process templates
├── tests/                   # Test data and configurations
├── workflows/               # Main workflow files
└── ...
```

The template contains a lot of tools, files, folders ...
It can be overwhelming at first, particualrly for someone
who is at the first experiences with NF.
I recommend working one step at a time, familiarize with the
structure, study existing nf-core pipelines of your interest
(but choose simple and active ones!)

## Exercise 2: Setting Up the Development Environment

### Objective
Configure VSCode with recommended extensions and set up pre-commit hooks for code quality.

### Steps

#### 2.1: Install VSCode Extensions

Open VSCode and install recommended extensions.
Go to the extensions marketplace and look for `nf-core-extensionpack`.
Install it. This includes:

Apptainer/Singularity - Provides syntax highlighting for Apptainer/Singularity definition files
Docker - Makes it easy to create, manage, and debug containerized applications
EditorConfig - Support for EditorConfig project files for code standardisation.
gitignore - Language support for .gitignore files
Markdown Extended - Gives nice markdown previews, including admonitions - see nf-core/website#2579
Nextflow - Nextflow language support
Prettier - Code formatter using prettier
Rainbow CSV - Highlight columns in csv files in different colors
Ruff - An extremely fast Python linter and code formatter, written in Rust.
Todo Tree - Show TODO, FIXME, etc. comment tags in a tree view
YAML - YAML Language Support by Red Hat, with built-in Kubernetes syntax support


#### 2.2: Examine Key Files using the Nextflow extension

The extension provides capabilities that help navigating a structured project as the
nf-core template. One of the main features is the possibility of following links and
import statements inside the code and having popups that show the definitions of
the interfaces of processes / subworkflows.

**Main workflow entry point:**

```bash
cat main.nf
```

follow the code from main.nf to workflows/salmoquant.nf
and from workflows/salmoquant.nf to modules/subworkflows

**Configuration entry point:**

```bash
cat nextflow.config
```

follow the main configuration to the various files that
are included in the conf/ folder

---

#### 2.3: Git configuration

The nf-core template comes initialized with git revision tracking.

```bash
git status
```

You can see from the log that the initial commit is the
template:

```bash
git log
```

There are already three different branches:

```bash
git branch
```

but we will get into their meaning and usage later.

---

#### 2.4: Set Up Pre-commit Hooks

Pre-commit hooks automatically validate code before commits. The nf-core template includes a pre-commit configuration.

View the pre-commit configuration:

```bash
cat .pre-commit-config.yaml
```

**Expected hooks:**
- `prettier`: "opinionated code formatter"
- Trailing whitespace removal
- End-of-file fixer

Open a shell to install the pre-commit hooks.
You need first the pre-commit python package:

```bash
pip install pre-commit
```

Then install the pre-commit hooks:

```bash
pre-commit install
```

Verify installation:

```bash
pre-commit run --all-files
```

This will run all pre-commit checks on the entire repository.

## Exercise 3: Understanding Modules and Subworkflows

### Objective
Learn about nf-core modules, subworkflows, and how to integrate them into your pipeline.

### Background

**Modules:**
- Self-contained code that define a single nextflow process
- Reusable across pipelines
- Maintained in nf-core/modules repository
- Include: process definition, software container, documentation and testing

**Subworkflows:**
- Multi-step workflows combining multiple modules
- Reusable logical components
- Maintained in nf-core/modules repository
- Include: subworkflow definition, module dependencies, documentation and testing

For the sake of simplicity, here we will focus on modules.
However, the concepts and the commands involved are quite similar.

### Steps

#### 3.1: Explore Module Structure

Modules are stored in the modules/nf-core/ folder.
Navigate to this folder with vscode.
The template by default contains the multiqc and the fastqc modules.

Open the folder for the fastqc.

**Typical module structure:**

```
modules/nf-core/fastqc/
├── main.nf          # Process definition
├── meta.yml         # Module metadata and documentation
├── environment.yml  # Conda environment that is built on the fly when running the pipeline with conda support
└── tests/           # nf-test configuration to test the module
```

Open the .nf file. You will see that even for a simple job as fastqc the process code
can be quite complex.
We will not go through the process of building modules along the nf-core guidelines
which can be quite complicated. However, keep in mind that although they seem quite
complicated, the guidelines are there to ensure the highest level of reusability,
e.g. the possibility of a complete customization of the command line of the tool,
specifying any possible input and capturing any possible output. This is of course challenging
are requires a certain overhead with respect to writing process for a specific
workflow.

#### 3.2: Installing Required Modules

For our Salmon-based RNA-seq pipeline, we need:
- **FASTQC**: Quality control
- **SALMON**: Pseudo-alignment and quantification
- **MULTIQC**: Results aggregation

Double check that which modules have been properly installed with the nf-core tools command line tool:

```bash
nf-core modules list local
```

Browse available modules from the nf-core repository and look for salmon:

```bash
nf-core modules list remote | grep -i salmon
```

You will see:
```
│ salmon/index                                          │
│ salmon/quant                                          │
```

So the indexing and the quantification are available. Install Salmon module:

```bash
nf-core modules install salmon/quant
```

#### 3.3: Including the module in the nextflow code

Now we will modify the salmoquant.nf file that contains the main workflow to


```diff
--- a/workflows/salmoquant.nf
+++ b/workflows/salmoquant.nf
@@ -9,6 +9,7 @@ include { paramsSummaryMap       } from 'plugin/nf-schema'
 include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
 include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
 include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_salmoquant_pipeline'
+include { SALMON_QUANT           } from '../modules/nf-core/salmon/quant/main'

 /*
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@@ -20,6 +21,10 @@ workflow SALMOQUANT {

     take:
     ch_samplesheet // channel: samplesheet read in from --input
+    ch_salmon_index
+    ch_fasta
+    ch_gtf
+
     main:

     ch_versions = channel.empty()
@@ -33,6 +38,20 @@ workflow SALMOQUANT {
     ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect{it[1]})
     ch_versions = ch_versions.mix(FASTQC.out.versions.first())

+    //
+    // MODULE: Run Salmon Quant
+    //
+    SALMON_QUANT (
+        ch_samplesheet,
+        ch_salmon_index,
+        ch_gtf,
+        ch_fasta,
+        "",
+        ""
+    )
+    ch_multiqc_files = ch_multiqc_files.mix(SALMON_QUANT.out.results.collect{it[1]})
+    ch_versions = ch_versions.mix(SALMON_QUANT.out.versions.first())
+
     //
     // Collate and save software versions
     //
(END)
```

#### 3.4: Module Configuration

When including an additional process to the pipeline, it is often required
to customize its behaviour by giving additional arguments, specifying which
files to save to the final output and where to save them (the publishDir directive),
and possibly any other process-specific configuration.
In a nf-core pipeline, it is custom to save this type of configuration to
the `conf/modules.config` file.

For the  'SALMON_QUANT' process, we will add this block to the `conf/modules.config` file:

```groovy
process {
  withName: 'SALMON_QUANT' {
    ext.args = '--validateMappings'
    publishDir = [
        path: { "${params.outdir}/salmon" },
        mode: params.publish_dir_mode,
        saveAs: { filename -> filename.equals('versions.yml') ? null : filename }
    ]
  }
}
```

---

## Exercise 4: Customizing Pipeline Input - Parameters and Schema

### Objective
Learn how to define pipeline parameters and update the JSON schema for parameter validation.

### Steps

#### 4.1: Adding reference files as input parameters

For running Salmon we need to provide a fasta file of the transcriptome, the corresponding
gft file and the salmon index for this transcritome.
These files are not directly provided by iGenomes, so we will add these files
as files that are required when running the pipeline.

New parameters needs to be initialized in the `nextflow.config` configuration file.

```diff
diff --git a/nextflow.config b/nextflow.config
index be8624f..a1f38dd 100644
--- a/nextflow.config
+++ b/nextflow.config
@@ -17,6 +17,9 @@ params {
     genome                     = null
     igenomes_base              = 's3://ngi-igenomes/igenomes/'
     igenomes_ignore            = false
+    transcriptome_fasta        = null
+    gft                        = null
+    salmon_index               = null

     // MultiQC options
     multiqc_config             = null
```

Now the parameters can be used throgh the as attribute of the params object.
For the sake of readability, we want to explicitely show the use of
these files in the interface of the main "SALMOQUANT" workflow. So,
we will create some value channels in the main and then pass them explicitely
to SALMOQUANT (in accordance to the interface that we have already defined for SALMOQUANT)

```diff
diff --git a/main.nf b/main.nf
index 4c29fc8..6787b78 100644
--- a/main.nf
+++ b/main.nf
@@ -45,11 +45,18 @@ workflow MATBONFANTI_SALMOQUANT {

     main:

+    ch_fasta        = channel.value(file(params.fasta, checkIfExists: true))
+    ch_gtf          = channel.value(file(params.gtf, checkIfExists: true))
+    ch_salmon_index = channel.value(file(params.salmon_index, checkIfExists: true))
+
     //
     // WORKFLOW: Run pipeline
     //
     SALMOQUANT (
-        samplesheet
+        samplesheet,
+        ch_salmon_index,
+        ch_fasta,
+        ch_gtf
     )
     emit:
     multiqc_report = SALMOQUANT.out.multiqc_report // channel: /path/to/multiqc_report.html

```

#### 4.3: Update the JSON Schema

In a nf-core pipeline, all the input parameters are initialized and validated at the beginnning
of the execution by making use of a json schema, that is contained in the file `nextflow_schema.json`.
A JSON Schema is a language that allows you to validate data that is stored in a "dictionary" format.
It defines the structure, data types, and constraints, enabling validation of whether an object
conforms to a specific format or structure.

Direct manipulation of a JSON schema is not easy, hence nf-core provides an interactive
web-based platform for updating and modifying the schema.

```bash
nf-core schema build
```

The tools write a url as output. The url points to a web-based interface where the schema can be edited.
Please note that the current tool can be a bit buggy, and also relies on the communication with
an external service. For this reason, the nf-core core development team is currently working
on a new tool.

An existing schema can then be validated with the command:

```bash
nf-core schema validate nextflow_schema.json
```

---

## Exercise 5: Customizing Pipeline Input - Samplesheet Structure

### Objective
Learn how to design and validate sample input CSV files for the pipeline.

### Steps

#### 6.1: Design Samplesheet Format

For RNA-seq with Salmon, create a samplesheet format:

```json
{
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "https://raw.githubusercontent.com/matbonfanti/salmoquant/master/assets/schema_input.json",
    "title": "matbonfanti/salmoquant pipeline - params.input schema",
    "description": "Schema for the file provided with params.input",
    "type": "array",
    "items": {
        "type": "object",
        "properties": {
            "sample": {
                "type": "string",
                "pattern": "^\\S+$",
                "errorMessage": "Sample name must be provided and cannot contain spaces",
                "meta": ["id"]
            },
            "fastq_1": {
                "type": "string",
                "format": "file-path",
                "exists": true,
                "pattern": "^([\\S\\s]*\\/)?[^\\s\\/]+\\.f(ast)?q\\.gz$",
                "errorMessage": "FastQ file for reads 1 must be provided, cannot contain spaces and must have extension '.fq.gz' or '.fastq.gz'"
            },
            "fastq_2": {
                "type": "string",
                "format": "file-path",
                "exists": true,
                "pattern": "^([\\S\\s]*\\/)?[^\\s\\/]+\\.f(ast)?q\\.gz$",
                "errorMessage": "FastQ file for reads 2 cannot contain spaces and must have extension '.fq.gz' or '.fastq.gz'"
            },
            "strandedness": {
                "type": "string",
                "enum": ["unstranded", "forward", "reverse"],
                "errorMessage": "Library strandedness must be provided and cannot contain spaces",
            }
        },
        "required": ["sample", "fastq_1", "strandedness"]
    }
}
```

#### 6.2: Create Input Validation Subworkflow

Create a subworkflow to validate input CSV:

```bash
cat > subworkflows/local/input_check.nf << 'EOF'
//
// Check input samplesheet and get read channels
//

workflow INPUT_CHECK {
    take:
        samplesheet // file: samplesheet.csv

    main:
        ch_input_rows = Channel
            .fromPath( samplesheet )
            .splitCsv ( header:true, sep:',' )
            .map { create_input_channel(it) }

        ch_reads = ch_input_rows
            .map { meta, fastqs -> [ meta, fastqs ] }

    emit:
        reads = ch_reads
}

def create_input_channel(LinkedHashMap row) {
    def meta = [:]
    meta.id = row.sample
    meta.strandedness = row.strandedness ?: 'unstranded'

    def fastqs = []
    if (row.fastq_2) {
        fastqs = [ file(row.fastq_1, checkIfExists: true), file(row.fastq_2, checkIfExists: true) ]
    } else {
        fastqs = [ file(row.fastq_1, checkIfExists: true) ]
    }

    return [ meta, fastqs ]
}
EOF
```

#### 6.3: Create Example Samplesheet

Create a template samplesheet:

```bash
cat > assets/samplesheet.csv << 'EOF'
sample,fastq_1,fastq_2,strandedness
sample1,reads_1_R1.fastq.gz,reads_1_R2.fastq.gz,reverse
sample2,reads_2_R1.fastq.gz,reads_2_R2.fastq.gz,reverse
sample3,reads_3_R1.fastq.gz,,forward
EOF
```

---

## Exercise 7: Run the pipeline with a test dataset

### Objective

### Steps



---

## Exercise 8: Code Linting and Testing with nf-test

### Objective
Learn how to validate pipeline code quality and write automated tests.

### Steps

#### 8.1: Run nf-core Lint

Check pipeline compliance with nf-core standards:

```bash
nf-core lint --release 2024.05
```

**Common issues reported:**
- Missing documentation
- Incorrect module format
- Schema validation errors
- Naming conventions

**Fix issues and re-run:**

```bash
nf-core lint --release 2024.05 --fix
```

#### 8.3: Create test profile

Create a test for the SALMON_QUANT module:


#### 8.5: Run nf-test

Execute tests:

```bash
nf-test test tests/main.test.nf
```

**Expected output:**
```
Tests finished successfully
```

Generate snapshot-based tests:

```bash
nf-test test tests/workflows/salmoquant/main.test.nf --update-snapshot
```

This creates snapshot files for comparison in future test runs.

---

## Exercise 10: Version Control and Pushing to GitHub

### Objective
Prepare the pipeline for publication and continuous integration.

### Steps

#### 10.3: Set Up GitHub Repository

Create a new repository on GitHub:

1. Go to https://github.com/new
2. Name: `nf-core-salmoquant`
3. Add description
4. Choose public or private
5. Create repository

Connect local repository to GitHub:

```bash
git remote add origin https://github.com/YOUR-USERNAME/nf-core-salmoquant.git
git branch -M main
git push -u origin main
```

## Summary Checklist

By completing these exercises, you should be able to:

- [ ] Create a new nf-core pipeline using the template generator
- [ ] Understand the template directory structure
- [ ] Configure VSCode with recommended extensions
- [ ] Set up and use pre-commit hooks
- [ ] Install and manage nf-core modules
- [ ] Add pipeline parameters and validate them with JSON schema
- [ ] Create and validate input samplesheet
- [ ] Run nf-core lint and nf-test

---

## Resources

- **nf-core website**: https://nf-co.re/
- **nf-core tools documentation**: https://nf-co.re/tools
- **Nextflow documentation**: https://www.nextflow.io/docs/latest/
- **nf-test documentation**: https://seqera.io/nf-test/
