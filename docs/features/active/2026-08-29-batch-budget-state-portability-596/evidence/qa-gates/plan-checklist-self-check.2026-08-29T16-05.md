# [P8-T5] Plan checklist versus evidence on disk — adversarial self-check

Timestamp: 2026-08-29T23-25

Command: three checks, run in this order against the executing worktree.

1. Artifact-path extraction and existence test over every task line of the plan:
   `pwsh -NoProfile -Command "<parse plan.2026-08-29T16-05.md; for each '- [x] [P#-T#]' line extract every matching evidence/*.md path and Test-Path it>"`
2. Required-field audit over every artifact under `evidence/`:
   `for f in $(find . -name "*.md" | sort); do for k in "^Timestamp:" "^Command:" "^EXIT_CODE:" "^Output Summary:"; do grep -q "$k" "$f" || echo "MISSING $k in $f"; done; done`
3. Live re-verification of the tree-observation acceptances that name no artifact: `git hash-object` on the three mirror pairs, both `git grep` absence searches, `wc -l` on the five in-scope source files, `Test-Path .claude/state`, and a title search of the five edited or created test files.

EXIT_CODE: 0

Output Summary: **70 plan tasks; 67 checked, 3 unchecked.** The 67 checked tasks reference **47
artifact paths, of which 0 are missing**; the remaining 19 checked tasks name no artifact and were
verified by re-running their tree observations live. **50 artifacts audited for the four required
fields; after the correction described below, 0 field failures remain.** The 3 unchecked tasks are
[P7-T4], [P7-T5], and [P7-T11]; each names an artifact that **exists** and each artifact records its
own acceptance as NOT MET with the reason stated, so all three are unchecked deliberately rather than
overlooked. **One mismatch was found and is reported in full below.** No task was checked off during
this self-check, and no artifact was created to paper over a gap.

## How this check was made capable of failing

This task is the one most easily performed as a rubber stamp, so the method was fixed before the
result was known and was made mechanical rather than narrative:

- The artifact paths were **extracted by a regular expression from the plan file itself**, not
  recalled from the execution transcript, so a task naming an artifact that was never written would
  surface as a missing file rather than be silently omitted from the list.
- The four-field audit ran over **every** `.md` file under `evidence/`, not over the subset the plan
  names, so an artifact that exists but is malformed is caught regardless of which task points at it.
- The 19 checked tasks that name no artifact were **not** exempted. Each names a tree observation,
  and every such observation was re-run against the live tree in this pass, so a claim that decayed
  after its phase closed would surface now.
- Three values that a recorded artifact could have carried staleley — the mirror hashes, the two
  absence searches, and the presence of `.claude/state/` — were **recomputed live** and compared
  against the recorded values rather than read from them.

The check did in fact fail once, on the mismatch recorded below. That is the evidence that it was
capable of failing.

## Result 1 — artifact existence for checked tasks

47 distinct artifact paths are named across the 67 checked tasks. Every one resolves to a file that
exists. **Missing files: 0.**

## Result 2 — required-field audit

All 50 artifacts under `evidence/` were audited for `Timestamp:`, `Command:`, `EXIT_CODE:`, and
`Output Summary:`.

**Mismatch found (1).** `evidence/issue-updates/issue-596.2026-08-29T16-05.md`, the artifact named by
[P8-T4], carried `Timestamp:` but carried no `Command:`, no `EXIT_CODE:`, and no `Output Summary:`.

Analysis of the mismatch. This was a conflict between two schemas rather than absent work:

- [P8-T4]'s own stated acceptance is `Timestamp:`, the exact intended text, and one of
  `PostedAs: body`, `PostedAs: comment`, or a `POSTING BLOCKED` header with the reason. The artifact
  satisfied all three when written, and `evidence-and-timestamp-conventions` lists exactly that set
  as the required contents of an issue-update mirror. It does not list `Command:` or `EXIT_CODE:` for
  a mirror.
- The plan's fail-closed evidence rule nonetheless states that **every** artifact carries the four
  fields at minimum, and [P8-T5] restates that requirement for every checked task.

Resolution. The task was **not** unchecked, because unchecking is the remedy for a task whose work is
absent, and [P8-T4]'s work is present and complete. The mirror was instead brought into the uniform
four-field schema without fabricating a posting: `Command:` names the verification commands actually
executed, which are the source of the factual claims in the mirrored text, and states explicitly that
**no `gh` command was executed**; `EXIT_CODE: 0` refers to those verification commands and the
artifact says so in terms; `Output Summary:` states that no posting occurred and that `PostedAs:
unknown` stands. `PostedAs: unknown` and the `POSTING BLOCKED` header are unchanged, so the artifact
makes no claim that any update reached GitHub.

Post-correction audit: **50 artifacts, 0 field failures.**

## Result 3 — the 19 checked tasks that name no artifact

These tasks state a tree or command observation as their acceptance. Each observation was re-run
live in this pass; none was accepted on the strength of its phase having completed.

