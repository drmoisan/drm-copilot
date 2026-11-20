# Feature Audit: PowerShell Branch-Coverage Gate Exemption (#476)

**Audit Date:** 2026-08-16
**Feature Folder:** `docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476`
**Base Branch:** `main`
**Head Branch:** `bug/powershell-branch-coverage-gate-unsatisfiable-476`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review
**Template source:** Bundled asset `extensions/drm-copilot/resources/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md` (the file the MCP resolver serves), read directly because MCP tools are unavailable in this session.

---

## Scope and Baseline

- **Base branch:** `main` (`origin/main` @ `687380a695c3fae873e75fbd22235d80ede0166a`)
- **Head branch/commit:** `bug/powershell-branch-coverage-gate-unsatisfiable-476` (commit `0cb97bcf33d0140fbad97bc7a0d0808032e2539a`)
- **Merge base:** `687380a695c3fae873e75fbd22235d80ede0166a` (ancestry-resolved per `pr-base-branch-merge-base`; `git rev-list --left-right --count origin/main...HEAD` reported `0 0` at branch creation)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (refreshed against base `main` at head `0cb97bcf`)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`, plus direct `git diff 687380a6..HEAD` inspection of every policy-file hunk
  - Feature evidence: `docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/evidence/{baseline,qa-gates,regression-testing}/` (21 artifacts)
  - Additional evidence: reviewer re-runs at head (full pytest, parity suites, SHA256 parity, Pester module inspection, inventory sweep, evidence-location validator)
- **Feature folder used:** `docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476`
- **Requirements source:** `spec.md` (sole AC source)
- **Work mode resolution note:** `issue.md` carries the explicit marker `- Work Mode: full-bug`; per the acceptance-criteria contract, `spec.md` is the only authoritative AC source and no `user-story.md` is expected or present.
- **Scope note:** Full branch-diff audit (42 files: 17 policy-surface modifications, 25 feature-folder additions). No caller-supplied scope narrowing was present or applied. Executor evidence artifacts carry timestamps offset ahead of the commit author time; all load-bearing claims were re-verified against the committed head rather than trusted from timestamps.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/spec.md` — only source (work mode `full-bug`)

### Acceptance criteria

The spec's `## Acceptance Criteria` section contains 16 checkbox criteria, AC1-AC16, all already checked `[x]` by the executor with per-criterion evidence citations. Abbreviated labels (full text preserved in `spec.md`):

