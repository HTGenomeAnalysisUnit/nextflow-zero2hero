# Day 3 - Section 4 - Advanced scripting inside a Nextflow process

This practical focuses on **Groovy scripting inside a single Nextflow process**.

You will start from a **minimal working pipeline** and progressively extend the *same process*, learning **how Groovy is evaluated inside `script:` blocks** and how it differs from **Bash execution at runtime**.

---

## Two phases, two languages

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

---

## Introduction to Ternary Operators

The **ternary operator** is a concise way to write simple conditional expressions in Groovy, the language used by Nextflow. It allows you to select between two values depending on a condition, all in a single line.

### Syntax

```bash
condition ? valueIfTrue : valueIfFalse

condition — a Boolean expression that is evaluated.

valueIfTrue — the result returned if the condition is true.

valueIfFalse — the result returned if the condition is false.
```

This is equivalent to a simple if/else statement but written in a compact and readable form.

Example (generic)

```bash
def result = condition ? "Yes" : "No"
```

If condition is true, result will be "Yes".

If condition is false, result will be "No".

Why ternary operators are used in Nextflow

* Dynamic value assignment — compute values based on conditions during pipeline construction (Groovy evaluation).

* Simplify commands and options — generate flags, parameters, or metadata without verbose if/else blocks.

* Concise and readable — keeps pipelines maintainable, especially when multiple conditional values are needed.

---

## Exercise 1 — Sample names and variable scope

Modify the `main.nf` so that:

* Each input file produces a distinct output file

* The output filename is derived safely from the input

* Variables inside script: are declared correctly using Groovy

The initial pipeline always writes:

```bash
result.txt
```

Because the process runs once per input file, outputs overwrite each other.

### Step 1 — Introduce a sample-specific variable (Groovy)

#### Choosing the right file property

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

---

Inside the script: block, define a variable derived from the input file:

```bash

script:
def sample = read.simpleName


```

### Step 2 — Use the variable in the command

Replace the command with:

```bash
echo "Processing file: ${read.name}" > ${sample}.txt
```

Note that:

* ${sample} is expanded by Groovy

* sample does not exist at runtime

### Step 3 — Fix the output declaration

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

### Questions?

* **Why must `sample` be declared with `def`?**  
  Declaring `sample` with `def` makes it a **local Groovy variable**, scoped only to the `script:` block.  
  This prevents accidental overwriting of other variables and ensures predictable behavior.

* **Why is `simpleName` preferable to `name` and `baseName` here?**  
  `simpleName` removes **all file extensions**, producing a clean, stable sample name.  
  `name` keeps all extensions, which may lead to long filenames.  
  `baseName` removes only the last extension, which can leave residual extensions like `.fastq`.  
  For output files, `simpleName` is usually safest.

* **Why would `> $sample.txt` not work?**  
  `$sample` is a **Bash variable**, but `sample` is a **Groovy variable**.  
  Bash has no knowledge of Groovy variables unless they are expanded first.  
  Using `${sample}` ensures the value is **injected by Groovy before Bash executes**.

* **At which phase is `${sample}` expanded?**  
  `${sample}` is expanded during the **Groovy phase** (pipeline construction), **before the task runs**.  
  By the time Bash executes, the value is already inserted into the command.

---

## Exercise 2 — Variable declaration inside the `script:` block

### Practice

Modify the `script:` section and add:

```bash
def sample = read.simpleName
suffix = "_processed"
```

Then change the command to:

```bash
echo "Processing file: ${read.name}" > ${sample}${suffix}.txt
```

Questions

* What is the difference between def prefix and suffix?

def prefix declares a local Groovy variable that exists only inside the script: block.

suffix, declared without def, becomes a Groovy binding variable.
Binding variables are placed in the global script binding instead of a local scope.

* Why does the pipeline still work?

The pipeline still works because Groovy automatically creates binding variables
when an undeclared variable is assigned.

suffix is therefore resolved during Groovy evaluation, and its value is
successfully injected into the command before execution.

However, this behavior is implicit and unsafe.

---§

## Exercise 3 — Groovy Closures

Inside the `script:` block, define a variable `readType` using a closure:

```nextflow
def readType = {
    simpleName.endsWith('_R1') ? 'forward' :
    simpleName.endsWith('_R2') ? 'reverse' :
    'single'
}()
````

Then print it to the output:

```bash
echo "Read type: ${readType}" >> ${sample}.txt
```

---

### What is happening

* The `{ ... }` syntax defines a **Groovy closure**, which is like a small function or code block.
* The `()` at the end **calls the closure immediately**, producing a value that is stored in `readType`.
* Inside the closure:

  * `simpleName.endsWith('_R1') ? 'forward' : ...` is a **ternary expression**.
  * It checks the filename suffix and returns `"forward"`, `"reverse"`, or `"single"`.
* This all happens during **Groovy evaluation** (pipeline construction), before Bash executes the command.
* The value of `readType` (a string) is then injected into the Bash command.

If you remove the `()`, `readType` becomes the **closure object itself**, not the computed value. Bash cannot use a closure object, so the command will fail or produce unexpected output.

---

### Questions

* **Why is the closure executed with `()`?**
  The parentheses call the closure immediately, returning the value (e.g., `"forward"`).
  Without calling it, `readType` is just a closure object, not a usable string.

* **What happens if you remove the parentheses?**
  `readType` becomes a closure object. When Bash tries to use it, it will **not produce the expected string**, leading to errors or incorrect output.

---

## Exercise 4 — Conditional behavior from filenames

### Practice

Inside the `script:` block, define a variable `flag` based on the filename:

```nextflow
def flag = { 
    sample.contains('tumor') ? '--tumor' : '--normal' 
}()
````

