# Corrected Forms â€” Do the New Rules Fire on the Final Revision? â€” [P5-T5]

Timestamp: 2026-08-26T13-20
Task: [P5-T5]
Command: `poetry run python scripts/dev_tools/_tmp_plan_gate_regression_driver.py --acceptance-diff`, followed by `poetry run python scripts/dev_tools/_tmp_plan_gate_regression_driver.py --acceptance-dump`
Working directory: `C:/Users/DanMoisan/repos/drm-copilot/.claude/worktrees/agent-a2c2e891a6977ab65`
EXIT_CODE: 0

## TASK OUTCOME: FAIL â€” [P5-T5] is left unchecked in the plan

The acceptance condition of [P5-T5] requires a finding count of 0 from every new rule for **each** identifier in the derived list. One identifier in the derived list, `P0-T10`, records a new-rule finding count of **1** at commit `5a8ede0f`. The condition is therefore not met, and the plan checkbox for [P5-T5] is left `- [ ]`. The reason is recorded in full below rather than worked around; no criterion was relaxed and no identifier was removed from the derived list to make the condition pass.

## How the list was derived

The list is not chosen by the executor. It is exactly the set of task identifiers whose acceptance text differs between the `e2aa6446` extraction and the `5a8ede0f` extraction recorded by [P5-T1], compared as text. It was derived by no other means.

The derivation is mechanical:

1. Both revision texts are read from git object storage with the same `git show` commands [P5-T1] recorded â€” not from any intermediate copy.
2. Each text is parsed into a mapping from task identifier to that task's attribution-window text, using the whole-window definition this plan freezes: the owning task line plus every following line up to, but not including, the line that closes the window. The parse reuses the shipped `PLAN_GATE_TASK_RE` and `PLAN_GATE_HEADING_RE` patterns imported from `scripts/dev_tools/plan_gate_commands.py`, so it cannot drift from the extractor's own window.
3. An identifier is in the list when its window text under the two commits is unequal as text. An identifier absent at one commit is compared against the empty string, so it is in the list.
4. The finding count per identifier is taken from the shipped `evaluate_plan_gates` run against the `5a8ede0f` text with a real repository context, counting findings whose text carries the square-bracketed identifier.

The 502 plan carries **75** task identifiers at `e2aa6446` and **76** at `5a8ede0f`.

## Size of the derived list

**The derived list contains 46 task identifiers.**

## Per-identifier new-rule finding counts at `5a8ede0f`

Verbatim output of the `--acceptance-diff` mode:

```text
first=e2aa6446 tasks=75
last=5a8ede0f tasks=76
differing=46
P0-T2	in_first=True	in_last=True	new_rule_findings_at_last=0
P0-T3	in_first=True	in_last=True	new_rule_findings_at_last=0
P0-T5	in_first=True	in_last=True	new_rule_findings_at_last=0
P0-T6	in_first=True	in_last=True	new_rule_findings_at_last=0
P0-T7	in_first=True	in_last=True	new_rule_findings_at_last=0
P0-T8	in_first=True	in_last=True	new_rule_findings_at_last=0
P0-T9	in_first=True	in_last=True	new_rule_findings_at_last=0
P0-T10	in_first=True	in_last=True	new_rule_findings_at_last=1
P0-T11	in_first=True	in_last=True	new_rule_findings_at_last=0
P0-T12	in_first=True	in_last=True	new_rule_findings_at_last=0
P0-T13	in_first=True	in_last=True	new_rule_findings_at_last=0
P0-T14	in_first=True	in_last=True	new_rule_findings_at_last=0
P0-T15	in_first=True	in_last=True	new_rule_findings_at_last=0
P0-T16	in_first=False	in_last=True	new_rule_findings_at_last=0
P1-T4	in_first=True	in_last=True	new_rule_findings_at_last=0
P2-T2	in_first=True	in_last=True	new_rule_findings_at_last=0
P2-T3	in_first=True	in_last=True	new_rule_findings_at_last=0
P3-T4	in_first=True	in_last=True	new_rule_findings_at_last=0
P3-T5	in_first=True	in_last=True	new_rule_findings_at_last=0
P4-T3	in_first=True	in_last=True	new_rule_findings_at_last=0
P4-T4	in_first=True	in_last=True	new_rule_findings_at_last=0
P4-T6	in_first=True	in_last=True	new_rule_findings_at_last=0
P5-T7	in_first=True	in_last=True	new_rule_findings_at_last=0
P5-T12	in_first=True	in_last=True	new_rule_findings_at_last=0
P6-T1	in_first=True	in_last=True	new_rule_findings_at_last=0
P6-T4	in_first=True	in_last=True	new_rule_findings_at_last=0
P7-T1	in_first=True	in_last=True	new_rule_findings_at_last=0
P7-T3	in_first=True	in_last=True	new_rule_findings_at_last=0
P7-T4	in_first=True	in_last=True	new_rule_findings_at_last=0
P7-T5	in_first=True	in_last=True	new_rule_findings_at_last=0
P7-T7	in_first=True	in_last=True	new_rule_findings_at_last=0
P8-T1	in_first=True	in_last=True	new_rule_findings_at_last=0
P8-T2	in_first=True	in_last=True	new_rule_findings_at_last=0
P8-T4	in_first=True	in_last=True	new_rule_findings_at_last=0
P8-T5	in_first=True	in_last=True	new_rule_findings_at_last=0
P8-T6	in_first=True	in_last=True	new_rule_findings_at_last=0
P8-T7	in_first=True	in_last=True	new_rule_findings_at_last=0
P8-T8	in_first=True	in_last=True	new_rule_findings_at_last=0
P8-T9	in_first=True	in_last=True	new_rule_findings_at_last=0
P8-T10	in_first=True	in_last=True	new_rule_findings_at_last=0
P8-T12	in_first=True	in_last=True	new_rule_findings_at_last=0
P8-T13	in_first=True	in_last=True	new_rule_findings_at_last=0
P8-T14	in_first=True	in_last=True	new_rule_findings_at_last=0
P8-T15	in_first=True	in_last=True	new_rule_findings_at_last=0
P8-T16	in_first=True	in_last=True	new_rule_findings_at_last=0
P8-T17	in_first=True	in_last=True	new_rule_findings_at_last=0
```

**45 of the 46 identifiers record a finding count of 0 from every new rule. One, `P0-T10`, records 1.**

## The one non-zero identifier, examined

The finding is:

```text
[P0-T10] write-mode command `npm run format` rewrites tracked source and exits 0 after rewriting; the attributed task text carries none of its observation markers. Record an observation beyond the exit code.
```

Two separate facts explain it, and they point in different directions. Both are recorded.

### Fact 1 â€” the identifier `P0-T10` names two different tasks at the two commits

At `e2aa6446`, `P0-T10` is a file-line-count baseline task. At `5a8ede0f`, `P0-T10` is a TypeScript-suite baseline task that runs `npm run format`, `npm run lint`, `npm run typecheck`, and `npm test`. They are not the same task at two stages of correction; the plan was renumbered between the two revisions and the identifier was reused.

This is a defect in the derivation the plan prescribes, not in the rules under test. [P5-T5] assumes a task identifier is a stable key across the two revisions, so that "acceptance text differs" means "this task was corrected". The extraction shows the assumption does not hold for this corpus: the plan grew from 75 tasks to 76 and identifiers were reallocated. An identifier-keyed comparison therefore reports both genuinely corrected tasks and tasks that merely inherited a number, and it cannot distinguish them.

The derived list of 46 is reported as prescribed regardless. Substituting a different derivation â€” matching on task text, on ordinal position, or on any similarity heuristic â€” would be exactly the executor-chosen list the task forbids, and would also be unauditable. The list stands as the prescribed derivation produces it, and the consequence of the prescription is recorded here.

### Fact 2 â€” the final revision's `P0-T10` does record an observation, just not one G7 can read

