
[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/htgenomeanalysisunit/nextflow-zero2hero)

# 2. Developing an nf-core Pipeline from Scratch

This section covers the practical steps to develop a new nf-core pipeline using the standardized nf-core template and tools.

## Table of Contents

1. [Exercise 1: Creating a Pipeline with nf-core Template](#exercise-1-creating-a-pipeline-with-nf-core-template)
2. [Exercise 2: Setting Up the Development Environment](#exercise-2-setting-up-the-development-environment)
3. [Exercise 3: Understanding Modules and Subworkflows](#exercise-3-understanding-modules-and-subworkflows)
4. [Exercise 4: Customizing Pipeline Input — Parameters and Schema](#exercise-4-customizing-pipeline-input--parameters-and-schema)
5. [Exercise 5: Customizing Pipeline Input — Samplesheet Structure](#exercise-5-customizing-pipeline-input--samplesheet-structure)
6. [Exercise 6: Create a Custom Module](#exercise-6-create-a-custom-module)
7. [Exercise 7: Define a Test Run for the Pipeline](#exercise-7-define-a-test-run-for-the-pipeline)
8. [Exercise 8: Code Linting and Testing with nf-test](#exercise-8-code-linting-and-testing-with-nf-test)
9. [Exercise 9: Version Control and Pushing to GitHub](#exercise-9-version-control-and-pushing-to-github)
10. [Summary Checklist](#summary-checklist)
11. [Resources](#resources)


---

## Exercise 1: Creating a Pipeline with nf-core Template

### Objective

Learn how to initialize a new nf-core pipeline using the template generator and understand the project structure.

---

### 1.1: Launch GitHub codespace


### 1.1: Launch GitHub Codespaces

GitHub Codespaces provides a cloud-based development environment that eliminates the need for local setup. This is particularly convenient for Nextflow and nf-core development.

**Starting your codespace:**

Navigate to https://codespaces.new/htgenomeanalysisunit/nextflow-zero2hero to launch a new codespace. GitHub will automatically create a cloud-based virtual machine with a pre-configured development environment.

**Accessing your codespace:**

You have two options for accessing the codespace:

1. **Browser-based VSCode** — Codespaces opens directly in your browser with a full VSCode interface. This requires no additional setup and works from any device with a web browser.

2. **Local VSCode with Codespaces extension** — Install the "GitHub Codespaces" extension in your local VSCode. This allows you to connect to the remote codespace while working in your familiar local environment, with better performance on slower connections.

**Setting up your working directory:**

Once the codespace is running, open the terminal and navigate to the course practicals folder where we will complete the exercises:

```bash
cd /workspaces/nextflow-zero2hero/practicals/day4/1-nf-core-introduction/
```

The repository includes all necessary tools and dependencies pre-installed, including Nextflow, Docker, and *nf-core tools*.
*nf-core tools* is a Python package developed by the nf-core community that provides utilities for Nextflow pipeline development and execution.


---

### 1.2: Install VSCode Extensions

Install recommended extensions for VSCode. Go to the extensions marketplace and look for `nf-core-extensionpack`. This includes:

- **Apptainer/Singularity** — Provides syntax highlighting for Apptainer/Singularity definition files
- **Docker** — Makes it easy to create, manage, and debug containerized applications
- **EditorConfig** — Support for EditorConfig project files for code standardization
- **gitignore** — Language support for .gitignore files
- **Markdown Extended** — Provides nice markdown previews, including admonitions
- **Nextflow** — Nextflow language support
- **Prettier** — Code formatter using Prettier
- **Rainbow CSV** — Highlight columns in CSV files in different colors
- **Ruff** — An extremely fast Python linter and code formatter, written in Rust
- **Todo Tree** — Show TODO, FIXME, etc. comment tags in a tree view
- **YAML** — YAML Language Support by Red Hat, with built-in Kubernetes syntax support

---

### 1.3: Create a New Pipeline

Use the nf-core template generator:

```bash
nf-core pipelines create
```

This will open an interactive prompt that you can use to customize the new pipeline:

**Interactive prompts:**
- **Pipeline type**: "Custom"
- **GitHub organization**: your GitHub ID
- **Workflow name**: "pseudoalign"
- **Short Description**: a sentence on the pipeline purpose
- **Author**: Your name
- **Template features**: Toggle all features
- **First version of the pipeline**: choose a version tag (use semantic versioning)
- **Path**: "."
- **Create GitHub repository**: "Finish without creating a repo"

Navigate to the created pipeline:

```bash
cd *-pseudoalign
```

---

### 1.4: Explore the Template Structure

List the main directories:

```bash
tree -L 1 .
```

**Key directories and files:**

```
├── CHANGELOG.md
├── CITATIONS.md
├── LICENSE
├── README.md
├── assets
├── conf
├── docs
├── main.nf
├── modules
├── modules.json
├── nextflow.config
├── nextflow_schema.json
├── nf-test.config
├── ro-crate-metadata.json
├── subworkflows
├── tests
├── tower.yml
└── workflows
```

The template includes many tools, files, and directories, which can feel overwhelming at first, especially for those who are new to Nextflow. I recommend approaching it step by step: take time to become familiar with the overall structure and study existing nf-core pipelines that match your interests (preferably simple and actively maintained ones).

---

## Exercise 2: Setting Up the Development Environment

### Objective

Configure VSCode with recommended extensions and set up pre-commit hooks for code quality.

### 2.1: Examine Key Files Using the Nextflow Extension

The Nextflow extension provides capabilities that help navigate a structured project like the nf-core template. One of the main features is the ability to follow links and import statements within the code and view popups that show the definitions of interfaces for processes and subworkflows.

**Main workflow entry point:**

Open file `main.nf` and follow the code from `main.nf` to `workflows/pseudoalign.nf` and from `workflows/pseudoalign.nf` to modules and subworkflows.

**Configuration entry point:**

Open file `nextflow.config` and follow the main configuration through the various files included in the `conf/` folder.

---

### 2.2: Git Configuration

The nf-core template comes initialized with git revision tracking:

```bash
git status
```

You can see from the log that the initial commit is the template:

```bash
git log
```

There are already three different branches:

```bash
git branch
```

We will get into their meaning and usage later.

---

### 2.3: Set Up Pre-commit Hooks

Pre-commit hooks automatically validate code before commits. The nf-core template includes a pre-commit configuration.

View the pre-commit configuration:

```bash
cat .pre-commit-config.yaml
```

**Expected hooks:**
- `prettier`: "opinionated code formatter"
- Trailing whitespace removal
- End-of-file fixer

Open a shell to install the pre-commit hooks. First, install the pre-commit Python package:

```bash
pip install pre-commit
```

Then install the pre-commit hooks:

```bash
pre-commit install
```

Verify the installation:

```bash
pre-commit run --all-files
```

This will run all pre-commit checks on the entire repository.

---

## Exercise 3: Understanding Modules and Subworkflows

### Objective

Learn about nf-core modules and subworkflows, and how to integrate them into your pipeline.

---

### Background

**Modules:**
- Self-contained code that define a single Nextflow process
- Reusable across pipelines
- Maintained in the nf-core/modules repository
- Include: process definition, software container, documentation, and testing

**Subworkflows:**
- Multi-step workflows combining multiple modules
- Reusable logical components
- Maintained in the nf-core/modules repository
- Include: subworkflow definition, module dependencies, documentation, and testing

For simplicity, we will focus on modules. However, the concepts and commands involved are quite similar.

---

### 3.1: Explore Module Structure

Modules are stored in the `modules/nf-core/` folder. Navigate to this folder with VSCode. The template by default contains the FastQC and MultiQC modules.

Open the folder for FastQC.

**Typical module structure:**

```
modules/nf-core/fastqc/
├── main.nf          # Process definition
├── meta.yml         # Module metadata and documentation
├── environment.yml  # Conda environment that is built on the fly
|                    #    when running the pipeline with conda support
└── tests/           # nf-test configuration to test the module
```

Open the `.nf` file. You will see that even for a simple task like FastQC, the process code can be quite complex. We will not go through the process of building modules according to nf-core guidelines, which can be quite complicated. However, keep in mind that although they seem complex, the guidelines are there to ensure the highest level of reusability, such as the ability to completely customize the command line of the tool and capture any possible output. This is of course challenging and requires some overhead compared to writing processes for a specific workflow.

---

### 3.2: Installing Required Modules

For our Salmon-based RNA-seq pipeline, we need:
- **FASTQC**: Quality control
- **SALMON**: Pseudo-alignment and quantification
- **MULTIQC**: Results aggregation

Double check which modules have been properly installed with the nf-core command-line tool:

```bash
nf-core modules list local
```

Browse available modules from the nf-core repository and search for Salmon:

```bash
nf-core modules list remote | grep -i salmon
```

You will see:
```
│ salmon/index                                          │
│ salmon/quant                                          │
```

Install the Salmon quant module:

```bash
nf-core modules install salmon/quant
```

---

### 3.3: Including the Module in the Nextflow Code

Now we will modify the `pseudoalign.nf` file that contains the main workflow:

```diff
--- a/workflows/pseudoalign.nf
+++ b/workflows/pseudoalign.nf
@@ -9,6 +9,7 @@ include { paramsSummaryMap       } from 'plugin/nf-schema'
 include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
 include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
 include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_pseudoalign_pipeline'
+include { SALMON_QUANT           } from '../modules/nf-core/salmon/quant/main'

 /*
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@@ -20,6 +21,10 @@ workflow pseudoalign {

     take:
     ch_samplesheet // channel: samplesheet read in from --input
+    ch_salmon_index
+    ch_fasta
+    ch_gtf
     main:

     ch_versions = channel.empty()
@@ -33,6 +38,20 @@ workflow pseudoalign {
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
+
     //
     // Collate and save software versions
     //
(END)
```

---

### 3.4: Module Configuration

When including an additional process in the pipeline, it is often necessary to customize its behavior by specifying additional arguments, defining which files to save to the final output and where to save them (via the `publishDir` directive), and potentially other process-specific configurations. In an nf-core pipeline, it is customary to save this type of configuration in the `conf/modules.config` file.

For the `SALMON_QUANT` process, add this block to the `conf/modules.config` file:

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

## Exercise 4: Customizing Pipeline Input — Parameters and Schema

### Objective

Learn how to define pipeline parameters and update the JSON schema for parameter validation.

---

### 4.1: Adding Reference Files as Input Parameters

For running Salmon, we need to provide a FASTA file of the transcriptome, the corresponding GTF file, and the Salmon index for this transcriptome. These files are not directly provided by iGenomes, so we will add these files as required input parameters for the pipeline.

New parameters need to be initialized in the `nextflow.config` configuration file:

```diff
diff --git a/nextflow.config b/nextflow.config
index be8624f..a1f38dd 100644
--- a/nextflow.config
+++ b/nextflow.config
@@ -17,6 +17,9 @@ params {
     genome                     = null
     igenomes_base              = 's3://ngi-igenomes/igenomes/'
     igenomes_ignore            = false
+    transcript_fasta           = null
+    gtf                        = null
+    salmon_index               = null

     // MultiQC options
     multiqc_config             = null
```

Now the parameters can be used through the `params` object. For readability, we want to explicitly show the use of these files in the interface of the main "pseudoalign" workflow. We will create value channels in the main and then pass them explicitly to pseudoalign (in accordance with the interface we have already defined):

```diff
diff --git a/main.nf b/main.nf
index 4c29fc8..6787b78 100644
--- a/main.nf
+++ b/main.nf
@@ -45,11 +45,18 @@ workflow NFDATAOMICS_PSEUDOALIGN {

     main:

+    ch_transcript_fasta = channel.value(file(params.transcript_fasta, checkIfExists: true))
+    ch_gtf              = channel.value(file(params.gtf, checkIfExists: true))
+    ch_salmon_index     = channel.value(file(params.salmon_index, checkIfExists: true))
+
     //
     // WORKFLOW: Run pipeline
     //
     pseudoalign (
-        samplesheet
+        samplesheet,
+        ch_salmon_index,
+        ch_transcript_fasta,
+        ch_gtf
     )
     emit:
     multiqc_report = pseudoalign.out.multiqc_report // channel: /path/to/multiqc_report.html

```

---

### 4.2: Update the JSON Schema

In an nf-core pipeline, all input parameters are initialized and validated at the beginning of execution using a JSON schema contained in the `nextflow_schema.json` file. A JSON Schema is a language that allows you to validate data stored in a dictionary format. It defines the structure, data types, and constraints, enabling validation of whether an object conforms to a specific format or structure.

Direct manipulation of a JSON schema is not easy. Therefore, nf-core provides an interactive web-based platform for updating and modifying the schema:

```bash
nf-core pipelines schema build
```

The tool outputs a URL that points to a web-based interface where the schema can be edited. Note that this tool can be somewhat buggy and relies on communication with an external service. The nf-core core development team is currently working on a new tool.

An existing schema can be validated with:

```bash
nf-core pipelines schema validate . nextflow_schema.json
```

---

## Exercise 5: Customizing Pipeline Input — Samplesheet Structure

### Objective

Learn how to design and validate sample input CSV files for the pipeline.

---

### 5.1: Design Samplesheet Format

In addition to input parameters, the format of the samplesheet is also validated using a JSON schema. In the template, the schema is already present at `assets/schema_input.json` and defines the columns: `sample`, `fastq_1`, and `fastq_2`.

```json
{
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "https://raw.githubusercontent.com/matbonfanti/pseudoalign/master/assets/schema_input.json",
    "title": "matbonfanti/pseudoalign pipeline - params.input schema",
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
            }
        },
        "required": ["sample", "fastq_1"]
    }
}
```

For our pipeline, we want to modify the schema to add a `strandedness` column that specifies the strandedness of the RNA library for the corresponding FASTQ file:

```json
{
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "https://raw.githubusercontent.com/matbonfanti/pseudoalign/master/assets/schema_input.json",
    "title": "matbonfanti/pseudoalign pipeline - params.input schema",
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
                "meta": ["strandedness"]
            }
        },
        "required": ["sample", "fastq_1", "strandedness"]
    }
}
```

Note the `"meta"` attribute, which allows storing a variable directly in the meta object.

---

### 5.2: Check the Nextflow Code for Samplesheet Validation and Channel Initialization

The samplesheet validation code is in the file `subworkflows/local/utils_nfcore_pseudoalign_pipeline/main.nf`. This file, which is part of the template, contains subworkflows and Groovy functions used for pipeline initialization and completion, as well as functions for printing pipeline documentation. It is meant to be customized (as opposed to utility functions in the `subworkflows/nf-core` folder that should remain unchanged).

The channel initialization for the samplesheet is at lines 87–105:

```groovy
    //
    // Create channel from input file provided through params.input
    //

    channel
        .fromList(samplesheetToList(params.input, "${projectDir}/assets/schema_input.json"))
        .map {
            meta, fastq_1, fastq_2 ->
                if (!fastq_2) {
                    return [ meta.id, meta + [ single_end:true ], [ fastq_1 ] ]
                } else {
                    return [ meta.id, meta + [ single_end:false ], [ fastq_1, fastq_2 ] ]
                }
        }
        .groupTuple()
        .map { samplesheet ->
            validateInputSamplesheet(samplesheet)
        }
        .map {
            meta, fastqs ->
                return [ meta, fastqs.flatten() ]
        }
        .set { ch_samplesheet }
```

Since `strandedness` is processed by the samplesheet parser and stored at this level as an attribute of the meta object, there is no need to change anything in the channel operations.

---

### 5.3: Create Example Samplesheet

Create a template samplesheet in the `assets/` folder for documenting the samplesheet format:

```csv
sample,fastq_1,fastq_2,strandedness
sample1,reads_1_R1.fastq.gz,reads_1_R2.fastq.gz,reverse
sample2,reads_2_R1.fastq.gz,reads_2_R2.fastq.gz,reverse
sample3,reads_3_R1.fastq.gz,,forward
```

---

## Exercise 6: Create a Custom Module

### Objective

Add a module to the pipeline without using an nf-core module installation.

---

### 6.1: Create a New Module to Untar Salmon Index

Currently, the channel initialized with `params.salmon_index` is passed directly to Salmon, which expects a folder with the index. It would be convenient to allow the possibility of passing a tar.gz archive to the pipeline. For example, when running your pipeline and staging non-local files from their URL, the URL must point to a single file; you cannot stage an entire folder.

Instead of using the nf-core module (`nf-core/untar`), we will create a local module from scratch. For local modules, it is not necessary to structure files in the complex way required for nf-core official modules.

Create a folder `modules/local/untar_salmon_index` with a `main.nf` file containing the process code:

```groovy
process UNTAR_SALMON_INDEX {
    tag "${archive}"
    label 'process_single'

    conda "conda-forge::sed=4.7 bioconda::grep=3.4 conda-forge::tar=1.34"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/ubuntu:20.04' :
        'nf-core/ubuntu:20.04' }"

    input:
    path archive

    output:
    path "${prefix}", emit: untar
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    prefix = archive.baseName.toString().replaceFirst(/\.tar$/, "")
    """
    mkdir ${prefix}
    tar \\
        -C ${prefix} --strip-components 1 \\
        -xavf ${args} \\
        ${archive}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        untar: \$(echo \$(tar --version 2>&1) | sed 's/^.*(GNU tar) //; s/ Copyright.*\$//')
    END_VERSIONS
    """

    stub:
    prefix = archive.baseName.toString().replaceFirst(/\.tar$/, "")
    """
    mkdir ${prefix}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        untar: \$(echo \$(tar --version 2>&1) | sed 's/^.*(GNU tar) //; s/ Copyright.*\$//')
    END_VERSIONS
    """
}
```

---

### 6.2: Configure and Integrate the Module in the Workflow

In nf-core pipelines, it is customary to never include `publishDir` directives in module code. This is because such directives are typically pipeline-specific, and the nf-core template is designed to maximize module reusability.

First, add the pipeline-specific configuration in `modules.config`. Add this snippet in the `process` block to prevent the output of the untar operation from being written to the output folder:

```groovy
    withName: 'UNTAR_SALMON_INDEX' {
        publishDir = [
            enabled: false
        ]
    }
```

Now integrate the new process into the pipeline workflow with the following modifications:

```diff
@@ -8,11 +8,10 @@
 include { paramsSummaryMap       } from 'plugin/nf-schema'
 include { paramsSummaryMultiqc   } from '../subworkflows/nf-core/utils_nfcore_pipeline'
 include { softwareVersionsToYAML } from '../subworkflows/nf-core/utils_nfcore_pipeline'
 include { methodsDescriptionText } from '../subworkflows/local/utils_nfcore_pseudoalign_pipeline'
 include { SALMON_QUANT           } from '../modules/nf-core/salmon/quant/main'
+include { UNTAR_SALMON_INDEX     } from '../modules/local/untar_salmon_index/main'

 /*
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     RUN MAIN WORKFLOW
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@@ -38,26 +37,15 @@
     )
     ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect{it[1]})
     ch_versions = ch_versions.mix(FASTQC.out.versions.first())

+    //
+    // MODULE: Untar Salmon Index when needed
+    //
+    if ( params.salmon_index.endsWith('.tar.gz') ) {
+        UNTAR_SALMON_INDEX ( ch_salmon_index )
+        ch_salmon_index_folder = UNTAR_SALMON_INDEX.out.untar
+        ch_versions = ch_versions.mix(UNTAR_SALMON_INDEX.out.versions)
+    } else {
+        ch_salmon_index_folder = ch_salmon_index
+    }
+
     //
     // MODULE: Run Salmon Quant
     //
     SALMON_QUANT (
         ch_samplesheet,
-        ch_salmon_index,
+        ch_salmon_index_folder,
         ch_gtf,
         ch_fasta,
         "",
         ""
     )
```

---

## Exercise 7: Define a Test Run for the Pipeline

### Objective

Set up and execute a test run of the pipeline to verify functionality.

---

### 7.1: Define and Launch a Test Run of the Pipeline

For running a test, we can reuse the input from the previous section of the training ("Configuring and Launching nf-core Pipelines").

Create a folder named `/workspaces/nextflow-zero2hero/practicals/day4/1-nf-core-introduction/rnaseq_test_02`:

```bash
mkdir -p ../rnaseq_test_02
cd ../rnaseq_test_02
```

Then create `samplesheet.csv`, `params.yaml`, and `custom.config`:

```csv
sample,fastq_1,fastq_2,strandedness
SRR6357070_2,https://raw.githubusercontent.com/nf-core/test-datasets/rnaseq/testdata/GSE110004/SRR6357070_1.fastq.gz,https://raw.githubusercontent.com/nf-core/test-datasets/rnaseq/testdata/GSE110004/SRR6357070_2.fastq.gz,reverse
SRR6357071_2,https://raw.githubusercontent.com/nf-core/test-datasets/rnaseq/testdata/GSE110004/SRR6357071_1.fastq.gz,https://raw.githubusercontent.com/nf-core/test-datasets/rnaseq/testdata/GSE110004/SRR6357071_2.fastq.gz,reverse
```

```yaml
# Input/Output
input: './samplesheet.csv'
outdir: './results'

# Genome references
gtf: 'https://raw.githubusercontent.com/nf-core/test-datasets/rnaseq/reference/genes.gtf.gz'
transcript_fasta: 'https://raw.githubusercontent.com/nf-core/test-datasets/rnaseq/reference/transcriptome.fasta'
salmon_index: 'https://raw.githubusercontent.com/nf-core/test-datasets/rnaseq/reference/salmon.tar.gz'
```

```groovy
// Custom nf-core/rnaseq configuration

process {
    resourceLimits = [
        cpus: 1,
        memory: '4.GB',
        time: '1.h'
    ]
}
```

Run the pipeline with the command:

```bash
nextflow run ../*-pseudoalign -profile docker -params-file params.yaml -c custom.config -w ./work_test
```

---

## Exercise 8: Code Linting and Testing with nf-test

### Objective

Learn how to validate pipeline code quality and write automated tests.

---

### 8.1: Run nf-core Lint

Go back to the pipeline folder:

```bash
cd ../*-pseudoalign
```

Check pipeline compliance with nf-core standards:

```bash
nf-core pipelines lint
```

The tool runs a number of named tests that span most of the nf-core guidelines, including:
- Inconsistencies with the pipeline template
- Incorrect module code and format
- Schema validation issues
- Incorrect MultiQC configuration
- And more

---

### 8.2: Create Test Profile

The nf-core template includes a profile where the pipeline developer can design a short test run to verify pipeline functionality and ensure that changes do not break the pipeline.

We will now use the quick test that we just ran and include it in the test profile.

First, copy the test samplesheet into the assets folder:

```bash
cp ../rnaseq_test_02/samplesheet.csv assets/test_samplesheet.csv
```

Next, customize the `conf/test.config` file, which contains the profile definition with the parameters and configuration needed to run the test:

```groovy
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Nextflow config file for running minimal tests
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Defines input files and everything required to run a fast and simple pipeline test.

    Use as follows:..
        nextflow run .../pseudoalign -profile test,<docker/singularity> --outdir <OUTDIR>

----------------------------------------------------------------------------------------
*/

process {
    resourceLimits = [
        cpus: 1,
        memory: '4.GB',
        time: '1.h'
    ]
}

params {
    config_profile_name        = 'Test profile'
    config_profile_description = 'Minimal test dataset to check pipeline function'

    // Input data
    input = "${projectDir}/assets/test_samplesheet.csv"
    gtf = 'https://raw.githubusercontent.com/nf-core/test-datasets/rnaseq/reference/genes.gtf.gz'
    transcript_fasta = 'https://raw.githubusercontent.com/nf-core/test-datasets/rnaseq/reference/transcriptome.fasta'
    salmon_index = 'https://raw.githubusercontent.com/nf-core/test-datasets/rnaseq/reference/salmon.tar.gz'
}
```

You can now run the test using the additional profile:

```bash
cd ../rnaseq_test_02
nextflow run ../*-pseudoalign -profile docker,test --outdir output -w ./work_test -resume
```

---

### 8.3: Run nf-test

Nextflow has a testing suite called nf-test that allows advanced checks on pipeline runs, ensuring that the pipeline test runs remain consistent at many levels (run execution success, number and paths of output files, checksums of output files). Setting up nf-test can be complicated, but the pipeline template is already configured with a default nf-test corresponding to the test profile.

However, there is a challenge: Salmon does not produce deterministic results, so a test that requires consistent checksums for its output is destined to fail.

To address this, configure nf-test to ignore the checksums of files dependent on Salmon quantification. Add these lines to `tests/.nftignore`:

```
multiqc/multiqc_data/multiqc_salmon.txt
multiqc/multiqc_data/salmon_plot.txt
salmon/*/aux_info/fld.gz
salmon/*/aux_info/meta_info.json
salmon/*/libParams/flenDist.txt
salmon/*/logs/salmon_quant.log
salmon/*/quant.genes.sf
salmon/*/quant.sf
salmon/salmon.*
salmon/*meta_info.json
```

Run the test with this command to create a snapshot of the output:

```bash
cd ../*-pseudoalign
nf-test test tests/default.nf.test --profile +docker --verbose --update-snapshot
```

The arguments are:
- `--profile +docker` — Use the Docker profile in addition to the default profile
- `--verbose` — Print detailed output
- `--update-snapshot` — Create or update snapshot files for comparison in future test runs

---

## Exercise 9: Version Control and Pushing to GitHub

### Objective

Prepare the pipeline for publication and continuous integration.

---

### 9.1: Commit Changes

The pipeline template comes initialized as a git repository. You can now commit all the changes made so far in an initial commit.

Check which files should be added (and which files should not):

```bash
git status
```

Create a new commit:

```bash
git commit
```

If the pre-commit hooks detect any formatting issues, the files will be automatically fixed. Add the changes and redo the commit.

---

### 9.2: Set Up GitHub Repository

Create a new repository on GitHub:

1. Go to https://github.com/new
2. Name it: `pseudoalign`
3. Add a description
4. Choose public or private visibility
5. Create the repository

Connect the local repository to GitHub:

```bash
git remote add origin https://github.com/<YOUR-GITHUB-ID>/pseudoalign.git
git branch -M master
git push -u origin master
git push -u origin dev
git push -u origin TEMPLATE
```

### 9.3: Close GitHub codespace


When you've completed your work, close the codespace to conserve your free account budget. GitHub provides a limited number of free codespace hours monthly.

**Stop the codespace:**

1. Go to https://github.com/codespaces
2. Find your codespace in the list
3. Click the three dots (**...**) menu next to it
4. Select **Stop codespace**

**Delete the codespace (optional):**

If you won't need it again, delete it to free up storage:

1. On https://github.com/codespaces, click the three dots menu
2. Select **Delete**

**Restart later:**

You can resume a stopped codespace at any time from the same page. Your work will be preserved.


---

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
- [ ] Set up version control and push to GitHub

---

## Resources

- **nf-core website**: https://nf-co.re/
- **nf-core tools documentation**: https://nf-co.re/tools
- **Nextflow documentation**: https://www.nextflow.io/docs/latest/
- **nf-test documentation**: https://www.nf-test.com/

