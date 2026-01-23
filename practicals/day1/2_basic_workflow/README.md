# Nextflow Channel Operations and Process Workflow Exercises

This tutorial contains three progressive exercises designed to teach fundamental Nextflow concepts through hands-on practice.

## Prerequisites

In this folder you will find:
- Input files needed for your exercises
  - metadata.csv
  - metadata.tsv
- Files with needed parameters
  - nextflow.config
  - params.yaml
- Nextflow files for each exercise
  - In the hint file you wll find an "initialised" file of your task if you don't know where to start
  - In the solution you will find a possible complete solution that will run successfully

To run your code, use the following command: 

`nextflow run /path/to/your/main.nf -c /path/to/yout/nextflow.config`

Hint: if you place the file `nextflow.config` in the directory where you will run nextflow, you can omit the `-c` parameter because if a file named `nextflow.config` is present in the execution directory it will automatically loaded and parsed.

Alternative: you can avoid parsing the config file by providing the parameters directly via the command line in this way:

`nextflow run /path/to/your/main.nf --input_csv /path/to/input.csv --input_tsv /path/to/input.tsv --outdir output/`

Other alternative: you can use a params file to pass parameters to your workflow:

`nextflow run /path/to/your/main.nf -params /path/to/params.yaml`

These methods are equivalent, choose the one you are more comfortable with!

## Exercise 1: Understanding and Creating Input Channels

### Learning Objectives
- Understand what Nextflow channels are and their role in data flow
- Learn different channel factory methods
- Practice creating channels from various data sources
- Understand the difference between value channels and queue channels

### Theoretical Background
Channels are the fundamental data structure in Nextflow that connect processes and enable data flow through your pipeline. Think of channels as pipes that carry data between different parts of your workflow. There are two main types:

1. **Queue channels**: Can be consumed only once and are automatically closed when empty
2. **Value channels**: Can be read multiple times and never close

Learn more about channels in the [official documentation](https://www.nextflow.io/docs/stable/channel.html).

### Channel Factory Methods You'll Use
- `channel.of()`: Creates a channel from explicit values
- `channel.fromPath()`: Creates a channel from file paths
- `.splitCsv()`: Operator that parses CSV/TSV files into records

For a complete list of channel factories, see the [Channel factories reference](https://nextflow.io/docs/latest/reference/channel.html).

### Your Task
You will create three different input channels:
1. A basic channel containing a hardcoded tuple with language and greeting
2. A channel that reads from a CSV file and parses it with headers
3. A channel that reads from a TSV file and parses it with tab separation

### Expected Learning Outcomes
After completing this exercise, you should understand:
- How to create channels using different factory methods
- The structure of tuple data in channels
- How file parsing works with `.splitCsv()`
- How to verify channel contents using `.view()`

---

## Exercise 2: Channel Operators and Data Transformation

### Learning Objectives
- Master essential channel operators for data manipulation
- Understand how to combine multiple channels
- Learn data transformation techniques using `.map()`
- Practice creating complex data processing pipelines

### Theoretical Background
Channel operators are methods that transform, filter, combine, or manipulate the data flowing through channels. They are the building blocks for creating sophisticated data processing workflows. Key concepts:

1. **Combining channels**: Use operators like `.mix()` to merge multiple channels
2. **Data transformation**: Use `.map()` to transform each item in a channel
3. **Chaining operations**: Operators can be chained together for complex transformations

For comprehensive information about all available operators, see the [Operators reference](https://www.nextflow.io/docs/latest/reference/operator.html).

### Channel Operators You'll Use
- `.mix()`: Combines items from multiple channels into a single channel
- `.map()`: Transforms each item in a channel using a closure
- Closure syntax: `{ item -> transformation }` or `{ param1, param2 -> transformation }`

### Your Task
You will create a data processing pipeline that:
1. Combines data from CSV and TSV channels using `.mix()`
2. Transforms file records into standardized tuple format using `.map()`
3. Merges processed file data with the basic channel
4. Applies final formatting to create personalized greeting messages

### Expected Learning Outcomes
After completing this exercise, you should understand:
- How to combine multiple data sources into unified workflows
- The power of `.map()` for data transformation
- How to work with row objects from CSV parsing
- String interpolation in Groovy/Nextflow
- Method chaining for building complex data pipelines

---

## Exercise 3: Process Definition and Workflow Integration

### Learning Objectives
- Understand Nextflow process structure and components
- Learn how to define process inputs and outputs
- Master the connection between channels and processes
- Practice creating complete end-to-end workflows

### Theoretical Background
Processes are the computational units in Nextflow that execute tasks. Each process defines:

1. **Input declaration**: Specifies what data the process expects
2. **Output declaration**: Defines what the process produces
3. **Script block**: Contains the actual commands to execute
4. **Directives**: Optional settings like `publishDir` for result management

For detailed information about processes, see the [Processes documentation](https://www.nextflow.io/docs/stable/process.html) and [Process reference](https://www.nextflow.io/docs/latest/reference/process.html).

### Process Components You'll Work With
- **Input types**: `val()` for values, `path()` for files, `tuple()` for combinations
- **Output types**: `path()` for files, `tuple()` for structured data
- **emit**: Named outputs that can be referenced in workflows
- **publishDir**: Directive to copy results to specified directories

### Your Task
You will:
1. Define a `sayHello` process that writes messages to files
2. Define a `saveHello` process that processes and publishes final results
3. Connect your channel operations from Exercise 2 to these processes
4. Create a complete workflow that transforms input data through both processes

### Expected Learning Outcomes
After completing this exercise, you should understand:
- The anatomy of a Nextflow process
- How to properly declare inputs and outputs
- The relationship between channel structure and process inputs
- How processes communicate through their outputs
- Result publishing and file management
- Complete workflow orchestration from data input to final output

### Workflow Execution Flow
Your final workflow will follow this pattern:

Input Channels → Channel Operations → sayHello Process → saveHello Process → Published Results

This represents a complete data processing pipeline where raw input is transformed, processed, and published as final results.
