---
name: pr-walkthrough
description: Teach a pull request in plain English with a detailed, code-backed walkthrough of every changed file. Use when someone wants to understand a PR, trace its behavior through the codebase, or review unfamiliar code.
disable-model-invocation: true
---

# PR Walkthrough

Accept a full GitHub PR URL such as `https://github.com/{owner}/{repo}/pull/{number}` or a bare PR number. Resolve a bare number in the current repository.

Read the PR with the user like two teammates looking through the code together.

## Build the mental model

Start with the problem, the old behavior, and the new behavior. Name the main boundaries. Trace one representative request, event, or data object through the system before discussing individual files. Explain unfamiliar project terms when they first appear.

Use `uvx termaid` when a small diagram explains file relationships, ownership, or control flow better than prose. Render diagrams with `uvx termaid` and paste the rendered output in a `text` code fence. Pass `--ascii` only when another instruction requires ASCII or the destination cannot render Unicode box-drawing characters. Never paste raw Mermaid source or use a `mermaid` code fence.

## Choose a teaching order

Cover every changed file in the order that teaches the behavior best. Group files into a few coherent stages such as protocol, producer, transport, consumer, and verification.

Classify each file before writing:

- **Primary:** Implements core control flow, state, lifecycle, concurrency, authorization, transport, or a public interface
- **Supporting:** Wires a primary change into another layer, updates types or exports, or supplies configuration
- **Routine:** Contains a fixture, generated output, or a mechanical test/call-site update

Spend most of the walkthrough on primary files. Give supporting files enough context to explain their role. Keep routine files short.

## Walk through each file

For every file, explain:

1. What responsibility the file had before this PR
2. What changed in this PR
3. How the important code executes, including inputs, state changes, branches, and outputs
4. Why the change belongs in this file
5. Which earlier or later file consumes the result

Do not reduce a behavioral file to one summary sentence. A reader should understand its contribution without opening the diff.

For every primary file, quote small excerpts from the PR and walk through them. Use 3 to 15 lines at a time. Prefer:

- A before-and-after excerpt when the change replaces an old mechanism
- The new branch or state transition when behavior depends on control flow
- The type or function signature when it defines a boundary
- A focused test excerpt when the test makes the contract clearest

Trim unrelated code. Mark omitted regions with `...`. Never invent code that looks like a quote. Label pseudocode as pseudocode.

After each excerpt, explain execution order and intent. Do not merely translate each line into English. Call out the invariant the code preserves and why a simpler-looking alternative would fail when that matters.

For tests, describe the scenario, stimulus, observed result, and guarantee. Do not stop at "adds coverage."

## Review while teaching

Mention bugs, risks, missing coverage, and tradeoffs beside the relevant code. Distinguish a confirmed defect from a residual risk or deliberate limitation. Keep the review inside the walkthrough.

Prefer a long walkthrough over compressing complex files into a file inventory. Large PRs may need several substantial sections. Keep every changed file visible in the final answer.

## Depth check

Before sending, verify:

1. Could the reader narrate the end-to-end flow without opening the PR?
2. Does every primary file include real code and an explanation of how it runs?
3. Do test descriptions state the behavior they prove?
4. Does every changed file have a specific role in the walkthrough?
5. Would any paragraph still fit an unrelated PR after changing the filename? If yes, rewrite it with concrete code and behavior.
6. Does the answer read mainly as a list of files? If yes, expand the primary files before sending.

Before sending, read `../prose-cleanup/SKILL.md` and apply it to the walkthrough.
