# Policy Audit: epic-orchestrate (#275)

**Audit Date:** 2026-07-03
**Feature Folder:** `docs/features/active/2026-07-02-epic-orchestrate-275/`
**Base Branch:** `main` (merge-base `3c5ff3289022abc3b7b16e2441c772e5f81fd9ff`)
**Head Branch:** `drm-copilot-wt-2026-07-02-19-03` @ `6d4bac761771558971174dce7b870ebb09bac72a`
**Audit Type:** Re-audit — R4 of remediation cycle 2 (the second remediation cycle for this feature)
**Prior audit (superseded, not assumed valid):** `policy-audit.2026-07-03T00-15.md` @ commit `44c827d` (its one residual Major finding is independently re-checked below, not trusted at face value).

---

## Scope

Per the Scope Invariant, this audit covers the **full branch diff against `main`**, not the cycle-2 delta alone: 148 files changed, 12035 insertions, 290 deletions (`git diff --stat 3c5ff3289022abc3b7b16e2441c772e5f81fd9ff..6d4bac761771558971174dce7b870ebb09bac72a`), independently reproduced this pass. PR context artifacts (`artifacts/pr_context.summary.txt`, `artifacts/pr_context.appendix.txt`) were confirmed fresh — timestamped 2026-07-02 23:18, generated against the current HEAD (`6d4bac7`), resolved base `origin/main @ f8cf6836d21c578051984b7521162ef502af9f01`, merge-base `3c5ff3289022abc3b7b16e2441c772e5f81fd9ff` (matches the caller-supplied merge-base exactly).

**Languages with changed files in this branch diff:** Python, PowerShell, TypeScript, Markdown/config (JSON). **No C# files are touched** (`git diff --name-status` confirms zero `.cs`/`.csproj` paths) — C# coverage is correctly N/A for this feature, not a scope-narrowing omission.

## Rejected Scope Narrowing

None detected. The caller prompt for this pass explicitly instructs "No scope narrowing" and directs independent re-verification rather than trusting the prior remediation's self-report; no instruction in this prompt attempted to narrow scope to a subset of files, a single language, or a single plan/task. This audit independently re-executed the full toolchain for all three in-scope languages (see Coverage Verification and Toolchain Verification below), not only the cycle-2 delta.

## Evidence Location Compliance

`poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` — **EXIT 0, zero violations** (independently re-run this pass). No file in the branch diff is written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, or `artifacts/evidence/`; all cycle-1 and cycle-2 evidence is correctly under `docs/features/active/2026-07-02-epic-orchestrate-275/evidence/{baseline,qa-gates,other,remediation-baseline}/`. No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` entries required — the remediation plan and inputs for this cycle both explicitly instructed evidence to be written to the canonical feature-folder path, and it was.

---

## Cycle 2 Fix Verification (the single change under audit this cycle)

**Fix:** `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` was 513 lines (13 over the mandatory 500-line cap in `general-code-change.md`) at the end of remediation cycle 1. `remediation-plan.2026-07-03T00-15.md` relocated the 8 residual `orchestrator-state` payload-shape tests plus 2 exclusively-used helper functions into a new sibling file, `tests/scripts/dev_tools/test_validate_orchestration_artifacts_state_shape.py`, per the convention already established twice in this feature.

**Independent re-verification (this pass):**

| Check | Result |
|---|---|
| `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` line count | **381 lines** — well under the 500-line cap. `wc -l` reproduced directly this pass. |
| `tests/scripts/dev_tools/test_validate_orchestration_artifacts_state_shape.py` line count | **154 lines** — new sibling file, confirmed to exist. |
| `tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py` unchanged | Confirmed: `git diff --stat 44c827d 6d4bac7 -- tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py` produces **no output** — the cycle-1 sibling split file was neither weakened nor touched by this cycle's extraction. |
| Full diff of the fixed file (`git diff 44c827d 6d4bac7 -- tests/scripts/dev_tools/test_validate_orchestration_artifacts.py`) | Pure removal: the 8 relocated test functions, 2 exclusive helpers, and the now-unused `json` import were deleted; every other function/test/assertion is byte-identical. No assertion text, docstring, or production code changed. |
| New sibling file's 8 relocated tests, run in isolation | `poetry run pytest tests/scripts/dev_tools/test_validate_orchestration_artifacts_state_shape.py -v` → **8 passed** (independently reproduced this pass). |
| New sibling file's import pattern | Imports `build_valid_orchestrator_state` from the sibling module (not duplicated), following the exact convention `test_validate_orchestration_artifacts_dispatch.py` already established; module docstring explicitly documents why the split exists and disambiguates itself from the pre-existing, unrelated `test_validate_orchestrator_state.py`. |
| Full `tests/scripts/dev_tools` suite | `poetry run pytest tests/scripts/dev_tools -q` → **1192 passed, 19 skipped, 0 failed** — exactly matching the P0-T7/P2-T4 baseline reported by the remediation plan (net-zero change: tests relocated, not added/removed/skipped). Independently reproduced this pass. |

**Verdict on the cycle-2 fix: PASS.** The 500-line file-size violation is fully resolved with no test weakening, no assertion change, and no regression in test count or coverage.

---

## Section 1 — General Code Change Policy (`general-code-change.md`)

| Rule | Status | Evidence |
|---|---|---|
| File size <= 500 lines (production + test) | ✅ PASS | All files touched or created by the full branch diff independently re-measured this pass (see table below); the previously-open violation is now resolved. |
| Fail fast / explicit error handling | ✅ PASS | Carried forward, independently re-confirmed for cycle-2's only touched files (test-only; no production logic changed). `EpicWaveCycleError`, explicit `Write-Error`/`exit 1` patterns in hooks, and specific-exception validators are unchanged from cycle 1's audit. |
| Naming conventions | ✅ PASS | Unchanged from cycle 1. |
| Public API compatibility / keyword-style params | ✅ PASS | Unchanged from cycle 1; no public API touched this cycle. |
| Dependencies (no unapproved additions) | ✅ PASS | No new dependency introduced in the full branch diff. |
| I/O boundary isolation | ✅ PASS | Unchanged from cycle 1. |

**File-size spot-check (all new/modified production and test files in the full branch diff, independently re-measured this pass):**

| File | Lines | Cap | Status |
|---|---|---|---|
| `tests/scripts/dev_tools/test_validate_orchestration_artifacts.py` | 381 | 500 | PASS (was 513 — now fixed) |
| `tests/scripts/dev_tools/test_validate_orchestration_artifacts_dispatch.py` | 255 | 500 | PASS |
| `tests/scripts/dev_tools/test_validate_orchestration_artifacts_state_shape.py` | 154 | 500 | PASS (new this cycle) |
| `tests/scripts/dev_tools/test_validate_epic_orchestrator_state.py` | 337 | 500 | PASS |
| `scripts/dev_tools/validate_epic_orchestrator_state.py` | 488 | 500 | PASS |
| `scripts/dev_tools/epic_wave_computation.py` | 153 | 500 | PASS |
| `scripts/dev_tools/validate_orchestration_artifacts.py` | 261 | 500 | PASS |
| `.claude/hooks/enforce-epic-merge-gate.ps1` | 304 | 500 | PASS |
| `.claude/hooks/enforce-epic-wave-barrier.ps1` | 304 | 500 | PASS |
| `.claude/hooks/enforce-epic-worktree-removal-gate.ps1` | 237 | 500 | PASS |
| `.claude/hooks/enforce-pr-author-skill.ps1` | 451 | 500 | PASS |
| `.claude/hooks/enforce-pr-author-skill.epic-base-branch.ps1` | 104 | 500 | PASS |
| `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts` | 451 | 500 | PASS |
| `extensions/drm-copilot/src/lib/validate/orchestration-artifacts.ts` | 200 | 500 | PASS |
| `.claude/agents/epic-orchestrator.md` | 127 | n/a (docs exempt) | PASS |
| `.claude/skills/epic-orchestrate/SKILL.md` | 232 | n/a (docs exempt) | PASS |

No file in the full branch diff exceeds the 500-line cap. This closes the last remaining file-size gap from cycle 1.

---

## Section 2 — General Unit Test Policy (`general-unit-test.md`)

| Rule | Status | Evidence |
|---|---|---|
| Independence / isolation / determinism | ✅ PASS | No shared mutable state, no wall-clock reads, no unseeded randomness observed in any touched file (independently re-spot-checked this pass for the relocated test file). |
| Coverage exclusion policy (no production file excluded) | ✅ PASS | No `exclude` entry added to any coverage config in the full branch diff. |
| Test file location (mirrors `tests/` tree) | ✅ PASS | `tests/scripts/dev_tools/test_validate_orchestration_artifacts_state_shape.py` correctly mirrors `scripts/dev_tools/validate_orchestration_artifacts.py`'s location; no colocation. |
| AAA structure / scenario completeness | ✅ PASS | Carried forward; independently spot-checked the relocated tests this pass — Arrange/Act/Assert structure intact, one behavior per test. |
| Documentation (descriptive names/docstrings) | ✅ PASS | The new sibling file's module docstring explains why the split exists and disambiguates it from the pre-existing, unrelated `test_validate_orchestrator_state.py`; every relocated test retains its original docstring verbatim. |

---

## Coverage Verification (Mandatory, All Languages With Changed Files)

Per the Coverage Verification procedure, coverage artifacts were inspected (not regenerated for languages unaffected by this cycle) and independently re-executed for Python (the only language touched by cycle 2).

| Language | Changed files this cycle? | Coverage artifact | Repo-wide coverage (this pass) | Verdict |
|---|---|---|---|---|
| Python | Yes (test-only relocation) | `artifacts/python/lcov.info` — regenerated this pass via `poetry run pytest --cov=scripts.dev_tools --cov-branch --cov-report=term-missing tests/scripts/dev_tools` | **86.25% line** (`percent_statements_covered`), **75.85% branch** (`percent_branches_covered`), independently cross-checked via `coverage json` totals: `{"percent_statements_covered": 86.2488928255093, "percent_branches_covered": 75.84615384615384}`. (Note: the plain terminal `TOTAL` row shows "83%", which is coverage.py's blended statement+branch `percent_covered` metric, not the line-coverage figure the policy floor applies to — the correct metric, `percent_statements_covered`, is 86.25%, matching the prior audit's own methodology and figure exactly, confirming no regression.) | **PASS** (>= 85% line, >= 75% branch, both met; 0.00pp delta from cycle-1's independently measured figure) |
| PowerShell | No (cycle 2 touched Python test files only) | `artifacts/pester/powershell-coverage.xml` — not regenerated this cycle per the remediation plan's explicit "Do Not Do" instruction (PowerShell files unaffected by a Python-only fix); independently **re-parsed** this pass (not solely re-read) to confirm it still reflects current file state | Per-file LINE coverage independently re-parsed from the JaCoCo-style XML this pass: `enforce-epic-merge-gate.ps1` 93.42%, `enforce-epic-wave-barrier.ps1` 94.25%, `enforce-epic-worktree-removal-gate.ps1` 91.80%, `enforce-pr-author-skill.ps1` 91.75%, `enforce-pr-author-skill.epic-base-branch.ps1` 91.30%, `validate-orchestrator-output.ps1` 86.96% — all 6 of this feature's files >= 85%. `git diff --stat 44c827d 6d4bac7` confirms zero PowerShell production files changed since this artifact was generated, so it remains valid evidence for the current HEAD. | **PASS** (all 6 in-scope files >= 85% line; confirmed unaffected/unregressed by cycle 2) |
| TypeScript | No (cycle 2 touched Python test files only) | `extensions/drm-copilot/coverage/lcov.info` (428547 bytes, timestamp unchanged since cycle-1's regeneration) — independently **re-parsed** this pass (summed `LH`/`LF`/`BRH`/`BRF` across all 136 `SF:` records) | **96.89% lines** (31320/32326), **88.28% branch** (4052/4590) — recomputed directly from the lcov file this pass, matching the prior audit's reported 96.88%/88.27%/96.88% within rounding. `git diff --stat 44c827d 6d4bac7` confirms zero TypeScript files changed since this artifact was generated. | **PASS** (both thresholds met; confirmed unaffected/unregressed by cycle 2) |
| C# | No changed files in the branch diff | N/A | N/A | **N/A** (zero changed `.cs`/`.csproj` files in the full branch diff — legitimate N/A, not a scope-narrowing omission) |

**New-code / modified-file coverage (uniform 85%/75% floor, no tier-specific lower threshold):**

- `scripts/dev_tools/validate_epic_orchestrator_state.py` (new): 95% line (independently reproduced via `coverage json` this pass, unchanged from cycle 1 — not touched by cycle 2).
- `scripts/dev_tools/epic_wave_computation.py` (new): 100% line / 100% branch (unchanged from cycle 1).
- `extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-core.ts` (new): 97.33% statements / 87.20% branch (unchanged from cycle 1).
- All 6 PowerShell hook files (new/modified): 86.96%–94.25% line (unchanged from cycle 1, re-confirmed above).
- The two new Python test files this cycle (`test_validate_orchestration_artifacts_state_shape.py` and its unchanged predecessor) are test files, not measured for their own coverage (test files are correctly excluded from the coverage denominator per `general-unit-test.md`'s exclusion policy).

**No regression on changed lines:** Confirmed for all three languages — Python's repo-wide figures are unchanged (86.25%/75.85%, identical to the cycle-1 measurement); PowerShell's and TypeScript's artifacts are byte-for-byte/timestamp-unchanged since cycle-1 regeneration, confirming zero drift.

---

## Toolchain Verification (Mandatory Seven-Stage Loop, All In-Scope Languages)

Independently re-executed in full this pass (not solely re-read from remediation evidence):

| Stage | Python | PowerShell | TypeScript |
|---|---|---|---|
| Formatting | `poetry run black --check scripts/dev_tools tests/scripts/dev_tools` → **0 files need reformatting** (211 files checked) | `Invoke-Formatter` re-applied to all 6 in-scope hook files via `pssa.settings.psd1` → **0 files needing reformat** | `npm run format -- --check` → **all matched files use Prettier code style** |
| Linting | `poetry run ruff check scripts/dev_tools tests/scripts/dev_tools` → **All checks passed!** | `Invoke-ScriptAnalyzer` against all 6 in-scope hook files via `pssa.settings.psd1` → **0 findings** | `npm run lint` → **0 findings** |
| Type checking | `poetry run pyright scripts/dev_tools tests/scripts/dev_tools` → **0 errors, 0 warnings, 0 informations** | N/A (PowerShell has no type-check stage per `.claude/rules/powershell.md`) | `npx tsc --noEmit` → **0 errors** |
| Unit tests | `poetry run pytest tests/scripts/dev_tools -q` → **1192 passed, 19 skipped, 0 failed** | `Invoke-Pester` against `tests/scripts/claude-hooks` → **467 passed, 0 failed, 0 skipped** | `node run-jest.cjs` → **1462 passed, 0 failed (121 suites)** |

Architecture-boundary tests, contract/schema checks, and integration tests were unaffected by cycle 2 (test-file-relocation only) and are carried forward unchanged from cycle 1's independently-verified PASS status (mirror-parity contract test re-run below).

**All four toolchain stages pass cleanly with zero findings in all three in-scope languages, independently reproduced in full this pass.** This resolves `spec.md`'s AC14 and the "Toolchain pass completed" generic closing item, both of which were checked off (`[x]`) in `spec.md` this pass — see Acceptance Criteria Check-off in `feature-audit.2026-07-03T00-45.md`.

---

## Section 3 — Bundled Mirror Parity (AC13)

Independently re-verified this pass against **both** mirrors for all 11 in-scope `.claude/`-tree files (the 10 originally listed plus the cycle-1 addition, `enforce-pr-author-skill.epic-base-branch.ps1`):

- `extensions/drm-copilot/resources/claude-customizations/` (test-enforced): `poetry run pytest tests/scripts/dev_tools -k "mirror or parity" -q` → **12 passed, 2 skipped** (independently reproduced this pass).
- `packages/mcp-server/resources/claude-customizations/` (gitignored, manually `cmp`-verified): all 11 files re-verified `cmp`-identical this pass (`epic-orchestrator.md`, `orchestrator.md`, `enforce-epic-merge-gate.ps1`, `enforce-epic-wave-barrier.ps1`, `enforce-epic-worktree-removal-gate.ps1`, `enforce-pr-author-skill.ps1`, `enforce-pr-author-skill.epic-base-branch.ps1`, `validate-orchestrator-output.ps1`, `epic-orchestrate/SKILL.md`, `orchestrate/SKILL.md`, `settings.json`).
- `config/orchestration-routing.json` vs. `extensions/drm-copilot/resources/config/orchestration-routing.json`: `cmp` exit 0, identical.

**Incidental observation (not a new finding attributable to this feature):** `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and its `extensions/drm-copilot/resources/powershell/PoshQC/settings/` mirror have a pre-existing textual divergence (the extensions mirror carries an `ExcludedPath` block the root file lacks) — confirmed via `git show 3c5ff32:...` on both files that this divergence **predates this feature's merge-base** and is unrelated to `spec.md`'s AC13 scope, which is explicitly limited to the `.claude/` tree (`spec.md` line 327). This feature's diff to that file is identical, additive-only, and applied consistently to both copies (6 new `CodeCoverage.Path` entries, in the same relative position, in both files) — it neither introduces nor worsens the pre-existing divergence. Not tracked as a finding of this feature.