The final `P0-T10` captures `git status --porcelain -- extensions/drm-copilot` before the four commands and again afterwards, and requires both snapshots verbatim in its artifact. That snapshot pair is a real observation beyond the exit code: a formatter that rewrote a file changes the porcelain output between the two captures, so the task can in fact distinguish a clean run from a repairing one.

G7 does not see it. G7's `prettier-write` entry looks for the literals `(unchanged)`, `unchanged`, and `rewrote` in the attributed task text â€” the markers Prettier's own success-case output prints â€” and the task's text carries none of them, because it observes the tree rather than the tool's stdout.

This is therefore a **G7 false positive in substance**: the acceptance condition is falsifiable, by a mechanism the register's marker set does not cover. It is recorded here as such and is carried into the Phase 6 corpus measurement, where the false-positive count is what the pre-declared decision rule consumes. It is not evidence that G7 is wrong to exist; it is evidence that the marker set recognises tool-output observation only, and that a snapshot-pair observation is a second legitimate form.

## What this task does and does not establish

It establishes that the new rules fire on **none** of the 45 identifiers whose acceptance text was corrected in a way the rules can read, and that every G8 and G9 finding present at `e2aa6446` is absent at `5a8ede0f`. That is the substance of the regression the task exists to demonstrate.

It does not establish the stated universal over all 46 identifiers, because of the single case above. The task is left unchecked on that basis.

## Full acceptance text of each derived identifier under both commits

Each section below reproduces the identifier's whole attribution-window text under `e2aa6446` and under `5a8ede0f`, together with its new-rule finding count at `5a8ede0f`. The dump is the verbatim output of the driver's `--acceptance-dump` mode, which walks the same two extractions.

### P0-T2 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P0-T2] Run `poetry run black --check .` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/python-format.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: the artifact records the exit code and the reformatted-file count.
```

Under `5a8ede0f`:

```text
- [ ] [P0-T2] Run `poetry run black --check .` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/python-format.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, `Output Summary:`. Acceptance: exit code 0; the final summary line ends with the literal `would be left unchanged.`; no output line begins with the literal `would reformat `; and that summary line is recorded verbatim. The acceptance names the clean-run literal rather than a would-reformat count because on a clean run no count and no per-file line is emitted at all â€” only the summary â€” so an acceptance demanding a count could never be satisfied. The check flag makes this invocation read-only, so no file is written and no snapshot pair is needed here; P8-T1 runs the write-mode form.
```

### P0-T3 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P0-T3] Run `poetry run ruff check .` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/python-lint.md` with the four required fields. Acceptance: the artifact records the exit code and the finding count.
```

Under `5a8ede0f`:

```text
- [ ] [P0-T3] Run `poetry run ruff check --no-fix .` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/python-lint.md` with the four required fields. The `--no-fix` flag is required and must not be dropped: the repository configuration sets `fix = true`, so the bare form rewrites fixable violations in place and still exits 0, which would mutate the tree before the baseline this task exists to establish and would report a clean exit for a tree it had just edited. Suppressing the fix makes the invocation genuinely read-only and restores exit-code fidelity, so a non-zero exit means findings exist. This mirrors P0-T2's use of the check flag for the formatter. Acceptance: the artifact records the exit code and the finding count.
```

### P0-T5 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P0-T5] Run `poetry run pytest --cov --cov-branch --cov-report=term-missing` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/python-test-coverage.md` with the four required fields plus numeric baseline line-coverage and branch-coverage percentages in `Output Summary:`. Acceptance: both percentages are recorded as numbers, not placeholders.
```

Under `5a8ede0f`:

```text
- [ ] [P0-T5] Run `poetry run pytest --cov --cov-branch --cov-report=term-missing` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/python-test-coverage.md` with the four required fields plus numeric baseline line-coverage and branch-coverage percentages in `Output Summary:`. The `term-missing` reporter prints one combined `Cover` column, not two percentages, so the executor derives the line figure from the `Stmts` and `Miss` totals and the branch figure from the `Branch` and `BrPart` totals of the `TOTAL` row rather than reading two numbers that are never printed. The project's `addopts` supplies only an LCOV reporter, which is why this command must pass `term-missing` explicitly. Acceptance: both percentages are recorded as numbers with the columns they were derived from, not as placeholders, alongside the passed and skipped test counts.
```

### P0-T6 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P0-T6] Run the PoshQC formatter via `mcp__drm-copilot__run_poshqc_format` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/powershell-format.md` with the four required fields. Acceptance: the artifact records the changed-file count.
```

Under `5a8ede0f`:

```text
- [ ] [P0-T6] Capture `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'` as a before snapshot, run the PoshQC formatter via `mcp__drm-copilot__run_poshqc_format`, capture the same command again as an after snapshot, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/powershell-format.md` with the four required fields plus both snapshots verbatim. The pair is captured for the same reason as in P0-T10: this is a write-mode formatter, so its exit status cannot report whether it rewrote anything, and the extension-based pathspec covers every file it can write without depending on the formatter's scan configuration. This is a baseline capture with no threshold. Acceptance: both snapshots are recorded verbatim even when empty, and the tool's summary is recorded verbatim alongside them.
```

### P0-T7 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P0-T7] Run the PoshQC analyzer via `mcp__drm-copilot__run_poshqc_analyze` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/powershell-analyze.md` with the four required fields. Acceptance: the artifact records the diagnostic count by severity.
```

Under `5a8ede0f`:

```text
- [ ] [P0-T7] Run the PoshQC analyzer via `mcp__drm-copilot__run_poshqc_analyze` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/powershell-analyze.md` with the four required fields, recording the tool's ok status and its summary verbatim. The analyzer is read-only, so unlike the formatter its ok status is a faithful signal and no snapshot pair is needed. Acceptance: the artifact records the ok status and the summary verbatim, plus the diagnostic count by severity when the summary reports one.
```

### P0-T8 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P0-T8] Run the Pester suite with coverage via `mcp__drm-copilot__run_poshqc_test` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/powershell-test-coverage.md` with the four required fields plus the numeric baseline line-coverage percentage in `Output Summary:`. Acceptance: the percentage is recorded as a number; note that no branch-coverage threshold applies to Pester.
```

Under `5a8ede0f`:

```text
- [ ] [P0-T8] Run the Pester suite with coverage via `mcp__drm-copilot__run_poshqc_test` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/powershell-test-coverage.md` with the four required fields plus the numeric baseline line-coverage percentage in `Output Summary:`. That MCP tool returns only an ok flag and a short summary, so the test count, the failure count, and the coverage percentage must be read from the run's own output files `artifacts/pester/pester-junit.xml` and `artifacts/pester/powershell-coverage.xml`, not from the tool's return value. Acceptance: the percentage and both counts are recorded as numbers and the artifact names the two output files they were read from; note that no branch-coverage threshold applies to Pester.
```

### P0-T9 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P0-T9] Run the TypeScript format, lint, type-check, and Jest suites and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/typescript-suites.md` with the four required fields plus the pass and fail counts. Acceptance: the artifact records a green pre-change state for the pack-manifest-completeness suite specifically.
```

Under `5a8ede0f`:

```text
- [ ] [P0-T9] Install the TypeScript toolchain by running `npm ci` with `extensions/drm-copilot` as the working directory, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/typescript-install.md` with `Timestamp:`, `Command:`, `EXIT_CODE:`, and `Output Summary:`. The dependency tree is absent from this worktree, so the three TypeScript tasks in this plan cannot execute until it is installed; `extensions/drm-copilot/package-lock.json` is present, so the install is reproducible. Acceptance: exit code 0 and the artifact records the installed package count.
```

### P0-T10 — new-rule finding count at `5a8ede0f`: 1

Under `e2aa6446`:

