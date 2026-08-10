# Feature Audit: parallel-surface-destination-portability-bash (#462)

**Audit Date:** 2026-08-10
**Feature Folder:** `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462`
**Base Branch:** `main`
**Head Branch:** `drm-copilot-wt-2026-08-10T09-25` @ `aec5e539338851b5e6c1eb2eb347dd897fecd683`
**Work Mode:** `full-feature`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `main` (resolved `origin/main` @ `a26286e87137780ee9e5f59ba2753c2307617572`)
- **Head branch/commit:** `drm-copilot-wt-2026-08-10T09-25` (commit `aec5e539338851b5e6c1eb2eb347dd897fecd683`)
- **Merge base:** `a26286e87137780ee9e5f59ba2753c2307617572` (equal to the base tip; the branch is not behind `main`)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt`
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/evidence/**` (22 artifacts: 5 baseline, 17 qa-gates, 1 regression-testing, 1 other)
  - Additional evidence: re-execution at head by this review (pytest 3774 pass; Jest 2495 pass; Black/Ruff/Pyright/tsc/ESLint clean; lcov totals re-derived) and `gh run view 31411775305` (headSha == branch head, conclusion success, `Bash coverage (lines): 92.4%`)
- **Feature folder used:** the single active folder whose suffix matches issue 462.
- **Requirements source:** `spec.md` and `user-story.md` (both carry the same 17 checkbox criteria; tracked independently).
- **Work mode resolution note:** `issue.md` line 10 carries the explicit marker `- Work Mode: full-feature`, so per the acceptance-criteria-tracking rules both `spec.md` and `user-story.md` are authoritative AC sources.
- **Scope note:** working tree clean at head; PR context was refreshed against `main` at 2026-08-10 17:06 UTC and matches the current head SHA, so no regeneration was required. The audit scope is the full branch diff (164 files), not any plan or task subset.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `spec.md` — primary source (`## Acceptance Criteria`, 17 checkbox items)
- `user-story.md` — co-equal source (`## Acceptance Criteria`, the same 17 items verbatim)

### Acceptance criteria (abbreviated labels; full text in the source files)

1. AC1 — Bash cohort-computation entry point under `.claude/lib/bash/`; identical partition and error messages to `parallel_cohort_computation.py` for every fixture in `tests/fixtures/parallel_cohorts/`; both parity suites green with a fixture-count floor.
2. AC2 — Bash `compute_concurrency_batches` entry point; consecutive ascending slices of at most `max_concurrency`; exact Python rejection message for `max_concurrency < 1`; batching fixtures asserted by both suites.
3. AC3 — Bash manifest-contract validator reproducing the M1–M7 error strings byte-for-byte (context prefix, Python `repr` quoting) for every fixture in `tests/fixtures/parallel_manifest_bash/`, with the single documented M1 YAML-parse-failure prefix-scoped exception recorded in the suite headers.
4. AC4 — Default-resolving accessors for `mode` (default `closed`) and `max_concurrency` (default `4`) matching `manifest_mode` / `manifest_max_concurrency`; bats cases for present, absent, and invalid values.
5. AC5 — Every new `.claude/lib/bash/` file has a byte-identical bundled mirror; manifest-membership test asserts a `core.json` entry and bundled counterpart per file.
6. AC6 — Claude push-down publishes `config/orchestration-routing.json` and `config/blast-radius.json`, including under pack-scoped publishes; Jest cases against the service-call path.
7. AC7 — Routing publish merges with a pre-existing destination file: source-authoritative `parallel` route, absent source routes added, destination-local routes preserved verbatim, byte-stable second push, fail-fast on unparseable destination without overwrite.
8. AC8 — Published `blast-radius.json` default contains no drm-copilot-only entries; repo-root `config/blast-radius.json` unchanged.
9. AC9 — Copilot and Codex push-down published sets unchanged; Jest non-regression cases for both entry points.
10. AC10 — `core.json` lists `.claude/rules/parallel-orchestration.md`, every new `.claude/lib/bash/` path, and both config files.
11. AC11 — `claude-pack-manifest-completeness.test.ts` enumerates `rules/*.md`, all of `lib/**` recursively, and the bundled `config/` tree.
12. AC12 — Shell-QC discovery contract and kcov include pattern cover `.claude/lib/bash/**`; `.claude/rules/shell.md` prose updated; existing shell-qc bats tests extended.
13. AC13 — shfmt, shellcheck, and bats pass on all new and modified shell files; bash line coverage >= 85%; green `_shell-coverage.yml` run against the branch head with run URL, conclusion, and printed coverage line recorded under `evidence/qa-gates/`.
14. AC14 — Destination-runtime references in the three parallel skills and two parallel agents invoke the bash entry points (blast-radius via the existing PowerShell port); Python modules cited only as authority/parity reference; no `poetry run` on the `/parallel-plan` destination-runtime path.
15. AC15 — Bash allowlist entries for the `.claude/lib/bash` entry points added to `parallel-planner.md`, `parallel-orchestrator.md`, and `.claude/settings.json`; PR identifies them as a deliberate permission-surface change.
16. AC16 — A payload-only workspace with no Python and no Poetry clears all four reported blockers; Jest payload-content assertions plus an `ubuntu-latest` bats case invoking the published entry points from a payload-only directory.
17. AC17 — No parallel-surface schema field, enum member, or validator invariant added, removed, or altered; Python validators, `_parallel_state_*` helpers, and the TypeScript parity port unchanged.

