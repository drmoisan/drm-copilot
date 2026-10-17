# host-bootstrap-does-not-install-poetry (Remediation Plan, cycle 2)

- **Issue:** #930
- **Owner:** drmoisan
- **Last Updated:** 2026-10-16 (cycle stamp 05-34, taken from the inputs file name)
- **Status:** Ready for preflight
- **Version:** 1.0
- **Work Mode:** minor-audit (from `issue.md`; the sole AC source is the `## Acceptance Criteria` section of `issue.md`)
- **Inputs:** `remediation-inputs.2026-10-16T05-34.md` (Finding 1)

**Fail-closed evidence rule:** If the edited file lacks any required field after Phase 1, the remediation verdict is BLOCKED, never PASS.

## Remediation Scope

| ID | Source | Required outcome |
|---|---|---|
| RI-1 | Finding 1 | The file named below carries `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`, and no file under `evidence/` lacks any of the four. |
| RI-2 | Finding 1 Action | The file name is unchanged, existing lines are preserved, and no path other than that file and this plan file is changed. |

The one file to edit (called E): `docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/other/rem1-phase0-instructions-read.2026-10-16T04-53.md`. It currently has `Timestamp:`, `Policy Order:`, and `Files Read:`, and lacks `Command:`, `EXIT_CODE:`, and `Output Summary:`.

Out of scope: every production, test, and policy file, `issue.md`, and every other evidence file. This plan stages and commits nothing and creates no evidence artifact; the caller commits after approval.

## Conventions

- `<FEATURE>` means `docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930`. `<E>` is the full repository-relative path of E. `<PLAN>` is `<FEATURE>/remediation-plan.2026-10-16T05-34.md`. `<REM0>` is the HEAD SHA printed by P0-T2. The executor substitutes literal values before running.
- No evidence artifact is created in any phase. Verification results are reported in the executor return, and the only recorded result is inside E.
- The clock value is read with `date -u +%Y-%m-%dT%H-%M` immediately before the write and is never estimated. To observe an exit code, the executor appends `; echo "EXIT=$?"` for the run only; the recorded `Command:` field omits that suffix. No exit code is invented, and `EXIT_CODE: SKIPPED` is invalid.
- E contains no absolute host path. Its existing lines and line endings are preserved; fields are added by appending lines after the last existing line.
- Anchor decision: the branch carries the feature's own commits ahead of origin/main, so a `git diff` anchored to origin/main lists those commits and cannot isolate this remediation. Scope and preservation checks anchor at `<REM0>`. Each name-listing diff is paired with `git status --porcelain` because a name-listing diff enumerates tracked changes only and cannot report a file the task creates.
- Allowed changes after execution: E, and `<PLAN>` (checkbox state). Untracked `SCRATCH/` is allowed.
- Literals the executor creates in E (quoted verbatim): `Command: test -f CLAUDE.md`, `EXIT_CODE: 0`, `Output Summary:`, `Fields Added At:`, and `Note:`. The `Note:` line states that the `Command:` shown is the verifying command run when the fields were added, and it does not repeat the literals 'Command:', 'Output Summary:', or 'Fields Added At:'.
- Minor-audit contract compatibility: E is this feature's cycle-1 Phase 0 policy-read artifact (`Timestamp:`, `Policy Order:`, `Files Read:`). After Phase 1 it also carries `Command:`, `EXIT_CODE:`, and `Output Summary:`, so the contract's Phase 0 artifact stays complete and no second one is created.

### Phase 0 — Policy read and baseline

- [x] [P0-T1] Read, in order, `CLAUDE.md`, `.claude/rules/general-code-change.md`, `.claude/rules/general-unit-test.md`, `.claude/rules/tonality.md`, `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`, `<FEATURE>/remediation-inputs.2026-10-16T05-34.md`, and the `## Acceptance Criteria` section of `<FEATURE>/issue.md`. No file is written. Acceptance: each of the seven reads succeeds, and the executor return lists the seven paths in this order under the heading `Policy read list`.
- [x] [P0-T2] Record the base for the plan file `docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/remediation-plan.2026-10-16T05-34.md`. Run `git rev-parse HEAD && git status --porcelain`. Acceptance: exit code 0, the executor return states the HEAD SHA as `REM0`, and the porcelain output lists no line other than `??` lines and a line for `<PLAN>`. Otherwise stop and report BLOCKED.
- [x] [P0-T3] Schema baseline before the edit of `<FEATURE>/evidence/other/rem1-phase0-instructions-read.2026-10-16T04-53.md`. Run `find <FEATURE>/evidence -type f -name '*.md' | while read f; do for t in 'Timestamp:' 'Command:' 'EXIT_CODE:' 'Output Summary:'; do grep -q -F "$t" "$f" || { echo "$f"; break; }; done; done | wc -l`. Acceptance: the printed count is exactly 1 and the one listed file is E (re-run without `| wc -l` to see the name). Any other result is reported as `BASELINE-MISMATCH` and the executor stops.

### Phase 1 — Add the missing fields