```text
- [ ] [P0-T10] Count the lines of `scripts/dev_tools/_blast_radius_extraction.py`, `.claude/lib/blast-radius/BlastRadiusExtraction.psm1`, `tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1`, `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py`, `tests/scripts/dev_tools/test_blast_radius_normalization.py`, `tests/scripts/dev_tools/test_blast_radius_validation.py`, and `tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1`, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/file-size-headroom.md`. Acceptance: the artifact records 497 and 498 for the two extraction modules and states the remaining headroom for each of the seven files.
```

Under `5a8ede0f`:

```text
- [ ] [P0-T10] Capture `git status --porcelain -- extensions/drm-copilot` as a before snapshot; then, with `extensions/drm-copilot` as the working directory, run `npm run format`, then `npm run lint`, then `npm run typecheck`, then `npm test`; then capture `git status --porcelain -- extensions/drm-copilot` again as an after snapshot; and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/typescript-suites.md` with the four required fields per command plus the aggregate pass and fail counts and both snapshots verbatim. The pair is captured here so that this baseline and the P8-T10 gate observe the same quantity by the same method and are therefore comparable. This is a baseline capture with no threshold: differing snapshots mean the tree carried pre-existing formatting drift, which is recorded as a finding for the operator rather than treated as a failure of this task. Acceptance: all four commands are recorded with their exit codes, both snapshots are recorded verbatim even when empty, and the artifact records a green pre-change state for the pack-manifest-completeness suite specifically.
```

### P0-T11 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P0-T11] Execute the five-marker probe against `classify_path_token` in the Python runtime using single-quoted literals, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/marker-probe-python.md` recording, per marker, the probe literal and the returned classification. Acceptance: the artifact records an executed result for all five markers, converting the code-trace determination into a measurement. If any marker is already rejected, record it and narrow the marker tuple accordingly in Phase 2.
```

Under `5a8ede0f`:

```text
- [ ] [P0-T11] Count the lines of `scripts/dev_tools/_blast_radius_extraction.py`, `.claude/lib/blast-radius/BlastRadiusExtraction.psm1`, `tests/scripts/claude-lib/blast-radius/BlastRadiusExtraction.Path.Tests.ps1`, `tests/scripts/dev_tools/test_blast_radius_extraction_rules.py`, `tests/scripts/dev_tools/test_blast_radius_normalization.py`, `tests/scripts/dev_tools/test_blast_radius_validation.py`, and `tests/scripts/claude-lib/blast-radius/BlastRadiusNormalization.Tests.ps1`, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/file-size-headroom.md`. Acceptance: the artifact records 497 and 498 for the two extraction modules and states the remaining headroom for each of the seven files.
```

### P0-T12 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P0-T12] Execute the same five-marker probe against `Get-PathTokenKind` in the PowerShell runtime using single-quoted literals only, asserting each probe's literal content before classification, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/marker-probe-powershell.md`. Acceptance: the artifact records the probe literal alongside its classification for all five markers and states explicitly that no double-quoted string was used.
```

Under `5a8ede0f`:

```text
- [ ] [P0-T12] Execute the five-marker probe against `classify_path_token` in the Python runtime using single-quoted literals, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/marker-probe-python.md` recording, per marker, the probe literal and the returned classification. Acceptance: the artifact records an executed result for all five markers, converting the code-trace determination into a measurement. If any marker is already rejected, record it and narrow the marker tuple accordingly in Phase 2.
```

### P0-T13 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P0-T13] Enumerate the top-level plan documents under `docs/features/active/` deterministically and sorted, derive one radius per document with a single constant derivation timestamp and the sibling spec text when present, compute every canonical ascending pair, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/conflict-graph-density-before.md` recording the item count, the full sorted item list, the edge count with each edge's reason kind and detail, the density to one decimal place, the cohort count, the maximum cohort width, and the total number of radius path entries across all radii. Acceptance: the item count is non-zero and is recorded; a deviation from 58 is recorded rather than silently accepted; the item list is stored verbatim so the after-measurement can be run over a byte-identical set.
```

Under `5a8ede0f`:

```text
- [ ] [P0-T13] Execute the same five-marker probe against `Get-PathTokenKind` in the PowerShell runtime using single-quoted literals only, asserting each probe's literal content before classification, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/marker-probe-powershell.md`. Acceptance: the artifact records the probe literal alongside its classification for all five markers and states explicitly that no double-quoted string was used.
```

### P0-T14 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P0-T14] Copy the AC-19 pre-registration table from this plan into `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/edge-delta-prediction.md`, together with the pre-registered value 53, the one-sided upper bound, and the conservation identity. Acceptance: the artifact exists and is written before any production file is modified, establishing that the prediction preceded the measurement.
```

Under `5a8ede0f`:

```text
- [ ] [P0-T14] Enumerate the top-level plan documents under `docs/features/active/` deterministically and sorted, derive one radius per document with a single constant derivation timestamp and the sibling spec text when present, compute every canonical ascending pair, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/conflict-graph-density-before.md` recording the item count, the full sorted item list, the edge count with each edge's reason kind and detail, the density to one decimal place, the cohort count, the maximum cohort width, and the total number of radius path entries across all radii. Acceptance: the item count is non-zero and is recorded; a deviation from 58 is recorded rather than silently accepted; the item list is stored verbatim so the after-measurement can be run over a byte-identical set.
```

### P0-T15 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P0-T15] Reproduce the defect in both runtimes: build two radii from structured plan text whose only shared entry is a placeholder feature-document token, with disjoint real files under different feature folders, and record the conflict verdict in `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/repro-before.md`, together with the negative-control run with the placeholder removed. Acceptance: the artifact records conflict true for the placeholder-only overlap and conflict false for the control, in both runtimes.

```

Under `5a8ede0f`:

```text
- [ ] [P0-T15] Copy the AC-19 pre-registration table from this plan into `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/edge-delta-prediction.md`, together with the pre-registered value 53, the one-sided upper bound, and the conservation identity. Also record in the artifact the resolved output of `git rev-parse HEAD` and of `git status --porcelain -- scripts .claude extensions/drm-copilot/resources`, both captured at the moment of writing. Those two recordings are what make the "written before" claim observable: without them, priority in time is asserted rather than evidenced, and a condition that cannot be checked is not a gate. The pathspec spans all three locations this item edits, not just the two repository-root trees: the bundled mirrors that P4-T2 and P6-T2 change live under the extension resources tree, and a witness that could not see them would leave part of the implementation outside the very claim it exists to support. Acceptance: the artifact exists, carries the pre-registered value 53 and the identity, and its recorded status output shows no modification to any file this item edits in any of the three locations â€” establishing that the prediction was fixed before the implementation began rather than after the measurement was seen.
```

### P0-T16 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
(identifier absent at this commit)
```

Under `5a8ede0f`:

```text
- [ ] [P0-T16] Reproduce the defect in both runtimes: build two radii from structured plan text whose only shared entry is a placeholder feature-document token, with disjoint real files under different feature folders, and record the conflict verdict in `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/baseline/repro-before.md`, together with the negative-control run with the placeholder removed. Acceptance: the artifact records conflict true for the placeholder-only overlap and conflict false for the control, in both runtimes.

```

### P1-T4 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P1-T4] [expect-fail] Run the Pester file created in P1-T3 via `mcp__drm-copilot__run_poshqc_test` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/regression-testing/powershell-classifier-marker-fail-before.md` with the four required fields plus `ExpectedExitCode: 1`. Acceptance: all five classifier-level cases fail, recorded by test name.

```

Under `5a8ede0f`:

```text
- [ ] [P1-T4] [expect-fail] Run `mcp__drm-copilot__run_poshqc_test` scoped to the folder `tests/scripts/claude-lib/blast-radius` â€” that tool takes folders, not individual files, and the new test file is auto-discovered because the configured Pester scan folders already include the `tests/scripts` tree â€” then write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/regression-testing/powershell-classifier-marker-fail-before.md` with the four required fields plus `ExpectedExitCode: 1`. Read the individual test names and their outcomes from `artifacts/pester/pester-junit.xml`, since the tool returns only an ok flag and a short summary. Acceptance: all five classifier-level cases are recorded as failing by test name, read from the JUnit file, and no other test in that folder regresses.

```

