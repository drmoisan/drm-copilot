# Guard Detection Over the Bundled Mirror Tree — Zero Findings — [P14-T2]

Timestamp: 2026-08-15T18-42

Command: one-off `pwsh -NoProfile -File <scratchpad>/scan-tree.ps1` that dot-sources `tests/scripts/claude-runtime/EnforcementHooksNoPythonInvocation.Helpers.ps1`, enumerates `extensions/drm-copilot/resources/claude-customizations/.claude/hooks` and `.../.claude/lib` recursively (`*.ps1`, `*.psm1`, excluding `lib/bash`), and runs `Get-PythonInvocationFinding` over every enumerated file with the same detection helper the guard suite uses.

EXIT_CODE: 0

Output Summary: zero findings across the bundled mirror tree over 55 enumerated files.

## Result

```
TREE: bundled mirror tree
ROOT_A: extensions/drm-copilot/resources/claude-customizations/.claude/hooks
ROOT_B: extensions/drm-copilot/resources/claude-customizations/.claude/lib
ENUMERATED_FILE_COUNT: 55
ALLOWLIST_ENTRY_COUNT: 0
PATHS_UNDER_EXTENSIONS: 55
FINDING_COUNT: 0
```

## Why This Verification Is Separate

The mirror tree is OUT of the guard suite's scan scope by design: the guard's scan roots are
anchored at `<repoRoot>/.claude/hooks` and `<repoRoot>/.claude/lib` only, and the suite
carries an explicit assertion that the enumerated file set contains no path under
`extensions/` (confirmed by `PATHS_UNDER_EXTENSIONS: 0` in the `[P14-T1]` guarded-tree run).
The mirror is deliberately NOT allowlisted either, because allowlist keys are
repo-root-relative paths. This task therefore runs the same detection helper over the mirror
tree explicitly rather than widening the guard's roots.

## Consistency With the Byte-Identity Contract

Both trees enumerate exactly 55 files and both report zero findings. That is the expected
result given the `[P12-T10]` byte-identity ledger: all seventeen changed or new `.claude/**`
files are byte-identical between the repository tree and the bundle mirror
(`MISMATCH_COUNT = 0`), and the Python contract test
`test_bundled_claude_payload_contains_all_repo_runtime_contracts` passes. A destination that
receives the pushed-down pack therefore gets hook and library sources that name no Python
interpreter on any code path — identical behavior to the repository tree.

## Standing Constraint Satisfied

No hook names a Python interpreter on any code path, in either the repository tree
(`[P14-T1]`, 0 findings over 55 files) or the bundle mirror tree (this artifact, 0 findings
over 55 files). Detection covers all four classes: constant-command invocation of
`python`/`python3`/`py`/`poetry` (bare, `&`, or `.`, including quoted constants);
`Start-Process` with a matching `-FilePath` or first-positional constant; fail-closed dynamic
invocation with the two documented carve-outs; and any `Invoke-Expression`.
