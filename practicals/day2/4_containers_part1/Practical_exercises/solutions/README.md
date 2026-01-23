# Containers practice

This exercise shows how to find a container for the tool `fastp`, pull it with Singularity/Apptainer, run `fastp` both inside and outside the container, inspect the image, and manage the Singularity cache.

Prerequisites
- Singularity or Apptainer installed and on your PATH (or available as a module).
- Network access to pull container images (or a local SIF image).
- A host path with example FASTQ files:  
  /project/nextflow_zero2hero/data/NA12878/fastq/sample1
  (adjust to your environment)

Quick note about image URIs
- Many bioinformatics containers are available on Docker/Quay/OCI registries (Biocontainers). Use a Docker/OCI URI (e.g. `docker://...` or a local `.sif`) when pulling with Singularity. Singularity Hub (`shub://`) is deprecated in many environments — prefer `docker://` or a prebuilt `.sif`.

1. Load Singularity (if your cluster uses modules)
```bash
module load singularity    # or `module load apptainer`
```

2. Find a `fastp` image
- Search Biocontainers (or Docker Hub / Quay) for `fastp` and select an image tag you want to use (for example `quay.io/biocontainers/fastp:<tag>` or a Docker Hub tag).
- Note the chosen image URI (we'll call it `<IMAGE_URI>` below).

3. Pull the container (example uses a generic docker URI)
```bash
# Example (replace <IMAGE_URI> with the chosen image)
singularity pull fastp.sif docker://<IMAGE_URI>
```

4. Start an interactive shell inside the container, mounting the host path into `/work`
- We want the host folder `/project/nextflow_zero2hero/data/NA12878/fastq/sample1` visible inside the container at `/work`.
```bash
singularity shell --bind /project/nextflow_zero2hero/data/NA12878/fastq/sample1:/work fastp.sif
```

5. Inside the container: check the mounted files and run `fastp`
```bash
# inside the container
ls -lh /work

# run fastp on the mounted reads (adjust filenames as needed)
fastp \
  -i /work/reads_R1.fastq \
  -I /work/reads_R2.fastq \
  -o sample1_reads_R1_qced.fastq.gz \
  -O sample1_reads_R2_qced.fastq.gz \
  --json sample1_fastp.json \
  --html sample1_fastp.html \
  --thread 4
```

Notes:
- Output files above (`sample1_reads_R1_qced.fastq.gz`, `sample1_reads_R2_qced.fastq.gz`, etc.) are created in the container's current working directory (which, depending on the container invocation, can be the host-mounted location or the container image filesystem). If you started the container with `--bind ...:/work` and then `cd /work` before running, outputs will be written to the host-mounted directory.
- If you prefer outputs to be placed inside the mounted `/work` explicitly, write output paths under `/work` (e.g., `-o /work/sample1_reads_R1_qced.fastq.gz`).

6. Repeat the same `fastp` run from outside the container (using the pulled SIF)
- This runs the tool inside the image without opening an interactive shell:
```bash
# run directly via singularity exec, binding the host folder to /work
singularity exec --bind /project/nextflow_zero2hero/data/NA12878/fastq/sample1:/work fastp.sif \
  fastp \
    -i /work/reads_R1.fastq \
    -I /work/reads_R2.fastq \
    -o /work/sample1_reads_R1_qced.fastq.gz \
    -O /work/sample1_reads_R2_qced.fastq.gz \
    --json /work/sample1_fastp.json \
    --html /work/sample1_fastp.html \
    --thread 4
```

7. Inspect the image metadata and environment
- Metadata (labels, help, runscript):
```bash
singularity inspect fastp.sif
# or with additional flags (if supported in your Singularity version)
# singularity inspect --labels fastp.sif
# singularity inspect --runscript fastp.sif
```
- List environment variables that the container sets by running `env` inside the container:
```bash
singularity exec fastp.sif env | sort
```
- You can also view the image runscript (standard SIF images often keep it at `/.singularity.d/runscript`):
```bash
singularity exec fastp.sif cat /.singularity.d/runscript
```

8. Check how much space this container occupies in the Singularity cache
```bash
singularity cache list -v
```
This prints cached container files and sizes.

9. Clean the Singularity cache (removes cached images and blobs)
```bash
singularity cache clean
# use --help for more refined options:
singularity cache clean --help
```