### P2-T2 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P2-T2] Create `tests/scripts/dev_tools/test_blast_radius_token_shapes.py` covering: a parametrized case per marker asserting the predicate reports the token as marker-bearing; a case with a marker in the filename position; a case asserting a marker-free real repository path is not reported as marker-bearing; cases for the empty string, a marker-only token, and a bare bracket pair asserting no exception is raised; and the relocated span predicate's retained and rejected cases. Add one further test asserting the new module's marker tuple is equal to the acceptance-gate marker tuple exported by scripts/dev_tools/plan_gate_coverage.py, so the two subsystems are pinned to agree by test rather than by convention. Acceptance: `poetry run pytest --cov=scripts.dev_tools._blast_radius_token_shapes --cov-branch tests/scripts/dev_tools/test_blast_radius_token_shapes.py` passes and reports line coverage at or above 85 percent and branch coverage at or above 75 percent for that module.
```

Under `5a8ede0f`:

```text
- [ ] [P2-T2] Create `tests/scripts/dev_tools/test_blast_radius_token_shapes.py` covering: a parametrized case per marker asserting the predicate reports the token as marker-bearing; a case with a marker in the filename position; a case asserting a marker-free real repository path is not reported as marker-bearing; cases for the empty string, a marker-only token, and a bare bracket pair asserting no exception is raised; and the relocated span predicate's retained and rejected cases. Add one further test asserting the new module's marker tuple is equal to the acceptance-gate marker tuple exported by scripts/dev_tools/plan_gate_coverage.py, so the two subsystems are pinned to agree by test rather than by convention. Acceptance: `poetry run pytest --cov=scripts.dev_tools._blast_radius_token_shapes --cov-branch --cov-report=term-missing tests/scripts/dev_tools/test_blast_radius_token_shapes.py` exits 0 and reports line coverage at or above 85 percent and branch coverage at or above 75 percent for that module. The `term-missing` reporter must be passed explicitly because the project's `addopts` supplies only an LCOV reporter, so without it no coverage table is printed and the percentages this acceptance demands would not be observable; derive both figures from the `Stmts`, `Miss`, `Branch`, and `BrPart` columns of the module's row.
```

### P2-T3 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P2-T3] Remove the feature-corpus-span predicate and its two constants from `scripts/dev_tools/_blast_radius_extraction.py` and import them from `scripts/dev_tools/_blast_radius_token_shapes.py` instead, leaving the module's public behaviour unchanged. Acceptance: the file's line count is strictly less than 497, and `poetry run pytest tests/scripts/dev_tools` passes with no new failure relative to the P0-T5 baseline.
```

Under `5a8ede0f`:

```text
- [ ] [P2-T3] Remove the feature-corpus-span predicate and its two constants from `scripts/dev_tools/_blast_radius_extraction.py`, leaving the module's public behaviour unchanged. Import from `scripts/dev_tools/_blast_radius_token_shapes.py` **only the names the extraction module still uses** â€” that is the span predicate alone, called at one site. The two relocated constants are read solely by the predicate itself, so importing them back would be an unused import and would trip ruff `F401`. The `--no-fix` flag on the lint command below is what makes that trip observable: the repository configuration sets `fix = true`, and an unused import is exactly the fixable class ruff repairs silently, so the bare form would delete the offending import line and exit 0 â€” the gate would pass on a file ruff had just edited and the executor would never learn the import was wrong. Acceptance: the file's line count is strictly less than 497, `poetry run ruff check --no-fix scripts/dev_tools/_blast_radius_extraction.py` exits 0, and `poetry run pytest tests/scripts/dev_tools --deselect tests/scripts/dev_tools/test_blast_radius_extraction_rules.py::test_classify_path_token_rejects_placeholder_marker` exits 0. The deselection is required and is not a weakening of the gate: P1-T1 deliberately added that parametrized test in a failing state and the guard that satisfies it is not added until P2-T4, so a broad run cannot exit 0 at this point in the sequence. Everything except the five known expect-fail parameters must pass, and the recorded deselected count must be exactly 5 â€” a different count means the expect-fail set moved and the gate fails.
```

### P3-T4 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P3-T4] Extend `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1` with the predicate half of each paired assertion so that, for each of the five markers, the file asserts both that the predicate reports the token as marker-bearing and that the classifier returns no classification for it; add the filename-position case, the marker-free-real-path case, the empty-string, marker-only, and bare-bracket-pair cases, the relocated span function's cases, and a module-export assertion for the re-exported span function. Every probe remains single-quoted or concatenated with a content assertion before classification. Acceptance: the file passes via `mcp__drm-copilot__run_poshqc_test`, contains no double-quoted probe string, is at or under 500 lines, and retains the single-quote constraint comment.
```

Under `5a8ede0f`:

```text
- [ ] [P3-T4] Extend `tests/scripts/claude-lib/blast-radius/BlastRadiusTokenShape.Tests.ps1` with the predicate half of each paired assertion so that, for each of the five markers, the file asserts both that the predicate reports the token as marker-bearing and that the classifier returns no classification for it; add the filename-position case, the marker-free-real-path case, the empty-string, marker-only, and bare-bracket-pair cases, the relocated span function's cases, and a module-export assertion for the re-exported span function. Every probe remains single-quoted or concatenated with a content assertion before classification. Acceptance: `mcp__drm-copilot__run_poshqc_test` scoped to the folder `tests/scripts/claude-lib/blast-radius` reports zero failures for this file in `artifacts/pester/pester-junit.xml`; the file contains no double-quoted probe string, is at or under 500 lines, and retains the single-quote constraint comment.
```

### P3-T5 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P3-T5] Write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/regression-testing/powershell-classifier-marker-pass-after.md` recording the run of the extended Pester file with the four required fields. Acceptance: exit code 0, and the artifact names the same test names that failed in P1-T4 as now passing.

```

Under `5a8ede0f`:

```text
- [ ] [P3-T5] Write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/regression-testing/powershell-classifier-marker-pass-after.md` recording the folder-scoped run of the extended Pester file with the four required fields, reading the per-test outcomes from `artifacts/pester/pester-junit.xml` rather than from the tool's return value. Acceptance: exit code 0, and the artifact names the same test names that failed in P1-T4 as now passing, quoting the JUnit file as the source.

```

### P4-T3 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P4-T3] Add the new bundled module path to `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, alongside the six existing blast-radius library entries. Acceptance: the manifest lists the new module exactly once, and no existing entry is reordered or duplicated.
```

Under `5a8ede0f`:

```text
- [ ] [P4-T3] Add the new bundled module path to `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, alongside the six existing blast-radius library entries. Acceptance: the manifest lists the new module exactly once, and no existing entry is reordered or duplicated. The exactly-once half is checkable against the post-edit file; the no-reordering half is a prior-state claim and is backstopped by P8-T13, whose staged and anchored diff records this file's hunks explicitly.
```

### P4-T4 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P4-T4] Add the new module path to the `CodeCoverage.Path` allow-list in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, and update the adjacent comment that currently states the blast-radius library is split across six files so it states the correct count and records the reason for this addition. Acceptance: the allow-list contains the new module path, and no existing allow-list entry is removed.
```

Under `5a8ede0f`:

```text
- [ ] [P4-T4] Add the new module path to the `CodeCoverage.Path` allow-list in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, and update the adjacent comment that currently states the blast-radius library is split across six files so it states the correct count and records the reason for this addition. Acceptance: the allow-list contains the new module path, and no existing allow-list entry is removed. As in P4-T3, the containment half is checkable against the post-edit file and the no-removal half is a prior-state claim backstopped by P8-T13's staged and anchored diff.
```

### P4-T6 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P4-T6] Run `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py`, the manifest Pester suite `tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1`, and the pack-manifest-completeness Jest suite, then write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/registration-surfaces.md` with the four required fields per command. Acceptance: all four suites report exit code 0, and the artifact names each suite and its result separately.

