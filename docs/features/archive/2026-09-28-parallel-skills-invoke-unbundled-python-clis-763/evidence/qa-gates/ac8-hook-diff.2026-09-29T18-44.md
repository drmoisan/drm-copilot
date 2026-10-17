# AC8 Comment-Only Hook Diff (P6-T6)

Timestamp: 2026-09-29T18-44
Command: git diff -U0 12db46245ba7683b5d6ccb676312a4b22a39b0ce -- .claude/hooks/enforce-parallel-abandon-gate.ps1
EXIT_CODE: 0
Output Summary:
- Exactly one hunk; its header is `@@ -28,4 +28,4 @@`.
- Removed lines (28-31 at BASE_SHA):
  `    those variables rather than repeating a literal. The producer side of the same pair is`
  `    scripts/dev_tools/parallel_mutation_abandon_cli.py, and`
  `    tests/scripts/dev_tools/test_parallel_abandon_token_seam.py parses both sides at run`
  `    time so a rename on one side without the other fails.`
- Added lines (28-31):
  `    those variables rather than repeating a literal. The pushed-down producer of the same pair`
  `    is .claude/lib/bash/abandon-parallel-item.sh (the Python CLI it ports remains the parity`
  `    reference), and tests/scripts/dev_tools/test_parallel_abandon_token_seam.py parses every`
  `    side at run time so a rename on one side without the others fails.`
- Every removed and added line lies inside the `<# ... #>` comment block, which ends on line 32
  (`#>`). No removed or added line contains `$script:`.
- The token assignment lines 41 and 42 (`$script:AbandonDispositionToken = ...` and
  `$script:AbandonConfirmToken = ...`) are unchanged; with the P4-T13 seam results (each token
  literal stated exactly once in the hook, the hook pair equal to the CLI pair and to the bash pair)
  this shows the gate's tokens are unchanged.

Diff anchor: BASE_SHA per DV2 (the spec's `git diff main` would attribute sibling integration-branch
commits to this item).
