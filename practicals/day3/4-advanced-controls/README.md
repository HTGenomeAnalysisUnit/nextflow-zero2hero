# Exercises – Advanced scripting inside Nextflow process blocks

These exercises focus on **Groovy scripting inside Nextflow processes**, which is often the most confusing part for beginners.

You will learn:

* How to define variables inside `script:` blocks.
* The difference between `def var` and `var`.
* How to use file properties such as `baseName`, `simpleName`, `name`.
* How to use closures and ternary logic for conditional behavior.

---

# Exercise 8 – Variables inside the `script` block

Consider this process:

```nextflow
process EXAMPLE_VAR {

    input:
    path read

    output:
    path "*.txt"

    script:
    def prefix = read.baseName
    suffix = "_processed"

    """
    echo "${prefix}${suffix}" > ${prefix}.txt
    """
}
```

---

## Questions

1. What is the difference between `def prefix` and `suffix`?
2. Why does this still work?

---

## Explanation

### `def prefix`

Declares a **local Groovy variable** scoped only to the script block.

### `suffix` (without def)

Becomes a **Groovy binding variable**, which can:

* Leak into the script context.
* Be overridden by environment or Nextflow internals.
* Cause unpredictable behavior in larger pipelines.

---

## Rule of thumb

Always declare variables explicitly:

```nextflow
def myVar = "value"
```

Never rely on implicit variables.

---

## Task

Modify the script so that both variables are declared safely.

---

# Exercise 9 – File object properties

Given this input:

```nextflow
path read
```

If the file is:

```text
sample1_R1.fastq.gz
```

Test the following:

```nextflow
def fullName   = read.name
def baseName   = read.baseName
def simpleName = read.simpleName
```

---

## Expected values

| Property          | Value               |
| ----------------- | ------------------- |
| `read.name`       | sample1_R1.fastq.gz |
| `read.baseName`   | sample1_R1.fastq    |
| `read.simpleName` | sample1             |

---

## Explanation

* `name` → full filename
* `baseName` → removes last extension
* `simpleName` → removes all extensions

---

## Task

Create a file prefix suitable for paired-end data:

```nextflow
sample1_R1.fastq.gz
sample1_R2.fastq.gz
```

You should extract:

```text
sample1
```

---

# Exercise 10 – Conditional variable creation

Now use a closure with a ternary operator:

```nextflow
def prefix = read.simpleName

def readType = { prefix.endsWith("_R1") ? "forward" : "reverse" }()
```

---

## Questions

1. Why is the closure executed with `()`?
2. What happens if you remove the parentheses?

---

## Explanation

The closure defines a function.
`()` executes it immediately.

Without `()`, `readType` would be a closure, not a value.

---

# Exercise 11 – Conditional command logic

Write a process that changes behavior depending on file name:

```nextflow
def prefix = read.simpleName

def flag = { prefix.contains("tumor") ? "--tumor" : "--normal" }()
```

Then use:

```bash
mytool ${flag} -i ${read}
```

---

## Task

Test this using two files:

```text
sample_tumor.fastq.gz
sample_normal.fastq.gz
```

Observe the generated command.

---

# Exercise 12 – Using task.cpus inside closures

```nextflow
def threads = { task.cpus > 4 ? task.cpus : 4 }()
```

---

## Question

Why is this useful?

---

## Explanation

It enforces a **minimum thread count** while still allowing scalability.

---

# Exercise 13 – Filename-based output naming

```nextflow
def prefix = read.simpleName

def outFile = "${prefix}.bam"
```

---

## Task

Modify this so that:

```text
sample1_R1.fastq.gz → sample1.bam
```

---

# Exercise 14 – Closure-based memory logic

```nextflow
def memOpt = { task.memory.toGiga() > 16 ? "-m 16000" : "-m 8000" }()
```

---

## Question

Why is this preferable to hard-coding?

---

# Exercise 15 – Debugging variable scope

Insert:

```bash
echo "Prefix=${prefix}"
echo "Suffix=${suffix}"
```

into the command section.

---

## Task

Explain which variables are expanded by:

* Groovy
* Bash

and in which phase.

---

# Conceptual summary

| Feature           | Purpose                 |
| ----------------- | ----------------------- |
| `def var`         | Safe Groovy variable    |
| `var`             | Unsafe implicit binding |
| `read.name`       | Full filename           |
| `read.baseName`   | Remove last extension   |
| `read.simpleName` | Remove all extensions   |
| Closures          | Conditional logic       |
| `task.cpus`       | Dynamic scaling         |
| `task.memory`     | Resource awareness      |

---

# Teaching takeaway

Inside a Nextflow process you are writing **two languages**:

1. Groovy (before execution)
2. Bash (during execution)

Understanding where variables are evaluated is the key to mastering Nextflow scripting.
