---
name: comment-cleanup
description: Cleans up the comments a change touched to a terse, ASCII-only house style with no LLM tells and no header comments that relist their contents.
disable-model-invocation: true
---

# Comment Cleanup

A manual style pass over the comments in a change. Apply the rules and edit the comments in place, like an auto-formatter; don't flag them for review.

## Scope

Only touch comments added or modified in the change; leave existing comments elsewhere alone unless asked. Never change code behavior. If a comment only restates the code, delete it rather than reword it. One exception: keep comment text that renders into output, such as generated CLI help or published API docs, even when it reads like a restatement.

## Rules

1. **Terse.** Cut filler and lead-ins ("Note that", "In order to", ...). Keep it short but grammatical. A word stays when cutting it would make the claim false or the prose stilted.
2. **Don't relist contents in a header.** A header comment on a method, struct, or enum that just relists its steps, fields, or variants adds nothing and rots as the code changes; delete it or keep only a non-obvious reason. Comments inside a body that describe what it does are fine.
3. **ASCII only.** Replace smart quotes, ellipsis (…), arrows (→), and accented/emoji characters with ASCII (straight quotes, `...`, `->`). Find them with `grep -nP "[^\x00-\x7F]" <files>`.
4. **No LLM tells.**
   1. No em or en dashes (— / –), and no `-` or `--` standing in for one; restructure the sentence instead
   2. No unnecessary parentheticals
   3. No contrast tails ("X but not Y", "X rather than Y") or negatives when they add nothing. A contrast that steers a real choice stays
   4. No buried verbs ("X is Y" stating a rule); give the relation the verb that names it best (sets, decides, limits, ...). Genuine identities stay
   5. No redundant "own": write "the X's Y", never "the X's own Y". Keep "own" only where it marks a separate, dedicated thing
   6. No yoked clauses: two facts bolted together with "and" ("X declares its list, and `--flag` holds the rules"). Fold them into one claim or give each its own sentence. Coordination stays when both clauses carry one thought
   7. No "so" chains: sentence after sentence hinging on "X, so Y". Bind the reason in with "because", or give each fact its own sentence. One "so" in a stretch of prose is fine
   8. No comma-hung tails: a clause dangling off a comma ("lists `face` first, since the flag order sets the numbers") binds into the sentence instead ("can set its face maps ahead by listing `face` first because the flag order sets the numbers"). Commas pile up fast and every one costs a beat
5. **Ordered lists.** Break a long series of facts into a numbered list; items carry no terminal punctuation. Argument docs take this form. An entry earns its line by saying something the signature doesn't.
6. **Periods over semicolons.** Split independent clauses into sentences. Readability beats terseness. An occasional semicolon is fine when the clauses are tightly paired; chains of them are not.

Rule 2 is the subtle one. Examples:

1. `// Loops over each user, adds the active ones to the result, and returns it` above `func ActiveUsers(...)` -> delete. Keep only a real _why_, e.g. `// Suspended accounts count as inactive.`
2. `// Config holds the host, port, timeout, and retry count` -> `// Config for the upstream connection.`
3. `// Status is one of Pending, Active, or Closed` -> `// Lifecycle state of an order.`, or delete.

If deleting a comment loses nothing a reader couldn't recover from the code quickly, delete it.

## Voice

Spend a word to save a reread. Don't trade one-pass parseability for density.

1. **Make the concrete thing the subject.** Name the flag, function, or expression and show it instead of describing it. `The fix is a catch-all: app.get("*", notFound) claims whatever no route matched`, not `a final route that matches the complement of the registered paths`.
2. **Repeat the noun.** As facts pile up, a pronoun makes the reader backtrack. "Errors use the byte offsets", not "errors use them".
3. **Narrate, don't legislate.** State the starting point, then what can happen, with "can" for options: `The pool starts with one idle connection. The first checkout takes it, and each further checkout opens another.` Not a timeless rule chain joined by "therefore".
4. **Keep the true actor.** "materials are declared by use" beats "materials declare by use" because materials don't declare anything. Swap "is" only for an everyday verb whose subject really acts.
5. **Every clause gets its own verb.** No verbless mid-sentence insertions ("any expression, a defined name the simplest, and ..."). A preposition or a small word ("with", "can") is cheaper than the reread the compression costs.
6. **One claim per sentence, nothing extra.** Cut rationale tails the reader doesn't need ("because the spec forbids an empty one"), enumerations of what the next lines show anyway, metaphors, and inferential connectives. A why earns its place when it stops a wrong edit or a wrong reading.
