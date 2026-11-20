# Policy Compliance Audit — parallel-merge-gate-allow-branch (Issue #492)

- Timestamp: 2026-08-19T09-17
- Branch: `bug/parallel-merge-gate-allow-branch-492` (commit d6040ace)
- Base: `origin/main`
- Work Mode: minor-audit (from `issue.md`)
- Scope: full branch diff `git diff origin/main...HEAD` (3 `.ps1` files, 17 `.md` files)

## Scope Note (PR context artifacts)

The PR context artifacts `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`
are STALE: they record head ref `fix/epic-run-cross-branch-kickoff-discovery @ a85d0726` and base
`67c871eb`, which belong to a different feature, not this branch. They were not regenerated because
the `gh` CLI is unavailable in this environment (the summary itself reports "GitHub CLI unavailable")
and the task supplied the authoritative diff directly. The audit scope is therefore the resolved
base `origin/main` and the direct `git diff origin/main...HEAD`, which is a legitimate scope source
under the Scope Invariant. This does not narrow scope; it is the full branch diff.

## Rejected Scope Narrowing

None. The caller prompt requested the full-branch-vs-base audit and did not attempt to narrow scope
to a plan, task, phase, or file subset. No narrowing was rejected.

## Languages With Changed Files

| Language | Changed files | Coverage verdict |
|---|---|---|
| PowerShell | `enforce-epic-merge-gate.ps1` (hook + bundle mirror), `enforce-epic-merge-gate.Tests.ps1` | PASS |
| Markdown (non-code) | 17 files (docs, evidence, issue, plan, research, doc mirrors) | not a coverage language |

No TypeScript, Python, or C# files changed on this branch; coverage verdicts for those languages
are not applicable (zero changed files).

## Coverage Verification (PowerShell)

Verified from the pre-existing coverage artifact `artifacts/pester/powershell-coverage.xml`
(JaCoCo XML), not regenerated.

- Changed production file: `.claude/hooks/enforce-epic-merge-gate.ps1` (modified file; the bundle
  mirror is byte-identical and not separately measured).
- File-level line coverage parsed from the artifact: covered=100, missed=5, total=105 -> 95.24%.
  The 5 missed lines are confined to the host-bound `<script>` entrypoint method (env read,
  try/catch, `exit`), which pre-existed and is unchanged by this branch.
- Changed-lines coverage: the change added 29 executable lines; covered count rose 71 -> 100 with
  missed unchanged at 5, so every newly added executable line is covered -> 100% (29/29).
- Line coverage >= 85%: PASS (95.24%). No regression on changed lines: PASS.
- Branch coverage: not applicable. Pester measures command/line coverage only; there is no
  PowerShell branch-coverage gate (`.claude/rules/powershell.md`, `.claude/rules/quality-tiers.md`).
  Absence of a branch figure is not recorded as FAIL.

Verdict: PASS.

## Evidence Location Compliance

`validate_evidence_locations.py --root .` exited 0 (no violations). The branch diff writes no files
under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or `artifacts/coverage/`. All
feature evidence is under the canonical `docs/features/active/2026-08-19-parallel-merge-gate-allow-branch-492/evidence/<kind>/`.

Verdict: PASS.

## Toolchain (verified from evidence artifacts)

| Stage | Evidence | Result |
|---|---|---|
| Format (PoshQC / Invoke-Formatter) | `evidence/qa-gates/qc-poshqc-format.md` | PASS (ok:true, idempotent, mirrors byte-identical) |
| Lint (PSScriptAnalyzer) | `evidence/qa-gates/qc-poshqc-analyze.md` | PASS (Error 0 / Warning 0 / Information 0) |
| Type check | n/a for PowerShell | n/a |
| Unit tests (Pester) | `evidence/qa-gates/qc-pester-coverage.md` | PASS (820 total pass; 51 in the target suite) |
| Coverage | `artifacts/pester/powershell-coverage.xml`, `evidence/qa-gates/qc-coverage-delta.md` | PASS (95.24%; changed-lines 100%) |

The reviewer did not rerun any toolchain stage; verdicts derive from inspecting the recorded
evidence artifacts and the coverage artifact.

## Policy Rule Compliance

### `.claude/rules/powershell.md` — PASS
- All functions are advanced functions with `[CmdletBinding()]`, `[OutputType(...)]`, and named
  parameters. New function `Test-ParallelCheckpointAllowsMerge` and read seam
  `Get-ParallelOrchestratorCheckpointContent` follow the pattern.
- Approved verbs used (`Get-`, `Test-`, `Invoke-`, `ConvertFrom-`). PSScriptAnalyzer reports 0
  findings.
- Filesystem access isolated behind injectable read-seam wrapper functions (design-seam option 3).
  No `Invoke-Expression`, no plaintext secrets, no hard-coded credentials.
- File length 408 lines (< 500 limit). Change budget: 1 production file plus 1 byte-identical
  bundle mirror and 1 test file — within the direct-mode and per-batch caps.

### `.claude/rules/general-code-change.md` — PASS
- Fail-fast / fail-closed posture: absent, unreadable, or invalid checkpoints deny. The single
  `catch` in `ConvertFrom-EpicMergeGateJson` returns `$null` deliberately to fail closed; this is a
  documented, intentional conversion of malformed input into a deny, not a silent swallow of an
  operational error. Acceptable under the fail-fast rule.
- Additive design: the parallel branch is appended after the child and epic branches; the existing
  branches are unchanged (see feature-audit AC4).

### `.claude/rules/general-unit-test.md` — PASS
- Tests are independent, isolated (one behavior per `It`), deterministic, and use no external
  services. Filesystem boundary is mocked via `Test-Path`/`Get-Content` parameter filters and via
  the read-seam functions; no temporary files are created (grep confirmed: no `TestDrive`,
  `New-TemporaryFile`, `Out-File`, `Set-Content`, or temp-path usage).
- Test file located at `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1`, mirroring the
  production tree; named `*.Tests.ps1`.
- Coverage >= 85% with no changed-line regression.

### `.claude/rules/tonality.md` — PASS
- Doc updates (`parallel-orchestration.md`, `parallel-orchestrate/SKILL.md`) and in-code comments
  use neutral, factual, evidence-first language with no hyperbole, humor, or metaphor.

### `.claude/rules/parallel-orchestration.md` edit — PASS (authorized by objective / AC8)
- The edit adds one line to the Enforcement section describing the merge gate's parallel
  allow-branch. It is factual and consistent with the landed behavior (route_id == "parallel",
  merge_status == "ci_green", pr_number match, otherwise `EPIC_MERGE_GATE_BLOCKED`).
- The baseline policy-compliance rule prohibits modifying documents under `.claude/rules/`. This
  edit is explicitly authorized by the issue objective and AC8, which scope a minimal enforcement
  reference to the merge gate. Per the task instruction it is not flagged as an unauthorized policy
  edit. The edit is minimal (one appended line) and does not alter any existing invariant.

## Blocking Findings

None.

## Verdict

PASS. No policy FAIL and no blocking-PARTIAL finding. Policy blocking_count = 0.
