# Final QA — Evidence-Location Validator

Task: `[P5-T11]`
Timestamp: 2026-09-07T23-02
Feature: enforcement-hook-trigger-matches-whole-command-text (#545)

**Result: PASS.** The validator exited 0 and printed nothing.

## Command 1 — the validator

Command: `python scripts/dev_tools/validate_evidence_locations.py --root .`
EXIT_CODE: 0
Observed stdout: **(no output)**
Observed stderr: **(no output)**

A clean run of this validator prints no lines at all. It emits one
`VIOLATION: <path> — use <path> instead` line per violation and exits 1 when it finds any, so an
empty stdout paired with exit 0 is the expected clean-run shape and is recorded here verbatim as
`(no output)` rather than paraphrased.

A non-empty stdout with exit 0 is not a possible outcome of this tool and would have to be reported
rather than recorded as a pass. That case did not occur: stdout was empty.

## Command 2 — the `artifacts/` listing

Command: `ls -1 artifacts/ 2>/dev/null | sort`
EXIT_CODE: 0
Observed output:

```
orchestration/
pester/
```

Two entries.

- `artifacts/orchestration/` is the sole `artifacts/` sub-path the evidence conventions permit, and
  it is permitted for orchestration checkpoint use only, not for evidence output. It holds the
  orchestrator-state checkpoint, not evidence.
- `artifacts/pester/` holds `pester-junit.xml` and `powershell-coverage.xml`, the raw tool output the
  PoshQC test runner writes. It is toolchain output read by evidence artifacts, not an evidence
  location, and it is not on the forbidden list.

No other `artifacts/` sub-path exists in this worktree.

## Forbidden-path declaration

**No path this plan wrote falls under any of the eight forbidden `artifacts/` sub-paths:**

| Forbidden sub-path | Present in this worktree | Written to by this plan |
|---|---|---|
| `artifacts/baselines/` | no | no |
| `artifacts/baseline/` | no | no |
| `artifacts/qa/` | no | no |
| `artifacts/qa-gates/` | no | no |
| `artifacts/evidence/` | no | no |
| `artifacts/coverage/` | no | no |
| `artifacts/regression-testing/` | no | no |
| `artifacts/post-change/` | no | no |

Eight of eight absent from the tree and eight of eight unwritten. The `ls -1 artifacts/` output above
is the direct evidence: only `orchestration/` and `pester/` exist, and neither appears in the
forbidden list.

## Canonical evidence locations actually used

Every artifact this plan wrote resolves under
`docs/features/active/2026-08-25-enforcement-hook-trigger-matches-whole-command-text-545/evidence/<kind>/`.

Command: `ls -1 <FEATURE>/evidence/`
EXIT_CODE: 0
Observed output:

```
baseline/
issue-updates/
other/
qa-gates/
regression-testing/
remediation-baseline/
```

Six sub-folders, all six on the canonical list defined by
`.claude/skills/evidence-and-timestamp-conventions/SKILL.md`. No non-canonical sub-folder exists.

`EVIDENCE_LOCATION_OVERRIDE_REJECTED:` — no entry. No caller, plan task, or delegation prompt in this
cycle supplied a non-canonical evidence path, so no substitution was required and none is recorded.

## Output Summary

`python scripts/dev_tools/validate_evidence_locations.py --root .` exited 0 with empty stdout —
`(no output)` — which is the tool's clean-run shape. `ls -1 artifacts/ | sort` returns exactly
`orchestration/` and `pester/`; neither is a forbidden evidence sub-path and neither is used for
evidence. All eight forbidden `artifacts/` sub-paths are absent from the tree and none was written by
this plan. All six evidence sub-folders in use are canonical. No evidence-location override was
supplied or rejected.