**Verdict: PASS**, independently re-verified against both mirrors this pass.

---

## Section 4 — Carried-Forward Non-Blocking Items (Re-Confirmed This Pass)

Per the task's explicit instruction, both items below were independently re-examined (not merely re-cited) this pass.

### 4.1 `enforce-epic-worktree-removal-gate.ps1` design-scope note

**Confirmed still present, unchanged, and explicitly documented as an accepted risk** (`spec.md` line 325: "The merge-gate and worktree-removal-gate hooks are policy-level checks that trust the on-disk checkpoint (§ Hooks item b design-decision note); this is an accepted, explicitly documented risk consistent with the same posture already accepted for `enforce-pr-author-skill.ps1`.").

**Additional verification performed this pass, going beyond the prior audit's re-statement:** direct inspection of `.claude/settings.json` confirms `enforce-epic-worktree-removal-gate.ps1` is registered on the plain `"Bash"` `PreToolUse` matcher (line 98) with **no subagent-type or prompt-marker gating**, unlike `enforce-epic-wave-barrier.ps1`, which is registered on the `"Agent"` matcher and (per the code-review's own prior finding) internally gates on subagent type/prompt markers. This means the hook's decision logic (independently re-read this pass) applies to **any** `git worktree remove` Bash command in **any** Claude Code session against this repository, not only within an active epic run — a broader blast radius than "no standalone-orchestration caller" alone conveys. However, `git grep -n "worktree remove"` across `.claude/` confirms the **only** documented Claude-Code-driven workflow that issues this command is `epic-orchestrate/SKILL.md` itself; `orchestrate/SKILL.md` (standalone orchestration) contains no reference to worktree management at all. AC9's literal wording ("denies `git worktree remove` unless... `merge_status` in `{merged, worktree_removed}`") does not require epic-mode scoping and is satisfied as written.

