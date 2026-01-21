# Day 3 - Advanced publish

## Introduction

`publishDir` is a process directive in Nextflow that allows you to copy or move output files from the temporary working directory to a permanent storage location. This is essential for:

- **Persisting important results** beyond pipeline execution
- **Organizing outputs** into logical directory structures
- **Sharing results** with other researchers or systems
- **Optimizing storage** by deciding what to keep and what to discard


### Main Parameters

| Parameter | Description | Values | Default |
|-----------|-------------|--------|---------|
| `path` | Destination directory | String or Closure | *required* |
| `mode` | Publication method | `'copy'`, `'copyNoFollow'`, `'link'`, `'symlink'`, `'rellink'`, `'move'` | `'symlink'` |
| `pattern` | File filter | glob pattern | `null` (all) |
| `overwrite` | Overwrite existing files | `true`, `false`, `'deep'` | `true` |
| `saveAs` | Rename/filter files | Closure | `null` |
| `enabled` | Enable/disable | `true`, `false` | `true` |
| `failOnError` | Fail on error | `true`, `false` | `false` |
| `tags` | Metadata tags | Map | `null` |

### Publication Modes

- **`symlink`** (default): Creates symbolic links (space efficient)
- **`rellink`**: Relative symbolic links (portability)
- **`link`**: Hard links (same filesystem only)
- **`copy`**: Real file copy (safe, consumes space)
- **`copyNoFollow`**: Copy without following symlinks
- **`move`**: Moves files (frees working space)



## Practical


```groovy
process FASTP {
    input:
    tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2)
    
    output:
    tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz"), path("${fastq_R2_basename}-${fastq_set_id}-qced.fastq.gz"), emit: qced_reads
    tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}_fastp.json"), path("${fastq_R1_basename}-${fastq_set_id}_fastp.html"), emit: fastp_reports
    tuple val("${task.process}"), val('fastp'), eval('fastp --version | head -n 1 | cut -d" " -f2'), topic: versions
    
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

**Module Outputs:**
- 2 FASTQ files (processed reads)
- 1 JSON file (metrics)
- 1 HTML file (visual report)

---

### Exercise 1: Basic Publication with Multiple Directories

**Objective**: Separate different output types into specific directories.

**Task**: Modify the FASTP process so that:
- Processed FASTQ files go to `results/processed_reads/`
- JSON reports go to `results/qc_reports/json/`
- HTML reports go to `results/qc_reports/html/`

**Hint**: You will need multiple `publishDir` directives.

<details>
<summary>View solution</summary>

```groovy
process FASTP {
    publishDir "${params.outdir}/processed_reads", mode: 'copy', pattern: '*-qced.fastq.gz'
    publishDir "${params.outdir}/qc_reports/json", mode: 'copy', pattern: '*.json'
    publishDir "${params.outdir}/qc_reports/html", mode: 'copy', pattern: '*.html'
    
    input:
    tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2)
    
    output:
    tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz"), path("${fastq_R2_basename}-${fastq_set_id}-qced.fastq.gz"), emit: qced_reads
    tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}_fastp.json"), path("${fastq_R1_basename}-${fastq_set_id}_fastp.html"), emit: fastp_reports
    tuple val("${task.process}"), val('fastp'), eval('fastp --version | head -n 1 | cut -d" " -f2'), topic: versions
    
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

</details>

---

### Exercise 2: Organization by Sample_ID using Closures

**Objective**: Create dynamic subdirectories based on `sample_id`.

**Task**: Modify the previous exercise so that the structure is:
```
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

**Hint**: Use closures in the `path` parameter that include the `sample_id` variable.

<details>
<summary>View solution</summary>

```groovy
process FASTP {
    publishDir { "${params.outdir}/processed_reads/${sample_id}" }, mode: 'copy', pattern: '*-qced.fastq.gz'
    publishDir { "${params.outdir}/qc_reports/${sample_id}" }, mode: 'copy', pattern: '*.json'
    publishDir { "${params.outdir}/qc_reports/${sample_id}" }, mode: 'copy', pattern: '*.html'
    
    input:
    tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2)
    
    output:
    tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz"), path("${fastq_R2_basename}-${fastq_set_id}-qced.fastq.gz"), emit: qced_reads
    tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}_fastp.json"), path("${fastq_R1_basename}-${fastq_set_id}_fastp.html"), emit: fastp_reports
    tuple val("${task.process}"), val('fastp'), eval('fastp --version | head -n 1 | cut -d" " -f2'), topic: versions
    
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

