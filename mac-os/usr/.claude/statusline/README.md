# Statusline segments

Each `<name>.sh` here is sourced by `~/.claude/statusline.sh` and provides
one or more imports. An import named in `statuslineconfig.json` (under
`segments.<segment>.import`) is a trio of functions:

1. `<import>_filter`: prints a jq expression extracting the fields the
   formatter needs from the statusline JSON Claude Code pipes in. Each value
   the expression emits becomes one positional argument to `<import>`.
   Optional: without it the formatter is called with no arguments.
2. `<import>_icon`: prints the segment's default icon. A profile `icons`
   array overrides it; an empty entry hides the icon.
3. `<import>`: prints the segment body from the filter's fields (`$1`..`$n`).
   Missing fields arrive as empty strings; always print a placeholder (`?`)
   rather than nothing, so segments never pop in and out.

The engine wraps every active import's filter in parentheses and joins them
into one jq program, separated by `"\u001e"` sentinels, so the input JSON is
parsed once per render no matter how many segments are active. Two
consequences:

1. A broken filter fails the whole program; every formatter then runs with
   no arguments and renders its placeholders.
2. Fields are split on newlines, so a filter must emit a fixed number of
   single-line values (numbers, or strings without newlines).

Adding a segment:

1. Create `<name>.sh` here with the trio above.
2. Register it in `statuslineconfig.json` under `segments` as
   `{ "file": "<name>.sh", "import": "<function>" }`.
3. Add it to a profile's `segments` array.
4. Track the file in `mac-os/setup/internal/dotfiles.sh`.
