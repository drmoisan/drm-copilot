# Feature Audit: core-pack-manifest-missing-epic-orchestrate-files (Issue #279)

**Audit Date:** 2026-07-03
**Feature Folder:** `docs/features/active/2026-07-03-core-pack-manifest-missing-epic-orchestrate-files-279/`
**Base Branch:** `main`
**Head Branch:** `drm-copilot-wt-2026-07-02-19-03` @ `bab8d604595899ed2a44b1dbc3b2d677e3e1d555`
**Work Mode:** `minor-audit`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (commit `476b110cc53c7f26a573c9cf23b4f3dba1b095a9`, per resolved `origin/main` at PR-context refresh time)
- **Head branch/commit:** `drm-copilot-wt-2026-07-02-19-03` (commit `bab8d604595899ed2a44b1dbc3b2d677e3e1d555`)
- **Merge base:** `072bb7611a177eaec25b042274bacb75899cdf8b` (independently confirmed via `git merge-base main HEAD`, matching the supplied merge-base SHA and `artifacts/pr_context.summary.txt`/`artifacts/pr_context.appendix.txt`)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (fresh, generated 2026-07-03 05:08:44 UTC in this session)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` (same generation timestamp)
  - Feature evidence: `docs/features/active/2026-07-03-core-pack-manifest-missing-epic-orchestrate-files-279/evidence/**` (baseline, qa-gates, regression-testing, other)
  - Additional evidence: independent re-execution of `npm run format`, `npm run lint`, `npm run typecheck`, `npm test -- --coverage`, and `npm test -- --testPathPatterns claude-pack-manifest-completeness --verbose` from `extensions/drm-copilot/` during this review
- **Feature folder used:** `docs/features/active/2026-07-03-core-pack-manifest-missing-epic-orchestrate-files-279/` (matches the issue-number suffix `279` in the branch's changed scoping docs; only one active feature folder exists for this issue)
- **Requirements source:** `issue.md` only — this is a `minor-audit` work-mode folder; `spec.md` and `user-story.md` intentionally do not exist and are not required, per `plan.2026-07-03T00-44.md`'s explicit requirements-source note.
- **Work mode resolution note:** `issue.md` carries an explicit `- Work Mode: minor-audit` marker (line 12). Per `acceptance-criteria-tracking` and `feature-review-workflow`, this restricts the AC source to the explicit `## Acceptance Criteria` section of `issue.md` only, which is present (lines 63-69).
- **Scope note:** The full branch diff (`072bb7611a177eaec25b042274bacb75899cdf8b..bab8d604595899ed2a44b1dbc3b2d677e3e1d555`) consists of one production JSON edit, one new TypeScript test file, and fourteen feature-folder documentation/evidence files. No plan-subset or file-subset narrowing was attempted or accepted; see `policy-audit.2026-07-03T01-15.md` `## Rejected Scope Narrowing` (none detected).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-07-03-core-pack-manifest-missing-epic-orchestrate-files-279/issue.md` — only source (`minor-audit` work mode)

### Acceptance criteria

1. AC1: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` lists all six paths added by the epic-orchestrate feature (issue #275): `.claude/agents/epic-orchestrator.md`, `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-wave-barrier.ps1`, `.claude/hooks/enforce-epic-worktree-removal-gate.ps1`, `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1`, inserted in the file's existing alphabetical/grouped ordering (agents together, hooks together, skills together).
2. AC2: `packages/mcp-server/resources/claude-customizations/pack-manifests/core.json` is not hand-edited; it remains gitignored and is regenerated from the extension's `resources/` tree by `packages/mcp-server/prepack.cjs` (`cpSync`).
3. AC3: A new or extended automated test reads the real bundled `.claude/agents/*.md`, `.claude/skills/*/SKILL.md`, and `.claude/hooks/*.ps1` files on disk and the real `pack-manifests/*.json` files (not a hardcoded expected-file list) and asserts that every such bundled file appears in the union of `paths` across all pack manifests.
4. AC4: The test in AC3 would fail against the pre-fix `core.json` (the six paths listed in AC1 are absent from every manifest before the fix), and its assertions cover those six specific paths, either directly or as a natural consequence of the completeness check.
5. AC5: The full TypeScript toolchain (format -> lint -> type-check -> test with coverage) passes cleanly on `extensions/drm-copilot` after the change, with no coverage regression on changed lines.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC1 — six paths added to `core.json` in correct grouped/ordered positions | PASS | `git diff 072bb7611a177eaec25b042274bacb75899cdf8b..bab8d604595899ed2a44b1dbc3b2d677e3e1d555 -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` shows exactly six additive lines, no removals or reorderings. Independently confirmed by reading the full post-change file: `.claude/agents/epic-orchestrator.md` immediately before `.claude/agents/epic-review.md`; the three `enforce-epic-*.ps1` hooks immediately before `.claude/hooks/enforce-evidence-locations.ps1`; `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` immediately before `.claude/hooks/enforce-pr-author-skill.ps1`; `.claude/skills/epic-orchestrate/SKILL.md` immediately before `.claude/skills/evidence-and-timestamp-conventions/SKILL.md` — matching the plan's specified insertion points exactly. | `git diff 072bb761..bab8d604 -- extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`; `node -e "require('./core.json')"` (valid JSON, 65 total paths) | None. |
| 2 | AC2 — `packages/mcp-server` manifest not hand-edited | PASS | `git diff --name-status 072bb7611a177eaec25b042274bacb75899cdf8b..bab8d604595899ed2a44b1dbc3b2d677e3e1d555` lists zero files under `packages/mcp-server/`. `evidence/other/implementation-ac-map.md` independently records the same re-confirmation during execution. | `git diff --name-status 072bb761..bab8d604` (filtered for `packages/mcp-server`) — no matches | None. |
| 3 | AC3 — real-filesystem completeness test, no hardcoded expected-file list | PASS | `extensions/drm-copilot/test/lib/push-down/claude-pack-manifest-completeness.test.ts` enumerates `.claude/agents/*.md`, `.claude/skills/*/SKILL.md`, `.claude/hooks/*.ps1` via `node:fs`/`node:path` resolved from `__dirname` (lines 62-91), and parses every real `pack-manifests/*.json` file to union their `paths` arrays (lines 98-120). No hardcoded expected-file list is used for the completeness assertion; the only hardcoded set is the documented, narrowly-scoped `PRE_EXISTING_UNRELATED_EXCEPTIONS` (three paths, explicitly out of scope for issue #279, not a substitute for real enumeration). | Source inspection of `claude-pack-manifest-completeness.test.ts`; `npm test -- --testPathPatterns claude-pack-manifest-completeness --verbose` (7/7 passing, independently re-run) | None. |
| 4 | AC4 — test fails pre-fix, covers all six paths | PASS | `evidence/regression-testing/fail-before.2026-07-03T14-30.md` records a temporary `git stash` revert of `core.json` to its pre-fix state, followed by `npm test -- --testPathPatterns claude-pack-manifest-completeness`, producing EXIT_CODE 1 with all 7 tests failing and all six issue-#279 paths individually named as missing in the failure output. The artifact also documents restoration of the fix and a subsequent clean pass (7/7). Additionally, the artifact transparently records that the pre-existing working-tree edit was initially incomplete (5 of 6 insertions) and was corrected before finalizing the proof — this transparency strengthens confidence in the evidence rather than weakening it. | Evidence artifact inspection; the six explicit `it.each` assertions in the test file (lines 140-156) directly name each of the six AC1 paths | None. |
| 5 | AC5 — full TypeScript toolchain passes cleanly, no coverage regression | PASS | Independently re-run during this review: `npm run format` (all files unchanged), `npm run lint` (exit 0, zero findings), `npm run typecheck` (exit 0, zero errors), `npm test -- --coverage` (122/122 suites, 1469/1469 tests, 96.88% lines / 88.27% branch — identical to the recorded baseline in `evidence/baseline/baseline-test-coverage.md`, a 0.00% delta on every metric). No production TypeScript source file was changed in this diff (only a JSON manifest and a new, coverage-excluded test file), so there are no changed production lines to regress; the unchanged overall percentages corroborate this directly. | `npm run format`; `npm run lint`; `npm run typecheck`; `npm test -- --coverage` (all run from `extensions/drm-copilot/`, all independently reproduced in this review) | None. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 5 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Optional hardening (non-blocking, see `code-review.2026-07-03T01-15.md` Findings Table): guard `JSON.parse` in `unionOfManifestPaths()` with a filename-scoped error message, and add explicit tests for malformed-JSON and empty-directory edge cases.
2. Optional follow-up issue (non-blocking): register the three pre-existing, unrelated manifest gaps (`pr-author.md`, `enforce-completion-helpers.ps1`, `validate-pr-author-output.ps1`) documented as permanent exceptions in the new test, so the exception list can eventually shrink to empty.

---

## Acceptance Criteria Check-off

All five criteria evaluated PASS above. Per `acceptance-criteria-tracking`, PASS criteria may be checked off in the authoritative source file if not already checked off.

**Verification of current state:** `issue.md` (lines 65-69) already shows all five AC items as `- [x]` (checked) prior to this review. This review independently re-verified each item's supporting evidence (see table above) and confirms every check-off is backed by passing, reproducible evidence. No new check-off action was required or taken by this review, since the executor had already checked off all five items with corresponding evidence at the time of implementation, and this review's independent re-verification confirms those check-offs remain accurate.

### AC Status Summary

- Source: `docs/features/active/2026-07-03-core-pack-manifest-missing-epic-orchestrate-files-279/issue.md`
- Total AC items: 5
- Checked off (delivered): 5
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `issue.md` | 5 | 5 | 0 | Checkbox-backed; all five items independently re-verified against evidence during this review with no discrepancies found. |
