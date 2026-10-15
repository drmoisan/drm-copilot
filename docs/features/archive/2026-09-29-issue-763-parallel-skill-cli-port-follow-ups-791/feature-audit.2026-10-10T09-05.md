# Feature Audit: parallel-skill CLI port follow-ups (#791)

**Audit Date:** 2026-10-10
**Work Mode:** full-bug (from `issue.md` marker `- Work Mode: full-bug`)
**AC Source:** `docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/spec.md`, `## Acceptance Criteria` (AC-1..AC-21)

## Scope and Baseline

- Branch: `bug/issue-763-parallel-skill-cli-port-follow-ups-791` @ `a00195532`.
- Base: `origin/main` @ `7bbd0b9b9`; merge-base `7bbd0b9b9`. Scope is the full branch diff (96 files).
- Plan: `plan.2026-10-08T13-56.md`, 84 tasks checked, 0 unchecked.
- PR context: `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, generated at `c81ffad7e`; HEAD adds only one evidence document after that commit.
- CI evidence: run 38053315951 at `c81ffad7e`, conclusion success on all 17 jobs, confirmed by this review with `gh run view` (job list and conclusions), job logs (`1..592`, no `not ok` line, `Bash coverage (lines): 94.5%`, `Tests Passed: 6744, Failed: 0`, `Covered 87.31%`), and the downloaded `shell-coverage` artifact `cov.xml` (remove-parallel-item.sh 0.991, parallel-mutation.sh 0.957).
- Baseline CI: run 38019731256 at merge-base `7bbd0b9b9` (bats `1..544`, bash 94.2%, Pester 6743 passed, Covered 87.31%).
- Operator constraint: local bats and PowerShell runs were replaced by PoshQC MCP calls plus CI job logs. This is an operator decision and is not treated as a defect.

## Acceptance Criteria Inventory

| AC | Summary | Pre-review state |
|---|---|---|
| AC-1 | Shell-fence regression test, fail-before/pass-after | checked |
| AC-2 | Python-fence regression test, fail-before/pass-after | checked |
| AC-3 | Split-line negative test | checked |
| AC-4 | Pre-existing guard suites pass; guard <= 500 lines | checked |
| AC-5 | parallel-remove steps 2, 3, 6 invoke the entry script | checked |
| AC-6 | Real-repo extraction test for parallel-remove and parallel-plan | checked |
| AC-7 | Abandon token seam preserved; no `--disposition abandon` to remove script | checked |
| AC-8 | bats coverage of `decide` rows | unchecked (CI-deferred) |
| AC-9 | bats coverage of `recolor`, `entry`, CLI usage errors | unchecked (CI-deferred) |
| AC-10 | Two parity lanes over one corpus with floors | unchecked (CI-deferred) |
| AC-11 | New bash files: size, no Python, shell-qc, mirrors, manifest, membership bats | unchecked (CI-deferred) |
| AC-12 | Payload-only case with restricted PATH | unchecked (CI-deferred) |
| AC-13 | Pester R791-O1 and abandon-gate suites pass | unchecked (CI-deferred) |
| AC-14 | Bundle guard real-repo tests pass | checked |
| AC-15 | Settings allow entries, no wildcard, mirror identical | checked |
| AC-16 | Agent grants and prose, mirror identical | checked |
| AC-17 | Python toolchain loop and coverage | checked |
| AC-18 | Bash toolchain in CI; kcov >= 85% for both new files | unchecked (CI-deferred) |
| AC-19 | No temp files or wall-clock waits in tests | checked |
| AC-20 | D5 follow-ups recorded | checked |
| AC-21 | Hook precedence evidence before permission edits | checked |

## Acceptance Criteria Evaluation

| AC | Verdict | Evidence |
|---|---|---|
| AC-1 | PASS | `test_extract_reads_invocation_on_first_line_of_shell_fence` parametrized over fence `bash`/`sh` and verb `bash`/`sh`/`source`; `fail-before.2026-10-10T08-16.md` shows the 6 cases failing with `got ()`; `pass-after-guard-fix.2026-10-10T08-21.md`; re-run by this review (135 passed). |
| AC-2 | PASS | `test_extract_reads_python_invocation_on_first_line_of_python_fence`; fail-before `AssertionError: Got ()`; passes now. |
| AC-3 | PASS | `test_extract_ignores_verb_and_path_split_across_lines` asserts `()`; fail-before showed the old pattern returned the path. |
| AC-4 | PASS | `test_skill_bundle_contract_evaluation.py`, `_cli.py`, `test_parallel_abandon_token_seam.py` have no diff on the branch; all five suites passed in this review's run; `skill_bundle_contract.py` is 486 lines. |
| AC-5 | PASS | Diff of `parallel-remove/SKILL.md`: steps 2, 3, 6 each contain `bash .claude/lib/bash/remove-parallel-item.sh decide|recolor|entry`; the function names are absent; the module is named once as "retained as the parity reference ... not invoked on this path". |
| AC-6 | PASS | `test_parallel_plan_extracts_compute_cohorts_under_bash_fence` and `test_parallel_remove_invokes_bundled_remove_script` pass. |
| AC-7 | PASS | Grep for `--disposition[ =]abandon` across changed files returned only pre-existing lines for `abandon-parallel-item.sh` (SKILL.md:52, :123; payload bats:149); none for `remove-parallel-item.sh`. `test_parallel_abandon_token_seam.py` passes. |
| AC-8 | PASS | `parallel_mutation_remove.bats` has a case for each listed decide row (four unstarted states, detach, abandon, no disposition, withdrawn, blocked, merged, omitted `--state`, disposition on unstarted, out-of-enum state, out-of-enum disposition), each asserting status and exact line or usage prefix. CI: 592 ok, 0 not ok (first case `ok 178`). |
| AC-9 | PASS | Cases present for empty set, no pinned edge, pinned edge offset, overlap, negative cohort, duplicate key, malformed edge and key; entry recompute true/false, in-flight with and without disposition, disposition on non-in-flight, negative generation, non-positive key, explicit `--at`, default `--at` format; CLI missing/unknown subcommand, unknown option, abbreviation. All pass in CI. |
| AC-10 | PASS | Both lanes read `tests/fixtures/parallel_mutation_remove/*.json` (15 fixtures); floor 15 in both; bats also asserts `checked >= floor`; Python asserts success and rejection per subcommand; divergences listed in script headers and both lanes. CI cases 221-223 ok; Python lane passed in this review's run. |
| AC-11 | PASS | 318 and 251 lines; no Python invocation; `cmp` identical to bundled copies; both in `core.json`; CI `shell-qc.sh check` success; membership case `ok 23 the six CLI entry points are present in both trees`. |
| AC-12 | PASS | `run_payload` uses `env -i PATH=tests/fixtures/parallel_payload_path` against the bundled copy with explicit `--at`; CI `ok 238` and `ok 239`. |
| AC-13 | PASS | R791-O1 asserts `allow` and out-of-scope for the exact command; CI `pester-junit.xml` reports it `Passed`; PowerShell QC Failed 0 and Linux hook suites Failed 0. |
| AC-14 | PASS | Both named tests in `test_skill_bundle_contract_repo.py` passed in this review's run. |
| AC-15 | PASS | Diff shows both entries in alphabetical position; no library wildcard; `cmp` identical; `test_push_down_claude_resource_contracts.py` passed. |
| AC-16 | PASS | `-m` grant removed, `-c` grant retained, remove-script grant added; prose states the #791 removal and the reason the `-c` grant remains; `cmp` identical; `test_parallel_orchestrator_surface_contracts.py` passed. |
| AC-17 | PASS | black, ruff, pyright clean (re-run check-only); `skill_bundle_contract.py` 96.45% lines, 95.00% branches, identical missing-line set before and after. |
| AC-18 | PASS | CI shell-coverage job success including `check` and `test --coverage`; kcov 99.1% (remove-parallel-item.sh) and 95.7% (parallel-mutation.sh), re-read from the downloaded `cov.xml`. |
| AC-19 | PASS | Grep over the eight changed test files found no temp-file or sleep usage. |
| AC-20 | PASS | `follow-ups.md` FU-791-1 cites `parallel-add` 99,106,148, `parallel-close` 49,55,65, `parallel-orchestrate` 634,789,797 (with current line numbers), and FU-791-2 cites `_parallel_mutation_errors.py:192`. |
| AC-21 | PASS | `evidence/other/hook-precedence-verification.2026-10-10T08-36.md` quotes both passages with URL, section, fetch date, cites hook lines 273 and 353, and ends `Finding: deny overrides allow: yes`. It was committed in `3e6a2545f` (08:35:50), before the permission edits in `e0e8dee1a` (08:37:39). |

## Summary

All 21 acceptance criteria evaluate as PASS. The seven criteria that were CI-deferred during execution (AC-8 to AC-13, AC-18) are satisfied by CI run 38053315951, whose results this review confirmed directly from the run metadata, job logs, and the coverage artifact rather than relying only on the executor's evidence document. No blocking finding exists, so no remediation-inputs artifact is produced.

Non-blocking items, recorded for visibility:
- Operator-accepted residual risks: a timed-out PreToolUse hook does not block, so the new abandon allow entry could skip a prompt in that case; plugin approval behavior can approve a hook-blocked call. Both are accepted in `spec.md` Risks & Mitigations.
- Code-review observations CR Low/Info (64-bit integer range not declared as a divergence; library relies on caller-side integer validation) are suitable for the FU-791-1 follow-up.

## Acceptance Criteria Check-off

Newly checked off in `spec.md` by this review (only `- [ ]` changed to `- [x]`): AC-8, AC-9, AC-10, AC-11, AC-12, AC-13, AC-18.

### Acceptance Criteria Status
- Source: `docs/features/active/2026-09-29-issue-763-parallel-skill-cli-port-follow-ups-791/spec.md`
- Total AC items: 21
- Checked off (delivered): 21
- Remaining (unchecked): 0
- Items remaining: none
