# Containers exercises

This exercise shows how to find a container for the tool `fastp`, pull it with Singularity/Apptainer, run `fastp` both inside and outside the container, inspect the image, and manage the Singularity cache.

Prerequisites
- Singularity or Apptainer installed and on your PATH (or available as a module).

1. Load Singularity (if your cluster uses modules)
```bash
module load singularity    # or `module load apptainer`
```

2. Find a `fastp` image
- Search Biocontainers (or Docker Hub / Quay) for `fastp` and select an image tag you want to use (for example `quay.io/biocontainers/fastp:<tag>` or a Docker Hub tag).
- Note the chosen image URI (we'll call it `<IMAGE_URI>` below).

3. Pull the container (example uses a generic docker URI)

4. Start an interactive shell inside the container, mounting the host path into `/work`
- We want the host folder `/project/nextflow_zero2hero/data/NA12878/fastq/sample1` visible inside the container at `/work`.

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

7. Inspect the image metadata and environment

- List environment variables that the container sets by running `env` inside the container:

- You can also view the image runscript (standard SIF images often keep it at `/.singularity.d/runscript`):


8. Check how much space this container occupies in the Singularity cache

This prints cached container files and sizes.

9. Clean the Singularity cache (removes cached images and blobs)
