# Baseline — Python Format (`black --check`)

Timestamp: 2026-08-30T06-22
Task: [P0-T4]
Branch: feature/remove-remaining-python-invocations-599-r2

Command: `poetry run black --check .` (run from the worktree root)

EXIT_CODE: 0

Output Summary: Clean. 458 files would be left unchanged; zero files would be reformatted. The
command's output, reproduced verbatim as captured:

```
All done! ✨ \U0001f370 ✨
458 files would be left unchanged.
```

The first line carries Black's three decorative emoji. They are shown above as the escaped code
points the capturing console emitted (`✨` sparkles, `\U0001f370` shortcake, `✨`
sparkles) rather than as rendered glyphs; this is a console-encoding artifact of the capture, not
part of Black's own output bytes.

## Read-Only Confirmation

`--check` puts Black in check mode: it reports what would change and writes nothing. Exit code 0
means every file is already formatted, so this baseline was not taken after a formatter repaired
pre-existing drift. Black distinguishes its outcomes by exit code in check mode — 0 for no changes
needed, 1 for files that would be reformatted — so the exit code is a valid discriminator here and
the acceptance does not rest on it alone: the `458 files would be left unchanged` count is recorded
above and would read `N files would be reformatted` on a drifted tree.
