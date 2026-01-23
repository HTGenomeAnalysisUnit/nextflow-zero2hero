# Using Singularity with Nextflow — Hands-on Guide

This short hands-on tutorial shows two simple ways to run Nextflow processes inside Singularity containers:

- Define the container inside the process (process-local container)
- Define a global container for all processes in `nextflow.config`

It also explains common traps (for example what happens when automatic bind-mounts / automounts are disabled) and how to work around them.

Prerequisites
- Nextflow installed and on your PATH (https://www.nextflow.io)
- Singularity / Apptainer installed and on your PATH
- Network access to pull images (or use a local Singularity image)

Quick notes
- The Nextflow `container` directive accepts a container image string (Docker, Singularity Hub, or other supported URI). When Singularity is enabled Nextflow will use Singularity to run that image.
- This tutorial does NOT use process selectors like `withName`, `withLabel`, or `tags`. Containers are defined either in the process or globally in the config.
- By default Nextflow will bind the working directory and staged files into the container for you (this is called automounting or automatic binding). If automounts are disabled, the container may not see your files — see the "Traps" section.

Contents
1. Example: process-local container (simple "hello" pipeline)
2. Example: global container defined in `nextflow.config`
3. Trap: what happens when you disable automounts
4. Tips and troubleshooting

---

## 1) Example — container defined inside the process (hello-nextflow style)

File: main.nf

```groovy
#!/usr/bin/env nextflow

// A minimal Nextflow pipeline that uses a Singularity image in the process itself.

process hello {
    // Container defined here (process-local)
    container 'shub://vsoch/hello-world'

    input:
    val name from Channel.of('Nextflow')

    /*
     * The script runs inside the container. Nextflow stages inputs
     * into the process work directory and (by default) binds that
     * work dir into the container so the process sees the files.
     */
    script:
    """
    echo "Hello $name from inside a Singularity container"
    """
}

workflow {
    hello()
}
```

File: nextflow.config

```groovy
singularity {
    enabled = true
    autoMounts = true
}
```

Run it:
```bash
nextflow run main.nf
```

Expected behavior:
- Nextflow will request the container `shub://vsoch/hello-world`.
- Singularity will pull the image (cached for future runs) and execute the process inside it.
- The `echo` output appears in the Nextflow log for that task.


Lets have a look again at the cache list 

```bash
singularity cache list
```

---

## 2) Example — global container in nextflow.config

You can define a global container for all processes in `nextflow.config` so you don't repeat the `container` directive inside every process.

File: nextflow.config

```groovy
singularity {
    enabled = true
    autoMounts = true
}

// Set a global container: every process will use this unless it specifies its own container
process {
    container = 'shub://vsoch/hello-world'
}
```
Run it:
```bash
nextflow run main.nf
```

Behavior:
- All processes inherit the `process.container` image unless they override it.
- Useful when every process uses the same image.

---

## 3) What happens if you disable automounts (and how to fix it)

What "automounts" means
- Nextflow usually instructs Singularity to bind (mount) the pipeline working directory (and other required host paths) into the container so the running process can access staged input files and write output files.
- This is automatic when `singularity.autoMounts = true` (the default).

If you disable automounts
- If `singularity.autoMounts` is set to `false`, Nextflow will not issue automatic binds. The container will run with the image's internal filesystem only.
- Consequence: files that Nextflow staged into the process work directory on the host will not be visible inside the container. Processes that try to read staged input files will fail with "file not found" errors; output files written inside the container root will not be visible to Nextflow unless you explicitly bind the right paths.

Example failure scenario
- Your process expects a staged file `input.txt` in the work directory, but with automounts disabled the container can't see that file and the tool inside the container errors out.

How to fix / workarounds
- Easiest: Keep automounts enabled (recommended):
  - In `nextflow.config`: `singularity.autoMounts = true` (or omit it since true is default).
- If you must disable automounts (rare), explicitly bind the required host paths:
  - Use Singularity run options to bind host paths into the container. In Nextflow config you can add extra CLI options to the Singularity invocation:
    - Example (in `nextflow.config`):
      ```groovy
      singularity {
          enabled = true
          autoMounts = false
          // add binds so the container sees the host work directory and any input folders
          runOptions = "--bind ${workDir}:/work --bind /path/to/data:/data"
      }
      ```

Important: when manually binding paths, make sure the container has appropriate permissions (UID/GID) to read/write the bound locations — Singularity generally preserves the calling user's UID/GID, so permission mismatches are less common than with Docker, but still possible.