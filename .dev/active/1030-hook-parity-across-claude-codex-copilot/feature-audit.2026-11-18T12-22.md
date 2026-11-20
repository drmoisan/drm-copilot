# Feature Audit: Hook parity across Claude Code, Codex and Copilot (#1030)

**Audit Date:** 2026-11-18
**Feature Folder:** `docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030`
**Base Branch:** `epic/shared-agent-harness-layer-integration`
**Head Branch:** `feature/hook-parity-across-claude-codex-copilot-1030`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/epic/shared-agent-harness-layer-integration` (commit `2d487f5b070b401a6d14271a039b1207a6e0383f`)
- **Head branch/commit:** `feature/hook-parity-across-claude-codex-copilot-1030` (commit `f9f358e9055db7b2b4ca7ce8d7d33ca1ebf67691`)
- **Merge base:** `2d487f5b070b401a6d14271a039b1207a6e0383f` (the integration branch tip equals the merge base)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-11-18 12:17:51 UTC at head `f9f358e90`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/evidence/**`
  - Additional evidence: `artifacts/pester/powershell-coverage.xml` re-parsed per file by this review; `config/harness-parity-matrix.json` summarized with `ConvertFrom-Json` (96 hook entries, all `native`, all `provisional`, one `decision_ref`, no missing `parity_group`, no duplicate `id`); `cmp` of the three root/bundle pairs (identical); `git diff --name-status 2d487f5b0..HEAD`
- **Feature folder used:** `docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030`
- **Requirements source:** `spec.md` and `user-story.md`
- **Work mode resolution note:** `issue.md` carries `- Work Mode: full-feature`, so `spec.md` and `user-story.md` are the AC sources.
- **Scope note:** Comparisons use the merge base of the integration branch and `HEAD`, as spec `## Execution-Time Gating` requires. The CI-dependent criteria are listed as pending-CI; the orchestrator verifies them at S9.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/spec.md` — primary source (16 checkbox items under `## Acceptance Criteria`)
- `docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/user-story.md` — secondary source (10 checkbox items under `## Acceptance Criteria`)

### Acceptance criteria

The criteria are the checkbox items of the two files, quoted in the source files and summarized by label in the evaluation table below (S-n for `spec.md` in file order, U-n for `user-story.md` in file order).

---

## Acceptance Criteria Evaluation

### From spec.md

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| S-1 | Phase 0 evidence for checks (a) to (d) with the four fields; mismatch led to a plan revision | PASS | `evidence/baseline/phase0-gate.2026-11-18T07-25.md` (stop on check (c)) and `phase0-gate.2026-11-18T07-55.md` (pass after AD-8 and plan v2.1) | `Read` of both records | Stop-then-replan recorded append-only. |
| S-2 | Every inventoried registration has one `native` entry with `parity_group` and `decision_ref`; `HarnessParityMatrix.RepoGate.Tests.ps1` passes | PASS | 96 hook entries, all `native`, `decision_ref` `#1030:hook-parity-dispositions.md`; Pester 0 failures | matrix summary script (this review); `pester-gate.2026-11-18T12-14.md` | |
| S-3 | Each Claude group has a Codex member or gap class; each unmatched Codex group has `CODEX-NATIVE`; gate passes with in-memory negatives | PASS | `HarnessHookParity.RepoGate.Tests.ps1` cases `reports no H1 to H5 violation`, `fails for a Claude group ...`, `fails for an unmatched Codex group ...` | code inspection; Pester 0 failures | |
| S-4 | Codex `validate-pr-author-output.ps1` root file, identical bundle copy, core manifest entry, behavior suite with the Claude decision cases, malformed payload fails closed with exit 2 | PASS | root and bundle identical; `core.json` entry; `codex-validate-pr-author-output.Tests.ps1` (`exits 2 with stderr and empty stdout for malformed stdin`) | `cmp` (identical); `git diff -- .../core.json` | |
| S-5 | One `[[hooks.SubagentStop]]` table (root and bundle) admitting `pr-author`; one continuation proven | PASS | `config.toml` diff adds one table; suite cases `exits 2 ... when stop_hook_active is false`, `exits 0 ... when stop_hook_active is true`, `uses a matcher that admits pr-author and does not admit feature-review` | `git diff -- .codex/config.toml` | |
| S-6 | Feature-folder-order port deferred (AD-8): no Codex file, registry or config entry, timeout unchanged and equal to the registry sum, `GAP:DEFER: ` note naming the module and child 4 | PASS | `scope.2026-11-18T11-18.md` AD-8 rows; gate case `records the feature-folder-order port as deferred`; `sets the Codex dispatcher timeout to the registry timeout sum` passed | `git diff --name-only <MB>..HEAD` (no such path) | |
| S-7 | Envelope twin function text identity; identical-helper set pinned | PASS | `cross-tree-helper-identity.Tests.ps1`; Pester 0 failures | code inspection | |
| S-8 | C1 `NOT-EXPRESSIBLE` naming `#555`; C2 `DEFER` naming `agent_type` | PASS | gate cases `records C1 ...`, `records C2 ...` | code inspection | |
| S-9 | Listed hooks carry `DEFER` naming the dependency | PASS | gate cases per deferred stem and `names the claude lib module and child 4 in each non-C2 DEFER reason` | code inspection | |
| S-10 | Copilot entries `native`, `owner_child` 6 | PASS | 4 Copilot entries; gate case `records every Copilot entry as native with owner_child 6` | matrix summary script | |
| S-11 | No-Python scan covers four roots and passes | PASS | `ScanRoots.Helpers.ps1` adds `.github/hooks`; case `AC-15 scans exactly the four hook roots` | branch diff | |
| S-12 | Bundled mirrors and pack manifests green, including `codex-pretooluse-integration.Tests.ps1` | UNVERIFIED | All listed suites except `codex-pretooluse-integration.Tests.ps1` passed locally (Pester and pytest 0 failures); that suite is CI-only under the launcher policy (`deviation-integration-lane.2026-11-18T09-10.md`) | n/a | Pending-CI; checked off at S9. Not a review finding. |
| S-13 | No edit to capped Codex hooks, agent frontmatter `hooks:`, settings `hooks` or Claude dispatch registry; generator `--check` passes | PASS | `scope.2026-11-18T11-18.md`; `final-static.2026-11-18T12-01.md` (both generator checks exit 0) | `git diff --name-only <MB>..HEAD -- .claude` (empty) | |
| S-14 | No new Python or TypeScript file; new hook and test files PowerShell; commands invoke `pwsh` | PASS | added files are `.ps1`/`.psm1`; both new commands start with `pwsh` | `git diff --name-status <MB>..HEAD` | |
| S-15 | Each new or changed Codex hook file at least 85% line coverage, recorded under `qa-gates/` | PASS | `validate-pr-author-output.ps1` 41/41, `subagentstop-envelope.ps1` 58/60 (96.67%); `pester-coverage.2026-11-18T11-16.md` | re-parse of `artifacts/pester/powershell-coverage.xml` | |
| S-16 | `poshqc / PowerShell hook suites (Linux)` passes on the PR head | UNVERIFIED | No PR and no CI run exist at review time | n/a | Pending-CI; checked off at S9. Not a review finding. |