```

Under `5a8ede0f`:

```text
- [ ] [P4-T6] Run these three commands and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/registration-surfaces.md` with the four required fields per command: first `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_poshqc_bundled_parity.py`; second `mcp__drm-copilot__run_poshqc_test` scoped to the folder `tests/scripts/claude-lib/blast-radius`, reading the outcome of `tests/scripts/claude-lib/blast-radius/BlastRadius.Manifest.Tests.ps1` from `artifacts/pester/pester-junit.xml`; third, with `extensions/drm-copilot` as the working directory, an `npm test` invocation scoped to the pack-manifest-completeness suite, whose repo-relative path is extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts and whose argument is that path with the extension-directory prefix removed. The suite path is named in prose rather than inline code deliberately: the working-directory-relative spelling matches no repository path, so inline-coding it would inject a phantom entry into this item's own radius â€” the class of defect this item repairs. Acceptance: all three commands report exit code 0, the manifest Pester file reports zero failures in the JUnit output, and the artifact names each command and its result separately.

```

### P5-T7 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P5-T7] Verify the AC-9 reuse decision holds on disk by running `git diff --exit-code -- tests/fixtures/blast_radius/conflict-path-overlap.json` and recording the result in `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/negative-control-reuse.md` together with the reuse rationale from this plan. Acceptance: exit code 0, proving the reused negative control was not edited to accommodate the change.
```

Under `5a8ede0f`:

```text
- [ ] [P5-T7] Verify the AC-9 reuse decision holds on disk by running `git diff --exit-code main -- tests/fixtures/blast_radius/conflict-path-overlap.json` and record the result in `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/negative-control-reuse.md` together with the output of `git rev-parse main` and the reuse rationale from this plan. Naming the `main` ref explicitly is required, and the bare `git diff --exit-code` form must not be substituted: the bare form compares the worktree against the index only, so it passes vacuously the moment the executor commits, whereas comparing against `main` spans every committed and uncommitted change this branch has made. Recording the resolved SHA is what makes the anchor auditable: `main` is a moving local ref, so if it is fetched forward mid-execution without a rebase this gate can fail for a change this branch never made. That direction is fail-closed and therefore safe, but it is only diagnosable when the SHA is on record. Acceptance: exit code 0, and the artifact carries the resolved `main` SHA alongside the command, proving the reused negative control was not edited at any point during execution.
```

### P5-T12 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P5-T12] Run `git diff --name-only -- tests/fixtures/blast_radius` and record the result in `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/fixture-corpus-diff.md`. Acceptance: the output lists exactly the four fixtures added in P5-T1 through P5-T4 and no other fixture path, proving all 32 pre-existing fixtures are unmodified.

```

Under `5a8ede0f`:

```text
- [ ] [P5-T12] Run both `git status --porcelain -- tests/fixtures/blast_radius` and `git diff --name-status main -- tests/fixtures/blast_radius`, and record both outputs in `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/fixture-corpus-diff.md`. Neither command alone suffices, and the reason is the commit state: the porcelain form reports the four new fixtures while they are untracked but goes empty once they are committed, while the `main`-anchored diff reports them once they are committed but never reports an untracked file. Taking the union of the two makes the gate independent of whether the executor has committed. Do not substitute `git add --intent-to-add` for either command: it mutates the index, and the union form needs no such side effect. That prohibition is scoped to this task alone and does not conflict with the `git add -A` step the five Phase 8 audits require. The two situations differ: this gate asserts a file *set* and the union supplies it without touching the index, whereas those audits need diff *content* and line counts, which no union of status output can supply. This task also runs several phases earlier, before any staging step, and works in either state, so requiring staging later does not disturb it. Acceptance: the union of the two outputs names exactly four paths, each of them one of the four fixtures created in P5-T1 through P5-T4 and each carrying an added or untracked status, and the union carries zero entries with a modified status â€” proving all 32 pre-existing fixtures are unmodified in both commit states.

```

### P6-T1 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P6-T1] Amend the read-by-mandate paragraph in `.claude/rules/parallel-orchestration.md` â€” the paragraph currently beginning at line 236 that states the extractor rejects three token shapes â€” so that it states **four token shapes**, names the fourth as a token containing a placeholder or interpolation marker, states the marker set explicitly, and cross-references .claude/rules/plan-acceptance-gates.md as the set's origin. The amendment must additionally record: the never-matches-a-tracked-path rationale including the Windows-reserved-character argument for the angle brackets; the mandated-artifact origin of the dominant token, citing the non-overridable evidence-path scheme; the planner obligation to append a concrete path when an item will actually write a path it expressed as a shape; the fail-open shared-surface-glob trade with its measured-empty corpus exposure; and the whitespace-split residual as a known residual. Enforcement must remain prose plus validator logic. Acceptance: the file contains the literal `four token shapes` on a single line; no JSON Schema file is added and no schema reference is introduced; the foreign-schema prohibition already in the file is unchanged.
```

Under `5a8ede0f`:

```text
- [ ] [P6-T1] Amend the read-by-mandate paragraph in `.claude/rules/parallel-orchestration.md` â€” the paragraph currently beginning at line 236 that states the extractor rejects three token shapes â€” so that it states **four token shapes**, names the fourth as a token containing a placeholder or interpolation marker, states the marker set explicitly, and cross-references .claude/rules/plan-acceptance-gates.md as the set's origin. The amendment must additionally record: the never-matches-a-tracked-path rationale including the Windows-reserved-character argument for the angle brackets; the mandated-artifact origin of the dominant token, citing the non-overridable evidence-path scheme; the planner obligation to append a concrete path when an item will actually write a path it expressed as a shape; the fail-open shared-surface-glob trade with its measured-empty corpus exposure; and the whitespace-split residual as a known residual. Enforcement must remain prose plus validator logic. Take `git diff main -- .claude/rules/parallel-orchestration.md` and record it with the resolved `main` SHA; the two prior-state conditions below are asserted against that diff, not against the post-edit file, because a condition of the form "the existing paragraph is unchanged" cannot fail once the executor commits, and the mirror checks in P6-T2 and P6-T3 only prove the repo file and its bundled copy agree, which stays true if the amendment clobbers the paragraph in both. Acceptance, all four parts: the file contains the literal `four token shapes` on a single line; the diff's removed-line set contains no line belonging to the foreign-schema prohibition paragraph; the diff's added-line set introduces no reference to a schema file; and the resolved `main` SHA is recorded alongside the diff command. The broader claim that no schema file is added anywhere in the repository is deliberately not asserted here: this diff is scoped to one pathspec, and a newly created schema file would be untracked and invisible to it. That claim is carried instead by P8-T13, whose staged whole-tree anchored diff is already taken and can see a new file.
```

### P6-T4 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P6-T4] Run `git diff --exit-code -- .claude/rules/plan-acceptance-gates.md .github` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/policy-file-untouched.md` with the four required fields. Acceptance: exit code 0, proving the acceptance-gate rule file and every file under the Copilot instruction tree are unmodified.

```

Under `5a8ede0f`:

```text
- [ ] [P6-T4] Run `git diff --exit-code main -- .claude/rules/plan-acceptance-gates.md .github` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/policy-file-untouched.md` with the four required fields plus the output of `git rev-parse main`. The `main` ref must be named for the same reason as in P5-T7: the bare worktree-against-index form passes vacuously after a mid-execution commit, so it cannot fail. Record the resolved SHA for the same moving-ref reason given there. State also the gate's one scope limit: a diff does not see a brand-new untracked file, so this gate proves no tracked file in those two locations was changed and does not prove that no new file was added under the Copilot instruction tree. That gap is not reachable here â€” no task in this plan creates anything under that tree, and staging such a file would make it visible to the diff â€” but the limit is recorded so a later reader does not credit the gate with broader coverage than it has. Acceptance: exit code 0, and the artifact carries the resolved `main` SHA alongside the command, proving the acceptance-gate rule file and every tracked file under the Copilot instruction tree are unmodified across the whole execution.

```

