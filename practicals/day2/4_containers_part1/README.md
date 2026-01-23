# Hands-on: Singularity

This short guide walks through loading Singularity, pulling an image, running and inspecting it, looking inside the container, and working with the Singularity cache.

Prerequisites
- A system with Singularity installed (module system or binary).
- Network access to pull images from Singularity Hub (or an alternate registry).

---

## 1. Load Singularity

If your system uses environment modules:

```bash
module load singularity
```

---

## 2. Pull an image

Pull the example image from Singularity Hub:

```bash
singularity pull hello-world.sif shub://vsoch/hello-world
```

After this command you should see the file `hello-world.sif` in the current directory.

---

## 3. Run the container

Run the container using the default runscript embedded in the image:

```bash
singularity run hello-world.sif
```

The output shows the image's default script executing automatically.

---

## 4. Inspect the image

To see metadata and the default runscript (the `runscript` directive):

```bash
singularity inspect -r hello-world.sif
```

This shows that the image runs a script (for this image it is `rawr.sh`) by default.

---

## 5. Run a different command inside the image

To run a different command inside the image use `exec`:

```bash
singularity exec hello-world.sif /bin/echo "Raawrr Oranges"
```

`exec` runs the specified command inside the container without invoking the default runscript.

---

## 6. Explore the container filesystem (interactive shell)

Start an interactive shell inside the image:

```bash
singularity shell hello-world.sif
```

Inside the container you can inspect folders:

```bash
# list current directory (the container's working directory)
ls

# list root with human-readable sizes
ls -lh /
```

Observations and notes:
- Ownership of files/folders inside the container usually reflects the user on the host (Singularity preserves the calling user's UID/GID by default). Check ownership with `ls -l`.
- Binding a directory into the container makes that host directory visible inside the container — it is not copied, it is mounted (shared view of the same files).
- Try creating a folder in the container root (e.g. `mkdir /myfolder`). Whether this succeeds depends on image permissions and whether your user has write permission in that location. On many images you will not be able to create new top-level directories without root access.

Check who you are inside the container:

```bash
whoami
```

You should normally see the same username as outside the container.

When finished, exit the container shell:

```bash
exit
```

---

## 7. Inspecting the cache

Remove the SIF and pull again to illustrate caching behavior:

```bash
rm hello-world.sif
singularity pull hello-world.sif shub://vsoch/hello-world
```

Now list the Singularity cache (verbose):

```bash
singularity cache list -v
```

This shows cached items (image names, sizes, etc.). The cache is used to speed up future pulls and avoid re-downloading layers.

---

## 8. Clean the cache

To remove cached items:

```bash
singularity cache clean
```

This will prompt a warning before deleting all cached files. For finer control, see:

```bash
singularity cache clean --help
```

To change the cache directory, set the environment variable `SINGULARITY_CACHEDIR` to a different path before pulling images:

```bash
export SINGULARITY_CACHEDIR=/path/to/my/singularity-cache
```

---

Tips and troubleshooting
- If you need to bind a specific host folder into the container at a particular mountpoint, use `--bind` (or `-B`) with `run`, `exec`, or `shell`:

```bash
singularity shell --bind "$(pwd):/work" hello-world.sif
```

- If a command fails due to permissions in the container's root filesystem, consider whether you need to bind a host directory to write into, or build a custom image with the required layout/permissions.
- Use `singularity inspect` (without `-r`) to see labels, environment, and other metadata.
