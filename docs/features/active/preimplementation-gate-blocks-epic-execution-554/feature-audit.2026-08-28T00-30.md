# Feature Audit — issue #554, remediation cycle 1 exit re-audit

- Timestamp: 2026-08-28T00-30
- Branch: `bug/preimplementation-gate-blocks-epic-execution-554-r3` at `3140652d`
- Base: merge base `1e991b86`
- Work mode: **`full-bug`** — sole acceptance-criteria source is
  `docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md`
- Supersedes: `feature-audit.2026-08-27T22-47.md` (retained)

## Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/preimplementation-gate-blocks-epic-execution-554/spec.md
- Total AC items: 35
- Checked off (delivered): 35
- Remaining (unchecked): 0
- Items remaining: none
```

**No criterion was unchecked by this re-audit.** All 35 are evaluated PASS. The single blocking
finding B5 concerns unchanged lines and does not bear on any criterion's text; the reasoning is set
out below.

## The Criterion Check-Off — verdict on the executor's reasoning

The criterion at issue is the one that was unchecked at cycle-1 exit:

> Line coverage across the PowerShell suite remains at or above 85%, and no changed line in either
> modified hook loses coverage.

**Verdict: the check-off is WARRANTED. It stands. But it is accepted on narrower grounds than the
executor stated, and one of its three supporting arguments is rejected as false.**

### Clause 1 — accepted on independent measurement

Repository-wide LINE coverage parsed directly from the report root of
`artifacts/pester/powershell-coverage.xml`: **7209 covered, 405 missed, 7614 total = 94.6809%**,
against a threshold of 85%. Margin +9.68 pp, and +0.46 pp above the cycle baseline. This reviewer's
parse reproduces the executor's figure exactly. The criterion says "across the PowerShell suite",
which is the repo-wide figure, so the sub-threshold `.codex/…/gate.ps1` file does not falsify this
clause. Accepted.

### Clause 2 — accepted

The executor offered three arguments. Two are accepted; one is rejected.

**Argument 1 — the plan defines groups 1 and 2 as spanning both surfaces. ACCEPTED.** Verified
against `coverage-delta.2026-08-27T22-47.md`: condition 2 names `.codex` lines 292-296 and 304-308
inside group 1, and condition 3 names `.codex` lines 421-422 inside group 2, each recorded as a named
exception. It would be incoherent for the artifact to require those ten lines to be recorded as
accepted exceptions and then treat the same ten as disqualifying one step later. The executor's
decision to surface the asymmetric wording of the clause openly, and to state the reading it applied
rather than quietly adopting it, is the correct handling of an ambiguous gate.

**Argument 2 — the remediation inputs projected this end state and called it checkable. ACCEPTED,
and this reviewer is bound by it.** `remediation-inputs.2026-08-27T22-47.md` states that after R1-R4
the file "will sit at approximately **83.3%** (27 uncovered of 162) because of the 15-line D5
residual", and that "the criterion is checkable once the `.claude` modified hook carries no uncovered
changed line outside the accepted read-seam residual, and the `.codex` modified hook's remaining
uncovered changed lines are confined to the named #555 exception." The measured end state is **27
uncovered of 162, 83.33%** — the projection to the line. Having pre-committed to that state being
checkable, this reviewer accepts it.

**Argument 3 — REJECTED in part.** The executor wrote that "the criterion as written asks that no
changed line in either modified hook **loses** coverage" and that "no line that was covered at the
merge base is uncovered now."

- The **first half is accepted**. Neither of the two lines that lost coverage — `.codex/…/gate.ps1`
  197 and 206 — is a changed line. All 34 uncovered changed lines are added lines, which had no
  base coverage to lose. On its literal text, clause 2 holds. **This is why the criterion stays
  checked.**
- The **second half is false**. Codex lines 197 and 206 were covered at the merge base and are
  uncovered now. See blocking finding B5 in `policy-audit.2026-08-28T00-30.md` for the merge-base
  evidence. The executor is not the origin of the error — it faithfully reproduced this reviewer's own
  cycle-1 claim, which is corrected in that document.

Because the criterion's literal text is scoped to changed lines and is satisfied, and because
arguments 1 and 2 independently support the check-off, the criterion remains `- [x]`. B5 is raised
separately, on the no-regression policy rather than on this criterion.

## Disposition of `[P6-T6]`

`[P6-T6]` in the original plan `plan.2026-08-26T08-40.md` line 312 remains unchecked. It is the only
unchecked task in that plan.

**Verdict: leaving it unchecked is the correct disposition.**

Its acceptance clause reads: "all three values are numeric, the post-change percentage is at or above
85, and **no changed line in either modified hook is reported as uncovered**". The third conjunct is
literally false and will remain so: `.claude/…/gate.ps1` reports 9 uncovered changed lines and
`.codex/…/gate.ps1` reports 25. Every one of the 34 is a member of a named, accepted exception, but
the clause admits no exceptions.

The three alternatives are worse. Checking it would assert a condition that measurably does not hold.
Rewording the clause would amend an acceptance gate after seeing the result it produced, which is the
defect class this repository's plan-gate rules exist to prevent. Deleting it would erase the record.
Leaving it unchecked, with the deliverable itself superseded by
`evidence/qa-gates/coverage-delta.2026-08-27T22-47.md`, records honestly that the plan's own gate was
written stricter than the feature could satisfy and that the shortfall is accounted for elsewhere.

`[P6-T6]` is a plan task, not a `spec.md` acceptance criterion, so it does not gate the AC set.

## Acceptance Criteria Evaluation

All 35 criteria evaluate **PASS**. Verification method is recorded per group; where an evidence
artifact is cited, its claim was corroborated independently rather than accepted on its face.

### Behavioural criteria — amendments 1 to 4 and the test matrix (criteria 1-23)

| Criteria | Verification | Verdict |
| --- | --- | --- |
| 1-4 (amendments, verbatim) | Implemented by the mode-resolution and readiness machinery; asserted by the matrix cases below | PASS |
| 5-13 (matrix cases 1-8, incl. 6a/6b) | `claude-hooks/…-gate-mode-resolution.Tests.ps1`, 83 cases, 0 failures in `pester-junit.xml` | PASS |
| 14-16 (parallel readiness positive, negative, canonical path) | same suite | PASS |
| 17 (epic target unresolvable) | same suite | PASS |
| 18 (merge-status hardening, D8) | same suite | PASS |
| 19 (Codex logic parity, D5 deliverable i) | `codex-hooks/…-gate-mode-resolution.Tests.ps1`, 53 cases, 0 failures | PASS |
| 20 (Codex transport gap recorded, D5 deliverable ii) | same suite; the case reads `.codex/config.toml` and asserts no `PreToolUse` matcher admits `Agent` or `Task`, cross-referencing #555 | PASS |
| 21 (four pre-existing suites pass unmodified) | all four absent from `git diff --name-only origin/main...HEAD`; 35 + 58 + 33 + 58 cases, 0 failures | PASS |
| 22 (`PreToolUseSchema.Contract.Tests.ps1` unmodified) | absent from the branch diff; passes | PASS |
| 23 (four helpers copies byte-identical to branch point) | SHA-256 of each against `git show 1e991b86:<f>`: 4/4 UNTOUCHED | PASS |

Regression evidence for the behaviour change is present on both sides:
`evidence/regression-testing/fail-before-case-6b.2026-08-26T10-18.md` and
`pass-after-case-6b.2026-08-26T11-36.md`.

### Structural and packaging criteria (24-27)

| Criterion | Verification | Verdict |
| --- | --- | --- |
| 24 — four mirrored pairs SHA-256 byte-identical, hashes recorded under `evidence/qa-gates/` | `sha256sum` on all eight files: 4/4 MATCH; recorded in `r1-mirror-pair-hashes.2026-08-27T22-47.md` | PASS |
| 25 — both `pester.runsettings.psd1` list both new hook files in `CodeCoverage.Path`; PoshQC bundled-parity Python test passes | Direct inspection: both files carry `-modes.ps1` for both surfaces at lines 139 and 214, byte-parallel | PASS |
| 26 — both pack manifests list the new modes hook for their surface; push-down completeness tests pass | Direct inspection: Claude `core.json` line 37, Codex `core.json` line 41 | PASS |
| 27 — new hook files appear in the Pester coverage report from the self-hosted invocation | Both `-modes.ps1` files appear as `sourcefile` elements in `powershell-coverage.xml` with 132 measured lines each; the registration therefore takes effect | PASS |

Criterion 26 is satisfied as written: both manifests list the **modes** hook. The Codex manifest's
omission of `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` is a separate,
pre-existing condition carried as non-blocking N5.

### Coverage criterion (28)

| Criterion | Verification | Verdict |
| --- | --- | --- |
| 28 — line coverage ≥ 85% across the suite; no changed line in either modified hook loses coverage | Repo-wide 94.6809%, measured. No changed line lost coverage — all 34 uncovered changed lines are added lines | PASS |

Adjudicated above. Remains checked.

### Constraint criteria (29-35)

| Criterion | Verification | Verdict |
| --- | --- | --- |
| 29 — no `.claude/rules/`, `.claude/skills/`, or `.github/` file in the branch diff | Path filter over all 99 changed files: NONE | PASS |
| 30 — deny-by-default preserved, no new permissive path | Cases for unparseable payload, absent tool-input key, and empty injected checkpoint content all present and passing | PASS |
| 31 — every file written by the branch appears in `## DECLARED BLAST RADIUS` | Programmatic resolution of all 99 changed files against the 15 exact entries, 8 root-level entries, and 7 directory prefixes: **0 undeclared** | PASS |
| 32 — full PowerShell toolchain passes in a single pass | Format, analyze, Pester-with-coverage artifacts at `2026-08-27T22-47`; corroborated by 3825 cases / 0 failures and a coverage XML from the same run | PASS |
| 33 — plan records D6 batch sequencing and the mechanical-byte-copy statement | `plan.2026-08-26T08-40.md` change-budget section; `evidence/qa-gates/plan-budget-statement.2026-08-26T11-36.md` | PASS |
| 34 — every production `.ps1` at or under 500 lines | 489, 477, 495, 477 self-hosted; four mirrors byte-identical | PASS |
| 35 — D3 follow-up record written under `evidence/other/` | `followup-epic-kickoff-contract-gap.2026-08-26T11-36.md` states the gap, the recommended contract amendment, and the out-of-scope reason; the deferral of the GitHub filing is recorded in `followup-issue-filing-deferred.2026-08-26T11-36.md` | PASS |

