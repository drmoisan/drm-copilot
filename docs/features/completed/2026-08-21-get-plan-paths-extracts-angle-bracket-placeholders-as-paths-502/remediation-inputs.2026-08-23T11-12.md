# Remediation Inputs — Issue #502 — 2026-08-23T11-12

**Feature Folder:** `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502`
**Base Branch:** `main` @ `d782ee1c8b05192ed1bda40936ba5e37d9a5512e`
**Head Branch:** `bug/get-plan-paths-angle-bracket-placeholders-502` @ `e3cc1f76ae6a79e3c986be668f83c1cd4c4b0e66`
**Work Mode:** `full-bug` — acceptance-criteria source is `spec.md`
**Authored by:** `feature-review`

---

## Read This First — `blocking_count` is 0

**This artifact does not open a remediation cycle.** It exists because the `feature-review-workflow` contract lists a PARTIAL acceptance criterion as a remediation trigger, and one criterion (AC-8) is graded PARTIAL. It is authored so the trigger is answered on the record rather than silently absorbed.

Applying the exit-gate rule from `remediation-handoff-atomic-planner` — `blocking_count` is the count of FAIL findings plus material PARTIAL findings flagged as blocking — the computation is:

| Component | Count |
|---|---|
| FAIL findings across all three audit artifacts | **0** |
| Blocker-severity code-review findings | **0** |
| Major-severity code-review findings against the branch | **0** |
| Material PARTIAL findings flagged as blocking | **0** |
| Toolchain stage failures | **0** |
| Coverage threshold violations | **0** |
| Coverage artifacts absent for a language with changed files | **0** |
| **`blocking_count`** | **0** |

**Recommendation to the orchestrator: set `exit_condition_met = true` and close the loop without opening a cycle.** Do not delegate a remediation plan to `atomic-planner` on the basis of this artifact. No `remediation-plan.md` is authored, because remediation is not required.

The single PARTIAL is a sentence of specification text that no longer describes the delivered design. It is not a coverage gap, not a behavioral gap, not a test gap, and not a policy violation. Every item below is a documentation or process follow-up whose correct home is a separate, low-priority documentation change — not a remediation cycle against this branch.

---

## Pointer to the Audit Artifacts That Produced These Findings

- `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/policy-audit.2026-08-23T11-12.md` — sections 8 (Gaps and Exceptions) and 10 (Compliance Verdict); Appendix B carries every command and its output
- `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/code-review.2026-08-23T11-12.md` — Findings Table
- `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/feature-audit.2026-08-23T11-12.md` — Acceptance Criteria Evaluation and the three dedicated disposition findings

---

## Enumerated Follow-Up List

Each item below states the file, the expected end state, and a verification command. None is blocking. Items R1 and R2 are the only ones that touch this feature folder; R3 through R6 are separate concerns recorded here so they are not lost.

### R1 — Reconcile AC-8's fixture clause with the delivered design (documentation only)

- **File:** `docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/spec.md`, `## Acceptance Criteria`, subsection B, AC-8
- **Current text:** "`tests/fixtures/blast_radius/conflict-placeholder-only-overlap.json` exists; two radii whose only shared entry is a placeholder token with disjoint real files report conflict false in both parity suites."
- **Problem:** The first clause asserts a file that does not exist and cannot usefully exist. A conflict fixture supplies literal recorded radii straight to the conflict relation; `classify_path_token` has exactly two callers (`scripts/dev_tools/compute_blast_radius.py:344` inside `normalize_declared_radius`, and `scripts/dev_tools/_blast_radius_extraction.py:372` inside `extract_plan_paths`), and the conflict-fixture harness at `tests/scripts/dev_tools/test_blast_radius_parity.py:417-465` invokes neither. Such a fixture's verdict is invariant under this fix: with the placeholder present it reports `conflict=true` before and after; with it absent it reports `false` before and after and duplicates `tests/fixtures/blast_radius/conflict-none-disjoint.json`. It can be satisfiable or discriminating, never both.
- **Expected end state:** The fixture clause is struck. The criterion states only the property that was delivered — that two radii whose only shared entry is a placeholder token with disjoint real files report no conflict after normalization, asserted by a named test in each runtime — and it is checked off. A one-line note records that the fixture clause was withdrawn as unsatisfiable, citing `evidence/other/p5-t3-blocker-conflict-fixture-seam.md`.
- **Do NOT:** create the fixture. It would be a test that cannot fail, which is the exact class of defect issue #486 and `.claude/rules/plan-acceptance-gates.md` exist to reject.
- **Do NOT:** weaken or delete the two delivered tests. They are the criterion's substance and they are stronger than the fixture would have been, because their post-normalization assertion routes through the classifier and therefore fails on a tree where the guard is absent.
- **Verification:**
  ```bash
  grep -n 'AC-8' docs/features/active/2026-08-21-get-plan-paths-extracts-angle-bracket-placeholders-as-paths-502/spec.md
  # AC-8 is checked and its text no longer names conflict-placeholder-only-overlap.json

  poetry run pytest tests/scripts/dev_tools/test_blast_radius_normalization.py \
    -k placeholder_only_overlap -q --no-cov
  # the named test still passes
  ```

