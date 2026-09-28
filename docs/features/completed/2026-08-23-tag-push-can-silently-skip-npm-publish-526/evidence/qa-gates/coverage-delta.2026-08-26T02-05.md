# Final QA — Coverage Delta and Threshold Verification — P7-T6

Timestamp: 2026-08-26T02-05

Note on filename stamp: the plan fixes every evidence filename at `.2026-08-24T13-10.md`. This
execution ran on 2026-08-26, so the executor substituted its own `yyyy-MM-ddTHH-mm` stamp
(`2026-08-26T02-05`) in that same position. The path prefix and base name are unchanged.

Command:

```
pwsh -NoProfile -Command "Import-Module ./scripts/powershell/PoshQC/PoshQC.psd1 -Force; Invoke-PoshQCTest -Root (Get-Location).Path"
git diff -U0 main -- scripts/dev-tools/Invoke-ReleaseTagPush.ps1
```

The first command produced `artifacts/pester/powershell-coverage.xml`, from which every post-change
figure below was parsed. The second produced the added-line set of group (iii). Both ran to
completion.

EXIT_CODE: 0

## Measurement route

Per the plan's binding "Per-file coverage measurement route" rule, the post-change document was
produced by the **direct self-hosted invocation**, not by `mcp__drm-copilot__run_poshqc_test`. The
MCP tool resolves its Pester runsettings from the installed VS Code extension and therefore emits no
coverage row for the two files P2-T8 and P5-T2 register. The direct run was executed after the MCP
run so that the document parsed here is the one carrying those rows.

All per-file rows were parsed by keying on the enclosing `package` element (the full directory path)
and then selecting the `sourcefile` by name within it, never on the bare `sourcefile` name.

---

## Group (i) — Baseline figures

Source: `docs/features/active/2026-08-23-tag-push-can-silently-skip-npm-publish-526/evidence/baseline/powershell-pester-baseline.2026-08-25T23-33.md`
(the P0-T5 baseline, produced by the MCP runner at commit `afbf51dfe6508319a2d673603d31825077d8cddb`).

| Metric | Value |
|---|---|
| Baseline overall line coverage | **96.1433 percent** (6656 covered of 6923 total) |
| Baseline sourcefile rows | 82 |
| Baseline per-file line coverage, `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` | **95.8333 percent** (46 covered of 48 total) |

The 96.14 percent baseline overall figure is recorded here as a **recording obligation**. It is
deliberately **not** used as an assertion target for the restricted post-change figure. The reason is
stated in the plan task text and restated below under "Why the restricted comparison is not asserted
against the baseline".

---

## Group (ii) — Post-change figures

### Post-change overall

| Metric | Value |
|---|---|
| Covered lines | 6792 |
| Total measured lines | 7071 |
| **Post-change overall line coverage** | **96.0543 percent** |
| Sourcefile rows | 84 |

Threshold check: 96.0543 >= 85. **PASS.**

### Post-change per-file

| File | Covered | Total | Percent | >= 85 |
|---|---|---|---|---|
| `scripts/dev-tools/Invoke-ReleaseTagPush.ps1` | 75 | 77 | **97.4026** | PASS |
| `scripts/dev-tools/Invoke-ReleaseVerification.ps1` | 83 | 92 | **90.2174** | PASS |
| `scripts/dev-tools/Invoke-ReleaseReconciliation.ps1` | 24 | 27 | **88.8889** | PASS |

### Post-change overall restricted to the baseline sourcefile set

The restriction excludes exactly the two files this change adds to the coverage denominator:
`scripts/dev-tools/Invoke-ReleaseVerification.ps1` and
`scripts/dev-tools/Invoke-ReleaseReconciliation.ps1`. The remaining row count is 82, which equals
the baseline sourcefile row count.

| Metric | Value |
|---|---|
| Covered lines (restricted) | 6685 |
| Total measured lines (restricted) | 6952 |
| **Restricted post-change line coverage** | **96.1594 percent** |
| Restricted sourcefile rows | 82 |

Threshold check: 96.1594 >= 85. **PASS.**

Recorded alongside, per the task's recording obligation: the group (i) baseline overall figure is
**96.1433 percent**.

### Why the restricted comparison is not asserted against the baseline

The two overall figures have different denominators by construction. The baseline was produced by
the MCP runner against an allow-list that does not contain the files P2-T8 and P5-T2 register; the
post-change document was produced by the direct invocation against an allow-list that does. A bare
comparison of the unrestricted figures would report a regression that did not occur.