**Verdict: still accurately non-blocking**, with a refinement to the risk description: the absence of an epic-mode precondition is a genuine, currently-latent design gap whose blast radius is repository/session-wide (not merely "future orchestration expansion"), but no currently-documented Claude-Code-driven workflow triggers it outside epic mode. Recommend this be prioritized as a near-term follow-up given the session-wide registration, rather than deferred indefinitely — but it does not block this cycle's exit, consistent with the repeated, explicit requester decision across two remediation cycles.

### 4.2 Dangling "Merge-Conflict Remediation" cross-reference

**Confirmed still present, unchanged.** `grep -n "Merge-Conflict Remediation" .claude/skills/orchestrate/SKILL.md` (line 162, within S9 step 6) returns only the referencing line itself; the actual procedure lives in `.claude/skills/epic-orchestrate/SKILL.md`'s "Merge-Conflict Handling (Fan-In)" section (confirmed present at line 120 via direct read this pass) — a different file and a differently-worded heading than the one cited. This is a documentation cross-reference defect (Minor), not a functional defect: the content it should point to exists and is correct, only the pointer's literal heading name is wrong.

**Verdict: still accurately non-blocking** (Minor severity, documentation-only).

---

## Section 5 — New Observation This Pass (Minor, Non-Blocking)

`.claude/settings.local.json` (tracked, not gitignored) picked up four new `permissions.allow` entries in the cycle-1 commit (`44c827d`, not touched by cycle 2): `Bash(git show *)`, `Bash(diff /tmp_root_baseline.psd1 /tmp_mirror_baseline.psd1)`, `Bash(echo "exit: $?")`, `Bash(rm -f /tmp_root_baseline.psd1 /tmp_mirror_baseline.psd1)`. The latter three reference specific, ephemeral temp-file paths that appear to be residual from an ad hoc verification step performed during a prior review pass, not a reusable or documented permission tied to any acceptance criterion. This is repository hygiene debt in a checked-in configuration file, not a functional or security defect (the referenced paths do not exist and the permissions are otherwise inert). **Severity: Minor, non-blocking.** Recommend removing the three ephemeral entries in a future housekeeping pass; not required for this cycle's exit given it carries no functional risk.

