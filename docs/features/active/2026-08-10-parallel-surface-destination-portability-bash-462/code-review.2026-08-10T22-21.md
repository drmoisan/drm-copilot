# Code Review: parallel-surface-destination-portability-bash (#462) — Remediation Cycle 1 Re-Review

**Review Date:** 2026-08-10
**Reviewer:** feature-review agent (Claude Code)
**Feature Folder:** `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462`
**Feature Folder Selection Rule:** Single active folder whose suffix matches the issue number in the branch scope; supplied by the caller and confirmed against the changed scoping docs in the PR-context summary.
**Base Branch:** `main` (merge base `a26286e87137780ee9e5f59ba2753c2307617572`)
**Head Branch:** `drm-copilot-wt-2026-08-10T09-25` @ `8c12ea8c9b708ce04f0fdb0d63fcc5a1b1dad132`
**Review Type:** Post-remediation re-review (cycle 1; prior review artifacts dated 2026-08-10T13-30 at head `f7711fb4`)

**Template source note:** The MCP `resolve_policy_audit_template_asset` tool is not available in this session; the template was read directly from the bundled asset `extensions/drm-copilot/resources/templates/policy_audit/code-review.yyyy-MM-ddTHH-mm.md`, the exact file the MCP resolver serves.

---

## Executive Summary

This re-review covers the full feature-vs-base diff (180 files, +13657/-166) with focused adjudication of the remediation cycle 1 delta (`f7711fb4..f8d82e1e`): the Bash allowlist narrowing (RI-2), the SC2015 suppression removal and eight-site rewrite (RI-3), the `.gitignore` anchoring (RI-4), the spec clause removal (RI-1), and the amended permission-surface disclosure artifact. The prior review found the feature ready; this review verifies the remediation changes did not regress that state and independently re-verifies each of the five items plus the six caller-designated judgment matters.

**What changed:** Cycle 1 touched 11 production/requirement files: three grant locations plus three bundled mirrors (RI-2), two pre-existing shell libraries (RI-3), `.gitignore` (RI-4), `spec.md` (RI-1), and the disclosure artifact. No parallel-surface schema file, validator, or enum was touched (AC17 re-proven across the full branch diff: `git diff --name-only a26286e8..HEAD` filtered for `scripts/dev_tools/` and `extensions/drm-copilot/src/lib/validate/` returns zero matches).

**Top 3 risks:**
1. Two genuinely untested error branches in `shell_qc_lib.sh` (`exit_code=$rc` at lines 352 and 363, reachable only when kcov itself exits non-zero) are now visible in the coverage report. Pre-existing behavior, newly measured; non-blocking (CR-1).
2. The three narrowed grants remain prefix wildcards, so a string suffix appended to the fixed filename (including a `/../` segment) still matches the pattern; POSIX ENOTDIR resolution prevents such a path from executing a different file, so the practical surface is trailing arguments only (CR-2, precision nit on the disclosure wording).
3. Shell verification remains CI-only from this environment; local shellcheck 0.11.0 cannot reproduce the CI SC2015 finding. Mitigated by the head-adjacent CI dispatch (run 31436071256) and the full CI run at the branch head (run 31436665265), both verified green by this reviewer via `gh run view`.

**PR readiness recommendation:** **Go** — all five remediation items delivered and verified; full-branch gates green at head; no Blocker, Major, or Minor findings that require action before merge.

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Info | `scripts/bash/shell_qc_lib.sh` | lines 352, 363 | The RI-3 line split exposed two untested error branches: `exit_code=$rc` after a non-zero `kcov` run and after a failed `kcov --merge`. Neither is exercised because no bats case forces the stubbed kcov to return non-zero. (CR-1) | Optional follow-up: add bats cases wiring a failing kcov stub through the `SHELL_QC_KCOV_BIN` seam to cover both branches. Out of scope for this feature; do not block merge. | Pre-existing untested behavior that the old one-line idiom mis-reported as covered; covering it would harden the coverage tool's own failure path. | Per-line hit-map diff in `evidence/qa-gates/shell-coverage-dispatch.2026-08-10T22-05.md`; sites verified against the current file by this reviewer. |
| Nit | `evidence/other/permission-surface-callout.2026-08-10T17-08.md` | "Scope of the pattern, stated precisely" | The claim that the trailing `*` "does not match a relative-traversal path" is exactly true for the example given (traversal *before* the filename) but is stated absolutely: a traversal segment appended *after* the fixed filename (e.g., `bash .claude/lib/bash/compute-cohorts.sh/../parallel-common.sh`) does match the string pattern. It cannot execute a different file — `compute-cohorts.sh` is a regular file, so `file/..` path resolution fails with ENOTDIR on POSIX systems — so the effective claim holds. (CR-2) | Optional wording refinement in a future revision: state that a post-filename traversal suffix matches the pattern string but is not resolvable/executable. No action required for merge. | Disclosure artifacts should be precise about the pattern-match surface versus the executable surface; the current text conflates the two in one clause while reaching the correct conclusion. | Reviewer analysis of the three grant patterns in `.claude/settings.json:8-10`; POSIX path-resolution semantics. |
| Info | `.gitignore` | lines 20, 22 | `git ls-files -ci --exclude-standard` reports two tracked files matching ignore rules (`.claude/settings.local.json`, `tests/fixtures/shell_qc/scripts/node_modules/skip_me.sh`). Both were tracked at the merge base and match rules unrelated to the anchored `lib/` rules; the RI-4 change introduced no tracking change. | None. Recorded so the pre-existing condition is not later misattributed to this branch. | Distinguishes the RI-4 anchoring's effect (none) from pre-existing tracked-but-ignore-matching files. | `git ls-files -ci --exclude-standard`; `git ls-tree a26286e8 --name-only` shows both files at the merge base. |

