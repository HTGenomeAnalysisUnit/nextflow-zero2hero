# 3. Contributing to nf-core

This section covers the practical steps to engage with the nf-core community and contribute to the project through code development, collaborative discussion, and pull requests.

---

## Staying Connected with the nf-core Community

### 1.1: Join the nf-core Slack Workspace

The nf-core community is most active on Slack. This is where discussions, announcements, and collaborative problem-solving happen.

**How to join:**

1. Visit: [https://nf-co.re/join/slack](https://nf-co.re/join/slack)
2. You'll receive an invitation to join the nf-core Slack workspace
3. Create your account and set your profile

**Key Slack channels to follow:**

- `#announcements`: Major nf-core news, releases, and events
- `#help`: General questions and troubleshooting
- `#tools`: Discussion about nf-core tools
- `#bytesize`: Quick 10-minute presentations on specific topics
- `#events`: Information about upcoming webinars, hackathons, and conferences
- Pipeline-specific channels: `#rnaseq`, `#scrnaseq`, `#sarek`, etc.

### 1.2: Subscribe to GitHub Repositories

Watch important repositories to receive notifications:

1. Go to [https://github.com/nf-core/](https://github.com/nf-core/)
2. Select repositories of interest (`nf-core/modules`, `nf-core/configs`, `nf-core/tools`)
3. Click **Watch** > **Custom** > Select notification preferences

### 1.3: Participating in nf-core Events

**Regular Events:**

- **Bytesize Talks**: Short (10-15 minute) technical presentations held regularly
   - Schedule: Check Slack `#events` or [https://nf-co.re/events](https://nf-co.re/events)
   - Topics: Recent developments, community tools, data management, best practices
   - Format: Live presentation + Q&A + recording available

- **nf-core Hackathons**: Intensive collaborative events where developers work on specific features
   - Typically held 2-3 times per year
   - Multi-day events with mentorship and support
   - Great opportunity to contribute or learn from experienced developers

- **Nextflow Summit**: Conferences bringing together the Nextflow and nf-core communities
   - Held twice a year
   - Dedicated nf-core track with talks on pipeline development and best practices
   - Networking opportunities with core developers and the broader community
   - Check [https://summit.nextflow.io](https://summit.nextflow.io) for dates and registration

---

## Understanding the GitHub Development Cycle

### Background

Contributing to nf-core follows a structured GitHub workflow:

```text
Identify issue
    ↓
Discuss solution
    ↓
Fork repository
    ↓
Create branch
    ↓
Make changes
    ↓
Test locally
    ↓
Push to fork
    ↓
Open pull request
    ↓
Code review
    ↓
Address feedback
    ↓
Approve & merge
```

### 2.1: Understanding Issues

**Issues** are the starting point for any contribution. They describe:

- Bug reports: Something is broken and needs fixing
- Feature requests: New functionality that would benefit the pipeline
- Documentation: Missing or unclear documentation

**Finding issues:**

1. Navigate to the pipeline repository (e.g., [https://github.com/nf-core/rnaseq](https://github.com/nf-core/rnaseq))
2. Click **Issues** tab
3. Filter by labels:
    - `good first issue`: Recommended for newcomers
    - `help wanted`: Community assistance needed
    - `bug`: Bug fixes
    - `enhancement`: New features
    - `documentation`: Documentation improvements

**Engaging with issues:**

The discussion in issues usually covers several topics:

1. **Explanations about the issue reported**: Details about the bug or the feature request
2. **Check for duplicates**: Is this issue already being addressed?
3. **Comment and discuss**:
    - Share your ideas about the solution
    - Ask clarifying questions
    - Link related issues or PRs
4. **Reach consensus**: The maintainers and the proponent agree on the approach
5. **Assign yourself**: Comment with "I'll take this!" to let others know you're working on it

### 2.2: The Branching Model Adopted by nf-core

The nf-core project uses a structured branching model to manage development:

- **`master` branch**: Contains official releases and stable code. Only production-ready code is merged here.
- **`dev` branch**: The main development branch where active feature development happens. This is the base branch for new feature branches.
- **Feature branches**: Individual branches created from `dev` for specific features or bug fixes.
- **`TEMPLATE` branch**: Reserved for updates to the nf-core pipeline template.

### 2.3: The Pull Request Lifecycle

**Pull Request (PR)**: A request to merge your changes into the main repository. It is the formal way to propose changes and have them reviewed before being integrated into the project's development.

We will exemplify this with the `salmoquant` workflow that was developed in the previous section of the course ("2. Developing an nf-core Pipeline from Scratch"), hosted on the nf-data organization.

**Scenario**: The SALMON_QUANT process has memory issues, and we want to increase the available memory allocation.

#### Forks

The first step is forking the repository. A **fork** is your personal copy of the repository where you can make changes without affecting the original. This prevents contributors from creating many branches and keeps the original project clean.

1. Visit the [https://github.com/nfdata-omics/salmoquant](https://github.com/nfdata-omics/salmoquant) repository
2. Click the **Fork** button (top right)
3. Choose where to fork (select your personal GitHub account)
4. GitHub creates a copy at `https://github.com/YOUR_USERNAME/salmoquant`

#### Feature Branches

**Branches** allow you to work on features independently:

- Create a feature branch from the `dev` branch for your specific changes

To create a branch `fix-salmon-memory` on your fork of nfdata-omics/salmoquant directly on GitHub:

- Visit your forked repository at `https://github.com/YOUR_USERNAME/salmoquant`
- Click the **Branch** dropdown and select `dev`
- Again in the **Branch** dropdown, type `fix-salmon-memory` in the text field
- Click **Create branch: fix-salmon-memory from 'dev'**

GitHub creates your feature branch directly without needing local setup.

#### Make Changes to the Code

Typically, you would clone the fork to your local environment and perform development there. However, for this exercise, we will work through the remaining steps on the GitHub web interface to highlight the process with a simple code change.

We can edit the `conf/modules.config` configuration file to increase memory allocation:

```diff

    withName: 'SALMON_QUANT' {
        ext.args = '--validateMappings'
+       memory = { check_max( 8.GB * task.attempt, 'memory' ) }
        publishDir = [
            path: { "${params.outdir}/salmon" },
            mode: params.publish_dir_mode,
            saveAs: { filename -> filename.equals('versions.yml') ? null : filename }
        ]
    }

```

When working in a proper development environment, you should perform these validation steps:

- Use pre-commit hooks to catch issues early
- Run the nf-core linting: `nf-core pipelines lint`
- Run the test profile: `nextflow run -profile test,...`
- Run the nf-test suite: `nf-test tests ...`

#### Open a Pull Request

Once you've committed your changes to your feature branch and pushed them to your fork:

1. Go to `https://github.com/YOUR_USERNAME/salmoquant`
2. You'll see a banner: "fix-salmon-memory had recent pushes"
3. Click the **Compare & pull request** button

Fill in the PR description using the provided PR template. Be clear about:

- What changes you made
- Why you made them

Click **Create pull request** to submit your PR.

**What happens next:**

Automated checks run automatically:

- Code linting
- GitHub Actions tests

Status indicators show:

- ✅ All checks passed
- ⚠️ Some checks failing (address before merge)
- 🔄 Checks in progress

#### Code Review

When the feature is implemented and tests are successful, the PR needs to be reviewed by the project maintainers.

Reviewers may request:

- **Changes**: Modifications required before merge
- **Comments**: Questions or suggestions
- **Approvals**: Confirmation that code is acceptable

Be patient: reviews may take a few days. Watch for notifications from GitHub about comments or reviews. If needed, you can notify the maintainers on Slack.

When reviewers request changes:

- Respond to their comments
- Commit new changes to your feature branch to address their requests
- The PR automatically updates with your new commits—no need to create a new PR

Once the PR is approved:

- You or a maintainer can merge the PR
- If there are conflicts, they need to be resolved first
- Your changes are then integrated into the `dev` branch

#### Summary

1. **Before opening a PR**:
    - Your changes should address a specific issue
    - Discuss your approach in the related issue or on Slack

2. **Opening a PR**:
    - Provide a clear description of your changes
    - Link to related issues
    - Explain what was changed and why

3. **Code Review**:
    - Maintainers review your code
    - Automated checks (linting, testing) are run
    - Feedback is provided as comments on specific lines

4. **Addressing Feedback**:
    - Make requested changes
    - Reply to each comment
    - Push changes to your branch (the PR updates automatically)

5. **Approval and Merge**:
    - Once approved, you or the maintainers can merge your PR
    - Your changes become part of the project

---

## Real-World Contribution Exercise

### Objective

Apply all learned concepts by contributing to the salmoquant pipeline. This comprehensive exercise demonstrates the full development cycle.

### 3.1: Identify a Feature to Implement

Identify a feature you want to implement in the salmoquant pipeline. Here are some suggestions, ranging from easier to more complicated tasks:

- Update the template README file with information about the pipeline
- Update the `CITATIONS.md` file with the Salmon citation
- Use the `strandedness` column from the samplesheet to provide the `libType` argument to Salmon
- Add FASTQ validation using `fq lint`
- Concatenate different FASTQ files for the same samples before running MultiQC (use the nf-core `cat/fastq` module)
- Add a module to build the Salmon index from a transcriptome FASTA file (as an alternative when not provided externally)
- Implement Kallisto as an alternative tool for pseudoalignment

### 3.2: Create a PR Proposing Changes

Complete these steps to submit your contribution:

1. Fork [https://github.com/nfdata-omics/salmoquant](https://github.com/nfdata-omics/salmoquant) to your personal namespace
2. Create a feature branch on your fork (starting from `dev`)
3. Open a new GitHub codespace from your fork on your feature branch.
4. Work on your changes, ensuring your code passes linting and testing steps
5. Commit and push the changes to the feature branch on your fork
6. Open a pull request to nfdata-omics/salmoquant

---

## Summary Checklist

By completing these exercises, you should be able to:

- [ ] Understand the GitHub development cycle and workflow
- [ ] Fork and clone repositories for contribution
- [ ] Create feature branches from the appropriate base branch
- [ ] Open pull requests with clear descriptions
- [ ] Respond to code review feedback and iterate on changes
- [ ] See your changes merged and integrated into the project
- [ ] Complete a full contribution cycle on your own pipeline

---

## Resources

- **nf-core website**: [https://nf-co.re/](https://nf-co.re/)
- **nf-core Slack**: [https://nf-co.re/join/slack](https://nf-co.re/join/slack)
- **GitHub Guides**: [https://guides.github.com/](https://guides.github.com/)
- **Nextflow Documentation**: [https://www.nextflow.io/docs/latest/](https://www.nextflow.io/docs/latest/)