### R2 — Reconcile AC-22's arithmetic and refresh the stale test count (documentation only)

- **Files:** the same `spec.md` — `## Acceptance Criteria` AC-22, and `## Outcome — issue #502 resolved`
- **Problem (AC-22):** The criterion requires the floors to be "raised from 26 to 26 plus the number of newly added fixtures," which with three new fixtures reads 29. Both executed floors read 30.
- **Problem (Outcome):** The section reports "Python: 4095 tests passing." The post-rebase count is 4112.
- **Expected end state:** AC-22's text matches the executed value of 30, with a clause recording that 30 was retained as the more conservative floor after the planned fixture count fell from four to three. The Outcome test count reads 4112, or is annotated as a pre-rebase figure.
- **Do NOT:** lower `MINIMUM_FIXTURE_COUNT` or `$minimumFixtureCount` to 29. That would weaken a live anti-vacuity gate to satisfy an arithmetic identity in prose. Both floors are equal at 30, both were raised from 26, and 30 is non-vacuous against 35 fixtures on disk — every substantive property the criterion exists to secure already holds.
- **Verification:**
  ```bash
  grep -n 'MINIMUM_FIXTURE_COUNT' tests/scripts/dev_tools/test_blast_radius_parity.py         # 30
  grep -n 'minimumFixtureCount' tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1  # 30
  ls tests/fixtures/blast_radius/*.json | wc -l                                              # 35
  poetry run pytest -q --no-cov 2>&1 | tail -1                                                # 4112 passed
  ```

### R3 — File the PR-context reference-pattern defect as its own issue (separate issue, not this branch)

- **File:** `scripts/dev_tools/pr_context/render_pr_helpers.py`, line 104, and its TypeScript counterpart `extensions/drm-copilot/src/lib/pr-context/render-pr-helpers.ts`
- **Problem:** The pattern `(?<!\w)#\d+|\b[A-Z][A-Z0-9]+-\d+\b` has a second alternative intended for JIRA-style project keys. It matches this specification's `AC-<n>` labels and the token `ISO-8601`, so the generated close-candidate list in `artifacts/pr_context.summary.txt` contains 52 entries of which 45 are not issue references (`#AC-1` through `#AC-41`, `#ISO-8601`, plus `#580` from the upstream `drmoisan/TaskMaster` repository, plus five unrelated real issues #452, #485, #487, #489, #500).
- **Impact:** If a pull-request body is generated from that list, the pull request would claim to close 45 non-existent issues and five unrelated real ones.
- **Expected end state:** A new issue records the defect. The candidate fix is to require a configured repo-local project key rather than accepting any all-caps hyphenated token, or to drop the second alternative entirely. The Python and TypeScript implementations must stay in parity.
- **Do NOT** fix this on the #502 branch. It is unrelated code, it has its own tests, and both runtimes must move together.
- **Immediate mitigation, required before the pull request is opened:** set the auto-close list to `#502` only.
- **Verification:**
  ```bash
  grep -n 'A-Z' scripts/dev_tools/pr_context/render_pr_helpers.py | head -3
  grep -c '^- #AC-' artifacts/pr_context.summary.txt   # currently 41
  ```

### R4 — Disclose issue #501's lifecycle record in the pull-request body (PR authoring)

