# Corrected Acceptance-Condition Forms Do Not Fire — [P5-T5]

Timestamp: 2026-08-26T16-05
Task: [P5-T5]
Command: `poetry run python C:/Users/DANMOI~1/AppData/Local/Temp/claude/C--Users-DanMoisan-repos-drm-copilot-wt-2026-08-23T20-24/52ac2030-ba56-47de-a115-b912d0d4409c/scratchpad/p5t5_r2.py`
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2c2e891a6977ab65`
EXIT_CODE: 0

Output Summary: the derivation is non-vacuous and PASSES its vacuity guard. At commit `e2aa6446` the task count is 75 and the number of tasks whose extracted acceptance text is non-empty is 75; at commit `5a8ede0f` the task count is 76 and the non-empty count is 75. Both non-empty counts exceed half their commit's task count. The longest-common-subsequence alignment yields 42 matched pairs, of which 35 are unchanged and 7 are corrected forms; 33 tasks are excluded as deletions and 34 as additions. Every one of the 7 corrected forms records a finding count of 0 from each of G7, G8, G8b, and G9. Total new-rule findings over the derived list: 0. PASS.

The exit code was captured directly with `echo "EXIT=$?"` immediately after the redirect. No pipe stands between the command and the capture.

The driver runs from the session scratchpad, outside the repository tree. No file was added under `scripts/dev_tools`, so the driver deletion evidenced by [P5-T6] stands undisturbed.

## Supersession notice

This artifact REPLACES an earlier one written at the same path. That earlier run applied a field-extraction rule that defined a task's acceptance text as the lines FOLLOWING the task line. The issue #502 plan states each acceptance condition INLINE on the task line after the literal marker `Acceptance:`, so that rule left the acceptance field empty for 74 of 75 tasks at `e2aa6446` and for 75 of 76 at `5a8ede0f`, compared empty against empty, classified every matched pair as unchanged, and returned an empty corrected-form list. The plan task was revised to split each task block at the first occurrence of the marker, which is format-general, and the vacuity guard recorded below was added so that a repeat of that silent failure is loud rather than silent. The earlier vacuous result is not carried forward and is not treated as a pass.

## The derivation actually applied

The set of corrected forms was not chosen by the executor. It is the output of the fixed five-step derivation the task states, applied to the two extractions [P5-T1] recorded — the text of `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/plan.2026-08-22T22-57.md` at commit `e2aa6446` and at commit `5a8ede0f`, read from git object storage with the same `git show` commands [P5-T1] recorded. The driver decodes both extractions as UTF-8 explicitly, so no character is transcoded by the host locale.

**Step 1 — task-entry lists.** Each extraction is walked once in document order. A task entry is a line matching the checkbox-and-identifier task form. Its *block* is that task line plus every following line up to but not including the next task line or the next Markdown ATX heading.

**Step 2 — field split at the marker.** Each block is split into its two fields at the FIRST occurrence within that block of the literal marker `Acceptance:`. The acceptance text is that marker together with everything after it to the end of the block. The description text is everything in the block before it, with the checkbox marker and the leading bracketed identifier removed. When the marker does not occur in the block, the acceptance text is empty and the whole block, less the checkbox marker and the bracketed identifier, is the description text. Both fields are normalized identically, by collapsing runs of whitespace to one space and stripping leading and trailing whitespace. This marker rule is format-general: it extracts the same two fields whether a plan states its acceptance condition inline on the task line, as the issue #502 plan does, or on an indented line beneath the task line, as the issue #519 plan does.

**Step 3 — alignment.** The two ordered lists are aligned with the standard dynamic-programming **longest-common-subsequence** algorithm applied to the description field, using byte equality of the normalized description as the match predicate. The table is filled over suffixes, `table[i][j]` being the longest-common-subsequence length of the two suffixes, and the pairing is recovered by a forward traceback from the origin. The **tie-break** is fixed: whenever the table offers two moves of equal length, the traceback takes the move advancing the `e2aa6446` index. In the implementation this is the comparison `table[i + 1][j] >= table[i][j + 1]`, whose non-strict relation is exactly what sends an equal-length offer down the `e2aa6446`-advancing branch. The tie-break makes the alignment yield one reproducible pairing rather than any of several equally long ones, so a third party re-running the same algorithm over the same two texts obtains that same pairing.

**Step 4 — classification of matched pairs.** A matched pair is a *corrected form* when its two acceptance texts differ and an *unchanged task* when they are equal. The derived corrected-form list is exactly the corrected forms.

**Step 5 — exclusion of unmatched tasks.** A task the alignment did not match is an addition or a deletion, never a correction, and is excluded. Identifier pairing is prohibited and was not used: the final revision inserted a task and thereby shifted every later identifier by one, so pairing on identifier would compare a task against an unrelated one and report that difference as a correction. The concrete instance is visible in the unchanged-pair table below — the `e2aa6446` task `P0-T10` is matched by the alignment to the `5a8ede0f` task `P0-T11`, one position later.

**Finding counts.** The counts come from one evaluation of the whole `5a8ede0f` extraction through the shipped entry point `evaluate_plan_gates`, with a repository context built by the shipped `build_plan_gate_context` against this worktree. Each finding is attributed to the identifier it carries as its leading bracketed token, and to the rule that produced it by the fixed leading phrase each rule's frozen finding string carries. No predicate is reimplemented and no finding is recomputed.

## Vacuity guard — the hard gate on this task

The task FAILS if either commit's non-empty acceptance-text count is less than half that commit's task count, because a derivation whose acceptance field is empty for most tasks measures nothing and every count it reports is vacuous.

| Commit | Task count | Tasks with non-empty acceptance text | Half the task count | Guard |
| --- | --- | --- | --- | --- |
| `e2aa6446` | 75 | 75 | 37.5 | PASS |
| `5a8ede0f` | 76 | 75 | 38 | PASS |

At `e2aa6446` every one of the 75 tasks carries a non-empty acceptance text. At `5a8ede0f` 1 task of 76 carries none. Neither count is below half, so the guard passes and the counts below are not vacuous.

## Counts

| Quantity | Integer |
| --- | --- |
| Task entries at `e2aa6446` | 75 |
| Task entries at `5a8ede0f` | 76 |
| Non-empty acceptance texts at `e2aa6446` | 75 |
| Non-empty acceptance texts at `5a8ede0f` | 75 |
| Matched pairs | 42 |
| Unchanged matched pairs | 35 |
| **Corrected forms (size of the derived list)** | **7** |
| Excluded — deletions (present only at `e2aa6446`) | 33 |
| Excluded — additions (present only at `5a8ede0f`) | 34 |

Arithmetic check: 42 matched + 33 deletions = 75 tasks at `e2aa6446`; 42 matched + 34 additions = 76 tasks at `5a8ede0f`; 35 unchanged + 7 corrected = 42 matched.

**The size of the derived corrected-form list is 7.**

## The derived corrected-form list, with per-rule finding counts

| # | `e2aa6446` id | `5a8ede0f` id | G7 | G8 | G8b | G9 |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `P0-T2` | `P0-T2` | 0 | 0 | 0 | 0 |
| 2 | `P2-T2` | `P2-T2` | 0 | 0 | 0 | 0 |
| 3 | `P3-T4` | `P3-T4` | 0 | 0 | 0 | 0 |
| 4 | `P4-T3` | `P4-T3` | 0 | 0 | 0 | 0 |
| 5 | `P4-T4` | `P4-T4` | 0 | 0 | 0 | 0 |
| 6 | `P8-T15` | `P8-T15` | 0 | 0 | 0 | 0 |
| 7 | `P8-T17` | `P8-T17` | 0 | 0 | 0 | 0 |

Every cell is 0. The total new-rule finding count over the derived list is 0, so no corrected acceptance form of the final revision fires under G7, G8, G8b, or G9. PASS.

### The differing acceptance text of each entry, under both commits

#### 1. `P0-T2` at `e2aa6446` -> `P0-T2` at `5a8ede0f`

At `e2aa6446`:

```text
Acceptance: the artifact records the exit code and the reformatted-file count.
```

At `5a8ede0f`:

```text
Acceptance: exit code 0; the final summary line ends with the literal `would be left unchanged.`; no output line begins with the literal `would reformat `; and that summary line is recorded verbatim. The acceptance names the clean-run literal rather than a would-reformat count because on a clean run no count and no per-file line is emitted at all — only the summary — so an acceptance demanding a count could never be satisfied. The check flag makes this invocation read-only, so no file is written and no snapshot pair is needed here; P8-T1 runs the write-mode form.
```

#### 2. `P2-T2` at `e2aa6446` -> `P2-T2` at `5a8ede0f`

At `e2aa6446`:

```text
Acceptance: `poetry run pytest --cov=scripts.dev_tools._blast_radius_token_shapes --cov-branch tests/scripts/dev_tools/test_blast_radius_token_shapes.py` passes and reports line coverage at or above 85 percent and branch coverage at or above 75 percent for that module.
```

At `5a8ede0f`:

```text
Acceptance: `poetry run pytest --cov=scripts.dev_tools._blast_radius_token_shapes --cov-branch --cov-report=term-missing tests/scripts/dev_tools/test_blast_radius_token_shapes.py` exits 0 and reports line coverage at or above 85 percent and branch coverage at or above 75 percent for that module. The `term-missing` reporter must be passed explicitly because the project's `addopts` supplies only an LCOV reporter, so without it no coverage table is printed and the percentages this acceptance demands would not be observable; derive both figures from the `Stmts`, `Miss`, `Branch`, and `BrPart` columns of the module's row.
```

#### 3. `P3-T4` at `e2aa6446` -> `P3-T4` at `5a8ede0f`

At `e2aa6446`:

```text
Acceptance: the file passes via `mcp__drm-copilot__run_poshqc_test`, contains no double-quoted probe string, is at or under 500 lines, and retains the single-quote constraint comment.
```

At `5a8ede0f`:

```text
Acceptance: `mcp__drm-copilot__run_poshqc_test` scoped to the folder `tests/scripts/claude-lib/blast-radius` reports zero failures for this file in `artifacts/pester/pester-junit.xml`; the file contains no double-quoted probe string, is at or under 500 lines, and retains the single-quote constraint comment.
```

#### 4. `P4-T3` at `e2aa6446` -> `P4-T3` at `5a8ede0f`

At `e2aa6446`:

```text
Acceptance: the manifest lists the new module exactly once, and no existing entry is reordered or duplicated.
```

At `5a8ede0f`:

```text
Acceptance: the manifest lists the new module exactly once, and no existing entry is reordered or duplicated. The exactly-once half is checkable against the post-edit file; the no-reordering half is a prior-state claim and is backstopped by P8-T13, whose staged and anchored diff records this file's hunks explicitly.
```

#### 5. `P4-T4` at `e2aa6446` -> `P4-T4` at `5a8ede0f`

At `e2aa6446`:

```text
Acceptance: the allow-list contains the new module path, and no existing allow-list entry is removed.
```

At `5a8ede0f`:

```text
Acceptance: the allow-list contains the new module path, and no existing allow-list entry is removed. As in P4-T3, the containment half is checkable against the post-edit file and the no-removal half is a prior-state claim backstopped by P8-T13's staged and anchored diff.
```

#### 6. `P8-T15` at `e2aa6446` -> `P8-T15` at `5a8ede0f`

At `e2aa6446`:

```text
Acceptance: validation reports no Blocking finding, and the artifact records the accepted `path_overlap` edge with issue #500 on the rule-file pair per the AC-41 decision above.
```

At `5a8ede0f`:

```text
Acceptance: validation reports no Blocking finding; the artifact records the accepted `path_overlap` edge with issue #500 on the rule-file pair per the AC-41 decision above; and the artifact records the two spec-sourced over-declarations named in the token-hygiene limit above — the blast-radius configuration file and the bundled pack manifest, both inline-coded in the spec and therefore harvested into the derived radius, with the configuration file additionally resolving as a touched shared surface. Each is recorded with the reason it is present and the statement that it is an accepted read-reference over-inclusion rather than a placeholder defect, so a reviewer comparing the declared radius against the file-change map does not read the difference as an error.
```

#### 7. `P8-T17` at `e2aa6446` -> `P8-T17` at `5a8ede0f`

At `e2aa6446`:

```text
Acceptance: both documents reflect the landed state and the mirror artifact exists with all three required fields. ---
```

At `5a8ede0f`:

```text
Acceptance: the mirror artifact exists and carries `Timestamp:`, the exact posted text, and `PostedAs:`; and both documents each record, by name, the three planner decisions AC-9, AC-19, and AC-41, plus the actual edge-count delta measured in P7-T5 and the final line and branch coverage figures from P8-T4. Those five named items replace a general "reflects the landed state" reading, which no observation could falsify. ---
```

## Every finding produced by the single evaluation of the `5a8ede0f` extraction

The evaluation produced 0 blocking findings and 3 warnings. All are reproduced verbatim so the attribution is auditable rather than asserted.

1. rule: not a new rule (G1 through G6); task: `P0-T5`

```text
[P0-T5] --cov argument value `--cov-branch` is supplied space-separated; the ambiguous form can bind the following positional argument. Use the --cov=<module> form.
```

2. rule: not a new rule (G1 through G6); task: `P8-T4`

```text
[P8-T4] --cov argument value `--cov-branch` is supplied space-separated; the ambiguous form can bind the following positional argument. Use the --cov=<module> form.
```

3. rule: G7; task: `P0-T10`

```text
[P0-T10] write-mode command `npm run format` rewrites tracked source and exits 0 after rewriting; the attributed task text carries none of its observation markers. Record an observation beyond the exit code.
```

Only one of the three findings comes from a new rule: a G7 finding against the `5a8ede0f` task `P0-T10`. That task is NOT in the derived corrected-form list — the alignment classifies it as an **addition**, listed in the addition table below, because its description text has no byte-equal counterpart at `e2aa6446`. Step 5 excludes additions from the derived list, so it contributes nothing to the corrected-form counts above. The other two findings are G4 findings from the pre-existing rule set, not from any rule this feature adds.

## The 35 unchanged matched pairs

| `e2aa6446` id | `5a8ede0f` id |
| --- | --- |
| `P0-T1` | `P0-T1` |
| `P0-T4` | `P0-T4` |
| `P0-T10` | `P0-T11` |
| `P0-T11` | `P0-T12` |
| `P0-T12` | `P0-T13` |
| `P0-T13` | `P0-T14` |
| `P0-T15` | `P0-T16` |
| `P1-T1` | `P1-T1` |
| `P1-T2` | `P1-T2` |
| `P1-T3` | `P1-T3` |
| `P2-T1` | `P2-T1` |
| `P2-T4` | `P2-T4` |
| `P2-T5` | `P2-T5` |
| `P3-T1` | `P3-T1` |
| `P3-T2` | `P3-T2` |
| `P3-T3` | `P3-T3` |
| `P4-T1` | `P4-T1` |
| `P4-T2` | `P4-T2` |
| `P4-T5` | `P4-T5` |
| `P5-T1` | `P5-T1` |
| `P5-T2` | `P5-T2` |
| `P5-T3` | `P5-T3` |
| `P5-T4` | `P5-T4` |
| `P5-T5` | `P5-T5` |
| `P5-T6` | `P5-T6` |
| `P5-T8` | `P5-T8` |
| `P5-T9` | `P5-T9` |
| `P5-T10` | `P5-T10` |
| `P5-T11` | `P5-T11` |
| `P6-T2` | `P6-T2` |
| `P6-T3` | `P6-T3` |
| `P7-T2` | `P7-T2` |
| `P7-T6` | `P7-T6` |
| `P8-T3` | `P8-T3` |
| `P8-T11` | `P8-T11` |

## Excluded tasks — the full exclusion set

Every excluded task is enumerated below with its identifier, the single commit it appears at, its description text, and its exclusion reason. No case is omitted.

### Deletions — 33 tasks present only at `e2aa6446`

| # | Identifier | Commit | Reason | Description text |
| --- | --- | --- | --- | --- |
| 1 | `P0-T3` | `e2aa6446` | deletion | Run `poetry run ruff check .` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/python-lint.md` with the four required fields. |
| 2 | `P0-T5` | `e2aa6446` | deletion | Run `poetry run pytest --cov --cov-branch --cov-report=term-missing` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/python-test-coverage.md` with the four required fields plus numeric baseline line-coverage and branch-coverage percentages in `Output Summary:`. |
| 3 | `P0-T6` | `e2aa6446` | deletion | Run the PoshQC formatter via `mcp__drm-copilot__run_poshqc_format` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/powershell-format.md` with the four required fields. |
| 4 | `P0-T7` | `e2aa6446` | deletion | Run the PoshQC analyzer via `mcp__drm-copilot__run_poshqc_analyze` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/powershell-analyze.md` with the four required fields. |
| 5 | `P0-T8` | `e2aa6446` | deletion | Run the Pester suite with coverage via `mcp__drm-copilot__run_poshqc_test` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/powershell-test-coverage.md` with the four required fields plus the numeric baseline line-coverage percentage in `Output Summary:`. |
| 6 | `P0-T9` | `e2aa6446` | deletion | Run the TypeScript format, lint, type-check, and Jest suites and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/typescript-suites.md` with the four required fields plus the pass and fail counts. |
| 7 | `P0-T14` | `e2aa6446` | deletion | Copy the AC-19 pre-registration table from this plan into `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/edge-delta-prediction.md`, together with the pre-registered value 53, the one-sided upper bound, and the conservation identity. |
| 8 | `P1-T4` | `e2aa6446` | deletion | [expect-fail] Run the Pester file created in P1-T3 via `mcp__drm-copilot__run_poshqc_test` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/regression-testing/powershell-classifier-marker-fail-before.md` with the four required fields plus `ExpectedExitCode: 1`. |
| 9 | `P2-T3` | `e2aa6446` | deletion | Remove the feature-corpus-span predicate and its two constants from `scripts/dev_tools/_blast_radius_extraction.py` and import them from `scripts/dev_tools/_blast_radius_token_shapes.py` instead, leaving the module's public behaviour unchanged. |
| 10 | `P3-T5` | `e2aa6446` | deletion | Write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/regression-testing/powershell-classifier-marker-pass-after.md` recording the run of the extended Pester file with the four required fields. |
| 11 | `P4-T6` | `e2aa6446` | deletion | Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py`, the manifest Pester suite `tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1`, and the pack-manifest-completeness Jest suite, then write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/registration-surfaces.md` with the four required fields per command. |
| 12 | `P5-T7` | `e2aa6446` | deletion | Verify the AC-9 reuse decision holds on disk by running `git diff --exit-code -- tests/fixtures/blast_radius/conflict-path-overlap.json` and recording the result in `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/negative-control-reuse.md` together with the reuse rationale from this plan. |
| 13 | `P5-T12` | `e2aa6446` | deletion | Run `git diff --name-only -- tests/fixtures/blast_radius` and record the result in `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/fixture-corpus-diff.md`. |
| 14 | `P6-T1` | `e2aa6446` | deletion | Amend the read-by-mandate paragraph in `.claude/rules/parallel-orchestration.md` — the paragraph currently beginning at line 236 that states the extractor rejects three token shapes — so that it states **four token shapes**, names the fourth as a token containing a placeholder or interpolation marker, states the marker set explicitly, and cross-references .claude/rules/plan-acceptance-gates.md as the set's origin. The amendment must additionally record: the never-matches-a-tracked-path rationale including the Windows-reserved-character argument for the angle brackets; the mandated-artifact origin of the dominant token, citing the non-overridable evidence-path scheme; the planner obligation to append a concrete path when an item will actually write a path it expressed as a shape; the fail-open shared-surface-glob trade with its measured-empty corpus exposure; and the whitespace-split residual as a known residual. Enforcement must remain prose plus validator logic. |
| 15 | `P6-T4` | `e2aa6446` | deletion | Run `git diff --exit-code -- .claude/rules/plan-acceptance-gates.md .github` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/policy-file-untouched.md` with the four required fields. |
| 16 | `P7-T1` | `e2aa6446` | deletion | Re-run the corpus measurement over the byte-identical item list stored by P0-T13, with the same constant derivation timestamp, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/conflict-graph-density.md` recording, before and after: item count with a non-zero assertion, edge count, density to one decimal place, cohort count, and maximum cohort width. |
| 17 | `P7-T3` | `e2aa6446` | deletion | Extend the same artifact with the named-survivor assertion over a fixed list carrying at least one path per acceptance rule — a recognized-extension file, a line-suffixed citation, a known-segment subtree glob, a configured root surface, and an own-feature-folder documentation glob. |
| 18 | `P7-T4` | `e2aa6446` | deletion | Extend the same artifact with the surviving-edge identity check: the known-genuine pair from the earlier false-conflict-edge capture must still conflict, with its reason kind and detail unchanged, on the shared MCP tools source file. |
| 19 | `P7-T5` | `e2aa6446` | deletion | Extend the same artifact with the prediction-against-actual report: the pre-registered pair count 53 from P0-T14, the executor's measured pair count, the actual edge-count delta, the itemized set of pairs that still conflict with each surviving reason, and the arithmetic showing the conservation identity holds. |
| 20 | `P7-T7` | `e2aa6446` | deletion | Re-run the P0-T15 repro in both runtimes post-fix and record the result in the same artifact. |
| 21 | `P8-T1` | `e2aa6446` | deletion | Run `poetry run black .` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-python-format.md` with the four required fields. |
| 22 | `P8-T2` | `e2aa6446` | deletion | Run `poetry run ruff check .` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-python-lint.md` with the four required fields. |
| 23 | `P8-T4` | `e2aa6446` | deletion | Run `poetry run pytest --cov --cov-branch --cov-report=term-missing` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-python-test-coverage.md` with the four required fields plus numeric post-change line-coverage and branch-coverage percentages. |
| 24 | `P8-T5` | `e2aa6446` | deletion | Compute the Python coverage delta and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/python-coverage-delta.md` recording the P0-T5 baseline percentages, the P8-T4 post-change percentages, and the coverage of the changed and newly added lines in `scripts/dev_tools/_blast_radius_token_shapes.py` and `scripts/dev_tools/_blast_radius_extraction.py`. |
| 25 | `P8-T6` | `e2aa6446` | deletion | Run `mcp__drm-copilot__run_poshqc_format` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-powershell-format.md` with the four required fields. |
| 26 | `P8-T7` | `e2aa6446` | deletion | Run `mcp__drm-copilot__run_poshqc_analyze` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-powershell-analyze.md` with the four required fields. |
| 27 | `P8-T8` | `e2aa6446` | deletion | Run `mcp__drm-copilot__run_poshqc_test` with coverage and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-powershell-test-coverage.md` with the four required fields plus the numeric post-change line-coverage percentage. |
| 28 | `P8-T9` | `e2aa6446` | deletion | Compute the PowerShell coverage delta and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/powershell-coverage-delta.md` recording the P0-T8 baseline percentage, the P8-T8 post-change percentage, and the coverage of the changed and newly added lines in `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` and `.claude/lib/blast-radius/BlastRadiusExtraction.psm1`. |
| 29 | `P8-T10` | `e2aa6446` | deletion | Run the TypeScript format, lint, type-check, and Jest suites and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-typescript-suites.md` with the four required fields. |
| 30 | `P8-T12` | `e2aa6446` | deletion | Audit the coverage configuration of both runtimes for exclusion entries and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/coverage-exclusion-audit.md`. |
| 31 | `P8-T13` | `e2aa6446` | deletion | Audit the full diff for contract changes and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/contract-scope-audit.md`. |
| 32 | `P8-T14` | `e2aa6446` | deletion | Audit the diff for any diagnostic channel and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/silent-drop-audit.md`. |
| 33 | `P8-T16` | `e2aa6446` | deletion | Map all 46 acceptance criteria from `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/spec.md` to the task and evidence artifact that satisfies each, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/acceptance-criteria-status.md`. |