---

## Acceptance Criteria Evaluation

Evaluations apply identically to both source files. Evidence cited below was independently inspected or re-executed by this review; executor evidence artifacts are cited where they were corroborated.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| 1 | AC1 cohort entry point + parity | PASS | 30-fixture corpus on disk (floor 20); pytest suite re-run green at head (31 cases within the 3774-pass run); `parallel_cohorts_parity.bats` green in CI run 31411775305 at head | `poetry run pytest tests/scripts/dev_tools/test_parallel_cohort_bash_parity.py -q`; `gh run view 31411775305 --json headSha,conclusion` | Both lanes enforce the floor and re-assert the checked count after iteration. |
| 2 | AC2 batching entry point | PASS | 9 batching fixtures incl. `batches_error_zero_concurrency` and `batches_error_negative_concurrency` pinning exact messages; `compute-concurrency-batches.sh` present in repo and bundle | fixture inspection; `diff -r .claude/lib/bash <bundle>` | Exact-message parity asserted in both lanes. |
| 3 | AC3 manifest validator byte parity | PASS | 43-fixture corpus (floor 24) spanning M1–M7; pytest manifest suite green at head (83 cases, 5 documented skips); bats parity loop asserts byte equality with the single `M1_YAML_PARSE` prefix-scoped fixture; identical divergence statement in all four suite headers | `poetry run pytest tests/scripts/dev_tools/test_parallel_manifest_bash_parity.py -q`; read of the four suite headers | The scoped M1 exception is exactly the one the criterion text documents. |
| 4 | AC4 default-resolving accessors | PASS | `pm_manifest_mode` / `pm_manifest_max_concurrency` asserted in `parallel_manifest_parity.bats` per fixture and in `parallel_manifest_validate.bats` for present/absent/invalid cases (incl. boolean and out-of-range caps) | read of both bats suites; fixture files `manifest_accessor_*.json`, `manifest_m3_*`, `manifest_m4_*` | Defaults `closed`/`4` match the Python accessors. |
| 5 | AC5 byte-identical bundled mirrors | PASS | Re-verified directly: `diff -r` of the nine-file directory against the bundled mirror is clean; `parallel_bash_manifest_membership.bats` (nine-file floor, reverse-direction check) green in CI at head | `diff -r .claude/lib/bash extensions/drm-copilot/resources/claude-customizations/.claude/lib/bash` | Also re-verified the seven modified `.claude/**` text files are byte-identical to their mirrors via `cmp`. |
| 6 | AC6 config publish incl. pack-scoped | PASS | `claude-config-carriage.test.ts` covers plain and pack-scoped publish and the three-copy byte pin; suite green in the 2495-pass Jest run re-executed at head | `npm --prefix extensions/drm-copilot run test:coverage` | `ROOT_FOLDERS` now `[".claude", "config"]` with the enumeration-order contract documented. |
| 7 | AC7 routing merge semantics | PASS | Six dedicated Jest behaviors: absent-destination copy, merge, stale-`parallel` overwrite, local-route preservation, idempotency (byte-stable second push), fail-fast without overwrite; implementation reviewed (`mergeRoutingDocuments`, `RoutingMergeFileSystem`) | Jest run at head; read of `claude-routing-merge.ts` | Merge confined to one destination-relative path via a decorator; engine untouched. |
| 8 | AC8 generic blast-radius default | PASS | Bundled default inspected: `shared_surfaces` limited to the three payload-guaranteed paths, empty `shared_surface_globs`, modules `claude-runtime`/`config`/`docs`/`tests`, `over_breadth_fraction` 0.25; repo-root `config/blast-radius.json` has zero diff lines | `git diff --name-only a26286e8..aec5e539 -- config/` (empty); read of the bundled default | Jest additionally asserts the published content contains no drm-copilot-only roots. |
| 9 | AC9 Copilot/Codex sets unchanged | PASS | Jest non-regression cases assert neither entry publishes a `config/` file and their `ROOT_FOLDERS` are unchanged; no Copilot/Codex source file appears in the diff | diff file list inspection; Jest run at head | The `ROOT_FOLDERS` constant is Claude-entry-local. |
| 10 | AC10 core.json completeness | PASS | Diff shows exactly the 13 required additions: the parallel-orchestration rule, `shell.md`, all nine bash files, and both config paths | `git diff a26286e8..aec5e539 -- .../pack-manifests/core.json` | `shell.md` was additionally required because its prose changed and it must publish consistently. |
| 11 | AC11 completeness-test enumeration | PASS | `claude-pack-manifest-completeness.test.ts` extended (+138 lines) with recursive `lib/**`, `rules/*.md`, and bundled `config/` walks behind a two-file floor; suite green at head; executor evidence records a non-vacuity probe (removing a config file failed two cases) | Jest run at head; read of the test diff | Closes the blocker-4 omission class. |
| 12 | AC12 Shell-QC reach | PASS | Third search root and third kcov include root in `shell_qc_lib.sh` (lines 91, 332); `.claude/rules/shell.md` Discovery Contract and Coverage Expectations prose updated and byte-mirrored; discovery bats extended to count 6 with `.claude/lib/bash/lib_entry.sh` pinned first; commands bats shellcheck-call count updated to 6 | read of both diffs; `cmp` of shell.md against its mirror | The checked-in fixture route required the `.gitignore` negation, verified effective. |
| 13 | AC13 shell toolchain green at head, coverage >= 85% | PASS | Independently re-derived: run 31411775305 (`Shell Coverage (reusable)`) headSha `aec5e539...` equals the branch head, conclusion `success`, log prints `Bash coverage (lines): 92.4%`; both workflow steps green; evidence artifacts under `evidence/qa-gates/` record the run chain | `gh run view 31411775305 --json headSha,conclusion,url`; `gh run view 31411775305 --log \| grep "Bash coverage"` | 92.4% >= 85%. Any further commit to the branch invalidates this discharge (see the evidence artifact's caveat). |
| 14 | AC14 destination-runtime wiring | PASS | `git grep "poetry run"` over the parallel skills/agents: zero invocations on the `/parallel-plan` path (the two `parallel-orchestrate` residuals are the documented repository-local checkpoint-validator fallback and drift CLI, both recorded with dispositions in `evidence/qa-gates/poetry-grep.2026-08-10T17-05.md`); `parallel-plan` references the bash entry points 6 times; `parallel-add` repoints the contention relation at the PowerShell port | `grep -rn "poetry run" .claude/skills/parallel-* .claude/agents/parallel-*`; `grep -c ".claude/lib/bash" <skills>` | Python modules are cited as authority/parity reference only, matching the criterion text. |
| 15 | AC15 allowlist entries + PR callout | PASS | `Bash(bash .claude/lib/bash/*)` present in `.claude/settings.json:8` and both agent `tools:` lists, byte-mirrored into the bundle (verified by `cmp`); verbatim PR-description text prepared at `evidence/other/permission-surface-callout.2026-08-10T17-08.md` | diff inspection; `cmp` of the three files against mirrors | The callout exists and is adequate in substance; two of its narrowness claims need correction before pasting into the PR body (code-review Finding 1). The criterion requires the PR to identify the change, which the prepared callout accomplishes; final discharge occurs at PR authoring. |
| 16 | AC16 payload-only workspace clears the four blockers | PASS | `parallel_payload_only.bats` runs all three entry points from the bundle root under a PATH exposing only four checked-in shims (`cat`, `cut`, `dirname`, `sort`) and positively asserts `python`, `python3`, `poetry` unreachable — green in CI at head; Jest payload-content case asserts the rule file, the three entry points, and both config files are published | read of the bats suite; CI run 31411775305; Jest run at head | Covers blockers 1–4: cohorts reachable, manifest validation reachable, config published, rule file in the manifest. |
| 17 | AC17 schema freeze | PASS (verified against the diff) | `git diff --name-only a26286e8..aec5e539 -- scripts/dev_tools/ extensions/drm-copilot/src/lib/validate/ config/ .claude/rules/parallel-orchestration.md packages/` returns zero paths against a 164-file diff — independently re-run by this review, not taken from the executor's `schema-freeze` artifact | the command cited | Broader filter than the executor's (adds all of `scripts/dev_tools/`, the rules file, repo `config/`, and `packages/`); still empty. The nine enums are consumed as literals in `parallel-common.sh`, never extended. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 17 criteria (in each of the two authoritative source files)
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 0 criteria
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None.

**Non-AC observations (do not affect the verdict):**

1. The spec's `## Seeded Test Conditions` bullet ending "and generation handling" is deliberately unchecked. Independent assessment upholds the executor's reasoning: `compute_cohorts` accepts no generation input — the Python authority documents `generation` as caller-owned state the library never produces, increments, or accepts, and the bash port mirrors that contract — so the clause has no testable library boundary. The other five clauses of the bullet are delivered by named fixtures. Seeded conditions are pre-design notes, not acceptance criteria.
2. Two Minor and one Nit code-quality findings are recorded in `code-review.2026-08-10T13-30.md`; none is a delivery gap against any criterion.

**Recommended follow-up verification steps:**

1. At PR authoring, paste the permission-surface callout with the two narrowness sentences corrected (code-review Finding 1), and curate the autoclose list (drop `#ISO-8601`; confirm whether #393/#394 genuinely close).
2. If any commit is added to this branch after `aec5e539`, dispatch one fresh `_shell-coverage.yml` run and confirm `headSha` equality and `success` before merge (AC13 strict-equality caveat).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if not already checked.
- All 17 criteria in `spec.md` and all 17 in `user-story.md` were already checked (`[x]`) by the executor at commit `ec226b2b`, with per-criterion evidence recorded in `evidence/qa-gates/acceptance-criteria-checkoff.2026-08-10T17-02.md`. This review independently re-evaluated each criterion and reached PASS on all 17, so the existing check-offs stand; no source-file edit was required or made by this review.

### AC Status Summary

- Source: `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/spec.md` and `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/user-story.md`
- Total AC items: 17 (per file; 34 tracked check-offs across the two files)
- Checked off (delivered): 17 (per file)
- Remaining (unchecked): 0
- Items remaining: None.

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `spec.md` | 17 | 17 | 0 | Checkbox-backed; check-offs pre-existing and independently re-verified |
| `user-story.md` | 17 | 17 | 0 | Checkbox-backed; mirrors spec.md verbatim; independently re-verified |

No source-file checkbox change was made by this review because every PASS criterion was already checked; the review's contribution is the independent re-verification recorded in the evaluation table above.
