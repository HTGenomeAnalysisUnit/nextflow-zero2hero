# Advanced Nextflow Channel Operations Exercises

This comprehensive tutorial covers advanced Nextflow channel operations through 8 progressive exercises. Each exercise focuses on specific operators and techniques for sophisticated data processing workflows.

## Prerequisites

In this folder you will find:

- Input files needed for your exercises
  - metadata.csv
  - nextflow.config
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

## Recap table of operators

| **Category** | **Operator** | **Description** | **Examples from Code** |
|--------------|--------------|-----------------|------------------------|
| **Channel Creation** | `fromPath` | Creates a channel from file paths | `channel.fromPath(file(params.input_csv, checkIfExists: true))` |
| | `splitCsv` | Splits CSV files into records | `.splitCsv(header)` |
| **Transformation** | `map` | Transforms channel elements | `.map{row -> tuple(...)}`, `.map{meta, greeting -> tuple(...)}` |
| | `transpose` | Transposes grouped elements | `all_languages_grouped.transpose()` |
| | `multiMap` | Creates multiple output channels from one input | `.multiMap{meta, greeting -> only_family: ..., only_sub_category: ...}` |
| **Filtering & Selection** | `branch` | Splits channel into multiple branches based on conditions | `.branch{meta, greeting -> neo_latin: ..., germanic: ..., other: ...}` |
| | `filter` | Filters elements based on conditions | `.filter{meta, _file -> meta.family == "germanic"}` |
| | `unique` | Removes duplicate elements | `.unique()` |
| **Grouping & Aggregation** | `groupTuple` | Groups elements by key | `.groupTuple()` |
| | `flatten` | Flattens nested structures | `.flatten()` |
| | `collect` | Collects all elements into a single emission | `.collect()` |
| | `collectFile` | Collects elements into a file | `.collectFile{meta, file_names -> ...}` |
| **Channel Combination** | `mix` | Mixes multiple channels (unordered) | `neo_latin_greetings_grouped.mix(greetings_by_family.germanic)` |
| | `concat` | Concatenates channels (ordered) | `neo_latin_greetings_grouped.concat(greetings_by_family.germanic)` |
| | `join` | Joins channels by key | `.join(greetings_by_family.germanic)`, `.join(..., remainder: true)` |
| | `combine` | Combines channels (cartesian product) | `.combine(greetings_by_family.germanic, by: 0)` |

---

## Exercise 1: Channel Branching

### Learning Objectives

- Understand conditional channel routing with the `branch` operator
- Learn how to split channels based on criteria
- Practice creating multiple output channels from a single source

### Theoretical Background

