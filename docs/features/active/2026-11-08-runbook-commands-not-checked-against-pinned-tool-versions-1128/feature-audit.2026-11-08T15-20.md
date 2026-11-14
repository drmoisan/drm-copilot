# Feature Audit: Runbook commands not checked against pinned tool versions (#1128)

**Audit Date:** 2026-11-08
**Feature Folder:** `docs/features/active/2026-11-08-runbook-commands-not-checked-against-pinned-tool-versions-1128`
**Base Branch:** `main`
**Head Branch:** `bug/runbook-command-version-check`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main`
- **Head branch/commit:** `bug/runbook-command-version-check` (commit `3b8edf1c694cb69c224892c2f9825b338ec900b9`)
- **Merge base:** `cdcff3871765396183590128e142a929cf78327b`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `evidence/baseline/`, `evidence/qa-gates/`, `evidence/regression-testing/` under the feature folder
  - Additional evidence: `artifacts/pester/powershell-coverage.xml` (parsed directly)
- **Feature folder used:** `docs/features/active/2026-11-08-runbook-commands-not-checked-against-pinned-tool-versions-1128`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` carries the `full-bug` marker and the caller confirmed it; `spec.md` is the only AC source.
- **Scope note:** Full branch diff against the merge base of `origin/main` and HEAD. The live hook check is deferred to post-merge by coordinator decision, so acceptance of the hook rests on Pester.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-11-08-runbook-commands-not-checked-against-pinned-tool-versions-1128/spec.md` - only source (checkbox-backed)

### Acceptance criteria

1. Reproduction: a regression fixture of a runbook with `python -m nuitka --clean-cache=clcache` in a shell block, no marker, and a poetry.lock pinning nuitka 4.3.4 produces a finding naming nuitka and 4.3.4 (fails before the fix because no check exists; passes after).
2. Lockfile resolution returns the pinned version for each supported format (poetry.lock, uv.lock, package-lock.json, requirements*.txt), with PEP 503 normalization.
3. A marker naming the pinned version passes for both the `verified` and `not verified` forms; a mismatched version, a `not pinned` claim for a pinned tool, and a malformed marker each produce a finding; an unpinned tool with the `not pinned` form passes; exempt fences produce no finding.
4. The SubagentStop hook blocks on findings, a missing `runbook_path:`, and a missing file, and allows a conformant runbook, with item-worktree resolution.
5. Skill, agent, example, and all mirrors are updated; mirror and pack-manifest contract tests pass.
6. Full toolchain passes with no new failures against the Phase 0 baseline and at least 85% line coverage on the new PowerShell files.

---

## Acceptance Criteria Evaluation

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Reproduction fixture | PASS | `tests/scripts/claude-lib/runbook/RunbookCommandVersion.Tests.ps1` carries the nuitka 4.3.4 fixture; `evidence/regression-testing/fail-before.2026-11-08T13-52.md` records the failure before the module existed (exit 2) | `git diff --stat origin/main...HEAD` | Probe on the head module confirmed a finding that names the tool and pinned version |
| 2 | Lockfile resolution per format | PASS | `Get-RunbookPinnedToolVersion` handles poetry.lock, uv.lock, package-lock.json, requirements*.txt; PEP 503 normalization in `ConvertTo-RunbookNormalizedToolName`; seven resolution tests | `Read .claude/lib/runbook/RunbookCommandVersion.psm1` | Module line coverage 91/91 |
| 3 | Marker validation | PASS | `Get-RunbookCommandVersionFinding` implements the four finding classes; thirteen marker tests; exempt-fence list matches the spec | `Read .claude/lib/runbook/RunbookCommandVersion.psm1` | A multi-line command is a known limitation, see code-review finding 1 |
| 4 | SubagentStop hook | PASS | `.claude/hooks/validate-human-exception-runbook-output.ps1` blocks on findings, missing `runbook_path:`, missing file; uses `Resolve-SubagentStopTargetWorktree`; 13 plus 8 hook tests; registered in the agent frontmatter | `Read .claude/hooks/validate-human-exception-runbook-output.ps1` | Live check deferred post-merge (coordinator decision) |
| 5 | Skill, agent, example, mirrors | PASS | `cmp` showed the `.claude` files byte-identical to the bundle copies; the `.agents` example identical to its bundle copy; `core.json` lists the module and hook; `pytest-final.2026-11-08T15-08.md` records the five contract suites green | `cmp` over the five mirrored paths | |
| 6 | Toolchain and coverage | PASS | `pester-final.2026-11-08T15-08.md`: 19648 tests, 0 failed; repo line 95.56% to 95.57%; coverage XML parse: module 91/91, hook 54/58 (93.1%); analyzer and format 0 findings | `parse artifacts/pester/powershell-coverage.xml` | The pytest branch variance in an unchanged file is a coordinator-recorded non-blocking note |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 6 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. After merge, exercise the live hook with a nuitka runbook (deferred by coordinator decision).
2. Consider the non-blocking design limitation on multi-line and chained commands recorded in the code review.

---

## Acceptance Criteria Check-off

All six criteria were already checked in `spec.md` by the executor and were independently re-evaluated as PASS. No source-file change was made by this review.

### AC Status Summary

- Source: `docs/features/active/2026-11-08-runbook-commands-not-checked-against-pinned-tool-versions-1128/spec.md`
- Total AC items: 6
- Checked off (delivered): 6
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 6 | 6 | 0 | Checkbox-backed |
