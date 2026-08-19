---
name: comment-cleanup
description: Cleans up the comments a change touched by applying the prose-cleanup rules plus comment-specific rules, like no header comments that relist their contents.
disable-model-invocation: true
---

# Comment Cleanup

A manual style pass over the comments in a change. Apply the rules in `~/.claude/skills/prose-cleanup/SKILL.md` plus the rules below. Edit the comments in place, like an auto-formatter; don't flag them for review.

## Scope

Only touch comments the change added or modified; leave the rest alone unless asked. Never change code behavior. If a comment only restates the code, delete it rather than reword it. One exception: keep comment text that renders into output, such as generated CLI help or published API docs, even when it reads like a restatement.

## Rules

1. **Don't relist contents in a header.** A header comment on a method, struct, or enum that just relists its steps, fields, or variants adds nothing and rots as the code changes; delete it or keep only a non-obvious reason. Comments inside a body that describe what it does are fine.
2. **Argument docs are ordered lists.** An entry earns its line by saying something the signature doesn't.

Rule 1 is the subtle one. Examples:

1. `// Loops over each user, adds the active ones to the result, and returns it` above `func ActiveUsers(...)` -> delete. Keep only a real _why_, e.g. `// Suspended accounts count as inactive.`
2. `// Config holds the host, port, timeout, and retry count` -> `// Config for the upstream connection.`
3. `// Status is one of Pending, Active, or Closed` -> `// Lifecycle state of an order.`, or delete.

If a reader can quickly recover everything a comment says from the code, delete it.
