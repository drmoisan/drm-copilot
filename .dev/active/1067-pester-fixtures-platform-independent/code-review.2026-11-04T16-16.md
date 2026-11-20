# Code Review: Platform-independent Pester fixtures (#1067)

**Review Date:** 2026-11-04
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-03-pester-fixtures-platform-independent-1067`
**Feature Folder Selection Rule:** Caller-supplied folder; its suffix matches issue 1067 and it holds the primary changed scoping documents.
**Base Branch:** `main` (merge base 11f188d1b4f3726d854ddc00f8ad4c810138f049)
**Head Branch:** `bug/pester-fixtures-platform-independent` at 7c31fb1d21431dd8d0961f32c30baae50bc70d74
**Review Type:** Re-review after remediation cycle 1

---

## Executive Summary

The branch makes 17 Pester suites under `tests/scripts/dev-tools` and `tests/scripts/powershell/PoshQC` host-independent and fixes four production defects (D1 to D4). Remediation cycle 1 (commit 7c31fb1d2) closed four non-blocking findings of the previous review with test-only edits in five suites. The reviewer read the full branch diff and the cycle diff, reran PSScriptAnalyzer and the formatter over all 24 changed PowerShell files (0 findings, 0 differences), reran both in-scope test trees at HEAD (953 tests, 0 failed, worktree clean afterwards), and parsed the current coverage artifact (repo-wide 93.84% line; changed files 95.02%).

**What changed in cycle 1:**
- R1-F1: `link-feature-docs.Tests.ps1` and `link-parent-child.Tests.ps1` save `POSHQC_SKIP_SCRIPT_EXECUTION` before setting it and, in a new `AfterAll`, remove it when it was absent or restore the prior value.
- R1-F5: `link-feature-docs.Tests.ps1` saves any prior `gh` function and, in `AfterAll`, restores it with `Set-Item -Path Function:\global:gh` or removes the stub with `Remove-Item -Path Function:\gh`.
- R1-F2, R1-F4: `Enter-DrmCopilotShell.Tests.ps1`, `Test-DiscoveryHostCapability.Entry.Tests.ps1`, and `Test-DiscoveryHostCapability.Tests.ps1` pass each fixture path through `CodeGeneration.EscapeSingleQuotedStringContent` before interpolating it into `[scriptblock]::Create` source.

**Verification of each cycle finding:**
- R1-F1 closed: fail-before `PROBE POSHQC_SKIP_SCRIPT_EXECUTION=1` (evidence/remediation-baseline/suite-link-feature-docs, suite-link-parent-child, two-trees.2026-11-04T15-45) and pass-after `=absent` (evidence/regression-testing/r1f1-r1f5-link-feature-docs, r1f1-link-parent-child, two-trees.2026-11-04T16-03); a pre-existing value survives (r1f1-prior-value: `PRIOR-VALUE-AFTER=prior`).
- R1-F5 closed: `PROBE GH-FUNCTION` moves from `present` to `absent`; a prior definition survives (r1f5-prior-gh: `PRIOR-GH-AFTER=issue-1067-prior-gh`); evidence/other/gh-dependency-search.2026-11-04T15-46.md records `GH-DEPENDENTS=0`, so no later suite relied on the leaked stub.
- R1-F2 and R1-F4 closed: evidence/other/escape-probe.2026-11-04T15-50.md shows `ESCAPE-ROUNDTRIP=True` and `UNESCAPED-PARSE=error` for `quote'root`; suite counts unchanged (r1f2-enter-drmcopilotshell, r1f2-discovery-entry, r1f4-discovery). The reviewer confirmed in the diff that the unescaped variable is still passed to the code under test and only the script-block source uses the escaped form.

**Top 3 risks:**
1. Windows behavior is verified only by the S9 CI gate on `windows-latest` (AC2).
2. Without a Linux CI leg for these two trees (open owner decision in spec.md), a new Windows-only fixture can reappear unnoticed.
3. R1-F3 (trampoline comment in `PoshQC.Testing.psm1`) is still open; the remediation inputs defer it to the final code-touching commit.

