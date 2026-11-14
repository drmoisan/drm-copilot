# Task Check: P2-T6 (remediation cycle 1, F2 requirement documents)

Timestamp: 2026-11-14T14-39
Command: wc -l spec.md user-story.md (before and after); grep -c on the asserted tokens
EXIT_CODE: 0
Output Summary: the unchecked user-story AC4 registration bullet now states spec D31 branch B (registry membership of the three tool names in the four pretooluse-dispatch.json registries, the Codex dispatcher timeout equal to the sum of its member timeouts, the new files in both core.json manifests, and the six proving tests); it contains pretooluse-dispatch.json and "sum of its member timeouts" and no longer names .claude/settings.json; it stays unchecked. In spec.md, the D30 entry references (heading entry number, entry path, earlier-entry range ending at 0011, revert-order sentence, reduction token) and the AC5 bullet's entry path name entry 0012 (0012-local-lane-exclusion.md); the version-history line is unchanged. Line counts are unchanged: spec.md 353, user-story.md 77.

## Changed Files

- docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/user-story.md (one bullet replaced in place)
- docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/spec.md (D30 and AC5 text replaced in place)

## Selection and Rule

No test selection: feature requirement documents are read by no contract test. Neither file is in a ledger region (P0-T2).

| Command | EXIT_CODE |
|---|---|
| wc -l before and after (353 and 77 both times) | 0 |
| token checks on user-story.md and spec.md | 0 |
