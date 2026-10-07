---
name: pr-walkthrough
description: Teach a pull request in plain English with a code-backed walkthrough of every changed file. Use when someone wants to understand a PR.
disable-model-invocation: true
---

# PR Walkthrough

Accept a GitHub PR URL such as `https://github.com/{owner}/{repo}/pull/{number}` or a bare PR number. Resolve a bare number in the current repository.

Read the PR with the user like two teammates looking through the code together. Send the walkthrough as a chat reply, not a file or a PR comment.

## Structure

Write the walkthrough with these headings:

```markdown
## Context

### Definitions

### Problem

### Solution

### Examples

## High-Level Overview

### Subsystems

### Interactions

### Files

## Review

### `path/to/file`

- **Subsystem:** <subsystem>
- **Role:** <role>

#### Concerns

### Plumbing
```

### Context

Context explains the problem and its solution with ideas and examples. It leaves out files, functions, and code. Any subsection can include a `uvx termaid` diagram.

#### Definitions

Defines the project-specific terms, acronyms, and concepts that recur in the walkthrough. Covers only the terms a reader needs to follow the PR.

#### Problem

Describes what the system did before the PR and what was wrong or missing.

#### Solution

Describes the approach the PR takes and what the system does after the PR. Explains the tradeoffs the approach accepts.

#### Examples

Follows one or more concrete scenarios through the system. Prefers scenarios a user drives, such as clicking a button or running a command.

Each example can open with a short setup of the starting state. Then two numbered lists give the steps before the PR and after it. An example has no before list when the scenario was impossible before the PR. Later sections can reuse the first example.

### High-Level Overview

High-Level Overview explains the PR at the subsystem level. Review covers individual files.

#### Subsystems

Groups the changed files by module, service, or layer. Gives each subsystem a name and a one-line responsibility.

#### Interactions

Describes how the subsystems call into each other, what passes between them, and how the PR changes those calls. Maps the first example's steps onto the subsystems by step number instead of retelling the example. Can include a `uvx termaid` diagram of the subsystems and their calls.

#### Files

Lists every changed file in a table with the columns `File`, `Subsystem`, and `Role`. Sorts the rows by role in the order Primary, Supporting, Plumbing, then by subsystem.

### Review

Review walks through every primary and supporting file, subsystem by subsystem, in the order the first example reaches the subsystems. Each file gets a `###` heading with its path. Under the heading, bullets give the file's subsystem and role from the Files table. A test file follows the file it tests. Primary files get most of the space and quoted excerpts.

#### Concerns

Lists problems with the change after a file's explanation. Appears only when the file has concerns. Each item starts with its kind:

- **Bug:** A confirmed defect
- **Risk:** A possible defect the walkthrough could not confirm
- **Missing coverage:** Behavior the tests do not exercise

#### Plumbing

Closes Review with one bullet per plumbing file. Each bullet says what changed. Files with the same mechanical change share a bullet.

## Process

### Understand the PR

Understand the whole PR before writing any section. This skill usually runs inside the PR's repository, so read beyond the diff. Check out the code before and after the PR when full files help. Put each checkout in a temporary `git worktree` so the user's working tree stays untouched. Remove each worktree afterward.

1. Read the PR title, description, and full diff with `gh pr view` and `gh pr diff`
2. Explore callers, callees, and related modules to learn what each file did before the PR and how the change fits in
3. Classify each file's role:
   - **Primary:** Implements the behavior the PR changes
   - **Supporting:** Wires a primary change into another layer, updates types or exports, supplies configuration, or tests the new behavior
   - **Plumbing:** Makes incidental changes the PR needed, such as fixtures, generated output, renames, and mechanical test or call-site updates

### Diagrams

1. Draw a diagram only when it shows a relationship the prose cannot, such as a flow across several parts or a lifecycle
2. Skip any diagram that restates a list or a single step
3. Render every diagram with `uvx termaid` and paste the output in a `text` code fence
4. Pass `--ascii` only when another instruction requires ASCII or the destination cannot render Unicode box-drawing characters
5. Never paste raw Mermaid source or use a `mermaid` code fence

### Walk through each file

For every primary and supporting file, explain what it did before the PR, what changed, and how the new code runs. For a new file, skip what it did before.

Quote excerpts from every primary file:

1. Include the enclosing function signature and any other surrounding code needed to read the excerpt without opening the file
2. Trim the rest and mark omitted regions with `...`
3. Show a before-and-after pair when the PR replaces an old mechanism
4. Explain a line with an added comment that starts with `<-` to set it apart from the PR's comments: `// <- runs even when the query throws`
5. Never present invented code or pseudocode as a quote

After each excerpt, walk through the code in execution order as a numbered list. Each step explains what the code does and why. Point out any invariant the code preserves. Keep single-line notes in the added comments, and repeat one in the list only when it helps the flow.

For a test, list its setup, action, and assertion in order, then state the behavior it proves.

### Before sending

Verify:

1. Could the reader narrate the end-to-end flow without opening the PR?
2. Would any paragraph still fit an unrelated PR after changing the filename? If yes, rewrite it with concrete code and behavior.

Then read `../prose-cleanup/SKILL.md` and apply it to the walkthrough.