### P7-T1 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P7-T1] Re-run the corpus measurement over the byte-identical item list stored by P0-T13, with the same constant derivation timestamp, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/conflict-graph-density.md` recording, before and after: item count with a non-zero assertion, edge count, density to one decimal place, cohort count, and maximum cohort width. Acceptance: the item set used for the after-measurement is identical to the before-measurement's stored list, and all five quantities are recorded for both states.
```

Under `5a8ede0f`:

```text
- [ ] [P7-T1] Re-run the corpus measurement over the byte-identical item list stored by P0-T14, with the same constant derivation timestamp, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/conflict-graph-density.md` recording, before and after: item count with a non-zero assertion, edge count, density to one decimal place, cohort count, and maximum cohort width. Acceptance: the item set used for the after-measurement is identical to the before-measurement's stored list, and all five quantities are recorded for both states.
```

### P7-T3 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P7-T3] Extend the same artifact with the named-survivor assertion over a fixed list carrying at least one path per acceptance rule â€” a recognized-extension file, a line-suffixed citation, a known-segment subtree glob, a configured root surface, and an own-feature-folder documentation glob. Acceptance: every listed path is present in the after-state radius entries, and the artifact records the per-path result.
```

Under `5a8ede0f`:

```text
- [ ] [P7-T3] Extend the same artifact with the named-survivor assertion. The list is fixed here rather than chosen at execution time, because a survivor list the executor selects can be selected to pass. The five probes, one per acceptance rule, are fixed as follows, each chosen against a measured carrier count over the 58 derived radii rather than by inspection of plan text. Recognized-extension rule: scripts/dev_tools/compute_blast_radius.py, 8 carriers. Known-segment subtree-glob rule: .claude/\*\* , 16 carriers. Configured-root-surface rule: package-lock.json, 7 carriers, which is a shared_surfaces entry and deliberately not a mandate_reads entry. Own-folder documentation-glob rule: the own-feature-folder glob of this item itself, docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/\*\* , which derivation adds automatically for every item, so it is guaranteed present for all 58. Line-suffixed-citation rule: at least one line-suffixed token must survive in at least one item's radius, expected instance config/blast-radius.json:12 â€” stated as an existence claim rather than a fixed token because every line-suffixed token in this corpus has exactly one carrier, which is inherent to line citations and would make a single named token break whenever its one carrier's plan is edited. All five are named in prose rather than inline code because this item writes none of them. Two probes were rejected on measurement and must not be reinstated: tests/scripts/dev_tools/\*\* has zero carriers because no plan in the corpus cites it, and quality-tiers.yml is structurally unreachable because it appears in both shared_surfaces and mandate_reads, so mandate-read exclusion strips it from every harvest and no derived radius can ever contain it. Acceptance: all five probes resolve as stated in the after-state radius entries, the artifact records the per-probe result with its observed carrier count, and any absence is a Blocking defect that halts the phase.
```

### P7-T4 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P7-T4] Extend the same artifact with the surviving-edge identity check: the known-genuine pair from the earlier false-conflict-edge capture must still conflict, with its reason kind and detail unchanged, on the shared MCP tools source file. Acceptance: the edge is present after the fix and its reason is recorded verbatim for comparison against the before-state.
```

Under `5a8ede0f`:

```text
- [ ] [P7-T4] Extend the same artifact with the surviving-edge identity check, on the specific pair fixed here rather than one selected at execution time: the items for issues 486 and 487 must still conflict after the fix, with the reason kind `path_overlap` and the detail naming the shared MCP tools source file at extensions/drm-copilot/src/mcp-tools.ts, which is the known-genuine edge captured by the earlier false-conflict-edge work. Acceptance: that edge is present in the after-state edge set, its reason kind and detail are recorded verbatim and match the before-state recording from P0-T14, and its absence is a Blocking defect that halts the phase.
```

### P7-T5 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P7-T5] Extend the same artifact with the prediction-against-actual report: the pre-registered pair count 53 from P0-T14, the executor's measured pair count, the actual edge-count delta, the itemized set of pairs that still conflict with each surviving reason, and the arithmetic showing the conservation identity holds. Acceptance: the actual delta is at or below 53; the identity balances exactly; every unit of shortfall below 53 is attributed to a named surviving pair; any excess in the measured pair count over 53 is itemized and shown to be induced by a shared placeholder token. A delta above 53 is a Blocking defect and must halt the phase.
```

Under `5a8ede0f`:

```text
- [ ] [P7-T5] Extend the same artifact with the prediction-against-actual report: the pre-registered pair count 53 from P0-T15, the executor's measured pair count, the actual edge-count delta, the itemized set of pairs that still conflict with each surviving reason, and the arithmetic showing the conservation identity holds. Acceptance: the actual delta is at or below 53; the identity balances exactly; every unit of shortfall below 53 is attributed to a named surviving pair; any excess in the measured pair count over 53 is itemized and shown to be induced by a shared placeholder token. A delta above 53 is a Blocking defect and must halt the phase.
```

### P7-T7 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P7-T7] Re-run the P0-T15 repro in both runtimes post-fix and record the result in the same artifact. Acceptance: the placeholder-only overlap now reports conflict false in both runtimes, and the negative control still reports conflict false.

```

Under `5a8ede0f`:

```text
- [ ] [P7-T7] Re-run the P0-T16 repro in both runtimes post-fix and record the result in the same artifact. Acceptance: the placeholder-only overlap now reports conflict false in both runtimes, and the negative control still reports conflict false.

```

### P8-T1 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P8-T1] Run `poetry run black .` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-python-format.md` with the four required fields. Acceptance: exit code 0 and zero files reformatted.
```

Under `5a8ede0f`:

```text
- [ ] [P8-T1] Run `poetry run black .` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-python-format.md` with the four required fields plus the run's final summary line verbatim. Acceptance: exit code 0; the final summary line ends with the literal `left unchanged.`; no output line begins with the literal `reformatted `; and that summary line is recorded verbatim. The absence of a `reformatted ` line is the observation, not a printed count: on a clean run no count and no per-file line is emitted, so an acceptance demanding a reformatted count could never be satisfied. This stage still needs no snapshot pair, unlike the Prettier and PoshQC stages, because when this formatter does rewrite a file it names that file on its own output line, so the observation is already run-scoped; Prettier and the PoshQC formatter report nothing at all, which is why those two need the pair.
```

### P8-T2 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P8-T2] Run `poetry run ruff check .` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-python-lint.md` with the four required fields. Acceptance: exit code 0 and zero findings.
```

Under `5a8ede0f`:

```text
- [ ] [P8-T2] Run `poetry run ruff check .` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-python-lint.md` with the four required fields plus the run's final output line verbatim. Acceptance: exit code 0; the output's final line is exactly `All checks passed!`; no output line begins with the literal `Fixed `; and that final line is recorded verbatim. The command deliberately keeps the repository's configured fixing form here, unlike P0-T3 and P2-T3, because this is the toolchain loop's lint stage and the loop is meant to apply fixes; what it must not do is apply one invisibly. The configuration sets `fix = true` and `show-fixes = true`, so ruff rewrites fixable violations, still exits 0, and prints `Fixed N error:` when it does. An exit-code-only gate therefore cannot observe an auto-fix, and the cross-language toolchain rule requires a restart from the first stage whenever any stage auto-fixes a file â€” an obligation that cannot be discharged by a signal nobody reads. The absence of the fix-indicator line is that signal, in the same shape as the P8-T1 formatter gate. A `Fixed ` line means the lint stage changed a file, so the Phase 8 restart clause applies.
```