| Tasks | Acceptance re-verified | Live result |
| --- | --- | --- |
| [P1-T1], [P2-T1], [P3-T1], [P7-T1] | batch-budget state files removed | `Test-Path '.claude/state'` prints `False`, so no `*-batch-budget.*.json` file exists |
| [P1-T2] | two new `It` titles in `persist-session-id.Tests.ps1` | both present, lines 104 and 124 |
| [P2-T2] | ten `It` titles in the PowerShell suite | all ten present, lines 256-403 |
| [P3-T2] | ten `It` titles in the Python suite | all ten present, lines 246-393 |
| [P4-T2] | seven `it` titles in the merge suite | all seven present, lines 21-133 |
| [P5-T1] | four `it` titles in the delivery suite | all four present, lines 45, 57, 69, 95 |
| [P1-T4] | `EnsureDirectory` and `WriteStateFile` reachable from the `env-file` branch; file under 500 lines | branch at line 104 contains both calls at lines 112 and 114; file is 164 lines |
| [P2-T4] | `'default'` and `(Get-Location).Path` absent; file under 500 lines | both `git grep` runs exit 1 with no output; file is 457 lines |
| [P3-T4] | same, Python hook | both searches exit 1 with no output; file is 454 lines |
| [P1-T5], [P2-T5], [P3-T5] | mirror pairs byte-identical | all three `git hash-object` pairs recomputed live and equal |
| [P4-T1] | merge module exists, imports no I/O module, under 500 lines | exists; zero import statements of any kind; 164 lines |
| [P4-T3] | `coverageThreshold` key present | key present at `jest.config.cjs:213` with `lines: 85`, `branches: 75` |
| [P5-T3] | call site imports from `./claude-gitignore-merge`; file under 500 lines | import at line 32; file is 361 lines |
| [P8-T1] | 17 criteria, checked items traceable to artifacts | counter reports 17 total, 16 checked; every checked item mapped in `evidence/qa-gates/ac-reconciliation.2026-08-29T16-05.md` |

**Mismatches in this group: 0.**

## Result 4 — the three unchecked tasks

Each is unchecked for a reason stated inside the artifact it names, and each of those artifacts
exists and is field-complete. None is an oversight.

| Task | Artifact | Stated reason |
| --- | --- | --- |
| [P7-T4] | `evidence/qa-gates/powershell-test-final.2026-08-29T16-05.md` | `run_poshqc_test` returned `ok: false`; derived `EXIT_CODE: 2`. The artifact records the verdict NOT MET and declines to normalize an unmet gate to pass. |
| [P7-T5] | `evidence/qa-gates/powershell-test-coverage-final.2026-08-29T16-05.md` | Form A exited 2 with a failed count of 2 rather than 0. The coverage half of the acceptance is met in full; the test half is not, and the artifact records the split. |
| [P7-T11] | `evidence/qa-gates/toolchain-loop-convergence.2026-08-29T16-05.md` | The loop did not converge. Two iterations ran; iteration 2 was clean at every stage except [P7-T4] and [P7-T5]. Because the two failures are deterministic, pre-existing, and outside the change set, no further iteration can clear them, so further iterations were not run and the task is recorded NOT MET. |

The common cause is the pre-existing pair of failing tests analysed in
`evidence/qa-gates/ac-reconciliation.2026-08-29T16-05.md` and
`evidence/other/known-limitations.2026-08-29T16-05.md`. The same cause leaves the acceptance criterion
on `spec.md` line 773 unchecked, so the plan checklist and the criteria checklist agree with each
other and with the evidence.

## Result 5 — cross-checks against live tree state

| Value | Recorded in | Recomputed live | Agreement |
| --- | --- | --- | --- |
| `enforce-powershell-batch-budget.ps1` pair hash | `mirror-hash-parity-after` | `d4503c778bace2d206bbaa356101ee34481446fa` for both files | matches |
| `enforce-python-batch-budget.ps1` pair hash | `mirror-hash-parity-after` | `db025b9d50826c8ade88d38dd9a651afcaef66d4` for both files | matches |
| `persist-session-id.ps1` pair hash | `mirror-hash-parity-after` | `8c0d0b1d7c1501eec5919217720ab5650a6634db` for both files | matches |
| `'default'` search | `search-default-after` | exit 1, no output | matches |
| `(Get-Location).Path` search | `search-path-resolution-after` | exit 1, no output | matches |
| `.claude/state` absent | `parity-gate-final-state` | `False` | matches |

No stale recorded value was found. This cross-check was run specifically because a recorded hash can
survive a later edit and continue to read as a pass.

## Verdict

**One mismatch found, reported, and resolved without unchecking a task whose work was complete and
without fabricating evidence.** All other checks passed: 47 of 47 named artifacts exist, 50 of 50
artifacts are field-complete after the correction, 19 of 19 artifact-free acceptances re-verified
live, 3 of 3 unchecked tasks unchecked for a stated and artifact-backed reason, and 6 of 6 live
cross-checks agree with their recorded values.
