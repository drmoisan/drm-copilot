# Feature Audit: parallel-surface-destination-portability-bash (#462) — Remediation Cycle 1 Re-Audit

**Audit Date:** 2026-08-10
**Feature Folder:** `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462`
**Base Branch:** `main`
**Head Branch:** `drm-copilot-wt-2026-08-10T09-25` @ `8c12ea8c9b708ce04f0fdb0d63fcc5a1b1dad132`
**Work Mode:** `full-feature`
**Audit Type:** Post-remediation acceptance verification (cycle 1)

**Template source note:** The MCP `resolve_policy_audit_template_asset` tool is not available in this session; the template was read directly from the bundled asset `extensions/drm-copilot/resources/templates/policy_audit/feature-audit.yyyy-MM-ddTHH-mm.md`, the exact file the MCP resolver serves.

---

## Scope and Baseline

- **Base branch:** `main` (merge base `a26286e87137780ee9e5f59ba2753c2307617572`)
- **Head branch/commit:** `drm-copilot-wt-2026-08-10T09-25` (commit `8c12ea8c9b708ce04f0fdb0d63fcc5a1b1dad132`; PR #463 open against `main` at this head, reviewer-verified via `gh pr view 463`)
- **Merge base:** `a26286e87137780ee9e5f59ba2753c2307617572` (reviewer-verified via `git merge-base HEAD main`)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-08-10 22:14 UTC at the current head; treated as fresh)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt` (full range `a26286e8..8c12ea8c`, 180 files)
  - Feature evidence: `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/evidence/**` (baseline, remediation-baseline, qa-gates, regression-testing, other)
  - Additional evidence: live `gh` queries (runs 31436071256, 31436665265; PR #463); reviewer-executed pytest, grep, hash, and check-ignore commands recorded in `policy-audit.2026-08-10T22-21.md` Appendix B
- **Feature folder used:** `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462`
- **Requirements source:** `spec.md` and `user-story.md` (17 identical criteria each; `spec.md` lines 304-383, `user-story.md` lines 97-176)
- **Work mode resolution note:** Explicit marker `- Work Mode: full-feature` at `issue.md:10`; per the acceptance-criteria-tracking rules this selects `spec.md` and `user-story.md` as the authoritative AC sources. `issue.md`'s "Acceptance Criteria (early draft)" section is a historical pre-promotion seed and is not authoritative under this mode.
- **Scope note:** Full feature-vs-base audit at the branch head. This is a re-audit after remediation cycle 1 (`remediation-plan.2026-08-10T21-03.md`, RI-1 through RI-5, all tasks complete); the prior feature-audit (2026-08-10T13-30, at `f7711fb4`) evaluated all 17 criteria PASS. Shell-lane verification is CI-only from this environment per `.claude/rules/shell.md`; the last production commit is `f8d82e1e` (head-adjacent), with only evidence/documentation commits following it (reviewer-verified: `git diff --stat f8d82e1e..HEAD` shows 3 evidence/plan files).

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/spec.md` — primary source (`## Acceptance Criteria`, 17 checkbox items, all `[x]`)
- `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/user-story.md` — co-equal source (`## Acceptance Criteria`, 17 checkbox items, identical text and order, all `[x]`)

### Acceptance criteria

The 17 criteria are identical in both files; the AC1-AC17 numbering below is positional and applies to both. Text is faithfully condensed; the full wording is at the cited line ranges.

1. **AC1** — Bash cohort-computation entry point under `.claude/lib/bash/` produces, for every fixture in `tests/fixtures/parallel_cohorts/`, the same cohort partition (compact JSON, ascending inner lists, Welsh-Powell index assignment) and the same error messages as `scripts/dev_tools/parallel_cohort_computation.py`. Evidence: both parity suites green with fixture-count floors.
2. **AC2** — Bash `compute_concurrency_batches` entry point chunks a cohort into consecutive ascending slices of at most `max_concurrency` and rejects `max_concurrency < 1` with the exact Python error message.
3. **AC3** — Bash manifest-contract validator reproduces the M1-M7 error strings byte-for-byte (`Parallel manifest` prefix, Python `repr` quoting) for every fixture in `tests/fixtures/parallel_manifest_bash/`, with the documented M1 YAML-parse-failure prefix-parity exception.
4. **AC4** — The bash validator exposes default-resolving accessors for `mode` (default `closed`) and `max_concurrency` (default `4`) matching `manifest_mode` and `manifest_max_concurrency`.
5. **AC5** — Every new `.claude/lib/bash/` file has a byte-identical bundled mirror, asserted by a manifest-membership test.
6. **AC6** — The Claude push-down publishes `config/orchestration-routing.json` and `config/blast-radius.json`, including under pack-scoped publishes.
7. **AC7** — The routing-config publish merges with a pre-existing destination file: source-authoritative `parallel` route, absent routes added, destination-local routes preserved verbatim, byte-stable second push, fail-fast on unparseable destination.
8. **AC8** — The published `blast-radius.json` default contains no drm-copilot-only entries; this repository's root config is unchanged.
9. **AC9** — The Copilot and Codex push-down published sets are unchanged (Jest non-regression cases).
10. **AC10** — `core.json` lists `.claude/rules/parallel-orchestration.md`, every new `.claude/lib/bash/` path, and both config files.
11. **AC11** — `claude-pack-manifest-completeness.test.ts` enumerates `rules/*.md`, all of `lib/**` recursively, and the bundled `config/` tree.
12. **AC12** — Shell-QC discovery contract and kcov include pattern cover `.claude/lib/bash/**`; `.claude/rules/shell.md` prose updated; existing shell-qc bats tests extended.
13. **AC13** — shfmt, shellcheck, and bats pass on all new and modified shell files; bash line coverage >= 85%, evidenced by a green `_shell-coverage.yml` run with the coverage log line recorded under `evidence/qa-gates/`.
14. **AC14** — Destination-runtime references in the three parallel skills and two parallel agents invoke the bash entry points; no `poetry run` remains on the `/parallel-plan` destination-runtime path.
15. **AC15** — Bash allowlist entries permitting the `.claude/lib/bash` entry points are added to the two agent definitions and `.claude/settings.json`, and the PR identifies them as a deliberate permission-surface change.
16. **AC16** — A payload-only workspace with no Python and no Poetry clears all four reported blockers.
17. **AC17** — No parallel-surface schema field, enum member, or validator invariant is added, removed, or altered: the Python validators, `_parallel_state_*` helpers, and the TypeScript parity port are unchanged.

---

## Acceptance Criteria Evaluation

Statuses apply identically to both source files. "Cycle-1 impact" notes whether remediation cycle 1 touched the criterion's surface.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | Cohort entry point + corpus parity | PASS | 31 cohort fixtures asserted by `tests/shell/parallel_cohorts_parity.bats` (CI run 31436071256 green) and `test_parallel_cohort_bash_parity.py`; reviewer re-ran the pytest lane: green (within 119 passed, 0.35s) | `poetry run pytest tests/scripts/dev_tools/test_parallel_cohort_bash_parity.py -q` | Cycle-1 impact: none. |
| 2 | `compute_concurrency_batches` + exact rejection message | PASS | 9 batching fixtures (`batches_*.json`) including zero/negative concurrency error cases; both lanes green | same as AC1 | Cycle-1 impact: none. |
| 3 | Manifest validator M1-M7 byte parity (documented M1 exception) | PASS | 43 manifest fixtures asserted by both lanes; divergence classes declared in suite headers; reviewer re-ran the pytest lane: green | `poetry run pytest tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py -q` | Cycle-1 impact: none. The 5 pytest skips are fixtures deliberately declaring no accessor expectation. |
| 4 | Default-resolving accessors | PASS | `manifest_accessor_*.json` fixtures (present/absent/invalid); bats accessor cases green in CI | CI run 31436071256 | Cycle-1 impact: none. |
| 5 | Byte-identical bundled mirrors | PASS | Reviewer-computed SHA-256 for all nine `.claude/lib/bash/*.sh` files: all MATCH bundled counterparts; `parallel_bash_manifest_membership.bats` green in CI; `test_push_down_claude_resource_contracts.py` green (61/61 gate, reviewer re-run) | `sha256sum` pair comparison; `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | Cycle-1 impact: none to the library files. |
| 6 | Config carriage incl. pack-scoped | PASS | Jest `claude-config-carriage.test.ts` (15 cases) green; CI run 31436665265 green at head | `gh run view 31436665265 --json conclusion,headSha` | Cycle-1 impact: none. |
| 7 | Routing merge semantics | PASS | Jest cases for copy, merge, stale-`parallel` overwrite, local-route preservation, idempotency, fail-fast; green at head | same as AC6 | Cycle-1 impact: none. |
| 8 | Repo-agnostic published blast-radius default | PASS | Jest assertion on published content; root `config/blast-radius.json` absent from the branch diff (appendix name-status) | appendix inspection | Cycle-1 impact: none. |
| 9 | Copilot/Codex sets unchanged | PASS | Jest non-regression cases for both entry points; green at head | same as AC6 | Cycle-1 impact: none. |
| 10 | `core.json` completeness | PASS | `pack-manifests/core.json` diff adds the rules file, nine bash paths, both config files; completeness test green | same as AC6 | Cycle-1 impact: none. |
| 11 | Completeness-test enumeration extension | PASS | `claude-pack-manifest-completeness.test.ts` diff (+138 lines) extends enumeration to `rules/*.md`, `lib/**`, bundled `config/`; suite green | same as AC6 | Cycle-1 impact: none. |
| 12 | Shell-QC discovery + kcov reach | PASS | `shell_qc_lib.sh` discovery roots `tools scripts .claude/lib/bash` (line 85) and include pattern `$repo_root/.claude/lib/bash` (line 335) — reviewer-inspected post-RI-3; rule prose updated; discovery bats extended (counts 5→6) | Read of `scripts/bash/shell_qc_lib.sh:85,335`; CI coverage report enumerates the library | Cycle-1 impact: RI-3 rewrote the loop body form only; root list and include pattern unchanged. Re-verified. |
| 13 | Shell toolchain green + coverage >= 85% | PASS | Green `_shell-coverage.yml` run 31436071256 at `f8d82e1e` (the last production commit; headSha equality recorded): both verification steps green, `Bash coverage (lines): 92.3%` (exact 92.266%, 1348/1461); full CI green at head `8c12ea8c` (run 31436665265, reviewer-verified) | `gh run view 31436071256 --json conclusion,headSha`; `evidence/qa-gates/shell-coverage-dispatch.2026-08-10T22-05.md` | Cycle-1 impact: evidence superseded — the prior 92.4% run is now the baseline. The 0.163pp delta is adjudicated as measurement fidelity, not regression (policy-audit G-1); 7.27 points above the floor. |
| 14 | Destination-runtime wiring off poetry | PASS | All prescribed invocations in the three skills and two agents name the three bash entry points (reviewer grep); no `poetry run` on the `/parallel-plan` destination-runtime path | `git grep -n "bash .claude/lib/bash" -- '.claude/skills' '.claude/agents'` | Cycle-1 impact: RI-2 prose rewrites changed which allowlist entry is *named*; invocation examples unchanged. Re-verified. |
| 15 | Allowlist entries + PR disclosure | PASS | Three entry-point-specific grants in all six locations, byte-identical repo/bundle (reviewer-verified hashes); old wildcard absent from all production surfaces (reviewer sweep: zero matches outside historical feature-folder docs); amended disclosure artifact describes the delivered grant and residual scope; permission-contract pytest green (uncovered = 0) | `grep -n "lib/bash" .claude/settings.json`; `git grep -n 'bash \.claude/lib/bash/\*)' -- ':!docs/features/**'`; `sha256sum` pairs | Cycle-1 impact: this is RI-2's target. Satisfied more strongly than at the prior audit: narrower grant, accurate disclosure (one non-blocking wording nit, code-review CR-2). |
| 16 | Payload-only workspace clears the four blockers | PASS | `tests/shell/parallel_payload_only.bats` green in CI; the three granted entry points are exactly the scripts it invokes; Jest in-memory payload assertions green | CI runs above | Cycle-1 impact: narrowing removed grants only for the six sourceable libraries, which the payload-only case never invokes directly. |
| 17 | Schema freeze | PASS | `git diff --name-only a26286e8..HEAD \| grep -E "^(scripts/dev_tools/\|extensions/drm-copilot/src/lib/validate/)"` → zero matches (exit 1), executed by this reviewer over the **full branch diff**, not only the cycle-1 delta | command as cited | No schema field, enum member, or validator invariant touched anywhere on the branch. |

**RI-1 side-check (not an AC):** `grep -n "generation handling"` returns no match in `spec.md` and no match in `user-story.md` (reviewer-verified via the recheck artifact and the current file state); the seeded-test-conditions bullet now lists the five delivered scenarios and is checked. The phrase remains only in `issue.md`'s historical pre-promotion seed, which is not an AC source under `full-feature`.

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 17 criteria (× 2 source files = 34 checkbox items)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Recommended follow-up verification steps:**

1. Optional (non-blocking, code-review CR-1): add bats cases forcing a non-zero kcov exit through the `SHELL_QC_KCOV_BIN` seam to cover `shell_qc_lib.sh:352,363`.
2. Optional (non-blocking, code-review CR-2): refine the disclosure artifact's traversal wording in a future revision to distinguish pattern-string matching from executable path resolution.

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- All 17 criteria in `spec.md` and all 17 in `user-story.md` were already checked (`[x]`) before this audit (checked off at the original review pass on 2026-08-10 and re-confirmed after remediation cycle 1 by `evidence/qa-gates/acceptance-criteria-recheck.2026-08-10T22-00.md`).
- Every criterion evaluates PASS in this re-audit, so all existing check-offs remain valid. **No source-file checkbox change was made by this audit** — there is nothing to newly check off and nothing requiring un-checking.

### AC Status Summary

- Source: `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/spec.md` and `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/user-story.md`
- Total AC items: 34 (17 per file)
- Checked off (delivered): 34
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 17 | 17 | 0 | Checkbox-backed; authoritative under `full-feature` |
| `user-story.md` | 17 | 17 | 0 | Checkbox-backed; authoritative under `full-feature`; identical text and order |