### P8-T4 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P8-T4] Run `poetry run pytest --cov --cov-branch --cov-report=term-missing` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-python-test-coverage.md` with the four required fields plus numeric post-change line-coverage and branch-coverage percentages. Acceptance: exit code 0, line coverage at or above 85 percent, branch coverage at or above 75 percent.
```

Under `5a8ede0f`:

```text
- [ ] [P8-T4] Run `poetry run pytest --cov --cov-branch --cov-report=term-missing` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-python-test-coverage.md` with the four required fields plus numeric post-change line-coverage and branch-coverage percentages. As in P0-T5, the reporter prints one combined `Cover` column, so derive the line figure from the `Stmts` and `Miss` totals and the branch figure from the `Branch` and `BrPart` totals of the `TOTAL` row, and record which columns each figure came from. Acceptance: exit code 0, line coverage at or above 85 percent, branch coverage at or above 75 percent, both derived the same way as the P0-T5 baseline so the two are comparable.
```

### P8-T5 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P8-T5] Compute the Python coverage delta and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/python-coverage-delta.md` recording the P0-T5 baseline percentages, the P8-T4 post-change percentages, and the coverage of the changed and newly added lines in `scripts/dev_tools/_blast_radius_token_shapes.py` and `scripts/dev_tools/_blast_radius_extraction.py`. Acceptance: no regression against the baseline on either metric, and changed-line coverage is recorded as a number.
```

Under `5a8ede0f`:

```text
- [ ] [P8-T5] Compute the Python coverage delta and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/python-coverage-delta.md` recording the P0-T5 baseline percentages, the P8-T4 post-change percentages, and the coverage of the changed and newly added lines in `scripts/dev_tools/_blast_radius_token_shapes.py` and `scripts/dev_tools/_blast_radius_extraction.py`. Run `git add -A` at the repository root first, then identify the changed line set from `git diff main` for those two paths. Both steps are required and neither is optional: an unanchored diff misses committed changes, and an unstaged diff omits the newly created leaf module entirely, which would make its changed-line set empty and let a vacuous zero satisfy the coverage figure. Acceptance: no regression against the baseline on either metric; the `git diff --name-status main` file list contains all nine created paths; the added-line count for `scripts/dev_tools/_blast_radius_token_shapes.py` is strictly greater than zero; and changed-line coverage is recorded as a number for each of the two paths alongside the resolved `main` SHA the line set was computed against.
```

### P8-T6 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P8-T6] Run `mcp__drm-copilot__run_poshqc_format` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-powershell-format.md` with the four required fields. Acceptance: exit code 0 and zero files changed.
```

Under `5a8ede0f`:

```text
- [ ] [P8-T6] Capture `git status --porcelain -- '*.ps1' '*.psm1' '*.psd1'` as a before snapshot, run `mcp__drm-copilot__run_poshqc_format`, capture the same command again as an after snapshot, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-powershell-format.md` with the four required fields plus both snapshots verbatim. The pair replaces a bare "zero files changed" reading because this is a write-mode formatter: its exit status is 0 whether or not it rewrote a file, so the exit code alone cannot observe a reformat, and a single post-hoc snapshot cannot attribute a modification to this run. Acceptance: the tool reports ok, and the before and after snapshots are byte-identical. Snapshots that differ mean the formatting stage changed a PowerShell file, so the Phase 8 restart clause applies.
```

### P8-T7 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P8-T7] Run `mcp__drm-copilot__run_poshqc_analyze` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-powershell-analyze.md` with the four required fields. Acceptance: exit code 0 and zero diagnostics.
```

Under `5a8ede0f`:

```text
- [ ] [P8-T7] Run `mcp__drm-copilot__run_poshqc_analyze` and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-powershell-analyze.md` with the four required fields plus the tool's summary verbatim. Acceptance: the tool reports ok, and the summary is recorded verbatim. The measured return shape carries only an ok flag, a tool name, a workspace root, and a one-sentence summary â€” no diagnostic count and no severity breakdown at any scope â€” and the analyzer writes no report file, so unlike the Pester surface there is nowhere to read a count from. The ok flag is therefore the only available signal and is the gate; an acceptance demanding a zero-diagnostic count would name a value the tool never emits. The ok status is the gate rather than a snapshot pair because the analyzer is read-only and so reports its own outcome faithfully.
```

### P8-T8 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P8-T8] Run `mcp__drm-copilot__run_poshqc_test` with coverage and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-powershell-test-coverage.md` with the four required fields plus the numeric post-change line-coverage percentage. Acceptance: exit code 0, line coverage at or above 85 percent, and the artifact confirms `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` appears in the measured file set.
```

Under `5a8ede0f`:

```text
- [ ] [P8-T8] Run `mcp__drm-copilot__run_poshqc_test` with coverage over the full configured scan scope and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-powershell-test-coverage.md` with the four required fields plus the numeric post-change line-coverage percentage. The tool returns only an ok flag and a short summary, so read the test count and failure count from `artifacts/pester/pester-junit.xml` and the coverage percentage and per-file measured set from `artifacts/pester/powershell-coverage.xml`. Acceptance: exit code 0, zero failures in the JUnit output, line coverage at or above 85 percent, and the coverage XML lists `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` in the measured file set.
```

### P8-T9 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P8-T9] Compute the PowerShell coverage delta and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/powershell-coverage-delta.md` recording the P0-T8 baseline percentage, the P8-T8 post-change percentage, and the coverage of the changed and newly added lines in `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` and `.claude/lib/blast-radius/BlastRadiusExtraction.psm1`. Acceptance: no regression against the baseline, and changed-line coverage is recorded as a number.
```

Under `5a8ede0f`:

```text
- [ ] [P8-T9] Compute the PowerShell coverage delta and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/powershell-coverage-delta.md` recording the P0-T8 baseline percentage, the P8-T8 post-change percentage, and the coverage of the changed and newly added lines in `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` and `.claude/lib/blast-radius/BlastRadiusExtraction.psm1`. Run `git add -A` at the repository root first, then identify the changed line set from `git diff main` for those two paths, for both reasons given in P8-T5. Acceptance: no regression against the baseline; the `git diff --name-status main` file list contains all nine created paths; the added-line count for `.claude/lib/blast-radius/BlastRadiusTokenShape.psm1` is strictly greater than zero; and changed-line coverage is recorded as a number for each of the two paths alongside the resolved `main` SHA the line set was computed against.
```

### P8-T10 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P8-T10] Run the TypeScript format, lint, type-check, and Jest suites and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-typescript-suites.md` with the four required fields. Acceptance: exit code 0, and the artifact states that the pass and fail counts are unchanged from the P0-T9 baseline, confirming the change is a no-op for that runtime.
```

Under `5a8ede0f`:

```text
- [ ] [P8-T10] Capture `git status --porcelain -- extensions/drm-copilot` as a before snapshot; then, with `extensions/drm-copilot` as the working directory, run `npm run format`, then `npm run lint`, then `npm run typecheck`, then `npm test`; then capture `git status --porcelain -- extensions/drm-copilot` again as an after snapshot; and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/final-typescript-suites.md` with the four required fields per command plus both snapshots verbatim. The before-and-after pair is what makes the formatting stage falsifiable and must not be collapsed to a single snapshot: the `format` script is a write-mode Prettier invocation and Prettier exits 0 even when it rewrites a file, and a single post-hoc status compares worktree to index and so cannot attribute a modification to the command that just ran. Two snapshots around the command make the observation run-scoped â€” a rewrite from this run appears only in the after snapshot, while drift already present appears in both and cancels. This package defines no check-only script, which is why the observation is made through git rather than through a second npm script. The pathspec is the whole extension directory rather than a narrower list because the `format` script also globs the extension root, where the lock file, both TypeScript configs, and four build scripts match; the lock file is a declared shared surface, so an unnoticed rewrite there would silently modify one. The wider scope is safe because the dependency tree is ignored by git and the pathspec is otherwise untouched by this item. Acceptance: all four npm commands exit 0; the before and after snapshots are byte-identical; and the artifact states that the pass and fail counts are unchanged from the P0-T10 baseline, confirming the change is a no-op for that runtime. Snapshots that differ mean the formatting stage changed a file, so the Phase 8 restart clause applies.
```