1. AC1 — Carve-out present and structurally parallel (four parts, bash precedent shape)
2. AC2 — PowerShell line threshold preserved exactly (`>= 85%` unchanged; `powershell.md:63` untouched)
3. AC3 — Measurement obligation intact (threshold-versus-measurement distinction explicit)
4. AC4 — Shared-file qualifications scoped to the branch clause only
5. AC5 — Branch-capable languages unweakened (Python/TypeScript/C# at `>= 75%`; rule files unmodified)
6. AC6 — PowerShell QA-gate skill aligned (`powershell-qa-gate/SKILL.md:45`)
7. AC7 — Codex surface aligned (`.agents/**` restatements)
8. AC8 — Root/bundle byte parity (8 pairs)
9. AC9 — Parity and completeness suites pass (pytest set + Jest twin)
10. AC10 — Coverage hook unmodified (and its mirror)
11. AC11 — Copilot surface unmodified (no `.github/**` change)
12. AC12 — README consistency edit (`README.md:298`)
13. AC13 — No command-coverage gate introduced
14. AC14 — Edit surface closed (17 enumerated files)
15. AC15 — Full test suites pass (pytest + Jest)
16. AC16 — Inventory swept (no residual unqualified PowerShell branch binding; `shell.md` unchanged)

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC1 carve-out, four parts | PASS | Diff hunk for `.claude/rules/powershell.md:64` contains all four parts in order: "Pester reports **command (instruction) coverage and line coverage only**"; "The uniform line-coverage threshold (>= 85% per `.claude/rules/quality-tiers.md`) applies"; "Branch coverage is not measurable by Pester for PowerShell"; "there is no PowerShell branch-coverage gate". Structure matches `.claude/rules/shell.md:68-70` read side-by-side. | `git diff 687380a6..HEAD -- .claude/rules/powershell.md` | Adds the measurement-distinction sentence beyond the bash precedent, as the spec requires. |
| 2 | AC2 line threshold preserved | PASS | The only removed line in `powershell.md` is the former branch bullet; line 63 (`Line coverage must remain >= 85% ...`) is textually unchanged. Every amended file retains its `>= 85%` statement unconditionally, including `README.md`. | Diff inspection of all 9 root edits | Reviewer confirmed no `>= 85%` statement is lowered, removed, or conditioned anywhere in the diff. |
| 3 | AC3 measurement obligation intact | PASS | No added line excludes PowerShell from measurement. Explicit distinction present at three sites: `powershell.md` ("removes an unevaluable threshold, not a measurement obligation ... remain in the coverage denominator"), `general-unit-test.md:24` ("threshold exemption only; ... remain in the coverage denominator"), `quality-tiers.md` rationale ("capability limit on an unevaluable threshold, not a licence to exclude files from measurement"). | Read-through of every added line in the policy diff | |
| 4 | AC4 qualification scoped to branch clause | PASS | In all four named files the qualifier attaches only to the branch clause; line bullets, the `No regression on changed lines.` row, and the changed-lines bullets are byte-unchanged in their hunks. `feature-review-workflow/SKILL.md` and `agents/feature-review.md` keep "fully subject to the line threshold and the no-regression requirement" for PowerShell. | Diff inspection | |
| 5 | AC5 branch-capable languages unweakened | PASS | `>= 75%` restated for branch-capable languages at every amended site; `.claude/rules/python.md`, `typescript.md`, `csharp.md` and their mirrors absent from the diff. | `git diff --name-only 687380a6..HEAD -- .claude/rules/python.md .claude/rules/typescript.md .claude/rules/csharp.md` (empty) | `python.md` still states the unqualified Python branch requirement at its own line 100, unchanged. |
| 6 | AC6 QA-gate skill aligned | PASS | Amended line 45 reads: "line coverage >= 85% per the uniform tier rule ... Pester measures command (instruction) coverage and line coverage only; branch coverage is not measurable for PowerShell, so no branch-coverage gate applies here ... Command coverage is informational and carries no threshold." | `git diff 687380a6..HEAD -- .claude/skills/powershell-qa-gate/SKILL.md` | Line clause and no-regression clause retained. |
| 7 | AC7 Codex surface aligned | PASS | `.agents/skills/general-unit-test/SKILL.md:29` and `.agents/skills/quality-tiers/SKILL.md:30,39,56` carry qualifications textually parallel to their `.claude` counterparts (cross-references adjusted to `.agents` paths); line and no-regression clauses unconditional. | `git diff 687380a6..HEAD -- .agents/` | |
| 8 | AC8 root/bundle byte parity | PASS | Reviewer-computed SHA256 for all 8 root/mirror pairs: 8 of 8 MATCH. | `sha256sum` per pair | Independently corroborated by AC9's parity suites. |
| 9 | AC9 parity and completeness suites pass | PASS | Reviewer re-ran the three-file pytest set at head: `20 passed`, exit 0. Jest completeness twin: executor evidence records 185 suites / 2552 tests passed, exit 0, twin explicitly included. | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` | Jest run inspected from `evidence/qa-gates/final-jest-coverage.2026-08-16T17-46.md` (raw output with exit code), not re-run. |
| 10 | AC10 coverage hook unmodified | PASS | Hook and mirror absent from the 42-entry diff; reviewer additionally read the hook at head and confirmed the `$null`-skip behavior (lines 195, 323-324) that makes the prose change mechanism-neutral. | `git diff --name-only 687380a6..HEAD -- .claude/hooks/ 'extensions/drm-copilot/resources/claude-customizations/.claude/hooks'` (empty) | |
| 11 | AC11 Copilot surface unmodified | PASS | Zero `.github/**` entries in the diff. | `git diff --name-only 687380a6..HEAD -- .github/` (empty) | |
| 12 | AC12 README consistency edit | PASS | Amended `README.md:298` keeps "line coverage >= 85%, with no regression on changed lines" and scopes branch `>= 75%` to branch-capable languages, naming PowerShell (Pester) and bash (kcov) exempt while keeping both fully subject to line and no-regression. | `git diff 687380a6..HEAD -- README.md` | |
| 13 | AC13 no command-coverage gate | PASS | All command-coverage mentions in the diff are descriptive; two carry explicit no-threshold disclaimers ("reported for information only, with no threshold attached"; "informational and carries no threshold"). No numeric threshold attaches to command or instruction coverage anywhere in the added text. | Read-through of every added line | |
| 14 | AC14 edit surface closed | PASS | The 17 modified (`M`) entries in `git diff --name-status 687380a6..HEAD` match the enumerated list one-for-one; zero hook, script, test, configuration, or `.github/**` entries; every changed file is `.md`. The 25 added (`A`) entries are all the feature's own documentation and evidence under `docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/`, which the spec's evidence convention requires in-branch and which the AC's evidence artifact expressly anticipated (the folder was untracked at evidence-capture time). | `git diff --name-status 687380a6..HEAD` | Criterion read as governing the policy edit surface; feature documentation does not violate closure. |
| 15 | AC15 full test suites pass | PASS | Reviewer re-ran the full Python suite at head: 3785 passed, 5 pre-existing skips, exit 0 (7.07s). Jest: executor evidence, 2552 passed, exit 0, coverage 96.61% lines / 89.96% branches, zero delta vs baseline on all 19 compared values. | `poetry run pytest -q`; evidence inspection of `final-jest-coverage.2026-08-16T17-46.md` and `coverage-delta.2026-08-16T17-47.md` | |
| 16 | AC16 inventory swept | PASS | Reviewer's independent case-insensitive `--hidden` sweep over `.claude/`, `.agents/`, `README.md`, and both bundle payloads at head found zero remaining unqualified PowerShell branch-threshold bindings. `shell.md` and its mirror are absent from the diff (byte-unchanged). | `rg -i --hidden -n "branch coverage|branch-coverage" ...`; `git diff --name-only 687380a6..HEAD -- .claude/rules/shell.md` (empty) | Residual unqualified matches bind to branch-capable languages or to the deliberately unmodified hook, as the executor's sweep also recorded. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 16 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. On the next feature-review pass over a PowerShell-touching diff, confirm no branch-coverage finding is raised while the line gate still operates (the spec's behavioral integration re-test; only fully observable on a future PowerShell-touching branch).
2. File the three recorded follow-ups from `issue.md`: AST-instrumentation branch collector, the `pester.runsettings.psd1` `CodeCoverage.Path` allow-list conflict with the Coverage Exclusion Policy, and the dangling `docs/ci.research.md` reference in `quality-tiers.md`.
3. After merge, run the standard release flow (paired extension + mcp-server version bump and publish) so consumer repositories receive the corrected payload.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- All 16 criteria evaluate to PASS and were already checked `[x]` in `spec.md` by the executor with evidence citations. This reviewer independently confirmed each criterion; no source-file checkbox change was needed and none was made.
- No criterion required un-checking.

### AC Status Summary

- Source: `docs/features/active/2026-08-16-powershell-branch-coverage-gate-unsatisfiable-476/spec.md`
- Total AC items: 16
- Checked off (delivered): 16
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 16 | 16 | 0 | Checkbox-backed; all pre-checked by executor; each independently re-verified by this reviewer |