The [branch operator](https://www.nextflow.io/docs/latest/reference/operator.html#branch) forwards each item from a source channel to one of multiple output channels based on selection criteria. Each branch is defined by a unique label followed by a boolean expression. When an item is received, it's routed to the first output channel whose expression evaluates to true.

Key concepts:

- **Conditional routing**: Items are directed to different channels based on conditions
- **Multiple outputs**: One input channel becomes multiple named output channels 
- **Fallback conditions**: Use `true` as the last condition to catch unmatched items
- **Custom return values**: Transform items as they're routed to branches

### Your Task

You will implement channel branching to separate languages by family:

- Create a `neo_latin` branch for Romance languages
- Create a `germanic` branch for Germanic languages
- Add an `other` fallback branch for unmatched languages
- Transform the output to include family metadata

### Expected Learning Outcomes

After completing this exercise, you should understand:

- How to define branch conditions using boolean expressions
- The importance of branch order (first match wins)
- How to transform data while branching
- When and why to use fallback conditions

---

## Exercise 2: Channel Combination and Concatenation

### Learning Objectives

- Master the `mix` and `concat` operators for combining channels
- Understand the differences between mixing and concatenating
- Learn `groupTuple` for collecting related items
- Practice `transpose` for flattening nested structures

### Theoretical Background

Channel combination operators allow you to merge data from multiple sources:

- **[mix](https://www.nextflow.io/docs/latest/reference/operator.html#mix)**: Combines items from multiple channels in any order (asynchronous)
- **[concat](https://www.nextflow.io/docs/latest/reference/operator.html#concat)**: Combines channels sequentially (first channel completes before second starts)
- **[groupTuple](https://www.nextflow.io/docs/latest/reference/operator.html#grouptuple)**: Collects tuples with matching keys into groups
- **[transpose](https://www.nextflow.io/docs/latest/reference/operator.html#transpose)**: Flattens nested lists in tuples

### Your Task

You will work with grouped data and transformations:

- Group greeting files by language family using `groupTuple`
- Use `transpose` to flatten grouped collections
- Compare `mix` vs `concat` behavior with the same data
- Transform grouped data for further processing

### Expected Learning Outcomes

After completing this exercise, you should understand:

- When to use `mix` vs `concat` for combining channels
- How `groupTuple` collects items by matching keys
- The flattening behavior of `transpose`
- Performance implications of different combination strategies

---

## Exercise 3: Filtering and Collection Operations

### Learning Objectives

- Master filtering techniques with the `filter` operator
- Learn collection strategies: `flatten`, `collect`, and `collectFile`
- Understand when to use each collection method
- Practice file-based data aggregation

### Theoretical Background

Data filtering and collection are essential for data processing pipelines:

- **[filter](https://www.nextflow.io/docs/latest/reference/operator.html#filter)**: Selects items that match specific criteria
- **[flatten](https://www.nextflow.io/docs/latest/reference/operator.html#flatten)**: Converts nested collections into individual items
- **[collect](https://www.nextflow.io/docs/latest/reference/operator.html#collect)**: Gathers all items into a single list
- **[collectFile](https://www.nextflow.io/docs/latest/reference/operator.html#collectfile)**: Aggregates items into files

### Your Task

You will implement various collection strategies:

- Filter channels to select specific language families
- Use `flatten` to separate grouped items into individual emissions
- Apply `collect` to gather items into lists
- Use `collectFile` to aggregate data into files with custom formatting

### Expected Learning Outcomes

After completing this exercise, you should understand:

- Different filtering criteria (boolean predicates, regular expressions, type qualifiers)
- When to flatten vs collect data structures
- File-based aggregation strategies

---

## Exercise 4: Advanced Joining Operations

### Learning Objectives

- Master channel joining with `combine`, `join`, and advanced matching
- Understand inner vs outer join semantics
- Learn key-based data merging strategies
- Practice handling duplicate and missing keys

### Theoretical Background

Joining operations merge data from multiple channels based on matching keys:

- **[combine](https://www.nextflow.io/docs/latest/reference/operator.html#combine)**: Creates cross-product combinations, optionally filtered by key
- **[join](https://www.nextflow.io/docs/latest/reference/operator.html#join)**: Performs inner joins (SQL-like) with matching keys
- **Key matching**: Uses tuple positions to match related data
- **Remainder option**: Controls what happens with unmatched items

### Your Task

You will implement different joining strategies:

- Create a reference metadata channel for joining
- Perform inner joins to merge matching data
- Use outer joins to preserve unmatched items
- Apply `combine` for cross-product operations
- Standardize and deduplicate joined results using `unique`

### Expected Learning Outcomes

After completing this exercise, you should understand:

- The difference between inner and outer joins
- When to use `combine` vs `join` for data merging
- Key-based matching strategies
- Handling of duplicate and missing keys in joins

---

## Exercise 5: Advanced Mapping and Regular Expressions

### Learning Objectives

- Master advanced `map` transformations
- Learn regular expression pattern matching in Nextflow
- Practice metadata extraction from filenames
- Understand the `multiMap` operator for creating multiple output channels

### Theoretical Background

Advanced mapping operations enable sophisticated data transformations:

- **Pattern matching**: Use regular expressions to extract information
- **[multiMap](https://www.nextflow.io/docs/latest/reference/operator.html#multimap)**: Creates multiple output channels from a single input
- **Metadata extraction**: Parse structured information from strings
- **Complex transformations**: Combine multiple operations in mapping functions

### Your Task

You will implement advanced mapping techniques:

- Use regular expressions to extract metadata from file paths
- Create multiple output channels using `multiMap`
- Transform data structures for different downstream processes
- Practice complex data parsing and restructuring

### Expected Learning Outcomes

After completing this exercise, you should understand:

- Regular expression syntax in Groovy/Nextflow
- How to extract structured data from strings
- Creating multiple channels from single inputs
- Advanced data transformation patterns

---

## Key Learning Points

- **Channel Operators**: [branch](https://www.nextflow.io/docs/latest/reference/operator.html#branch), [mix](https://www.nextflow.io/docs/latest/reference/operator.html#mix), [concat](https://www.nextflow.io/docs/latest/reference/operator.html#concat), [groupTuple](https://www.nextflow.io/docs/latest/reference/operator.html#grouptuple), [transpose](https://www.nextflow.io/docs/latest/reference/operator.html#transpose)
- **Data Processing**: [filter](https://www.nextflow.io/docs/latest/reference/operator.html#filter), [flatten](https://www.nextflow.io/docs/latest/reference/operator.html#flatten), [collect](https://www.nextflow.io/docs/latest/reference/operator.html#collect), [collectFile](https://www.nextflow.io/docs/latest/reference/operator.html#collectfile)
- **Joining Operations**: [combine](https://www.nextflow.io/docs/latest/reference/operator.html#combine), [join](https://www.nextflow.io/docs/latest/reference/operator.html#join), [unique](https://www.nextflow.io/docs/latest/reference/operator.html#unique)
- **Advanced Mapping**: [map](https://www.nextflow.io/docs/latest/reference/operator.html#map), [multiMap](https://www.nextflow.io/docs/latest/reference/operator.html#multimap), regular expressions