### P8-T12 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P8-T12] Audit the coverage configuration of both runtimes for exclusion entries and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/coverage-exclusion-audit.md`. Acceptance: the artifact shows no coverage exclusion entry matching a production source path was added anywhere in the diff, and both new production modules appear in their runtime's coverage denominator.
```

Under `5a8ede0f`:

```text
- [ ] [P8-T12] Run `git add -A` at the repository root, then audit the coverage configuration of both runtimes for exclusion entries over the diff produced by `git diff main`, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/coverage-exclusion-audit.md`, recording both commands and the resolved `main` SHA. Staging is required even though exclusion entries live in tracked configuration files, because an unstaged diff is an incomplete diff and this audit's negative claim is only as broad as the diff it reads. Acceptance: the `git diff --name-status main` file list contains all nine created paths; the artifact shows no coverage exclusion entry matching a production source path was added anywhere in that diff; and both new production modules appear in their runtime's coverage denominator.
```

### P8-T13 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P8-T13] Audit the full diff for contract changes and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/contract-scope-audit.md`. Acceptance: the artifact shows the diff adds or changes no function signature, no return type, no artifact type, no CLI flag, no MCP input-schema property, no finding-rule literal, and no config/blast-radius.json key.
```

Under `5a8ede0f`:

```text
- [ ] [P8-T13] Run `git add -A` at the repository root, then audit the diff produced by `git diff main` for contract changes, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/contract-scope-audit.md`, recording both commands and the resolved `main` SHA. Staging is load-bearing here above all: the two new leaf modules are what add function signatures, and an unstaged diff would not contain them, so the no-new-signature claim would be made against a diff that structurally cannot show a violation. Acceptance: the `git diff --name-status main` file list contains all nine created paths; and the artifact shows the diff adds or changes no function signature on any pre-existing public surface, no return type, no artifact type, no CLI flag, no MCP input-schema property, no finding-rule literal, and no key in the blast-radius configuration file. The two new leaf modules' own exported predicates are the intended additions and are enumerated as such rather than counted as violations. This diff is also the backstop for P4-T3's no-reordering condition and P4-T4's no-removal condition, so the artifact records the manifest and allow-list hunks explicitly. It additionally carries P6-T1's whole-repository claim that no JSON Schema file is added anywhere: that condition cannot be observed from P6-T1's single-pathspec diff, and a new schema file would be untracked, so it is asserted here where the diff is staged and whole-tree. The artifact records that no added path in the file list is a schema file.
```

### P8-T14 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P8-T14] Audit the diff for any diagnostic channel and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/silent-drop-audit.md`. Acceptance: the artifact shows no new finding rule, no new warning or advisory emission, and that the expected-findings blocks of all 32 pre-existing fixtures are unchanged.
```

Under `5a8ede0f`:

```text
- [ ] [P8-T14] Run `git add -A` at the repository root, then audit the diff produced by `git diff main` for any diagnostic channel, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/silent-drop-audit.md`, recording both commands and the resolved `main` SHA. Staging is required because a finding rule added inside a newly created file is invisible to an unstaged diff, which is exactly the case this audit must be able to catch. Acceptance: the `git diff --name-status main` file list contains all nine created paths; and the artifact shows no new finding rule, no new warning or advisory emission, and that the expected-findings blocks of all 32 pre-existing fixtures are unchanged.
```

### P8-T15 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P8-T15] Declare this item's blast radius: enumerate `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` in `shared_surfaces`, append the concrete paths `.claude/rules/parallel-orchestration.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` to the declared `paths` after normalization because this item genuinely writes them and the rule tree is otherwise excluded as a mandate-read, then run blast-radius validation over the declared radius against this plan and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/declared-radius-validation.md` with the four required fields. Acceptance: validation reports no Blocking finding, and the artifact records the accepted `path_overlap` edge with issue #500 on the rule-file pair per the AC-41 decision above.
```

Under `5a8ede0f`:

```text
- [ ] [P8-T15] Declare this item's blast radius: enumerate `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` in `shared_surfaces`, append the concrete paths `.claude/rules/parallel-orchestration.md` and `extensions/drm-copilot/resources/claude-customizations/.claude/rules/parallel-orchestration.md` to the declared `paths` after normalization because this item genuinely writes them and the rule tree is otherwise excluded as a mandate-read, then run blast-radius validation over the declared radius against this plan and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/declared-radius-validation.md` with the four required fields. Acceptance: validation reports no Blocking finding; the artifact records the accepted `path_overlap` edge with issue #500 on the rule-file pair per the AC-41 decision above; and the artifact records the two spec-sourced over-declarations named in the token-hygiene limit above â€” the blast-radius configuration file and the bundled pack manifest, both inline-coded in the spec and therefore harvested into the derived radius, with the configuration file additionally resolving as a touched shared surface. Each is recorded with the reason it is present and the statement that it is an accepted read-reference over-inclusion rather than a placeholder defect, so a reviewer comparing the declared radius against the file-change map does not read the difference as an error.
```

### P8-T16 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P8-T16] Map all 46 acceptance criteria from `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/spec.md` to the task and evidence artifact that satisfies each, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/acceptance-criteria-status.md`. Acceptance: every criterion from AC-1 through AC-41 plus the traceability table rows is present with a named artifact path and a pass, fail, or blocked verdict; no criterion is recorded as unverified.
```

Under `5a8ede0f`:

```text
- [ ] [P8-T16] Map every item in the two enumerated sets from `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/spec.md` to the task and evidence artifact that satisfies it, and write `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/qa-gates/acceptance-criteria-status.md`. The two sets are the **41** numbered criteria AC-1 through AC-41 in the `## Acceptance Criteria` section, and the **11** rows of the `### Traceability to issue.md` table, for **52** mapped items in total. Do not count the four impact/severity radios or the logs-attached checkbox: they sit outside the `## Acceptance Criteria` section and are not criteria. Acceptance: the artifact contains exactly 41 numbered criterion rows and exactly 11 traceability rows, each with a named artifact path and a pass, fail, or blocked verdict; no item is recorded as unverified, and the two counts are stated explicitly so a miscount fails the gate.
```

### P8-T17 — new-rule finding count at `5a8ede0f`: 0

Under `e2aa6446`:

```text
- [ ] [P8-T17] Update `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/issue.md` and `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/spec.md` with the outcome, the three planner decisions, and any deviation from scope, and mirror the issue update to `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/issue-updates/issue-502.md` with `Timestamp:`, the exact posted text, and `PostedAs:`. Acceptance: both documents reflect the landed state and the mirror artifact exists with all three required fields.

---

```

Under `5a8ede0f`:

```text
- [ ] [P8-T17] Update `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/issue.md` and `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/spec.md` with the outcome, the three planner decisions, and any deviation from scope, and mirror the issue update to `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/evidence/issue-updates/issue-502.md` with `Timestamp:`, the exact posted text, and `PostedAs:`. Acceptance: the mirror artifact exists and carries `Timestamp:`, the exact posted text, and `PostedAs:`; and both documents each record, by name, the three planner decisions AC-9, AC-19, and AC-41, plus the actual edge-count delta measured in P7-T5 and the final line and branch coverage figures from P8-T4. Those five named items replace a general "reflects the landed state" reading, which no observation could falsify.

---

```


## Output Summary

Both driver invocations exited 0. The derived list of task identifiers whose acceptance text differs between the `e2aa6446` and `5a8ede0f` extractions contains **46** identifiers, derived only from the two extractions [P5-T1] recorded, using the shipped task-line and heading patterns for the window parse. **45 of the 46 record a new-rule finding count of 0. One, `P0-T10`, records 1** â€” a G7 finding on `npm run format`. Two causes are recorded: the identifier names two different tasks at the two commits because the plan was renumbered, and the final revision's task observes the tree through a `git status --porcelain` snapshot pair rather than through the formatter's stdout, which is a legitimate observation G7's marker set does not cover. It is classified as a G7 false positive in substance and carried into the Phase 6 corpus measurement. **[P5-T5] is FAIL and its plan checkbox is left unchecked.**