</details>

---

### Exercise 3: Advanced Renaming with saveAs

**Objective**: Simplify and standardize published file names.

**Task**: Use `saveAs` to rename files as follows:
- `*-qced.fastq.gz` → `{sample_id}_{R1/R2}.fastq.gz`
- `*_fastp.json` → `{sample_id}_qc_report.json`
- `*_fastp.html` → `{sample_id}_qc_report.html`

**Hint**: `saveAs` receives the original filename and must return the new name (or `null` to skip publishing).

<details>
<summary>View solution</summary>

```groovy
process FASTP {
    publishDir "${params.outdir}/processed_reads/${sample_id}", mode: 'copy', 
        pattern: '*-qced.fastq.gz',
        saveAs: { filename ->
            if (filename.contains('R1')) return "${sample_id}_R1.fastq.gz"
            else if (filename.contains('R2')) return "${sample_id}_R2.fastq.gz"
            else return filename
        }
    
    publishDir "${params.outdir}/qc_reports/${sample_id}", mode: 'copy',
        pattern: '*.json',
        saveAs: { filename -> "${sample_id}_qc_report.json" }
    
    publishDir "${params.outdir}/qc_reports/${sample_id}", mode: 'copy',
        pattern: '*.html',
        saveAs: { filename -> "${sample_id}_qc_report.html" }
    
    input:
    tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2)
    
    output:
    tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz"), path("${fastq_R2_basename}-${fastq_set_id}-qced.fastq.gz"), emit: qced_reads
    tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}_fastp.json"), path("${fastq_R1_basename}-${fastq_set_id}_fastp.html"), emit: fastp_reports
    tuple val("${task.process}"), val('fastp'), eval('fastp --version | head -n 1 | cut -d" " -f2'), topic: versions
    
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

</details>

---

### Exercise 4: Conditional Publishing with enabled

**Objective**: Control which files are published based on pipeline parameters.

**Task**: Implement the following logic:
- Processed reads are published only if `params.save_processed_reads == true`
- HTML reports are published only if `params.generate_html_reports == true`
- JSON reports are always published

**Hint**: Use the `enabled` parameter in each `publishDir`.

<details>
<summary>View solution</summary>

```groovy
process FASTP {
    publishDir "${params.outdir}/processed_reads/${sample_id}", 
        mode: 'copy', 
        pattern: '*-qced.fastq.gz',
        enabled: params.save_processed_reads
    
    publishDir "${params.outdir}/qc_reports/${sample_id}", 
        mode: 'copy',
        pattern: '*.json',
        enabled: true  // Siempre publicar
    
    publishDir "${params.outdir}/qc_reports/${sample_id}", 
        mode: 'copy',
        pattern: '*.html',
        enabled: params.generate_html_reports
    
    input:
    tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2)
    
    output:
    tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz"), path("${fastq_R2_basename}-${fastq_set_id}-qced.fastq.gz"), emit: qced_reads
    tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}_fastp.json"), path("${fastq_R1_basename}-${fastq_set_id}_fastp.html"), emit: fastp_reports
    tuple val("${task.process}"), val('fastp'), eval('fastp --version | head -n 1 | cut -d" " -f2'), topic: versions
    
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

**Note**: You will need to define these parameters in your main script or `nextflow.config`:
```groovy
params.save_processed_reads = false
params.generate_html_reports = true
```

</details>

---

### Exercise 5: Combining Modes and Storage Strategies

**Objective**: Optimize storage usage using different publication modes.

**Task**: Configure the process to:
- **Processed FASTQ**: Use `symlink` (large files, temporary reference)
- **JSON**: Use `copy` (small files, critical persistence)
- **HTML**: Use `move` (small files, free working space)

**Plus**: Add `failOnError: false` to HTML reports in case of permission issues.