No Blockers, Major, or Minor findings.

---

## Implementation Audit

### Bash implementation audit

#### What changed well

- **RI-3 is a genuine simplification, verified semantically equivalent at all eight sites.** Diff inspection of `scripts/bash/shell_qc_lib.sh` (seven sites: discovery-root collection, bats-dir collection, three max-exit-code folds in `run_check`/`run_test`, two in `run_test_coverage`) and `scripts/bash/cleanup_worktrees_lib.sh` (one site in `run_report`) confirms every rewritten middle command is an array append (`roots+=("$root")`, `dirs+=("$candidate")`) or a scalar assignment (`exit_code=$rc`, `rc=$crc`). None of these can return non-zero, so the deleted `|| true` was never load-bearing — SC2015's hazard (the `C` branch running when `B` fails) was unreachable, and the `if` form preserves behavior exactly under `set -e` (a false `if` condition does not trigger errexit). The finding class is eliminated on every shellcheck version rather than suppressed.
- **The two load-bearing `|| true` sites were correctly preserved verbatim.** `shell_qc_lib.sh:267` tolerates grep's no-match exit inside a command substitution whose emptiness is then explicitly handled (`[[ -n $match ]] || return 1`), and `:369` makes the canonical-path copy of an already-merged report best-effort. Both are the `|| rc=$?`-family capture that `.claude/rules/shell.md` mandates for tools that legitimately return non-zero. Reviewer-verified: these are the only `|| true` occurrences remaining in either file, and zero `A && B || true` sites remain anywhere under `scripts/bash/` or `.claude/lib/bash/` (`grep -rnE '&&.*\|\| true'` → no matches).
- **The false justification text was removed with the suppressions.** The deleted comment blocks claimed `.claude/rules/shell.md` mandates the `A && B || true` idiom; it does not (it mandates `|| rc=$?` capture). Removing an inaccurate policy citation is itself a correctness improvement.
- The RI-3 edit left the Shell-QC contract intact: the discovery root list (`tools scripts .claude/lib/bash`) and the kcov include pattern are unchanged; only statement form changed.

#### API and safety notes

- No function signature, exported name, or emitted string changed in cycle 1. The bash library's public surface remains the three CLI entry points; the six libraries are sourced only (verified: the only `lib/bash` references outside entry-point invocations are shellcheck `source=` annotations and rule/skill prose).
- **Grant narrowing (RI-2) does not under-permit.** Every prescribed invocation across `.claude/skills/parallel-plan`, `parallel-orchestrate`, `parallel-add`, and both agent definitions names one of the three entry points and is covered by the matching prefix grant. The permission-contract pytest (`test_parallel_orchestrator_permission_contracts.py`) asserts uncovered = 0 against the live files; this reviewer re-ran it (green, within the 61/61 gate). No skill or agent invokes a sourceable library as a command.

#### Error handling and logging

- Entry points retain `set -euo pipefail`; error contracts (exact Python messages on stderr, exit 1) are unchanged and re-asserted by both parity lanes in the head-adjacent CI run.

### TypeScript implementation audit

- No TypeScript file changed in cycle 1. The prior review's assessment of `claude-routing-merge.ts` (308 lines, decorator-seam merge with idempotency and fail-fast) and `claude-customizations.ts` stands; re-confirmed by green CI at head and reviewer-parsed lcov (new file 98.05% lines / 87.50% branches; modified file 100% / 93.55%).

### Python implementation audit

- No Python file changed in cycle 1. The two parity suites are test-only additions; reviewer re-ran both plus the two contract modules: 119 passed, 5 skipped (fixtures deliberately declaring no accessor expectation — parametrization design, not disabled tests), 0.35s.

---

## Test Quality Audit

The remediation cycle added no production tests (correctly — RI-1 explicitly forbids adding a test for the removed unwritable clause) and added one executable gate: the RI-2 pytest contract run, which turns the allowlist narrowing into a regression-protected seam rather than a one-time diff check.

### Reviewed test and QA artifacts

