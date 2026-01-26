# Day 3 – Section 2 – Advanced publish

## Introduction

`publishDir` is a process directive that allows you to copy or move output files from the temporary working directory to a permanent storage location. It is essential for **persisting important results** beyond pipeline execution and for **optimizing storage** usage by controlling which outputs are retained or discarded. This directive also lets you define **how and where results are stored**, enabling better organization of outputs into clear and logical directory structures.

Below are the key points to keep in mind when using `publishDir`. For more detailed information, you can refer to the official documentation for [the `publishDir` directive](https://www.nextflow.io/docs/latest/reference/process.html#publishdir).

- Only the files explicitly declared in the `output` block are published; not all files produced by the process are automatically exported.
- By default, files are published in `symlink mode`, meaning that what is published is actually a symbolic link to the original file in the working directory.
- The `publishDir` directive can be defined **multiple times** to route different output files to different target directories, each according to its own set of rules.
- Files are copied to the publish directory **asynchronously**, meaning they may not be immediately available when the process finishes. For this reason, downstream processes should not access results via the publish directory, but instead consume the outputs emitted by the originating process.

## Practical

During this practical session you will run the process FASTP multiple times, changing the way its outputs are published. In our process, the fastp software generates **2 FASTQ** files (defined by the parameters `-o` and `-O`), a **JSON** file (`--json`) and a **HTML** file (`--html`).

```groovy
process FASTP {
    input:
    tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2)
    
    output:
    tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz"), path("${fastq_R2_basename}-${fastq_set_id}-qced.fastq.gz")
    tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}_fastp.json"), path("${fastq_R1_basename}-${fastq_set_id}_fastp.html")
    
    script:
    fastq_R1_basename = fastq_R1.baseName.replace('.fastq', '')
    fastq_R2_basename = fastq_R2.baseName.replace('.fastq', '')
    """
    fastp \
        -i ${fastq_R1} -o ${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz \
        -I ${fastq_R2} -O ${fastq_R2_basename}-${fastq_set_id}-qced.fastq.gz \
        --json ${fastq_R1_basename}-${fastq_set_id}_fastp.json \
        --html ${fastq_R1_basename}-${fastq_set_id}_fastp.html \
        --thread ${task.cpus}
    """
}
```

### Configuration

Before you start, create an interactive session with the required resources and dependencies:

```bash
# get an interactive session
$ srun --wait=0 --pty -p cpu-interactive -c 1 --mem 4G -J nxf_training /bin/bash

# load the dependencies
$ module load singularity nextflow/25.04.3
```

If you followed our suggestion, you should already have a `practicals_output` folder for running the exercises. Create a dedicated subdirectory for this practical and move into it:

```bash
# set <practicals_outputs> as the path where you created your workspace
$ mkdir -p practicals_outputs/day3/2-advanced_publish
$ cd practicals_outputs/day3/2-advanced_publish
```

You will do 6 different exercises during this practical. For each of them, create a dedicated directory and copy the *nextflow.config* for this session from the reference materials.

```bash
# example for exercise 1, repeat this for the rest of exercises!
$ mkdir exercise_1
$ cd exercise_1
$ cp nextflow_zero2hero_practicals/nextflow-zero2hero/practicals/day3/2-advanced_publish/* .
```

For each exercise, modify the FASTP process in *main.nf* with `publishDir` to accomplish the objective, then execute the pipeline by doing:

```bash
# in the exercise folder, ie. exercise_1
$ nextflow run .
```

Use the parameter `outdir` (`params.outdir`) as the root directory for publishing your files. Unless otherwise specified, use the `copy` mode in the exercise. 

### Exercise 1: Basic Publication with Multiple Directories

**Objective**: Separate different output types into specific directories. After this, determine which file each of the published files (symlinks) points to.

**Task**: Modify the FASTP process so that:

- Processed FASTQ files go to `results/processed_reads/`
- JSON reports go to `results/qc_reports/json/`
- HTML reports go to `results/qc_reports/html/`

**Hint**: You will need multiple `publishDir` directives.

??? example "View solution"

    ```
    
        process FASTP {
            publishDir "${params.outdir}/processed_reads", pattern: '*-qced.fastq.gz'
            publishDir "${params.outdir}/qc_reports/json", pattern: '*.json'
            publishDir "${params.outdir}/qc_reports/html", pattern: '*.html'
            
            input:
            tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2)
            
            output:
            tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz"), path("${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz")
            tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}_fastp.json"), path("${fastq_R1_basename}-${fastq_set_id}_fastp.html")
            
            script:
            fastq_R1_basename = fastq_R1.baseName.replace('.fastq', '')
            fastq_R2_basename = fastq_R2.baseName.replace('.fastq', '')
            """
            fastp \
                -i ${fastq_R1} -o ${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz \
                -I ${fastq_R2} -O ${fastq_R2_basename}-${fastq_set_id}-qced.fastq.gz \
                --json ${fastq_R1_basename}-${fastq_set_id}_fastp.json \
                --html ${fastq_R1_basename}-${fastq_set_id}_fastp.html \
                --thread ${task.cpus}
            """
        }

    ```

### Exercise 2: Organization by Sample_ID

**Objective**: Create dynamic subdirectories based on `sample_id`.

**Task**: Modify the previous exercise so that the structure is:

```text
results/
  ├── processed_reads/
  │   ├── sample_A/
  │   │   └── [fastq files]
  │   └── sample_B/
  │       └── [fastq files]
  └── qc_reports/
      ├── sample_A/
      │   ├── [json files]
      │   └── [html files]
      └── sample_B/
          ├── [json files]
          └── [html files]
```

**Hint**: Use the `sample_id` variable in `path`

??? example "View solution"

    ```

        process FASTP {
            publishDir "${params.outdir}/processed_reads/${sample_id}", pattern: '*-qced.fastq.gz'
            publishDir "${params.outdir}/qc_reports/${sample_id}", pattern: '*.json'
            publishDir "${params.outdir}/qc_reports/${sample_id}", pattern: '*.html'
            
            input:
            tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2)
            
            output:
            tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz"), path("${fastq_R2_basename}-${fastq_set_id}-qced.fastq.gz")
            tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}_fastp.json"), path("${fastq_R1_basename}-${fastq_set_id}_fastp.html")
            
            
            script:
            fastq_R1_basename = fastq_R1.baseName.replace('.fastq', '')
            fastq_R2_basename = fastq_R2.baseName.replace('.fastq', '')
            """
            fastp \
                -i ${fastq_R1} -o ${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz \
                -I ${fastq_R2} -O ${fastq_R2_basename}-${fastq_set_id}-qced.fastq.gz \
                --json ${fastq_R1_basename}-${fastq_set_id}_fastp.json \
                --html ${fastq_R1_basename}-${fastq_set_id}_fastp.html \
                --thread ${task.cpus}
            """
        }

    ```

### Exercise 3: Advanced Renaming with `saveAs`

**Objective**: Simplify and standardize published file names. Keep the directories structure from the previous exercise.

**Task**: Use `saveAs` to rename files as follows:

- `*-qced.fastq.gz` → `{sample_id}_{R1/R2}.fastq.gz`
- `*_fastp.json` → `{sample_id}_qc_report.json`
- `*_fastp.html` → `{sample_id}_qc_report.html`

**Hint**: `saveAs` receives the original filename and must return the new name (or `null` to skip publishing).

??? example "View solution"

    ```

        process FASTP {
            publishDir "${params.outdir}/processed_reads/${sample_id}", 
                pattern: '*-qced.fastq.gz',
                saveAs: { filename ->
                    if (filename.contains('R1')) return "${sample_id}_R1.fastq.gz"
                    else if (filename.contains('R2')) return "${sample_id}_R2.fastq.gz"
                    else return filename
                }
            
            publishDir "${params.outdir}/qc_reports/${sample_id}", 
                pattern: '*.json',
                saveAs: { filename -> "${sample_id}_qc_report.json" }
            
            publishDir "${params.outdir}/qc_reports/${sample_id}", 
                pattern: '*.html',
                saveAs: { filename -> "${sample_id}_qc_report.html" }
            
            input:
            tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2)
            
            output:
            tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz"), path("${fastq_R2_basename}-${fastq_set_id}-qced.fastq.gz")
            tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}_fastp.json"), path("${fastq_R1_basename}-${fastq_set_id}_fastp.html")
            
            script:
            fastq_R1_basename = fastq_R1.baseName.replace('.fastq', '')
            fastq_R2_basename = fastq_R2.baseName.replace('.fastq', '')
            """
            fastp \
                -i ${fastq_R1} -o ${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz \
                -I ${fastq_R2} -O ${fastq_R2_basename}-${fastq_set_id}-qced.fastq.gz \
                --json ${fastq_R1_basename}-${fastq_set_id}_fastp.json \
                --html ${fastq_R1_basename}-${fastq_set_id}_fastp.html \
                --thread ${task.cpus}
            """
        }

    ```

### Exercise 4: Conditional Publishing with `enabled`

**Objective**: Control with which files are published based on pipeline parameters. Keep the directories structure from Exercise 2.

**Task**: Modify the parameters `save_reads`, `save_html` and `save_json` in *nextflow.config* to implement the following logic:

- Processed reads are published
- HTML reports are published
- JSON reports are not published

**Hint**: Use the `enabled` parameter in each `publishDir`.

??? example "View solution"

    ```

        process FASTP {
            publishDir "${params.outdir}/processed_reads/${sample_id}", 
                pattern: '*-qced.fastq.gz',
                enabled: params.save_reads
            
            publishDir "${params.outdir}/qc_reports/${sample_id}", 
                pattern: '*.json',
                enabled: params.save_json 
            
            publishDir "${params.outdir}/qc_reports/${sample_id}", 
                pattern: '*.html',
                enabled: params.save_html
            
            input:
            tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2)
            
            output:
            tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz"), path("${fastq_R2_basename}-${fastq_set_id}-qced.fastq.gz")
            tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}_fastp.json"), path("${fastq_R1_basename}-${fastq_set_id}_fastp.html")
            
            script:
            fastq_R1_basename = fastq_R1.baseName.replace('.fastq', '')
            fastq_R2_basename = fastq_R2.baseName.replace('.fastq', '')
            """
            fastp \
                -i ${fastq_R1} -o ${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz \
                -I ${fastq_R2} -O ${fastq_R2_basename}-${fastq_set_id}-qced.fastq.gz \
                --json ${fastq_R1_basename}-${fastq_set_id}_fastp.json \
                --html ${fastq_R1_basename}-${fastq_set_id}_fastp.html \
                --thread ${task.cpus}
            """
        }

    ```

### Exercise 5: Combining Modes and Storage Strategies

**Objective**: Optimize storage usage using different publication modes. Keep the directories structure from Exercise 2.

**Task**: Configure the process to:

- **Processed FASTQ**: Use `symlink` (large files, temporary reference)
- **JSON**: Use `copy` (small files, critical persistence)
- **HTML**: Use `move` (small files, free working space)

**Plus**: Add `failOnError: false` to HTML reports in case of permission issues.

??? example "View solution"

    ```

        process FASTP {
            publishDir "${params.outdir}/processed_reads/${sample_id}", 
                mode: 'symlink',  
                pattern: '*-qced.fastq.gz'
            
            publishDir "${params.outdir}/qc_reports/${sample_id}", 
                mode: 'copy',  
                pattern: '*.json'
            
            publishDir "${params.outdir}/qc_reports/${sample_id}", 
                mode: 'move',  
                pattern: '*.html',
                failOnError: false  
            
            input:
            tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2)
            
            output:
            tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz"), path("${fastq_R2_basename}-${fastq_set_id}-qced.fastq.gz")
            tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}_fastp.json"), path("${fastq_R1_basename}-${fastq_set_id}_fastp.html")
            
            
            script:
            fastq_R1_basename = fastq_R1.baseName.replace('.fastq', '')
            fastq_R2_basename = fastq_R2.baseName.replace('.fastq', '')
            """
            fastp \
                -i ${fastq_R1} -o ${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz \
                -I ${fastq_R2} -O ${fastq_R2_basename}-${fastq_set_id}-qced.fastq.gz \
                --json ${fastq_R1_basename}-${fastq_set_id}_fastp.json \
                --html ${fastq_R1_basename}-${fastq_set_id}_fastp.html \
                --thread ${task.cpus}
            """
        }

    ```

### Exercise 6: Adding Date Suffix 

**Objective**: Learn to use Groovy's date formatting to add timestamps to published files.

**Task**: Implement a `publishDir` configuration that renames HTML files to include a date suffix like `{sample_id}_report_{date}.html` (example, *sample1_report_20260128.html*)

**Hints**:

- In `saveAs`, use `new Date().format('yyyyMMdd')` to generate the date string.

??? example "View solution"

    ```

        process FASTP {
            publishDir "${params.outdir}/processed_reads/${sample_id}", pattern: '*-qced.fastq.gz'
            publishDir "${params.outdir}/qc_reports/${sample_id}", pattern: '*.json'
            publishDir "${params.outdir}/qc_reports/${sample_id}", 
                pattern: '*.html',
                saveAs: { filename ->
                    def date = new Date().format('yyyyMMdd')
                    return "${sample_id}_report_${date}.html"
                }
            
            input:
            tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2)
            
            output:
            tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz"), path("${fastq_R2_basename}-${fastq_set_id}-qced.fastq.gz")
            tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}_fastp.json"), path("${fastq_R1_basename}-${fastq_set_id}_fastp.html")
            
            
            script:
            fastq_R1_basename = fastq_R1.baseName.replace('.fastq', '')
            fastq_R2_basename = fastq_R2.baseName.replace('.fastq', '')
            """
            fastp \
                -i ${fastq_R1} -o ${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz \
                -I ${fastq_R2} -O ${fastq_R2_basename}-${fastq_set_id}-qced.fastq.gz \
                --json ${fastq_R1_basename}-${fastq_set_id}_fastp.json \
                --html ${fastq_R1_basename}-${fastq_set_id}_fastp.html \
                --thread ${task.cpus}
            """
        }

    ```
