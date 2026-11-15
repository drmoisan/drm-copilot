# Code Review: Preimplementation gate resolves sibling-worktree Bash to the session root (#1188), R4 re-audit

---

**Review Date:** 2026-11-15
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188`
**Feature Folder Selection Rule:** named by the caller; matches the issue number in `issue.md` and the branch `bug/gate-sibling-worktree-pytest-target`
**Base Branch:** `main` (merge base `1df569f65ccdcca86cc9adeb5a1a33ef56f988cb`)
**Head Branch:** `bug/gate-sibling-worktree-pytest-target` at `5f8b15daf20b977cfdba2fa14319e36f6536df67` (PR #1191)
**Review Type:** Re-audit after remediation cycles 1 (R1) and 2 (F2)

---

## Executive Summary

The branch changes 100 files. Beyond the operand extraction reviewed in the initial review (unchanged except for the `--rcfile`/`--init-file` value skip), it now adds the classification supplement `enforce-orchestration-preimplementation-gate-classify.ps1` (116 lines, four byte-identical copies), one guarded dot-source and one supplement call in each gate, the move of `Get-OrchestrationModeDenyReason` into the Codex epic-scope file (Codex gate now 485 lines), classify Cases, suites, and a parity suite, the literal-path rule in six brief copies and two Codex skill copies, and eight Python contract rows.

Evidence reviewed: the PR context summary (generated 2026-11-15 20:39:14 UTC at the reviewed head), the full diff, the cycle 1 and cycle 2 evidence, the reviewer's full Pester gate at the head, the reviewer's targeted pytest run, blob-hash identity of every mirror, and reviewer real-process probes of `Test-ImplementationCommand`, `Get-OrchestrationGateSupplementalPatternIndex`, `Get-OrchestrationGateJoinedWordText`, `Get-OrchestrationGateCommandTargetOperand`, and `Invoke-OrchestrationPreimplementationGateDecision` over 46 command forms on both surfaces, plus a seven-mutant discrimination probe of the classify rows.

R1 is resolved for the named commands: `npm --prefix $(pwd) run lint` (unquoted and quoted) denies `TARGET_WORKTREE_NOT_DERIVABLE`, and `npx --prefix <item> jest` is classified and resolves to the item worktree. F2 is delivered as specified. Two blocking findings remain: R2, a fail-open of the new supplement for a substitution before the command word, and E1, an evidence stamp later than its commit.

**What changed:**
`.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` (+116, new) and three copies; both gates (+2/-1 each; Codex also -17 for the moved block); Codex epic-scope (+17 for the moved block); operands sibling (+1 option-value skip); classify and operands tests; brief and Codex skill text; `tests/scripts/dev_tools/test_bash_command_shape_surfaces.py` (+49).

**Top 3 risks:**
1. Form 1 of the supplement returns no index when the joined-word run starts at a record before the `npm` or `npx` record (R2), so a leading `FOO=$(...)` assignment leaves the command ungated.
2. Wrapper payloads (`sh -c "pytest x"`, `sh -c "npm run lint"`, `pwsh -Command "npm run lint"`) are unclassified by stage 1 on `main` and on this branch; this is pre-existing and outside the item's design (see Info row).
3. Isolated subagents receive the change only after merge, because hooks run from the default branch (stated in the spec rollout section; observed by the reviewer when the session checkout denied the AC-3 launcher form).

**PR readiness recommendation:** **No-Go** until R2 and E1 are fixed in a light remediation cycle.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` (all four copies) | `Get-OrchestrationGateJoinedWordText` run grouping and the first-record checks in `Get-OrchestrationGateSupplementalPatternIndex` | R2: a run starts at the first record followed by a substitution opener and absorbs every later record joined only by openers and closers; records are text spans that contain spaces, so `FOO=$(pwd) npm --prefix $(pwd) run lint` forms one run whose first record is `FOO=`. The `npm` (or `npx`) whole-word check reads only that first record, so Form 1 returns nothing, and the npm record is never evaluated as a run start (the loop resumes after the run's last member). The command is unclassified and the Claude gate allows it; without the assignment the same command denies. | Make Form 1 evaluate the members of a run: for each member whose `RawText` carries `npm` (or `npx`) as a whole word, match the unchanged pattern against the joined text from that member to the run end, and return the index when any member matches. Add Positive function and gate rows for `FOO=$(pwd) npm --prefix $(pwd) run lint`, `env FOO=$(pwd) npm --prefix $(pwd) run lint`, and `FOO=$(pwd) npx --prefix $(pwd) jest`, and an operands gate row (V-style) for the first form on both surfaces; keep the four copies byte-identical. | It is a gate fail-open in cycle 1's new code on the form class the supplement exists for; the mutation probe shows that removing the first-record checks fails no row, so no row pins this behavior. | Reviewer probe on both surfaces: `classified=False`, `supp=[]`, Claude decision `allow` for the four forms; controls `npm --prefix $(pwd) run lint` and `FOO=x npm --prefix $(pwd) run lint` classify; mutants M2 and M3 survive |
| Blocker | `docs/features/active/2026-11-14-preimplementation-gate-resolves-sibling-worktree-bash-to-session-root-1188/evidence/qa-gates/self-review.2026-11-15T20-38.md` | filename stamp and `Timestamp:` line | E1: the file was added by commit `5f8b15daf` at 2026-11-15T20:37:51Z, earlier than its stamp 20-38, so the stamp was composed rather than read from the clock, and the file carries no correction line. | Append one correction line (append-only, clock-read) stating that the stamp was composed and that the file was written no later than 2026-11-15T20:37:51Z; do not rename or edit existing lines. | Owner rule: timestamps come from the clock and evidence is append-only; the comparable `fail-before.2026-11-15T20-35.md` stamp (commit at 20:30:27Z) already carries such a correction. | `git log --diff-filter=A` per evidence file compared with filename stamps; this is the only uncorrected case among 57 added files |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1` and `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` | `Test-ImplementationCommand` stage 1 | Wrapper payloads are unclassified: `sh -c "pytest tests/x.py"`, `sh -c "npm run lint"`, `bash -c "npx jest"`, and `pwsh -Command "npm run lint"` return false, because each stage-1 pattern needs whitespace or line start before the command word and the payload begins with a quote. `sh -c "git add x"` is classified through the structural staging check. | No change in this item. Recommend that the coordinator track payload classification for the non-git patterns as its own issue. | Pre-existing on `main` (the branch adds only the supplement index to stage 1, and the supplement returns no index for these forms); it affects every non-git pattern and belongs to the stage-1 design of #1160, not to target resolution or the two supplement forms. | Reviewer probe |
| Info | `.claude/hooks/enforce-orchestration-preimplementation-gate-classify.ps1` | Form 1 | Mention forms whose joined text carries the npm pattern are newly classified, for example `echo npm --prefix $(pwd) run lint` and `grep -r npm --prefix $(pwd) run lint .`; they deny as unresolvable. | No change. | They match Form 1 as the spec defines it, stage 2 keeps every hit that involves a substitution, and the direction is fail-closed. | Reviewer probe |
| Info | `evidence/regression-testing/fail-before.2026-11-15T20-35.md` | correction line | The appended correction states the run was written between 20-29 and 20-33; the adding commit is at 20:30:27Z, so the upper bound is 20:30. | No change required. | The correction is accurate as an inclusive bound. | `git log` |

No covered file is at or above 700 logical lines (largest production file: Codex epic-scope at 491; largest test file: `legacy-codex-hook-contracts.Tests.ps1` at 517). `config/file-size-baseline.json` is unchanged.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- The supplement is isolated in a pure sibling and wired with one guarded dot-source and one call per gate; stage 2, the index-0 bookkeeping rule, and the five patterns are unchanged (verified against the merge base).
- The Codex gate shrank from 500 to 485 lines by moving `Get-OrchestrationModeDenyReason` unchanged before the wiring lines were added.
- The balance check, the `${` and backtick openers, and the npx option set are each pinned by at least one row (mutants M1, M5, M6, M7 fail rows).
- `bash --rcfile` and `bash --init-file` values are skipped, closing the earlier Minor row, with G rows on both surfaces.
- V3 is the unquoted AC-6 command again, with the quoted form as an extra row; N3 is an allow-ready and deny-not-ready pair.

#### API and safety notes

- `Get-OrchestrationGateSupplementalPatternIndex` returns a subset of `2, 3` in ascending order and performs no I/O.
- The four classify copies share blob `b3c7c45c`; the four operands copies share blob `802f0449`; each gate and epic-scope file equals its bundle copy.

#### Error handling and logging

- A failed dot-source of the classify sibling denies naming the file (I2 on both surfaces).
- When any record's `RawText` cannot be located in the command text, `Get-OrchestrationGateJoinedWordText` returns no run; the reviewer found no ordinary command that triggers this path (every probed form located all records).

---

## Test Quality Audit

The classify tables cover both forms, their near misses, and controls, with Kind stating the before and after classification. The fail-before evidence (`fail-before-r1.2026-11-15T18-51.md`) records the positive rows failing against the unmodified gates. The cycle 2 Python rows failed before the text edit and pass after. The reviewer's mutation probe found two surviving mutants (removing the first-record `npm` or `npx` check), which mark the untested behavior behind R2.

### Reviewed test and QA artifacts

- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-classify.Cases.ps1`, `...-classify.Tests.ps1` (Claude and Codex), `...-classify.Parity.Tests.ps1`.
- `tests/scripts/claude-hooks/enforce-orchestration-preimplementation-gate-operands.Cases.ps1` (V3, N3, rcfile rows).
- `tests/scripts/dev_tools/test_bash_command_shape_surfaces.py` (eight new cases).
- `evidence/qa-gates/final-qc-pester.2026-11-15T20-04.md`, `final-qc-pytest.2026-11-15T20-06.md`, `final-qc-powershell-static.2026-11-15T19-42.md`, `final-qc.2026-11-15T20-36.md`, `final-qc-tests.2026-11-15T20-36.md`.
- `evidence/regression-testing/fail-before-r1.2026-11-15T18-51.md`, `fail-before-v3-correction.2026-11-15T18-51.md`, `fail-before.2026-11-15T20-35.md`.

### Quality assessment prompts

- **Determinism:** in-memory rows; no clock, file, or process access.
- **Isolation:** one row per form.
- **Speed:** full parallel gate 684.94 s wall clock; targeted pytest 3.38 s.
- **Diagnostics:** `-Because` text; Python messages list the missing tokens.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; leak scan 0 failures. |
| No unsafe subprocess or command construction | ✅ PASS | Neither sibling starts a process or evaluates text. |
| Input validation at boundaries | ⚠️ PARTIAL | Every probed non-literal operand of a classified command fails closed; R2 leaves one supplement form unclassified. |
| Error handling remains explicit | ✅ PASS | No catch-all; deny reasons carry the reason code and detail. |
| Configuration / path handling is safe | ✅ PASS | Relative and lone outside paths keep the session root; ambiguity and listing failure deny. |
| No hook invokes Python | ✅ PASS | No Python call added to a hook. |

---

## Research Log

No external research was required. Shell and tool semantics were confirmed by real-process probes of the item worktree's hook code.

---

## Verdict

R1 and F2 are resolved as specified, coverage and mirrors are complete, and the toolchain is clean. The branch is not ready to merge until R2 (supplement fail-open for a substitution before the command word) and E1 (uncorrected evidence stamp) are fixed; both are contained and suit a light remediation cycle.
