# Feature Audit — Remediation Cycle 1 Re-Evaluation (AC 3)

- **Issue:** #301
- **Timestamp:** 2026-07-04T12-00
- **Scope:** Re-evaluation of AC 3 ("Pester coverage for `enforce-completion-consistency.ps1` passes for the targeted hook test file") following remediation cycle 1's Fix 1 (`CodeCoverage.Path` gap) and Fix 2 (coverage-enabled Pester rerun).
- **Supporting evidence:** `docs/features/active/2026-07-03-pester-completion-consistency-301/evidence/qa-gates/coverage-comparison.2026-07-04T12-00.md`, `docs/features/active/2026-07-03-pester-completion-consistency-301/evidence/qa-gates/final-powershell-pester.2026-07-04T12-00.md`

## AC 3 Verdict: PARTIAL (not PASS)

The prior feature-audit (`feature-audit.2026-07-04T11-15.md`) established the verification bar for closing AC 3: "confirm >=85% line / >=75% branch coverage for the [four] new/modified files" (the four in-scope hook files named in `remediation-inputs.2026-07-04T11-15.md`: `.claude/hooks/enforce-completion-consistency.ps1`, `.claude/hooks/enforce-completion-helpers.ps1`, `.codex/hooks/enforce-completion-consistency.ps1`, `.codex/hooks/enforce-completion-helpers.ps1`).

Fix 1 (this cycle) closed the `CodeCoverage.Path` configuration gap: all four files now appear as `<sourcefile>` entries in `artifacts/pester/powershell-coverage.xml` (previously absent entirely). This is real, verified progress.

Fix 2's coverage rerun produced the following grep-verified, real per-file `<counter type="LINE">` figures (see `coverage-comparison.2026-07-04T12-00.md` for the full grep evidence):

| File | Line % | Meets 85% floor? |
|---|---|---|
| `.claude/hooks/enforce-completion-consistency.ps1` | 91.87% (113/123) | Yes |
| `.claude/hooks/enforce-completion-helpers.ps1` | 93.02% (40/43) | Yes |
| `.codex/hooks/enforce-completion-consistency.ps1` | 0.00% (0/123) | **No** |
| `.codex/hooks/enforce-completion-helpers.ps1` | 0.00% (0/43) | **No** |

`BRANCH` coverage cannot be evaluated for any file: `artifacts/pester/powershell-coverage.xml` contains no `<counter type="BRANCH">` anywhere in the report (verified repo-wide). This is a pre-existing Pester coverage-export tooling limitation, not a defect introduced by this remediation cycle.

**Why PARTIAL, not PASS:** Two of the four in-scope files (`.codex/hooks/enforce-completion-consistency.ps1`, `.codex/hooks/enforce-completion-helpers.ps1`) show 0.00% real, grep-verifiable line coverage. Root cause: the existing `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1` dot-sources the bundled-extension mirror path (`extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-completion-consistency.ps1`) rather than the canonical repo-root `.codex/hooks/enforce-completion-consistency.ps1` path that was added to `CodeCoverage.Path` in this cycle. No test file anywhere in the repository exercises the canonical `.codex/hooks/` path directly (confirmed via `grep -rn "\.codex/hooks/enforce-completion" tests/`). Reporting a PASS verdict for AC 3 while two of the four files show 0% real coverage would not be supported by the evidence and would conflict with the repository's evidence-first policy and the remediation plan's explicit prohibition on citing coverage figures "that cannot be located via direct text search" as passing when the actual figure is 0%.

**What this remediation cycle did close:**
- The `CodeCoverage.Path` configuration gap (Fix 1) — all four files are now measured at all, closing the pre-fix total-absence gap.
- Real, verified >=85% line coverage for the two `.claude/hooks/` canonical files.

**What remains open (follow-up remediation cycle, out of this cycle's declared scope):**
- The `.codex/hooks/enforce-completion-consistency.ps1` and `.codex/hooks/enforce-completion-helpers.ps1` canonical files require either: (a) retargeting `tests/scripts/claude-hooks/enforce-completion-consistency-codex.Tests.ps1` to dot-source the canonical repo-root path instead of (or in addition to) the bundled-extension mirror, or (b) an explicit, documented parity/coverage-equivalence exception if the mirror-only test strategy is intentionally retained. Either resolution requires editing the Codex test file, which is outside this remediation cycle's declared scope (limited to `pester.runsettings.psd1`, the four hook files, and `tsconfig.json`).
- Pester's coverage export does not emit `BRANCH` counters at all in this repository's tooling configuration; branch-coverage verification for these files is not currently possible with the existing Pester CoverageGutters/JaCoCo export and is a separate, pre-existing tooling gap.

## Recommendation

Do not check AC 3 to `[x]` in `issue.md` on the strength of this remediation cycle alone (it is already marked `[x]` from a prior state pre-dating this audit; that prior check-off should be revisited in a follow-up cycle once the Codex test-file gap is resolved, rather than being reaffirmed here). This audit's own PARTIAL verdict is recorded to accurately reflect the current, verifiable coverage state and to route the remaining two-file gap into a future remediation cycle rather than closing it prematurely.