<details>
<summary>View solution</summary>

```groovy
process FASTP {
    publishDir "${params.outdir}/processed_reads/${sample_id}", 
        mode: 'symlink',  // Eficiente para archivos grandes
        pattern: '*-qced.fastq.gz'
    
    publishDir "${params.outdir}/qc_reports/${sample_id}", 
        mode: 'copy',  // Copia segura para datos críticos
        pattern: '*.json'
    
    publishDir "${params.outdir}/qc_reports/${sample_id}", 
        mode: 'move',  // Libera espacio de work/
        pattern: '*.html',
        failOnError: false  // No fallar si hay problemas de permisos
    
    input:
    tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2)
    
    output:
    tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz"), path("${fastq_R2_basename}-${fastq_set_id}-qced.fastq.gz"), emit: qced_reads
    tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}_fastp.json"), path("${fastq_R1_basename}-${fastq_set_id}_fastp.html"), emit: fastp_reports
    tuple val("${task.process}"), val('fastp'), eval('fastp --version | head -n 1 | cut -d" " -f2'), topic: versions
    
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

**Space usage comparison**:
- `symlink`: ~0 MB additional (links only)
- `copy`: ~100% of original size
- `move`: ~0 MB additional (moves without copying)

</details>

---

### Exercise 6: Complete Advanced Configuration (Challenge)

**Objective**: Combine all concepts into a professional solution.

**Task**: Implement a complete system that:
1. Organizes files by `sample_id` in subdirectories
2. Renames files to standard format
3. Only publishes reads if `params.save_reads == true`
4. Uses `symlink` for reads, `copy` for reports
5. Adds date suffix to HTML reports: `{sample_id}_report_{date}.html`
6. Does not publish JSON files if they contain errors (use `saveAs` to filter)
7. Uses `tags` to add metadata: `type` and `sample_id`

**Hints**:
- Use `new Date().format('yyyyMMdd')` for the date
- In `saveAs`, return `null` to skip publishing a file
- `tags` accepts a Map with metadata

<details>
<summary>View solution</summary>

```groovy
process FASTP {
    publishDir "${params.outdir}/processed_reads/${sample_id}", 
        mode: 'symlink',
        pattern: '*-qced.fastq.gz',
        enabled: params.save_reads,
        saveAs: { filename ->
            if (filename.contains(fastq_R1.baseName)) return "${sample_id}_R1.fastq.gz"
            else if (filename.contains(fastq_R2.baseName)) return "${sample_id}_R2.fastq.gz"
            else return filename
        },
        tags: [type: 'processed_reads', sample_id: sample_id]
    
    publishDir "${params.outdir}/qc_reports/${sample_id}", 
        mode: 'copy',
        pattern: '*.json',
        saveAs: { filename ->
            // Solo publicar si el archivo no está vacío (> 100 bytes)
            def file = new File(filename)
            return file.size() > 100 ? "${sample_id}_qc_metrics.json" : null
        },
        tags: [type: 'qc_metrics', sample_id: sample_id]
    
    publishDir "${params.outdir}/qc_reports/${sample_id}", 
        mode: 'copy',
        pattern: '*.html',
        saveAs: { filename ->
            def date = new Date().format('yyyyMMdd')
            return "${sample_id}_report_${date}.html"
        },
        tags: [type: 'qc_report', sample_id: sample_id]
    
    input:
    tuple val(sample_id), val(fastq_set_id), path(fastq_R1), path(fastq_R2)
    
    output:
    tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}-qced.fastq.gz"), path("${fastq_R2_basename}-${fastq_set_id}-qced.fastq.gz"), emit: qced_reads
    tuple val(sample_id), val(fastq_set_id), path("${fastq_R1_basename}-${fastq_set_id}_fastp.json"), path("${fastq_R1_basename}-${fastq_set_id}_fastp.html"), emit: fastp_reports
    tuple val("${task.process}"), val('fastp'), eval('fastp --version | head -n 1 | cut -d" " -f2'), topic: versions
    
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

**Required configuration** (`nextflow.config` or params):
```groovy
params {
    outdir = './results'
    save_reads = false
}
```

</details>