### From user-story.md

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| U-1 | Every registration, including both dispatch registries, has one entry; matrix gate passes | PASS | as S-2 | as above | |
| U-2 | Every Claude group has a Codex member or gap class; hook-parity gate passes with negatives | PASS | as S-3 | as above | |
| U-3 | Codex pr-author behavior suite with the Claude decision cases; allows when `stop_hook_active` is set | PASS | as S-4, S-5 | as above | |
| U-4 | Feature-folder-order port deferred with the `GAP:DEFER: ` note | PASS | as S-6 | as above | |
| U-5 | DEFER and NOT-EXPRESSIBLE records with reasons | PASS | as S-8, S-9 | as above | |
| U-6 | Copilot `native`, `owner_child` 6 | PASS | as S-10 | as above | |
| U-7 | No-Python scan includes `.github/hooks` and passes | PASS | as S-11 | as above | |
| U-8 | Bundled mirrors, pack manifests and contract tests listed in the spec pass | UNVERIFIED | as S-12 | n/a | Pending-CI (CI-only integration suite). |
| U-9 | No edit to Codex hook files at 490 or more lines at Phase 0 | PASS | as S-13 | as above | |
| U-10 | Linux hook-suite CI job passes on the PR head | UNVERIFIED | as S-16 | n/a | Pending-CI. |

### Reviewer judgment: AD-8 deferral

The Codex `enforce-feature-folder-order` port, originally `ADD`, was moved to `DEFER` by decision AD-8 after Phase 0 check (c) found the Claude source imports child 2's `DevelopmentDocsRoot.psm1`, which `.codex/lib` does not publish. The decision follows the OQ-3 rule already applied to five other validators, is recorded in `spec.md`, `user-story.md`, the plan and the disposition record, and is enforced by rules H1 and H5. This review accepts it: a private Codex copy would be a second implementation that drifts, and a `.claude/lib` load breaks the Codex no-`.claude`-path rule.

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 22 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 4 criteria (all CI-dependent, pending S9)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None. The four UNVERIFIED items are CI-dependent and are verified by the orchestrator at S9.

**Recommended follow-up verification steps:**

1. At S9, confirm `poshqc / PowerShell hook suites (Linux)`, `poshqc / PowerShell QC` (which runs `codex-pretooluse-integration.Tests.ps1`) and `CI Required Gate` are green on the PR head, then check off S-12, S-16, U-8 and U-10 and plan task `[P3-T5]`.
2. The spec `## Definition of Done` checkboxes (not AC) are all unchecked; the orchestrator may update them at S9.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.
- If the source uses prose or numbered requirements instead of checkbox items, do not rewrite the source file; record status only in this audit.

### AC Status Summary

- Source: `docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/spec.md`, `docs/features/active/2026-10-30-hook-parity-across-claude-codex-copilot-1030/user-story.md`
- Total AC items: 26
- Checked off (delivered): 22
- Remaining (unchecked): 4
- Items remaining: spec.md "Bundled mirrors and pack manifests are green: ... `codex-pretooluse-integration.Tests.ps1` ... pass."; spec.md "The `poshqc / PowerShell hook suites (Linux)` CI job passes on the PR head, including the new suites under `tests/scripts/codex-hooks/`."; user-story.md "Bundled mirrors, pack manifests and their contract tests listed in the spec pass."; user-story.md "The `poshqc / PowerShell hook suites (Linux)` CI job passes on the PR head."

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 16 | 14 | 2 | Checkbox-backed; both open items are CI-dependent. Definition of Done (not AC): 0 of 7 checked. |
| `user-story.md` | 10 | 8 | 2 | Checkbox-backed; both open items are CI-dependent. |

No source-file checkbox change was made by this review: every PASS item was already checked by the executor, and the four UNVERIFIED items must stay unchecked until S9.