- [x] [P1-T1] Run `test -f CLAUDE.md && test -f .claude/rules/general-code-change.md && test -f .claude/rules/general-unit-test.md && test -f .claude/rules/tonality.md && test -f .claude/skills/evidence-and-timestamp-conventions/SKILL.md && test -f docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/remediation-inputs.2026-10-16T04-12.md && test -f docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/issue.md && echo ALL-7-PRESENT` and note its observed exit code and printed output. Acceptance: the observed exit code is 0 and the output is `ALL-7-PRESENT`; otherwise stop and report BLOCKED. The EXIT_CODE value written in P1-T3 is this observed value.
- [x] [P1-T2] Before the edit of `<FEATURE>/evidence/other/rem1-phase0-instructions-read.2026-10-16T04-53.md`, read the clock with `date -u +%Y-%m-%dT%H-%M`. Acceptance: the printed value matches the shape `yyyy-MM-ddTHH-mm`; the executor return states it.
- [x] [P1-T3] With the Edit tool, append to E (`<FEATURE>/evidence/other/rem1-phase0-instructions-read.2026-10-16T04-53.md`), after its last existing line, the lines `Command:` (the P1-T1 command without the `; echo` suffix), `EXIT_CODE:` (the observed integer from P1-T1), `Output Summary:` (the observed output in one line), `Fields Added At:` (the P1-T2 value), and `Note:`. Do not append `EXIT_CODE:` unless P1-T1 observed 0. Acceptance: `grep -c -F 'Command: test -f CLAUDE.md' <E>` prints 1, `grep -c -x -F 'EXIT_CODE: 0' <E>` prints 1, and `grep -c -F 'Fields Added At:' <E>` prints 1.

### Phase 2 — Final QA validation

- [x] [P2-T1] QA token check on `<FEATURE>/evidence/other/rem1-phase0-instructions-read.2026-10-16T04-53.md`. Run `grep -c -F 'Timestamp:' <E> && grep -c -F 'Command:' <E> && grep -c -F 'EXIT_CODE:' <E> && grep -c -F 'Output Summary:' <E>`. Acceptance: exit code 0 and each of the four printed counts is at least 1 (grep -c exits 1 for a zero count, so the chain stops at the first missing token). The executor return reports the four counts.
- [x] [P2-T2] QA schema count after the edit, over every `.md` file under `docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence`, which includes `docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/other/rem1-phase0-instructions-read.2026-10-16T04-53.md`. Run the P0-T3 command again. Acceptance: the printed count is 0. The executor return reports before (P0-T3) and after counts.
- [x] [P2-T3] QA preservation of existing content in `<FEATURE>/evidence/other/rem1-phase0-instructions-read.2026-10-16T04-53.md`. Run `git diff --numstat <REM0> -- <E>` and `grep -c -x -F 'Timestamp: 2026-10-16T04-53' <E>`. Acceptance: the numstat output is one line whose deleted-lines column is 0 and whose added-lines column is greater than 0, and the grep count is 1.
- [x] [P2-T4] QA recorded exit code in `<FEATURE>/evidence/other/rem1-phase0-instructions-read.2026-10-16T04-53.md`. Re-run the P1-T1 command and compare with `grep -m1 '^EXIT_CODE:' <E>`. Acceptance: the re-run exit code equals the integer recorded in E, and both are 0.
- [x] [P2-T5] QA scope check for `<FEATURE>/evidence/other/rem1-phase0-instructions-read.2026-10-16T04-53.md` and `<FEATURE>/remediation-plan.2026-10-16T05-34.md`, with the diff anchored at `<REM0>` and the porcelain companion. Run `git diff --name-status <REM0>`, then `git diff --name-status <REM0> | grep -v -F -e <E> -e <PLAN> | wc -l`, then `git diff --name-status <REM0> | grep -c -F <E>`, then `git status --porcelain | grep -v -F -e <E> -e <PLAN> -e SCRATCH/ | wc -l`. Acceptance: the first listing contains only `M` entries (no `D`, `R`, or `A`), the second and fourth commands print 0, and the third prints 1.

## Self-review and preflight signals

SELF-REVIEW: RE-DERIVED THIS PASS
- `docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/other/rem1-phase0-instructions-read.2026-10-16T04-53.md` | lines 1-21: carries Timestamp, Policy Order, Files Read only; seven file entries; first Timestamp value `2026-10-16T04-53`.
- `docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/remediation-inputs.2026-10-16T05-34.md` | Finding 1 and Action.
- `docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/remediation-plan.2026-10-16T04-12.md` | format model, anchor decision paragraph.
- `docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/issue.md` | line 59 `## Acceptance Criteria`.
- Glob of `<FEATURE>/*.md` | all seven listed paths exist, including `remediation-inputs.2026-10-16T04-12.md`; Glob of `<FEATURE>/evidence/**` | 44 files, one of which is E.

PLANNER-INTERNAL-REVIEW: PASS
CITATION-TO-TREE: PASS
CITATION: docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/evidence/other/rem1-phase0-instructions-read.2026-10-16T04-53.md | Timestamp line 3
CITATION: docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/remediation-inputs.2026-10-16T05-34.md | Finding 1
CITATION: docs/features/active/2026-10-15-host-bootstrap-does-not-install-poetry-930/issue.md | ## Acceptance Criteria
AC-TRACEABILITY: PASS
SCOPE-BOUNDARY: PASS
AC-INVENTORY: RI-1, RI-2
AC-MAPPING: RI-1 | IMPLEMENTATION: P1-T3 | TESTS: P2-T1, P2-T2 | EVIDENCE: fields inside E, counts in executor return
AC-MAPPING: RI-2 | IMPLEMENTATION: P1-T3 | TESTS: P2-T3, P2-T5 | EVIDENCE: numstat and scope output in executor return
UNRESOLVED-GAPS: NONE
