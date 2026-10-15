# Code Review: ci-green-gate-all-checks-and-codex-parity (Issue #899, also #891)

- Timestamp: 2026-10-12T18-25
- Reviewer: feature-review agent (reduced minor-audit re-audit, remediation cycle 2 exit)
- Branch: `bug/ci-green-gate-all-checks-and-codex-parity-899`, HEAD `e32cce737c072bef90a724dd7d97e23dd06b2566`
- Base: `origin/main` @ `7d9a5c33526d7a98d5577ab4a9ad6f465f3dff3c`; diff `git diff origin/main...HEAD`
- Companion artifacts: `policy-audit.2026-10-12T18-25.md`, `feature-audit.2026-10-12T18-25.md`
- Prior review: `code-review.2026-10-12T16-45.md` (0 Blocking; CR-1, CR-2 Minor; CR-3, CR-4 Info)

## Executive Summary

Since the prior review the branch gained two code-surface edits (cycle 2) and a merge of `origin/main`. Both edits are correct and minimal:

1. `.claude/agents/parallel-orchestrator.md` (and mirror) adds `Bash(pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1*)`. The Merge-on-Green step 2 invocation `pwsh -NoProfile -File .claude/lib/ci-gate/Invoke-CiGateParser.ps1 -ChecksJson <checks-json> -HeadSha <headRefOid>` matches this prefix exactly, including the `-NoProfile -File` flag order. The grant admits only the parser script and adds no general `pwsh` capability.
2. Merge-on-Green step 2 (and mirror) renders the error text as `"no checks reported"` instead of a backticked span. This removes the false command detection by the permission contract test without changing meaning. The backticked pins in the S9 and Codex-gate fragment sets are unaffected because they apply to other sections.

The merge of `origin/main` auto-merged the persona `tools:` list; the #890 grant (`mutate-parallel-run.sh*`) and the #899 parser grant are both present, and the #890 removal of the `poetry run python -c *` grant is preserved. Mirrors are byte-identical (reviewer `cmp`).

No Blocking code finding. CR-1 to CR-4 are re-evaluated below and remain non-blocking. One new Info finding (CR-5) is recorded.

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Minor | `.claude/skills/parallel-orchestrate/SKILL.md`; `.agents/skills/orchestrate/SKILL.md` (and mirrors) | Merge-on-Green step 2; `## CI Green Gate` steps 3 and 5 | CR-1 (carried, unchanged): both surfaces run the parser without `-RequireWorkflow CI` on a non-epic PR and address only the "no checks reported" error. If `gh pr checks --json` returns an empty array instead of that error, the parser returns `success` for the empty set. S9 closes this with "The parser is never run with `-ChecksJson '[]'` without `-RequireWorkflow CI`"; the other two surfaces carry no equivalent sentence. | Follow-up: add one sentence to each surface stating that an empty check list is not green, and pin it in the contract module. | The risk depends on `gh` CLI behavior for zero checks, which currently emits the error. Cycle 2 did not touch this wording. | `.claude/skills/parallel-orchestrate/SKILL.md:378-386`; parser help lines 17-25 |
| Minor | `.claude/lib/ci-gate/Invoke-CiGateParser.ps1` | lines 104 and 338 (pre-existing) | CR-2 (carried, unchanged): default delegates format with `'yyyy-MM-ddTHH:mm:ssZ'`; `:` is the culture time separator in .NET custom formats, so `verified_at` is not guaranteed ISO-8601 on every culture. Tests use `?` wildcards for the separator. | Follow-up: pass `InvariantCulture` in both defaults and tighten the assertions. | Pre-existing behavior; out of scope for #899/#891. | `tests/scripts/claude-lib/ci-gate/Invoke-CiGateParser.Tests.ps1:420-423` |
| Info | `scripts/dev_tools/generate_codex_agent_variants.py` (not changed) | write path | CR-3 (carried): the generator writes CRLF on Windows. The committed TOML files carry 0 CR bytes (reviewer count at HEAD) and `--check` exits 0. | Follow-up candidate: write output with `newline="\n"`. | Pre-existing tooling behavior; committed result is correct. | `evidence/other/codex-variants-regenerate.2026-10-11T09-44.md` |
| Info | `tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` | fragment constants | CR-4 (carried): exact-fragment pins require test updates on rewording. | None required. | Established pattern in sibling contract modules. | Module docstring |
| Info | `.claude/agents/parallel-orchestrator.md` | `tools:` line 24 | CR-5 (new): the parser grant uses `-NoProfile -File` while the adjacent drift-detection grant uses `-NoProfile -NonInteractive -File`. Each grant matches its own prescribed invocation, so the difference is consistent, but adding `-NonInteractive` to the procedure text later would require changing the grant in the same edit. | None required now; keep the grant and the Merge-on-Green invocation text in lockstep. | The permission contract test enforces the pairing, so drift is caught. | `test_parallel_orchestrator_permission_contracts.py` passed at HEAD |

## Detailed Notes

### Cycle 2 grant scope

- The grant pattern ends with `*` after the script path, so it admits any arguments to `Invoke-CiGateParser.ps1` and nothing else. It does not admit other scripts under `.claude/lib/ci-gate/` beyond names that share the prefix; no such file exists (`ls .claude/lib/ci-gate` contains only the parser).
- Placement after the `Invoke-ParallelDriftDetection.ps1` grant follows `remediation-inputs.2026-10-12T17-20.md` R-2 and avoided the #890 edit region; the subsequent merge confirmed no conflict.
- No `.claude/settings.json` change; the grant is persona-scoped.

### No-checks wording

- `.claude/skills/parallel-orchestrate/SKILL.md:384` now reads `... or when \`gh pr checks\` fails with a "no checks reported" error, do not record ...`. The `gh pr checks` command span remains backticked and is covered by the existing `Bash(gh *)` grant.
- `evidence/remediation-baseline/pin-survey-no-checks.2026-10-12T17-20.md` shows no contract pin applies the backticked form to the Merge-on-Green section; `MERGE_ON_GREEN_FRAGMENTS` does not contain the string. The reviewer run of `test_ci_gate_all_checks_contracts.py` at HEAD passed.

### Unchanged since the prior review

- `git diff --stat a14899f7b HEAD -- .claude/lib/ci-gate tests/scripts/claude-lib/ci-gate tests/scripts/dev_tools/test_ci_gate_all_checks_contracts.py` is empty. The prior notes on S9 correctness, Codex parity, and test design still apply.

## Verdict

No Blocking code finding. Non-blocking: 2 Minor (CR-1, CR-2) and 3 Info (CR-3, CR-4, CR-5).
