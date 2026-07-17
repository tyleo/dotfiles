# Statusline segments (Windows)

Each `<name>.ps1` here is dot-sourced by `statusline.ps1` and provides one
or more imports. An import named in `statuslineconfig.json` (under
`segments.<segment>.import`) is a pair of functions:

1. `<Import>Icon`: returns the segment's default icon. A profile `icons`
   array overrides it; an empty entry hides the icon.
2. `<Import>`: returns the segment body from the parsed statusline JSON
   object passed as its argument. Missing fields must render a placeholder
   (`?`) rather than nothing, so segments never pop in and out.

Unlike the bash engine (`mac-os/usr/.claude/statusline/README.md`) there is
no filter companion: PowerShell parses the input JSON natively in one pass,
so formatters read fields straight off the object.

Adding a segment:

1. Create `<name>.ps1` here with the pair above.
2. Register it in `statuslineconfig.json` under `segments` as
   `{ "file": "<name>.ps1", "import": "<Function>" }`.
3. Add it to a profile's `segments` array.
