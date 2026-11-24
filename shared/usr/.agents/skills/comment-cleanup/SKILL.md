---
name: comment-cleanup
description: Cleans up the comments a change touched by applying the prose-cleanup rules plus comment-specific rules.
disable-model-invocation: true
---

# Comment Cleanup

A manual style pass over the comments in a change. Apply the rules in `~/.agents/skills/prose-cleanup/SKILL.md` plus the rules below. Edit the comments in place, like an auto-formatter; don't flag them for review.

Write for other engineers on the team, who already know the product.

## Scope

Only touch comments the change added or modified; leave the rest alone unless asked. Never change code behavior. If a comment only restates the code, delete it rather than reword it. One exception: keep comment text that renders into output, such as generated CLI help or published API docs, even when it reads like a restatement.

## Rules

1. **Don't relist contents in a header.** A header comment on a method, struct, or enum that just relists its steps, fields, or variants adds nothing and rots as the code changes; delete it or keep only a non-obvious reason. Keep a one-sentence header on what the function does or returns when the name doesn't already say it. A header that states what a function errors on is fine. Comments inside a body that describe what it does are fine.
2. **Argument docs are ordered lists.** An entry earns its line by saying something the signature doesn't.
3. **Don't put the design doc in a comment.** Describe the code under the comment and leave out how the rest of the feature works. If an edit in another file could make the comment false, delete it.
4. **Don't say who set a value.** Phrases like "what staff typed" or "which staff add" state the obvious. For a nullable field, say what null means.
5. **Don't mention what isn't built.** Cut "stand-in", "for now", and "until X exists".

Rule 1 is the subtle one. Examples:

1. `// Loops over each user, adds the active ones to the result, and returns it` above `func ActiveUsers(...)` -> delete. Keep only a real _why_, e.g. `// Suspended accounts count as inactive.`
2. `// Config holds the host, port, timeout, and retry count` -> `// Config for the upstream connection.`
3. `// Status is one of Pending, Active, or Closed` -> `// Lifecycle state of an order.`, or delete.
4. `/** A new contest's dates. It starts on the first Saturday after today that also leaves the cooldown after the last contest's building, builds through the Sunday of the next weekend, and announces its winners that Friday. */` above `scheduleAfter` -> `` /** The default schedule for the contest after `last`. */ ``

Examples for rules 3 and 4:

1. Eight lines on scheduling and judging above `model Contest` -> `// A themed contest that teams of Creators enter Games in.`
2. `// Whether a picture is a contest image's shape. No screen crops or stretches the image, so every contest's has to be this shape.` -> `// Contest images are 3:1.` The screens that show the image decide whether it's cropped.
3. `// The credits an honorable mention gives its team: what staff typed, or null for the default the contest was saved with.` -> `` // Credits for an honorable mention. Null uses `mentionDefaultCredits`. ``

If a reader can quickly recover everything a comment says from the code, delete it.
