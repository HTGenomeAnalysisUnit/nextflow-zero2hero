# Advanced scripting inside a Nextflow process

**Groovy vs Bash — theory with practice**

This practical focuses on **Groovy scripting inside a single Nextflow process**.

You will start from a **minimal working pipeline** and progressively extend the *same process*, learning **how Groovy is evaluated inside `script:` blocks** and how it differs from **Bash execution at runtime**.

The key idea to keep in mind throughout the exercises is:

> Inside a Nextflow process you are always writing **two languages**.

---

## Mental model — two phases, two languages

A Nextflow process is evaluated in **two distinct phases**.

### Phase 1 — Groovy (pipeline construction)

Before any task is executed, Nextflow evaluates the process definition using **Groovy**.

During this phase:

* `script:` blocks are parsed
* Groovy variables are resolved
* Closures are executed
* File object properties are accessed
* `task.cpus` and `task.memory` are known

Anything written as:

```nextflow
${variable}
```

inside a triple-quoted string is **expanded by Groovy before execution**.

By the time the task runs, Groovy variables no longer exist only their *values* remain.

---

### Phase 2 — Bash (task runtime)

After Groovy evaluation, Nextflow launches the task using the system shell (usually Bash).

During this phase:

* The command is executed line by line
* Shell variables are expanded
* Environment variables become available
* Files are created and modified

Variables such as:

```bash
$HOME
$PATH
$PWD
```

are **expanded by Bash at runtime**, not by Groovy.

To prevent Groovy from expanding a Bash variable, it must be escaped:

```bash
\$HOME
```

Keep this boundary in mind while working through the exercises below.

---

# Exercise 1 — Safe sample names and variable scope

Modify the process so that:

* Each input file produces a distinct output file

* The output filename is derived safely from the input

* Variables inside script: are declared correctly using Groovy


The initial pipeline always writes:

```bash
result.txt
```

Because the process runs once per input file, outputs overwrite each other.

## Step 1 — Introduce a sample-specific variable (Groovy)

Inside the script: block, define a variable derived from the input file:

```bash

script:
def sample = read.simpleName


```

### Choosing the right file property

Given the input file:

```text
sample1_R1.fastq.gz
````

Nextflow exposes several file properties that behave differently.

* **`read.name`** — keeps all extensions
  *(e.g.)*

  ```text
  sample1_R1.fastq.gz
  ```

* **`read.baseName`** — removes only the **last** extension
  *(e.g.)*

  ```text
  sample1_R1.fastq
  ```

* **`read.simpleName`** — removes **all** extensions
  *(e.g.)*

  ```text
  sample1_R1
  ```

Because output filenames should usually be **extension-free and stable**,
`read.simpleName` is the safest default when deriving sample names for outputs.



## Step 2 — Use the variable in the command

Replace the command with:

```bash
echo "Processing file: ${read.name}" > ${sample}.txt
```

Note that:

* ${sample} is expanded by Groovy

* sample does not exist at runtime

## Step 3 — Fix the output declaration

Because the filename is now dynamic, update the output: block:

```bash
output:
path "*.txt"
```

Expected solution

```bash
process PROCESS_READ {

    publishDir "./results", mode: 'copy'

    input:
    path read

    output:
    path "*.txt"

    script:
    def sample = read.simpleName
    """
    echo "Processing file: ${read.name}" > ${sample}.txt
    """
}
```

## Questions?

* Why must sample be declared with def?

* Why is simpleName preferable to name and baseName here?

* Why would > $sample.txt not work?

* At which phase is ${sample} expanded?
