### Additions — 34 tasks present only at `5a8ede0f`

| # | Identifier | Commit | Reason | Description text |
| --- | --- | --- | --- | --- |
| 1 | `P0-T3` | `5a8ede0f` | addition | Run `poetry run ruff check --no-fix .` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/python-lint.md` with the four required fields. The `--no-fix` flag is required and must not be dropped: the repository configuration sets `fix = true`, so the bare form rewrites fixable violations in place and still exits 0, which would mutate the tree before the baseline this task exists to establish and would report a clean exit for a tree it had just edited. Suppressing the fix makes the invocation genuinely read-only and restores exit-code fidelity, so a non-zero exit means findings exist. This mirrors P0-T2's use of the check flag for the formatter. |
| 2 | `P0-T5` | `5a8ede0f` | addition | Run `poetry run pytest --cov --cov-branch --cov-report=term-missing` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/python-test-coverage.md` with the four required fields plus numeric baseline line-coverage and branch-coverage percentages in `Output Summary:`. The `term-missing` reporter prints one combined `Cover` column, not two percentages, so the executor derives the line figure from the `Stmts` and `Miss` totals and the branch figure from the `Branch` and `BrPart` totals of the `TOTAL` row rather than reading two numbers that are never printed. The project's `addopts` supplies only an LCOV reporter, which is why this command must pass `term-missing` explicitly. |
| 3 | `P0-T6` | `5a8ede0f` | addition | Capture `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'` as a before snapshot, run the PoshQC formatter via `mcp__drm-copilot__run_poshqc_format`, capture the same command again as an after snapshot, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/powershell-format.md` with the four required fields plus both snapshots verbatim. The pair is captured for the same reason as in P0-T10: this is a write-mode formatter, so its exit status cannot report whether it rewrote anything, and the extension-based pathspec covers every file it can write without depending on the formatter's scan configuration. This is a baseline capture with no threshold. |
| 4 | `P0-T7` | `5a8ede0f` | addition | Run the PoshQC analyzer via `mcp__drm-copilot__run_poshqc_analyze` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/powershell-analyze.md` with the four required fields, recording the tool's ok status and its summary verbatim. The analyzer is read-only, so unlike the formatter its ok status is a faithful signal and no snapshot pair is needed. |
| 5 | `P0-T8` | `5a8ede0f` | addition | Run the Pester suite with coverage via `mcp__drm-copilot__run_poshqc_test` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/powershell-test-coverage.md` with the four required fields plus the numeric baseline line-coverage percentage in `Output Summary:`. That MCP tool returns only an ok flag and a short summary, so the test count, the failure count, and the coverage percentage must be read from the run's own output files `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`, not from the tool's return value. |
| 6 | `P0-T9` | `5a8ede0f` | addition | Install the TypeScript toolchain by running `npm ci` with `extensions/drm-copilot` as the working directory, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/typescript-install.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. The dependency tree is absent from this worktree, so the three TypeScript tasks in this plan cannot execute until it is installed; `extensions/drm-copilot/package-lock.json` is present, so the install is reproducible. |
| 7 | `P0-T10` | `5a8ede0f` | addition | Capture `git status --porcelain -- extensions/drm-copilot` as a before snapshot; then, with `extensions/drm-copilot` as the working directory, run `npm run format`, then `npm run lint`, then `npm run typecheck`, then `npm test`; then capture `git status --porcelain -- extensions/drm-copilot` again as an after snapshot; and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/typescript-suites.md` with the four required fields per command plus the aggregate pass and fail counts and both snapshots verbatim. The pair is captured here so that this baseline and the P8-T10 gate observe the same quantity by the same method and are therefore comparable. This is a baseline capture with no threshold: differing snapshots mean the tree carried pre-existing formatting drift, which is recorded as a finding for the operator rather than treated as a failure of this task. |
| 8 | `P0-T15` | `5a8ede0f` | addition | Copy the AC-19 pre-registration table from this plan into `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/edge-delta-prediction.md`, together with the pre-registered value 53, the one-sided upper bound, and the conservation identity. Also record in the artifact the resolved output of `git rev-parse HEAD` and of `git status --porcelain -- scripts .claude extensions/drm-copilot/resources`, both captured at the moment of writing. Those two recordings are what make the "written before" claim observable: without them, priority in time is asserted rather than evidenced, and a condition that cannot be checked is not a gate. The pathspec spans all three locations this item edits, not just the two repository-root trees: the bundled mirrors that P4-T2 and P6-T2 change live under the extension resources tree, and a witness that could not see them would leave part of the implementation outside the very claim it exists to support. |
| 9 | `P1-T4` | `5a8ede0f` | addition | [expect-fail] Run `mcp__drm-copilot__run_poshqc_test` scoped to the folder `tests/scripts/claude-lib/blast-radius` — that tool takes folders, not individual files, and the new test file is auto-discovered because the configured Pester scan folders already include the `tests/scripts` tree — then write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/regression-testing/powershell-classifier-marker-fail-before.md` with the four required fields plus `ExpectedExitCode: 1`. Read the individual test names and their outcomes from `artifacts/pester/pester-junit.xml`, since the tool returns only an ok flag and a short summary. |
| 10 | `P2-T3` | `5a8ede0f` | addition | Remove the feature-corpus-span predicate and its two constants from `scripts/dev_tools/_blast_radius_extraction.py`, leaving the module's public behaviour unchanged. Import from `scripts/dev_tools/_blast_radius_token_shapes.py` **only the names the extraction module still uses** — that is the span predicate alone, called at one site. The two relocated constants are read solely by the predicate itself, so importing them back would be an unused import and would trip ruff `F401`. The `--no-fix` flag on the lint command below is what makes that trip observable: the repository configuration sets `fix = true`, and an unused import is exactly the fixable class ruff repairs silently, so the bare form would delete the offending import line and exit 0 — the gate would pass on a file ruff had just edited and the executor would never learn the import was wrong. |
| 11 | `P3-T5` | `5a8ede0f` | addition | Write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/regression-testing/powershell-classifier-marker-pass-after.md` recording the folder-scoped run of the extended Pester file with the four required fields, reading the per-test outcomes from `artifacts/pester/pester-junit.xml` rather than from the tool's return value. |
| 12 | `P4-T6` | `5a8ede0f` | addition | Run these three commands and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/registration-surfaces.md` with the four required fields per command: first `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py`; second `mcp__drm-copilot__run_poshqc_test` scoped to the folder `tests/scripts/claude-lib/blast-radius`, reading the outcome of `tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1` from `artifacts/pester/pester-junit.xml`; third, with `extensions/drm-copilot` as the working directory, an `npm test` invocation scoped to the pack-manifest-completeness suite, whose repo-relative path is extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts and whose argument is that path with the extension-directory prefix removed. The suite path is named in prose rather than inline code deliberately: the working-directory-relative spelling matches no repository path, so inline-coding it would inject a phantom entry into this item's own radius — the class of defect this item repairs. |
| 13 | `P5-T7` | `5a8ede0f` | addition | Verify the AC-9 reuse decision holds on disk by running `git diff --exit-code main -- tests/fixtures/blast_radius/conflict-path-overlap.json` and record the result in `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/negative-control-reuse.md` together with the output of `git rev-parse main` and the reuse rationale from this plan. Naming the `main` ref explicitly is required, and the bare `git diff --exit-code` form must not be substituted: the bare form compares the worktree against the index only, so it passes vacuously the moment the executor commits, whereas comparing against `main` spans every committed and uncommitted change this branch has made. Recording the resolved SHA is what makes the anchor auditable: `main` is a moving local ref, so if it is fetched forward mid-execution without a rebase this gate can fail for a change this branch never made. That direction is fail-closed and therefore safe, but it is only diagnosable when the SHA is on record. |
| 14 | `P5-T12` | `5a8ede0f` | addition | Run both `git status --porcelain -- tests/fixtures/blast_radius` and `git diff --name-status main -- tests/fixtures/blast_radius`, and record both outputs in `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/fixture-corpus-diff.md`. Neither command alone suffices, and the reason is the commit state: the porcelain form reports the four new fixtures while they are untracked but goes empty once they are committed, while the `main`-anchored diff reports them once they are committed but never reports an untracked file. Taking the union of the two makes the gate independent of whether the executor has committed. Do not substitute `git add --intent-to-add` for either command: it mutates the index, and the union form needs no such side effect. That prohibition is scoped to this task alone and does not conflict with the `git add -A` step the five Phase 8 audits require. The two situations differ: this gate asserts a file *set* and the union supplies it without touching the index, whereas those audits need diff *content* and line counts, which no union of status output can supply. This task also runs several phases earlier, before any staging step, and works in either state, so requiring staging later does not disturb it. |
| 15 | `P6-T1` | `5a8ede0f` | addition | Amend the read-by-mandate paragraph in `.claude/rules/parallel-orchestration.md` — the paragraph currently beginning at line 236 that states the extractor rejects three token shapes — so that it states **four token shapes**, names the fourth as a token containing a placeholder or interpolation marker, states the marker set explicitly, and cross-references .claude/rules/plan-acceptance-gates.md as the set's origin. The amendment must additionally record: the never-matches-a-tracked-path rationale including the Windows-reserved-character argument for the angle brackets; the mandated-artifact origin of the dominant token, citing the non-overridable evidence-path scheme; the planner obligation to append a concrete path when an item will actually write a path it expressed as a shape; the fail-open shared-surface-glob trade with its measured-empty corpus exposure; and the whitespace-split residual as a known residual. Enforcement must remain prose plus validator logic. Take `git diff main -- .claude/rules/parallel-orchestration.md` and record it with the resolved `main` SHA; the two prior-state conditions below are asserted against that diff, not against the post-edit file, because a condition of the form "the existing paragraph is unchanged" cannot fail once the executor commits, and the mirror checks in P6-T2 and P6-T3 only prove the repo file and its bundled copy agree, which stays true if the amendment clobbers the paragraph in both. Acceptance, all four parts: the file contains the literal `four token shapes` on a single line; the diff's removed-line set contains no line belonging to the foreign-schema prohibition paragraph; the diff's added-line set introduces no reference to a schema file; and the resolved `main` SHA is recorded alongside the diff command. The broader claim that no schema file is added anywhere in the repository is deliberately not asserted here: this diff is scoped to one pathspec, and a newly created schema file would be untracked and invisible to it. That claim is carried instead by P8-T13, whose staged whole-tree anchored diff is already taken and can see a new file. |
| 16 | `P6-T4` | `5a8ede0f` | addition | Run `git diff --exit-code main -- .claude/rules/plan-acceptance-gates.md .github` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/policy-file-untouched.md` with the four required fields plus the output of `git rev-parse main`. The `main` ref must be named for the same reason as in P5-T7: the bare worktree-against-index form passes vacuously after a mid-execution commit, so it cannot fail. Record the resolved SHA for the same moving-ref reason given there. State also the gate's one scope limit: a diff does not see a brand-new untracked file, so this gate proves no tracked file in those two locations was changed and does not prove that no new file was added under the Copilot instruction tree. That gap is not reachable here — no task in this plan creates anything under that tree, and staging such a file would make it visible to the diff — but the limit is recorded so a later reader does not credit the gate with broader coverage than it has. |
| 17 | `P7-T1` | `5a8ede0f` | addition | Re-run the corpus measurement over the byte-identical item list stored by P0-T14, with the same constant derivation timestamp, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/conflict-graph-density.md` recording, before and after: item count with a non-zero assertion, edge count, density to one decimal place, cohort count, and maximum cohort width. |
| 18 | `P7-T3` | `5a8ede0f` | addition | Extend the same artifact with the named-survivor assertion. The list is fixed here rather than chosen at execution time, because a survivor list the executor selects can be selected to pass. The five probes, one per acceptance rule, are fixed as follows, each chosen against a measured carrier count over the 58 derived radii rather than by inspection of plan text. Recognized-extension rule: scripts/dev_tools/compute_blast_radius.py, 8 carriers. Known-segment subtree-glob rule: .claude/\*\* , 16 carriers. Configured-root-surface rule: package-lock.json, 7 carriers, which is a shared_surfaces entry and deliberately not a mandate_reads entry. Own-folder documentation-glob rule: the own-feature-folder glob of this item itself, docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/\*\* , which derivation adds automatically for every item, so it is guaranteed present for all 58. Line-suffixed-citation rule: at least one line-suffixed token must survive in at least one item's radius, expected instance config/blast-radius.json:12 — stated as an existence claim rather than a fixed token because every line-suffixed token in this corpus has exactly one carrier, which is inherent to line citations and would make a single named token break whenever its one carrier's plan is edited. All five are named in prose rather than inline code because this item writes none of them. Two probes were rejected on measurement and must not be reinstated: tests/scripts/dev_tools/\*\* has zero carriers because no plan in the corpus cites it, and quality-tiers.yml is structurally unreachable because it appears in both shared_surfaces and mandate_reads, so mandate-read exclusion strips it from every harvest and no derived radius can ever contain it. |
| 19 | `P7-T4` | `5a8ede0f` | addition | Extend the same artifact with the surviving-edge identity check, on the specific pair fixed here rather than one selected at execution time: the items for issues 486 and 487 must still conflict after the fix, with the reason kind `path_overlap` and the detail naming the shared MCP tools source file at extensions/drm-copilot/src/mcp-tools.ts, which is the known-genuine edge captured by the earlier false-conflict-edge work. |
| 20 | `P7-T5` | `5a8ede0f` | addition | Extend the same artifact with the prediction-against-actual report: the pre-registered pair count 53 from P0-T15, the executor's measured pair count, the actual edge-count delta, the itemized set of pairs that still conflict with each surviving reason, and the arithmetic showing the conservation identity holds. |
| 21 | `P7-T7` | `5a8ede0f` | addition | Re-run the P0-T16 repro in both runtimes post-fix and record the result in the same artifact. |
| 22 | `P8-T1` | `5a8ede0f` | addition | Run `poetry run black .` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-python-format.md` with the four required fields plus the run's final summary line verbatim. |
| 23 | `P8-T2` | `5a8ede0f` | addition | Run `poetry run ruff check .` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-python-lint.md` with the four required fields plus the run's final output line verbatim. |
| 24 | `P8-T4` | `5a8ede0f` | addition | Run `poetry run pytest --cov --cov-branch --cov-report=term-missing` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-python-test-coverage.md` with the four required fields plus numeric post-change line-coverage and branch-coverage percentages. As in P0-T5, the reporter prints one combined `Cover` column, so derive the line figure from the `Stmts` and `Miss` totals and the branch figure from the `Branch` and `BrPart` totals of the `TOTAL` row, and record which columns each figure came from. |
| 25 | `P8-T5` | `5a8ede0f` | addition | Compute the Python coverage delta and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/python-coverage-delta.md` recording the P0-T5 baseline percentages, the P8-T4 post-change percentages, and the coverage of the changed and newly added lines in `scripts/dev_tools/_blast_radius_token_shapes.py` and `scripts/dev_tools/_blast_radius_extraction.py`. Run `git add -A` at the repository root first, then identify the changed line set from `git diff main` for those two paths. Both steps are required and neither is optional: an unanchored diff misses committed changes, and an unstaged diff omits the newly created leaf module entirely, which would make its changed-line set empty and let a vacuous zero satisfy the coverage figure. |
| 26 | `P8-T6` | `5a8ede0f` | addition | Capture `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'` as a before snapshot, run `mcp__drm-copilot__run_poshqc_format`, capture the same command again as an after snapshot, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-powershell-format.md` with the four required fields plus both snapshots verbatim. The pair replaces a bare "zero files changed" reading because this is a write-mode formatter: its exit status is 0 whether or not it rewrote a file, so the exit code alone cannot observe a reformat, and a single post-hoc snapshot cannot attribute a modification to this run. |
| 27 | `P8-T7` | `5a8ede0f` | addition | Run `mcp__drm-copilot__run_poshqc_analyze` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-powershell-analyze.md` with the four required fields plus the tool's summary verbatim. |
| 28 | `P8-T8` | `5a8ede0f` | addition | Run `mcp__drm-copilot__run_poshqc_test` with coverage over the full configured scan scope and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-powershell-test-coverage.md` with the four required fields plus the numeric post-change line-coverage percentage. The tool returns only an ok flag and a short summary, so read the test count and failure count from `artifacts/pester/pester-junit.xml` and the coverage percentage and per-file measured set from `artifacts/pester/powershell-coverage.xml`. |
| 29 | `P8-T9` | `5a8ede0f` | addition | Compute the PowerShell coverage delta and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/powershell-coverage-delta.md` recording the P0-T8 baseline percentage, the P8-T8 post-change percentage, and the coverage of the changed and newly added lines in `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` and `.claude/lib/blast-radius/BlastRadiusExtraction.psm1`. Run `git add -A` at the repository root first, then identify the changed line set from `git diff main` for those two paths, for both reasons given in P8-T5. |
| 30 | `P8-T10` | `5a8ede0f` | addition | Capture `git status --porcelain -- extensions/drm-copilot` as a before snapshot; then, with `extensions/drm-copilot` as the working directory, run `npm run format`, then `npm run lint`, then `npm run typecheck`, then `npm test`; then capture `git status --porcelain -- extensions/drm-copilot` again as an after snapshot; and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-typescript-suites.md` with the four required fields per command plus both snapshots verbatim. The before-and-after pair is what makes the formatting stage falsifiable and must not be collapsed to a single snapshot: the `format` script is a write-mode Prettier invocation and Prettier exits 0 even when it rewrites a file, and a single post-hoc status compares worktree to index and so cannot attribute a modification to the command that just ran. Two snapshots around the command make the observation run-scoped — a rewrite from this run appears only in the after snapshot, while drift already present appears in both and cancels. This package defines no check-only script, which is why the observation is made through git rather than through a second npm script. The pathspec is the whole extension directory rather than a narrower list because the `format` script also globs the extension root, where the lock file, both TypeScript configs, and four build scripts match; the lock file is a declared shared surface, so an unnoticed rewrite there would silently modify one. The wider scope is safe because the dependency tree is ignored by git and the pathspec is otherwise untouched by this item. |
| 31 | `P8-T12` | `5a8ede0f` | addition | Run `git add -A` at the repository root, then audit the coverage configuration of both runtimes for exclusion entries over the diff produced by `git diff main`, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/coverage-exclusion-audit.md`, recording both commands and the resolved `main` SHA. Staging is required even though exclusion entries live in tracked configuration files, because an unstaged diff is an incomplete diff and this audit's negative claim is only as broad as the diff it reads. |
| 32 | `P8-T13` | `5a8ede0f` | addition | Run `git add -A` at the repository root, then audit the diff produced by `git diff main` for contract changes, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/contract-scope-audit.md`, recording both commands and the resolved `main` SHA. Staging is load-bearing here above all: the two new leaf modules are what add function signatures, and an unstaged diff would not contain them, so the no-new-signature claim would be made against a diff that structurally cannot show a violation. |
| 33 | `P8-T14` | `5a8ede0f` | addition | Run `git add -A` at the repository root, then audit the diff produced by `git diff main` for any diagnostic channel, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/silent-drop-audit.md`, recording both commands and the resolved `main` SHA. Staging is required because a finding rule added inside a newly created file is invisible to an unstaged diff, which is exactly the case this audit must be able to catch. |
| 34 | `P8-T16` | `5a8ede0f` | addition | Map every item in the two enumerated sets from `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/spec.md` to the task and evidence artifact that satisfies it, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/acceptance-criteria-status.md`. The two sets are the **41** numbered criteria AC-1 through AC-41 in the `## Acceptance Criteria` section, and the **11** rows of the `### Traceability to issue.md` table, for **52** mapped items in total. Do not count the four impact/severity radios or the logs-attached checkbox: they sit outside the `## Acceptance Criteria` section and are not criteria. |

