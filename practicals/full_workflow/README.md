## Complete Workflow Example

This directory contains a complete example of a simplified variant-calling workflow using Nextflow. It demonstrates how to set up, configure, and execute a series of tasks from start to finish. 

### Run the test

To execute the complete workflow example

1. navigate to your workspace for the training (let's say you created a folder like `/group/mygroup/myuser/nextflow_training/`)
2. create a dedicate foder for the execution, and move into it. Like `mkdir full_workflow; cd full_workflow`
3. run the following command:

```bash
module load singularity nextflow/25.04.3

nextflow run /project/nextflow_zero2hero/practicals/full_workflow -profile humantechnopole,singularity,test --outdir full_workflow_results
```

### Main features

The workflow follows current best practices for Nextflow pipelines

- the execution is organized in distinct workflows, defined in the `workflows` folder
- the single processes are defined as modules in the `modules` folder
- the main configuration is in the `nextflow.config` file, while dynamic resources allocation is defined in the `conf/base.config` file
- accessory executables and scripts are in the `bin` folder