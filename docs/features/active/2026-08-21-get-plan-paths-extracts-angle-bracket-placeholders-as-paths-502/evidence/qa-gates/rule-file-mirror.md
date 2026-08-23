# QA Gate — Bundled Mirror Parity — [P6-T3]

Timestamp: 2026-08-23T03-10

Feature: 2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502 (issue #502)
Task: [P6-T3]

Command: `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts`

EXIT_CODE: 0

Output Summary:

```text
.                                                                        [100%]
1 passed in 0.10s
```

## What the passing test establishes

The test enumerates every non-memory file under the repository `.claude` tree and asserts, for each,
both that the path exists in the bundled payload and that the bundled text equals the repository
text. It is therefore a byte-identical mirror assertion over the whole runtime surface, not a
spot check, and it covers all three of this item's `.claude` changes at once:

| Change | Repository file | Bundled counterpart |
| --- | --- | --- |
| new module ([P3-T1], [P4-T1]) | `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` | `extensions/drm-copilot/resources/claude-customizations/.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` |
| changed extraction module ([P3-T2], [P3-T3], [P4-T2]) | `.claude/lib/blast-radius/BlastRadiusExtraction.psm1` | the same path under the bundled root |
| amended rule file ([P6-T1], [P6-T2]) | `.claude/rules/parallel-orchestration.md` | the same path under the bundled root |

Independent `diff` and MD5 comparisons of the two module pairs were also taken at [P4-T6]; both
reported no difference. This test is the stronger of the two checks because it is exhaustive over the
tree rather than scoped to named files, so a mirror this item forgot would also fail it.

## Environment note

Before the run, the gitignored runtime-state directory `.claude/state` was removed. The test's file
enumeration is a plain recursive walk of the `.claude` tree and does not consult `.gitignore`, so a
transient batch-budget state file written by a PreToolUse hook during the session appears to the test
as an unmirrored repository file and fails it. Removing the directory is the repository's established
practice at a batch boundary and is recorded in prior feature evidence under the same reasoning; it
also serves as the batch close between phases, which the PowerShell change-budget rule prescribes
when a batch would otherwise exceed its per-batch file cap.

The removal is not a weakening of this gate. The files removed are regenerable session state, are
excluded from version control, and are not part of the runtime contract the test asserts. The gate's
subject — the mirrored `.claude` payload — is unaffected by their presence or absence.

## Output Summary

Exit code 0, 1 passed. The bundled `.claude` payload is byte-identical to the repository `.claude`
tree across every non-memory file, which confirms the mirrors for the new token-shape module, the
changed extraction module, and the amended `parallel-orchestration.md` rule file.
