---
name: prose-cleanup
description: Cleans up named prose (markdown docs, a section, new text in a change, ...) to a terse, ASCII-only house style with no LLM tells.
disable-model-invocation: true
---

# Prose Cleanup

A manual style pass over prose. The invocation names the target. Edit the text in place, like an auto-formatter; don't flag it for review.

## Scope

Only touch the named target; leave the rest alone. Example invocations:

1. `/prose-cleanup the .md documents in this change`
2. `/prose-cleanup the "## Refactoring" section`
3. `/prose-cleanup any new prose added by this change`

## Rules

1. **Terse.** Cut filler and lead-ins ("Note that", "In order to", ...). Keep it short but grammatical. A word stays when cutting it would make the claim false or the prose stilted.
2. **ASCII only.** Replace smart quotes, ellipsis (…), arrows (→), and accented/emoji characters with ASCII (straight quotes, `...`, `->`). Find them with `grep -nP "[^\x00-\x7F]" <files>`.
3. **No LLM tells.**
   1. No em or en dashes (— / –), and no `-` or `--` standing in for one; restructure the sentence instead
   2. No unnecessary parentheticals
   3. No contrast tails ("X but not Y", "X rather than Y") or negatives when they add nothing. A contrast that steers a real choice stays
   4. No buried verbs ("X is Y" stating a rule); give the relation the verb that names it best (sets, decides, limits, ...). Genuine identities stay
   5. No redundant "own": write "the X's Y", never "the X's own Y". Keep "own" only where it marks a separate, dedicated thing
   6. No yoked clauses: two facts bolted together with "and" ("X declares its list, and `--flag` holds the rules"). Fold them into one claim or give each its own sentence. Coordination stays when both clauses carry one thought
   7. No "so" chains: sentence after sentence hinging on "X, so Y". Bind the reason in with "because", or give each fact its own sentence. One "so" in a stretch of prose is fine
   8. No comma-hung tails: a clause dangling off a comma ("lists `face` first, since the flag order sets the numbers") binds into the sentence instead ("lists `face` first because the flag order sets the numbers")
4. **Ordered lists.** Break a long series of facts into a numbered list; items carry no terminal punctuation.
5. **Periods over semicolons.** Split independent clauses into sentences. Readability beats terseness. An occasional semicolon is fine when the clauses are tightly paired; chains of them are not.

## Voice

Spend a word to save a reread. Don't trade one-pass parseability for density.

1. **Make the concrete thing the subject.** Name the flag, function, or expression and show it instead of describing it. `The fix is a catch-all: app.get("*", notFound) claims whatever no route matched`, not `a final route that matches the complement of the registered paths`.
2. **Repeat the noun.** As facts pile up, a pronoun makes the reader backtrack. "Errors use the byte offsets", not "errors use them".
3. **Narrate, don't legislate.** State the starting point, then what can happen, with "can" for options: `The pool starts with one idle connection. The first checkout takes it, and each further checkout opens another.` Don't chain timeless rules with "therefore".
4. **Keep the true actor.** "materials are declared by use" beats "materials declare by use" because materials don't declare anything. Swap "is" only for an everyday verb whose subject really acts.
5. **Every clause gets its own verb.** No verbless mid-sentence insertions ("any expression, a defined name the simplest, and ..."). A preposition or a small word ("with", "can") is cheaper than a reread.
6. **One claim per sentence, nothing extra.** Cut rationale tails the reader doesn't need ("because the spec forbids an empty one"), enumerations of what the next lines show anyway, metaphors, and inferential connectives. A why earns its place when it stops a wrong edit or a wrong reading.