## Verbatim driver output

```text
first_task_count=75
first_nonempty_acceptance=75
first_guard_pass=True
final_task_count=76
final_nonempty_acceptance=75
final_guard_pass=True
matched_count=42
unchanged_count=35
corrected_count=7
deletion_count=33
addition_count=34
blocking_count=0
warning_count=3
FINDING <unattributed> P0-T5
FINDING <unattributed> P8-T4
FINDING G7 P0-T10
CORRECTED P0-T2 -> P0-T2 G7=0 G8=0 G8b=0 G9=0
CORRECTED P2-T2 -> P2-T2 G7=0 G8=0 G8b=0 G9=0
CORRECTED P3-T4 -> P3-T4 G7=0 G8=0 G8b=0 G9=0
CORRECTED P4-T3 -> P4-T3 G7=0 G8=0 G8b=0 G9=0
CORRECTED P4-T4 -> P4-T4 G7=0 G8=0 G8b=0 G9=0
CORRECTED P8-T15 -> P8-T15 G7=0 G8=0 G8b=0 G9=0
CORRECTED P8-T17 -> P8-T17 G7=0 G8=0 G8b=0 G9=0
corrected_form_total_findings=0
GUARD_PASS
payload=C:\Users\DANMOI~1\AppData\Local\Temp\claude\C--Users-DanMoisan-repos-drm-copilot-wt-2026-08-23T20-24\52ac2030-ba56-47de-a115-b912d0d4409c\scratchpad\p5t5_r2_payload.json
```

## Verdict

**PASS.** The vacuity guard passes for both commits. The derived corrected-form list has 7 entries, each reproduced above with the differing acceptance text under both commits, and each carries a finding count of 0 from G7, G8, G8b, and G9. The list was derived by the stated longest-common-subsequence alignment over the two recorded extractions with the stated tie-break; it was not derived by identifier pairing and no task was selected, dropped, or judged by the executor.
