# Pre-mortem Before the Final Push (issue #935)

Timestamp: 2026-10-16T20-48
Head: `048d76cd8` (origin/main merged at `fa27cd5ed`)
Purpose: list what could fail the next review or CI, and the check or mitigation for each, before the single final push.

| # | Risk | Likelihood | Check / mitigation | Status |
|---|---|---|---|---|
| 1 | The tightened isolation predicate (F-2, R2) flags a hook suite merged from main since the last full run (main added, among others, `tests/scripts/codex-hooks/enforce-epic-merge-gate-docs-only.Tests.ps1` and `hook-docs-only-diff.Tests.ps1`). | Medium | Discovery suite ran in the seeded shuffled run on the merged tree: 365 testcases, 0 failures (`evidence/qa-gates/shuffled-suite-run.2026-10-16T20-48.md`). CI Linux and Windows jobs re-check. | Mitigated locally |
| 2 | Order dependence between the split suites and their originals. | Low | Seeded shuffled run (seed 935) of all 13 touched and consumer suites: 742/742 passed. | Mitigated |
| 3 | Split-count equations (AC-14..AC-17) drift after the main merge. | Low | Local counts 52/26/121/32/54 match baseline + 1 and baseline; CI Windows counts confirmed at S9 (P7-T5). | Mitigated locally |
| 4 | AC-24 coverage below the 85% floor on the final head. | Low | Prior PR runs 89.66-90.27%; the decision accepts the baseline gap only. P7-T6 records root, baseline, main at the same population and the per-file diff; below 85% would reopen the item. | Checked at S9 |
| 5 | Review re-raises COV-1 as blocking. | Low | Option 1 decision recorded (`evidence/other/cov1-decision-option1.2026-10-16T20-38.md`), AC-24 amendment in `spec.md`, PR body updated (DOC-1). | Mitigated |
| 6 | Scope check (AC-21/AC-22) fails because the main merge introduced paths into the three-dot diff. | Low | `git diff --name-only origin/main...HEAD` lists the 18 Write-Set paths plus feature-folder docs only; nothing under `.claude/`, `.codex/`, `.github/`, `extensions/`, `scripts/`, `config/`. | Verified |
| 7 | File-size limit (AC-20) exceeded after cycle 3 edits. | Low | Cycle 3 P4 line counts all at or below 500 (largest 454). No code file changed since. | Verified |
| 8 | Format or analyzer drift in edited files. | Low | Cycle 3 final QA: formatter changed nothing, analyzer returned without error; no code change since. | Verified |
| 9 | Python suites (`quality-checks7`) fail on unrelated main changes. | Low | Not in this item's write set; CI on the merged head decides; a failure unrelated to the diff would be reported, not fixed here. | Watch at S9 |
| 10 | The PR-author hook or completion hooks reject the final checkpoint (step8 status, ci_gate head mismatch). | Medium | step8 kept `in_progress` until S9 per coordinator rule; ci_gate recorded for the exact final head after the post-check-off push and S9 re-run. | Process |
| 11 | Stale review artifacts: the latest review (16-02) predates the merge and decision. | Medium | A full-diff feature review runs on the merged head before the push; its findings are fixed before pushing. | Pending (review delegated) |
