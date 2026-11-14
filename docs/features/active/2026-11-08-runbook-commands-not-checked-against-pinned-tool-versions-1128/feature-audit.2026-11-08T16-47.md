# Feature Audit: Runbook commands not checked against pinned tool versions (#1128)

**Audit Date:** 2026-11-08
**Feature Folder:** `docs/features/active/2026-11-08-runbook-commands-not-checked-against-pinned-tool-versions-1128`
**Base Branch:** `main`
**Head Branch:** `bug/runbook-command-version-check`
**Work Mode:** `full-bug`
**Audit Type:** Re-audit after remediation cycle 2 (CI-1 tier classification)

---

## Scope and Baseline

- **Base branch:** `main`
- **Head branch/commit:** `bug/runbook-command-version-check` (commit `d7f1037c64e300c4b3ab853d2ecf20f0eebf97e9`)
- **Merge base:** `d68dc94e9e12eaf798f557e3670a05b4d215053a`
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `evidence/baseline/`, `evidence/qa-gates/`, `evidence/regression-testing/`, `evidence/remediation-baseline/` under the feature folder
  - Additional evidence: `artifacts/pester/powershell-coverage.xml` (parsed directly), and execution of the head module on the two remediation reproductions
- **Feature folder used:** `docs/features/active/2026-11-08-runbook-commands-not-checked-against-pinned-tool-versions-1128`
- **Requirements source:** `spec.md`
- **Work mode resolution note:** `issue.md` carries the `full-bug` marker and the caller confirmed it; `spec.md` is the only AC source.
- **Cycle 2 note:** the only change since the PASS review at `627cc03ae` is the `quality-tiers.yml` entry, evidence, and a clean origin/main merge; CI-1 is confirmed resolved.
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
| 1 | Reproduction fixture | PASS | `tests/scripts/claude-lib/runbook/RunbookCommandVersion.Tests.ps1` carries the nuitka 4.3.4 fixture; `evidence/regression-testing/fail-before.2026-11-08T13-52.md` records the failure before the module existed | `git diff --stat origin/main...HEAD` | Probe on the head module confirmed a finding that names nuitka and 4.3.4 |
| 2 | Lockfile resolution per format | PASS | `Get-RunbookPinnedToolVersion` handles poetry.lock, uv.lock, package-lock.json, requirements*.txt; PEP 503 normalization in `ConvertTo-RunbookNormalizedToolName`; resolution tests unchanged and passing | `Read .claude/lib/runbook/RunbookCommandVersion.psm1` | Module line coverage 129/129 |
| 3 | Marker validation | PASS | `Get-RunbookCommandVersionFinding` implements the four finding classes; marker tests pass; exempt-fence list matches the spec. The two limitations recorded in the prior review (continuation lines, chained and environment-prefixed commands) are resolved: probe of the head module returned 0 findings for the marked reproductions and the nuitka finding for the unmarked ones | `Execute the head module on both reproductions` | `ri-fail-before.2026-11-08T15-35.md`: 22 failures before the fix, 0 after |
| 4 | SubagentStop hook | PASS | `.claude/hooks/validate-human-exception-runbook-output.ps1` blocks on findings, missing `runbook_path:`, missing file; uses `Resolve-SubagentStopTargetWorktree`; 13 plus 8 hook tests; registered in the agent frontmatter | `Read .claude/hooks/validate-human-exception-runbook-output.ps1` | Live check deferred post-merge (coordinator decision) |
| 5 | Skill, agent, example, mirrors | PASS | `cmp` showed the module, hook, agent, `.claude` skill and example byte-identical to the bundle copies, and the `.agents` skill and example identical to the `codex-and-agents-customizations` copies; `core.json` lists the module and hook; `pytest-final.2026-11-08T16-03.md` records 16537 passed, 0 failed | `cmp` over the mirrored paths | |
| 6 | Toolchain and coverage | PASS | Cycle 2: `check-quality-tiers.2026-11-08T16-40.md` exit 0 (rerun at head: 32 of 32); `pytest-final.2026-11-08T16-46.md` 16538 passed, 0 failed, line 93.58%, branch 90.17%, equal to baseline. Cycle 1: `pester-final.2026-11-08T15-56.md`: 19754 tests, 0 failed; repo line 95.56% to 95.58%; no per-file drop; coverage XML parse: module 129/129, hook 54/58 (93.1%); analyzer and format 0 findings | `parse artifacts/pester/powershell-coverage.xml` | The pytest 395->362 branch variance is in an untouched file and is a recorded non-blocking note |

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