The restricted set is not itself fixed either. Phase 3 added lines to
`scripts/dev-tools/Invoke-ReleaseTagPush.ps1`, which sits **inside** the restricted set. Asserting
the restricted figure against 96.1433 percent would therefore reduce to an unstated requirement that
the Phase 3 added lines be covered at 96.1433 percent, which no acceptance criterion states. The
restricted figure is accordingly asserted against the absolute 85 percent floor, and the
no-regression obligation is carried by the group (iii) changed-lines threshold, which is what
`.claude/rules/general-unit-test.md` actually asserts.

For information only, not as an assertion: the restricted post-change figure of 96.1594 percent is
in fact 0.0161 percentage points **above** the 96.1433 percent baseline, so no regression occurred on
the baseline set even though no such comparison is required.

---

## Group (iii) — New-code line coverage

### Whole-file coverage for the two files this change adds

| File | Covered | Total | Percent | >= 85 |
|---|---|---|---|---|
| `scripts/dev-tools/Invoke-ReleaseVerification.ps1` | 83 | 92 | **90.2174** | PASS |
| `scripts/dev-tools/Invoke-ReleaseReconciliation.ps1` | 24 | 27 | **88.8889** | PASS |

### Changed-line coverage for `scripts/dev-tools/Invoke-ReleaseTagPush.ps1`

The added-line set was computed from the **base-ref-scoped** diff form mandated by the task:

```
git diff -U0 main -- scripts/dev-tools/Invoke-ReleaseTagPush.ps1
```

The base-ref-scoped form is mandatory. The working-tree-versus-index form returns an empty added-line
set once the change is staged or committed, and an 85 percent threshold asserted over an empty
denominator is satisfied whatever the executor did. The recorded added-line count below is strictly
greater than zero, which is what makes this gate falsifiable.

Four hunks were reported: `+43,7`, `+194,14`, `+209,23`, and `+243,25`.

| Metric | Value |
|---|---|
| **Added lines reported by the diff** | **69** |
| Of those, lines carrying a coverage entry (measured) | 31 |
| Of those measured lines, covered | 31 |
| Uncovered measured added lines | none |
| **Covered fraction of the added lines** | **100.0000 percent** |

Threshold check: 100.0000 >= 85. **PASS.**

The 38 added lines that carry no coverage entry are non-executable text — comment-based help,
parameter-block declarations, blank lines, and closing braces. Pester emits no `line` element for
them, so they are absent from the denominator on both sides of the ratio and cannot inflate or
deflate it.

---

## Acceptance conjuncts — all six satisfied

| # | Conjunct | Observed | Verdict |
|---|---|---|---|
| 1 | All three groups reported as numeric values | groups (i), (ii), (iii) above | PASS |
| 2 | Added-line count for `Invoke-ReleaseTagPush.ps1` strictly greater than zero | 69 | PASS |
| 3 | Per-file line coverage of `Invoke-ReleaseVerification.ps1` and `Invoke-ReleaseTagPush.ps1` each at least 85 percent | 90.2174 and 97.4026 | PASS |
| 4 | Post-change overall percentage at least 85 percent | 96.0543 | PASS |
| 5 | Restricted post-change percentage at least 85 percent, recorded alongside the 96.14 percent baseline figure | 96.1594, recorded alongside 96.1433 | PASS |
| 6 | Covered fraction of the added lines at least 85 percent | 100.0000 | PASS |

Pester does not measure branch coverage, so no branch threshold is asserted. This is the threshold
exemption `.claude/rules/quality-tiers.md` grants to PowerShell; it is not a coverage exclusion, and
neither new file was excluded from measurement (confirmed separately by P7-T7).

Output Summary: All three coverage groups are recorded as numeric values. Group (i): baseline overall
96.1433 percent (6656/6923), baseline `Invoke-ReleaseTagPush.ps1` 95.8333 percent (46/48). Group
(ii): post-change overall 96.0543 percent (6792/7071) across 84 sourcefiles; per-file 97.4026 percent
for `Invoke-ReleaseTagPush.ps1`, 90.2174 percent for `Invoke-ReleaseVerification.ps1`, 88.8889
percent for `Invoke-ReleaseReconciliation.ps1`; restricted post-change 96.1594 percent (6685/6952)
across the 82-row baseline set, recorded alongside the 96.1433 percent baseline figure. Group (iii):
whole-file coverage 90.2174 percent and 88.8889 percent for the two added files, and for
`Invoke-ReleaseTagPush.ps1` an added-line count of 69 of which 31 are measured and 31 covered, giving
100.0000 percent changed-line coverage. All six acceptance conjuncts pass. AC24 is satisfied on its
coverage-threshold clause.