- **File:** `docs/features/potential/promoted/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow.md` (added, +105)
- **Problem:** A branch scoped to issue #502 also lands issue #501's promoted lifecycle record.
- **Assessment:** Keep the file. It is genuinely absent from `main` while `docs/features/active/2026-08-21-pretooluse-hooks-parse-flat-payload-and-always-allow-501` already exists there, so it closes a real lifecycle-record gap consistent with the known promotion defect (#487). Commit `7116e545` explains the origin: both records were authored upstream in `drmoisan/TaskMaster` carrying that repository's issue numbers (#579, #580) and were renumbered to their local issues in the same commit.
- **Expected end state:** The pull-request body states that the diff also lands #501's lifecycle record and why, so a reviewer does not have to read a commit message to find out.
- **Verification:** the PR body names the file and the reason.

### R5 — Confirm AC-36's observability caveat closes at the next MCP publish (deferred verification)

- **Files:** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its bundled mirror (both already correct; no edit required)
- **Problem:** The MCP server runs as `npx -y @danmoisan/drm-copilot-mcp` and reads its coverage allow-list from the published package, not from the repository. All nine `pester.runsettings.psd1` copies in the npx cache carry zero `BlastRadiusTokenShape` entries, so the canonical `artifacts/pester/powershell-coverage.xml` lists six blast-radius source files rather than seven. Until the next publish, a regression in `BlastRadiusTokenShape.psm1` would not be reflected in the MCP gate's coverage figure.
- **Why this is not blocking:** Both in-repository allow-lists carry the entry, added in the same commit as the module. Direct measurement against the repository allow-list reports the module at 19 of 19 lines = 100% line and 22 of 22 instructions, independently verified by this reviewer. The module has a dedicated 197-line Pester suite whose cases run inside the full 3389-test suite, so the behavior is tested; only the coverage attribution is missing from the gate artifact. No repository change can close the gap.
- **Expected end state:** After the next MCP package publish, `BlastRadiusTokenShape.psm1` appears in the MCP-driven coverage artifact.
- **Verification:**
  ```powershell
  # after the next publish
  Select-String -Path artifacts/pester/powershell-coverage.xml -Pattern 'BlastRadiusTokenShape' -SimpleMatch
  # expect at least one match
  ```

### R6 — Investigate the residual conflict-graph density (separate feature, not remediation)

- **Problem:** This fix cut total radius path entries by 34% (3729 → 2472) and removed a provably-spurious edge class, yet edge count fell only 1282 → 1267, density only 77.6% → 76.6%, and cohort count and maximum cohort width did not move at all (32 and 4 in both states). The concurrency objective that motivated issue #502 is therefore not yet met.
- **Assessment:** Not a defect in this change, and the evidence artifacts state it plainly rather than presenting the entry-count reduction as a concurrency win. Recorded here so the observation is not lost between features.
- **Expected end state:** A separate investigation identifies what supplies the remaining 1267 edges — the candidates visible from this audit are real shared paths, module-level overlap, and shared-surface overlap — and whether any of them is another false-edge class.
- **Do NOT** attempt this on the #502 branch.
- **Verification (starting point):** re-derive radii over `docs/features/active/*` and group the surviving `conflict_edges[].reason` values by `kind` to see which relation dominates.

---

## Global "Do Not Do" List

Applies to any change that acts on this artifact.

1. **Do not create `tests/fixtures/blast_radius/conflict-placeholder-only-overlap.json`.** It would be an assertion that cannot fail, which `.claude/rules/plan-acceptance-gates.md` exists to reject.
2. **Do not lower `MINIMUM_FIXTURE_COUNT` or `$minimumFixtureCount`.** Both are at 30, equal, raised from 26, and non-vacuous against 35 fixtures. Lowering a live gate to match prose arithmetic is a policy weakening.
3. **Do not modify any file under `.github/` or any `.claude/rules/*.md` file.** The `.claude/rules/parallel-orchestration.md` amendment already in the branch is correct, complete, byte-mirrored, and verified; it needs no further edit.
4. **Do not touch production code, tests, or fixtures for any item in this artifact.** Every item is documentation, process, or a separate concern. The delivered implementation is complete and verified.
5. **Do not narrow the marker set, add a diagnostic channel for rejected tokens, or add a `config/blast-radius.json` key.** All three were considered and decided against with recorded rationale in `spec.md`, in both runtimes' inline documentation, and in the rule prose. Reversing any of them requires a new specification, not a remediation edit.
6. **Do not re-run Phase 8 or regenerate the evidence set.** Every figure in it was independently reproduced by this audit. The evidence is sound.
7. **Do not scope-creep the PR-context pattern fix (R3) onto this branch.** It is unrelated code with its own tests and a required Python/TypeScript parity obligation.
8. **Do not use a bare `poetry run ruff check` in any verification step.** `pyproject.toml` sets `fix = true` under `[tool.ruff]`, so the bare form rewrites source and still exits 0 — a gate that passes on a file it just modified. Use `--no-fix` (issue #515).
9. **Do not treat any item here as blocking the pull request.** `blocking_count` is 0 and the audited verdict is Go.

---

## Suggested Grouping If These Items Are Ever Planned

- **One documentation-only change:** R1 + R2, both in `spec.md`. No code, no tests, no toolchain run beyond a documentation validation. This is the only work that touches this feature folder.
- **One new issue:** R3, the PR-context reference-pattern defect, with a Python/TypeScript parity requirement.
- **Two pull-request-authoring actions, not code:** R3's immediate mitigation (auto-close list reduced to `#502`) and R4 (disclose #501's lifecycle record).
- **One deferred verification:** R5, at the next MCP package publish.
- **One separate investigation:** R6, residual conflict-graph density.

---

## Exit-Gate Statement

`blocking_count = 0`. No FAIL finding, no Blocker finding, no Major finding against the branch, no toolchain failure, no coverage violation, and no coverage artifact absent for a language with changed files. The one PARTIAL acceptance criterion is unsatisfiable as written and its substance is discharged by verified tests in both runtimes.

**The remediation loop should be marked complete without opening a cycle.** The branch is ready for normal pull-request flow.