- `evidence/qa-gates/ri2-pytest-gate.2026-08-10T22-08.md` — 61/61 contract tests at `f8d82e1e`; the permission seam (`uncovered = 0`) and the repo/bundle byte-parity contract both executable. Reviewer re-ran the same modules: green.
- `evidence/qa-gates/shell-coverage-dispatch.2026-08-10T22-05.md` — the authoritative RI-3 verification: CI's apt-packaged shellcheck (the version that emitted the original findings) passes with zero suppressions present; shfmt 3.8.0 accepts the expanded `if` form; 245 bats green; coverage 92.3% with a per-line hit-map analysis of the delta. High evidentiary quality: headSha equality recorded, digit-anchored grep documented against the usage-banner false-match trap.
- `evidence/qa-gates/allowlist-narrowing-verification.2026-08-10T21-50.md` — frontmatter parses, JSON assertions, and the repo-wide old-string sweep. Reviewer independently repeated the sweep (`git grep -n 'bash \.claude/lib/bash/\*)' -- ':!docs/features/**'` → zero matches).
- `evidence/qa-gates/gitignore-anchoring.2026-08-10T21-44.md` — check-ignore and status verification; the artifact correctly flags checks (a) and (c) as non-discriminating regression guards. Reviewer re-ran all three checks at head: five paths unignored (exit 1), positive controls match `/lib/` and `/lib64/`, working tree clean.
- `evidence/qa-gates/acceptance-criteria-recheck.2026-08-10T22-00.md` — per-criterion re-check of all 34 checkboxes with named evidence; spot-checked by this reviewer (AC12 root list, AC15 grants, AC17 scope filter) with no discrepancy.
- `evidence/qa-gates/shell-local-precheck.2026-08-10T21-55.md` — correctly labeled insufficient-alone (local shellcheck 0.11.0 cannot reproduce the CI finding); the discipline of recording the insufficiency in the artifact itself is good practice.

### Quality assessment prompts

- **Determinism:** All gates pin exact commands, SHAs, and run IDs; the coverage grep is digit-anchored against a documented placeholder-text trap; `LC_ALL=C` and `sort -n` guard the library's output ordering.
- **Isolation:** The RI-2 gate exercises exactly the files the narrowing touched; the CI dispatch batches all cycle-1 shell changes into one head-matched run.
- **Speed:** Contract subset 0.23s; parity subset 0.35s; CI shell job 3m18s.
- **Diagnostics:** Parity failures name the fixture and the diverging string; the permission contract names the uncovered invocation.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Diff inspection; grants, fixtures, and evidence artifacts contain no credentials. |
| No unsafe subprocess or command construction | ✅ PASS | Entry points parse `--flag value` arguments with strict token regexes (`-?[0-9]+`, leading-zero rejection); no `eval`; stubs resolved through the `SHELL_QC_<TOOL>_BIN` seam with `command -v`. |
| Permission surface narrowed, not widened | ✅ PASS | Single directory-crossing wildcard replaced by three fixed-filename prefix grants in all six locations; old pattern absent from all production surfaces; no existing grant broadened (the `poetry run` grants are unchanged). Residual surface: trailing arguments on three named scripts (intended), plus the theoretical post-filename suffix match neutralized by ENOTDIR resolution (CR-2). |
| Input validation at boundaries | ✅ PASS | Manifest validator fail-closed on constructs outside the YAML subset; `max_concurrency` boolean/int/bounds rejection with exact Python messages; routing merge fails fast on unparseable destination files without clobbering. |
| Error handling remains explicit | ✅ PASS | RI-3 removed no error handling — it removed a no-op guard; the two genuine tolerance sites are preserved with intent comments. |
| Configuration / path handling is safe | ✅ PASS | `.gitignore` anchoring scoped the build-artifact rules to the repo root; five formerly-negated paths verified unignored; no tracked file's status changed (Info finding above documents the two pre-existing entries). |

---

## Research Log

No external research was required. All adjudications rest on repository evidence: the branch diff, the feature evidence artifacts, live `gh` run/PR queries, on-disk lcov artifacts, and POSIX path-resolution semantics (for CR-2).

---

## Verdict

The remediation cycle delivered exactly what the five inputs directed, with no scope creep and no schema-surface contact. The RI-3 rewrite is semantically equivalent and lint-clean on the authoritative CI toolchain with zero suppressions; the RI-2 narrowing is byte-consistent across all six locations, executably verified against the prescribed invocation surface, and accurately disclosed (one wording nit, CR-2); the RI-4 anchoring changed no tracking outcome; the RI-1 edit removed an unwritable requirement rather than papering over it. The 0.163pp bash coverage delta is a measurement-fidelity effect, adjudicated PASS in `policy-audit.2026-08-10T22-21.md` Section 8 (G-1), with the two newly visible untested error branches recorded as optional follow-up (CR-1).

The change is ready for normal PR flow. **Go.**