---

## Summary

| Section | Verdict |
|---|---|
| Scope Invariant / Rejected Scope Narrowing | PASS — no narrowing attempted or detected |
| Evidence Location Compliance | PASS — 0 violations, validator exit 0 |
| Cycle-2 fix (file-size violation) | PASS — fully resolved, independently re-verified |
| General Code Change Policy | PASS |
| General Unit Test Policy | PASS |
| Coverage Verification (Python/PowerShell/TypeScript) | PASS (all three); C# N/A (zero changed files) |
| Toolchain Verification (all 4 stages, all 3 languages) | PASS |
| Bundled Mirror Parity (AC13) | PASS |
| Carried-forward worktree-removal-gate design note | Non-blocking, re-confirmed (refined risk description) |
| Carried-forward dangling cross-reference | Non-blocking, re-confirmed |
| New: `settings.local.json` hygiene debt | Minor, non-blocking, newly observed this pass |

**No Blocking or hard-policy-violation findings remain in this pass.** All prior Blocking and Major findings from cycles 0 and 1 are resolved; the two carried-forward items are confirmed Major/Minor and non-blocking by independent re-verification, and one new Minor hygiene observation was made. See `feature-audit.2026-07-03T00-45.md` for the acceptance-criteria disposition and exit recommendation.