**PR readiness recommendation:** **Go** — no Blocker, Major, or Minor finding; all local gates pass at HEAD.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `scripts/powershell/PoshQC/PoshQC.Testing.psm1` and bundle mirror | default `-InvokePester` trampoline comment (not in branch diff) | R1-F3 remains open: the comment states the Pester run is hosted in the global session state, while the executor observed test code running in the PoshQC module session state. | Apply the comment-only correction in the final code-touching commit as `remediation-inputs.2026-11-04T15-31.md` states, keep the mirror byte-identical, and let CI on that head verify it. | Accuracy of an explanatory comment; no runtime effect. | remediation-inputs.2026-11-04T15-31.md, "Findings deferred within this item". |
| Info | `scripts/dev-tools/HostBootstrapWorkspace.psm1`, `scripts/dev-tools/DrmCopilotPromptSupport.ps1` | D2/D3 `Combine($PWD.ProviderPath, ...)` | Relative input entered from a non-FileSystem location resolves against provider text. | No change; recorded as a design assumption in spec.md. | Edge case only; unchanged from the previous review. | spec.md `## Assumptions, Constraints, Dependencies`. |
| Info | `tests/scripts/codex-hooks/codex-bundle-hook-probe.Tests.ps1` | concurrent-shard run (not in branch diff) | The first cycle concurrent run failed once with a child-process `System.IO.FileLoadException` (exit 134) for a truncated assembly name; the suite passed 3 of 3 alone and the rerun was clean. | Track as a host or runtime observation outside this item if it recurs. | Unrelated to the five cycle files (different shard, separate process). | evidence/other/execution-deviations.2026-11-04T16-02.md, item 2. |
| Nit | `tests/scripts/dev-tools/link-feature-docs.Tests.ps1` | `AfterAll` gh restore | The removal branch uses the unqualified `Function:\gh` while the restore branch uses `Function:\global:gh`; the asymmetry is intentional (the executor's probe showed `Remove-Item` ignores the `global:` qualifier) and is commented. | None required. | The comment states the reason; both branches are verified by probe evidence. | evidence/other/execution-deviations.2026-11-04T16-02.md, item 1; r1f5-prior-gh. |

No Blocker, Major, or Minor findings. No changed covered file reaches the 700-line advisory tier (largest: `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1`, 529 logical lines); `config/file-size-baseline.json` is unchanged on the branch.

---

## Implementation Audit

### PowerShell implementation audit

#### What changed well

- Production files are unchanged since the previous review (`git diff --name-only 089e55e5c HEAD -- scripts extensions` is empty); the D1 to D4 assessment stands.
- Cycle edits copy existing reference patterns in the repository rather than introducing a new helper.
- Each save and restore covers both the absent and the present case, and each case has evidence.

#### API and safety notes

- No parameter, output type, or exported function changed.
- PSScriptAnalyzer with the repository settings: 0 findings over all 24 changed files.

#### Error handling and logging

- `-ErrorAction SilentlyContinue` is limited to removal of state that may already be absent; no error path in production changed.

---

## Test Quality Audit

The reviewer reran Pester over both in-scope trees at HEAD with coverage off: Tests=953 Passed=944 Failed=0 Skipped=9, and `git status --porcelain --untracked-files=all` was empty afterwards.

### Reviewed test and QA artifacts

- `tests/scripts/dev-tools/link-feature-docs.Tests.ps1`, `link-parent-child.Tests.ps1` — saves are the first statements of `BeforeAll`; one `AfterAll` per file; no `Context` or `It` changed.
- `tests/scripts/dev-tools/Enter-DrmCopilotShell.Tests.ps1`, `Test-DiscoveryHostCapability.Entry.Tests.ps1`, `Test-DiscoveryHostCapability.Tests.ps1` — escape applied to the value, not the template; assertions unchanged.
- `evidence/regression-testing/isolation-shuffle.2026-11-04T16-03.md`, `two-trees.2026-11-04T16-03.md`, `isolation-parallel.2026-11-04T16-10.md` — seeded, two-tree, and concurrent-shard runs with 0 failures and both leak probes absent.
- `evidence/qa-gates/self-review.2026-11-04T16-11.md` — template walk with no FAIL row.

### Quality assessment prompts

- **Determinism:** No temporary files, TestDrive, wall-clock, or random input.
- **Isolation:** The two remaining process-wide leaks identified by the previous review are removed.
- **Speed:** No added file-system access.
- **Diagnostics:** Exact expectations unchanged.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | PASS | Diff inspection; no personal path in touched fixtures. |
| No unsafe subprocess or command construction | PASS | Script-block source in tests is now built from escaped literals. |
| Input validation at boundaries | PASS | D4 validation is host-independent. |
| Error handling remains explicit | PASS | Existing throws unchanged. |
| Configuration / path handling is safe | PASS | See the Info finding on non-FileSystem locations. |

---

## Research Log

No external research was required. The executor's probe output for `Remove-Item` on scope-qualified `Function:` paths (execution-deviations item 1) was accepted as the evidence for the removal form.

---

## Verdict

The change is ready for normal PR flow. No Blocker, Major, or Minor finding exists; all four cycle-1 findings are closed with fail-before and pass-after evidence. The S9 CI green gate must confirm `poshqc / PowerShell QC` and its `windows-latest` shards on the final PR head (AC2), and R1-F3 is to be applied in the final code-touching commit as the remediation inputs state.