Criterion 31's declared-radius entry set includes the six writes added by the cycle-1 amendment. The
amendment was verified strictly additive; see `code-review.2026-08-28T00-30.md`, Scope Decision 2.
Statement `(e)` of that section forward-declares later cycles' root-level artifacts, so the three
artifacts written by this re-audit resolve to a declared entry without any further amendment.

## Baseline Comparison

The branch delivers, relative to `origin/main` at `1e991b86`:

- A structural delegation classifier replacing the seven-token free-text scan, on both surfaces.
- A new pure `-modes.ps1` sibling per surface carrying the mode table, checkpoint-path resolution,
  target-folder and issue-number extraction, and the epic and parallel readiness predicates.
- Epic and parallel checkpoint consultation with injected read seams, so decision logic is testable
  without filesystem access.
- Deny reasons that name the checkpoint consulted and the failed predicate.
- Coverage registration for both new production files in both `pester.runsettings.psd1` copies, and
  pack-manifest registration in both `core.json` copies.
- Three test suites: two new, one extended.

Behaviourally unchanged, and verified so: the Edit/Write and Bash legs, the issue #539 staging
exemption, `Test-ImplementationPath`, `Test-ImplementationCommand`, and
`Test-ExemptOrchestrationStagingCommand`.

## Outstanding

One blocking finding, **B5**, recorded in `policy-audit.2026-08-28T00-30.md` and detailed with
remediation directives in `remediation-inputs.2026-08-28T00-30.md`. It does not unseat any acceptance
criterion.

One accepted shipping exception: `.codex/hooks/enforce-orchestration-preimplementation-gate.ps1` at
**83.33%**, below the 85% uniform threshold, on the 15-line decision-D5-constrained branch at lines
426-443, tied to **issue #555**. This must appear in the pull-request description.