Then print the generated command:

```bash
echo "Command: mytool ${flag} -i ${read.name}" >> ${sample}.txt
```

Test with these files:

```text
sample_tumor.fastq.gz
sample_normal.fastq.gz
```

---

### What is happening

* The `{ ... }` syntax defines a **closure** (a code block that computes a value).
* The `()` at the end **calls the closure immediately**, producing the string value for `flag`.
* Inside the closure:

  * `sample.contains('tumor') ? '--tumor' : '--normal'` is a **ternary expression**.
  * It checks whether the sample name includes `"tumor"` and returns the appropriate flag.
* This computation happens **during Groovy evaluation**, so the final Bash command already includes the resolved value.

Without calling the closure (`()`), `flag` would be a closure object, not a string, and the Bash command would fail.

---

### Questions

* **Why is the closure executed with `()`?**

  Calling the closure immediately returns the computed string (e.g., `"--tumor"`).
  Without `()`, `flag` is just a closure object.

* **What happens if you remove the parentheses?**

  The Bash command receives a closure object, not a string, causing errors or unexpected behavior.

* **Why is it preferable to compute this flag in Groovy rather than inside Bash?**

  Computing it in Groovy ensures the **pipeline is explicit and predictable**:
  the command already contains the correct value before execution.
  It avoids Bash string manipulation errors and makes the process more maintainable.

---

## Exercise 5 —  Using `task.cpus` (Groovy metadata)

use **all allocated CPUs** for the task, but allow for a **minimum of 1 thread**.

* If `task.cpus` is set to 2, then use 2 threads.
* If `task.cpus` is higher, use that many threads.
* If `task.cpus` is unset, default to 1.

Set the process header to specify available CPUs:

```nextflow
cpus 2
````

Inside the `script:` block, define the number of threads dynamically:

```nextflow
def threads = { task.cpus ?: 1 }()
```

Then use it in the command:

```bash
echo "Threads: ${threads}" >> ${sample}.txt
```

---

### What is happening

* `task.cpus` gives the **number of CPUs allocated** to this process.
* The closure `{ task.cpus ?: 1 }` returns `task.cpus` if it exists, otherwise defaults to 1.
* `()` calls the closure immediately during **Groovy evaluation**, storing the value in `threads`.
* The Bash command can now safely use `${threads}` for multithreading tools.

---

### Question

Why is this preferable to hard-coding thread counts?

* Using `task.cpus` ensures that the process **adapts to the allocated resources**.
* Hard-coding thread counts can lead to **over- or under-utilization** of CPUs.
* This approach guarantees a **dynamic, deterministic, and safe value** that reflects the actual environment.

---

## Exercise 6 — Using `task.memory` (Groovy metadata)

Set the process header to specify memory:

```nextflow
memory '8 GB'
````

Inside the `script:` block, define a memory option for your tool based on the allocated memory:

```nextflow
def memOpt = { "-m ${task.memory.toMega()}" }()
```

Then print it to the output:

```bash
echo "Memory option: ${memOpt}" >> memory.txt
```

---

### What is happening

* `task.memory` gives the **memory allocated** to the process.
* `task.memory.toMega()` converts the value to **megabytes**, which many tools require for command-line options.
* The closure `{ "-m ${task.memory.toMega()}" }` constructs the tool-specific memory string.
* `()` calls the closure immediately during **Groovy evaluation**, so `${memOpt}` is a proper string before Bash execution.
* The Bash command can now safely use `${memOpt}` when running memory-aware tools.

---

### Question

Why is this preferable to hard-coding memory values?

* Using `task.memory` ensures the process **adapts to the allocated resources**.
* Hard-coded memory options can **exceed available memory** or **underutilize resources**.
* Computing the option in Groovy guarantees a **deterministic and safe value** that reflects the environment.

---

## Exercise 7 — Groovy vs Bash expansion

Inside the `script:` block, print a Groovy variable and a Bash environment variable:

```bash
echo "Home: \$HOME" > bash_variables.txt
echo "Path: \$PATH" >> bash_variables.txt

```

### What is happening

* `${sample}`, `${readType}`, `${flag}`, `${threads}`, `${memOpt}` are all **Groovy variables**.

  * Their values are computed during **Groovy evaluation** (pipeline construction) and injected into the Bash commands.
* `$HOME` is a **Bash environment variable**.

  * It is expanded **at task runtime**.
  * Saving it in a separate file (`bash_variables.txt`) makes the distinction explicit.
* **Takeaway rule:** Always ask:

> “Is this evaluated by Groovy, or by Bash?”

Confusing the two is the source of most bugs in advanced Nextflow scripting.

---

### Examples of expansion

| Variable      | Expanded by | When             |
| ------------- | ----------- | ---------------- |
| `${sample}`   | Groovy      | Before execution |
| `${threads}`  | Groovy      | Before execution |
| `${readType}` | Groovy      | Before execution |
| `$HOME`       | Bash        | Runtime          |
| `$PATH`       | Bash        | Runtime          |

---

### Key point

* **Groovy phase:** variables (`def var`, closures) and `${var}` are computed **before Bash runs**.
* **Bash phase:** shell variables (`$VAR`) and commands are executed **at runtime**.

By separating the Groovy and Bash outputs, you can **see clearly which variables are evaluated when**, and avoid the most common Nextflow scripting errors.
