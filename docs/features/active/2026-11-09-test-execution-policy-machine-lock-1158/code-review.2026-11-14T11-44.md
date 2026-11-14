# Code Review: Test-execution policy and machine test-suite lock (#1158)

---

**Review Date:** 2026-11-14
**Reviewer:** feature-review agent
**Feature Folder:** `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158`
**Feature Folder Selection Rule:** the only feature folder carrying issue #1158; no version subfolder
**Base Branch:** `main` (merge base `add7d747886ce893356b63de2941435f2895b345`)
**Head Branch:** `feature/test-execution-policy-machine-lock-1158` at `c03f350da362989a3eb4b2153ec9cff5fef45447` (no pull request yet)
**Review Type:** First feature review (S7); scope is the full branch diff

---

## Executive Summary

The branch introduces a test-execution policy with three behavior changes by design: local runs exclude the integration and golden lanes, at most one test suite runs per machine (per user) under an OS advisory file lock, and suites run only through a recognizable launcher. The change set is 334 files: five hook helper files with Claude and Codex twins and bundle copies, the launcher (`Invoke-TestSuite.ps1`, `run-test-suite.sh`, `Invoke-PesterSuite.ps1`) in four locations, PoshQC lane-exclusion parameters and MCP template lock branches, launcher routing in seven Python modules and the VS Code tasks, registry membership in the four `pretooluse-dispatch.json` copies, skill and agent text across the Claude, Codex, `.agents` and Copilot surfaces, ledger entry `0012`, and tests. Evidence reviewed: the PR context at the reviewed head, all final QA records, the coverage artifacts parsed directly, the Pester JUnit, a real-process probe of the hook with 39 payloads, and `check_quality_tiers` at the reviewed head.

The implementation is cohesive, well seamed and well tested. The hook's command-form normalization is broad: every specified prefix, launch, wrapper, chained and quoted form tested by the probe was denied, and none of the benign controls was denied. Two documentation defects block merge: agent and skill instructions still direct `poetry run pytest` directly, which the new hook denies, and the user-story registration criterion was not aligned with spec decision D31.

**What changed:**
New pure modules (`test-execution-policy.ps1`, `test-execution-lock-decision.ps1`, `test-execution-command-form.ps1`), the I/O adapter `test-execution-lock.ps1`, the hook entry `enforce-test-execution-policy.ps1`, the launcher scripts, `config/test-execution-policy.json`, `integration` and `golden` pytest markers, `-ExcludeTag`/`-ExcludeTestFileSuffix` in PoshQC, and `classify_launcher_exit` handling in the Python QC paths.

**Top 3 risks:**
1. Agents following the atomic-executor toolchain list or the `python-qa-gate` toolchain loop issue a command the hook denies (F1). The deny reason names the launcher, so the cost is a wasted tool call per occurrence, but the instructions contradict the policy.
2. The hook is a policy-level control: unspecified forms (`watch`, `ionice`, `pnpm`, `yarn`, `make`, `tox`, `nox`) pass. The spec discloses the policy-level scope.
3. Linux CI results for the hook suites and the CI integration lanes are pending; no pull request exists yet.

**PR readiness recommendation:** **Needs Revision** — two blocking documentation findings (F1, F2).

---

## Findings Table

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocker | `.claude/agents/atomic-executor.md` | `## Toolchain Commands`, line 81 (also `extensions/drm-copilot/resources/claude-customizations/.claude/agents/atomic-executor.md` line 81 and `.codex/agents/atomic-executor*.toml` line 92, six files); `.claude/skills/python-qa-gate/SKILL.md` line 33 (also `.agents/skills/python-qa-gate/SKILL.md` line 33 and the bundle copies) | F1: the Python toolchain line still lists `poetry run pytest -n auto`, and `python-qa-gate` step 4 still reads `poetry run pytest -n auto --cov-branch --cov-report=term-missing --cov`. The same branch removed `Bash(poetry run pytest *)` from the executor allowlist, changed the TypeScript line of the same list to the launcher, and added a `python-qa-gate` paragraph (line 81) stating that the pytest gate runs through the launcher. The hook denies the listed command. | Replace both commands with `env -u VIRTUAL_ENV sh .claude/skills/test-execution-policy/scripts/run-test-suite.sh pytest` (with the coverage extras for step 4) in every copy, regenerate the Codex variants, and regenerate the process-reduction ledger records whose regions contain these lines (entry `0001` stored patch). | The instructions contradict the policy the branch introduces and the executor's own tool allowlist; spec AC5 requires the skills to describe the launcher route. OD-8 directs related findings to be fixed inside the item. | Reviewer real-process probe: `env -u VIRTUAL_ENV poetry -C /abs/wt run pytest -n auto` and `poetry run python -m pytest -q` are denied with `TEST_EXECUTION_POLICY_BLOCKED: test suites run only through the test-execution launcher`. `git diff add7d7478..HEAD -- .claude/agents/atomic-executor.md` changes lines 14, 18 and 82 but not 81. `docs/engineering/process-reductions/patches/0001-parallel-only-test-gates.patch` contains both lines. |
| Blocker | `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/user-story.md` | line 66 (Repository owner, AC4) | F2: the criterion requires registration "as a standalone entry in the Bash group and in an MCP group ... in `.claude/settings.json`, `.codex/config.toml`, and their bundle copies". After #1159 merged, the hook is a member of the four `pretooluse-dispatch.json` registries (spec D31 branch B), and `.claude/settings.json` holds only the dispatcher entry. Spec AC4 line 335 carries the D31 alternative; the user story does not. The item is unchecked. | A planner revision aligns the user-story wording with spec D31 (registry membership, timeout sum), then the item is checked off against the existing Registration test evidence. | The criterion cannot be checked off as worded, and reviewers and executors may not edit AC text. The delivered registration meets the spec's decided intent. | `.claude/hooks/pretooluse-dispatch.json` group whose matcher names Bash and the two PoshQC MCP test tools; `.codex/hooks/pretooluse-dispatch.json` member with `timeout` 30; `.codex/config.toml` dispatcher `timeout` 690 to 720; `test-execution-policy.Registration.Tests.ps1` 19 cases, 0 failures in `artifacts/pester/pester-junit.xml`; `self-review.2026-11-14T11-28.md` row "AC4 item (user story, registration)". |
| Minor | `docs/features/active/2026-11-09-test-execution-policy-machine-lock-1158/spec.md` | line 343 (AC5) | The checked criterion names `docs/engineering/process-reductions/0011-local-lane-exclusion.md`; the delivered entry is `0012-local-lane-exclusion.md` because #1167 took `0011`. | Correct the entry number in the same planner revision as F2. | Plan task P6-T9 authorizes the renumbering, so the delivery is correct; only the criterion text is stale. | `docs/engineering/process-reductions/0012-local-lane-exclusion.md` in the diff; plan line 141. |
| Info | `.claude/hooks/test-execution-command-form.ps1` | `$script:TestExecutionPrefixTable`, `Get-TestExecutionRunnerMatch` | Unspecified prefixes and runners pass: `watch -n 5 pytest`, `ionice -c3 pytest`, `pnpm test`, `yarn test`, `make test`, `tox`, `nox -s tests`. | No change required for this item. Consider adding `watch` and `ionice` to the prefix table, and package-manager script forms, if agents are observed using them. | The spec lists the prefix and runner words explicitly and discloses that the hook is a policy-level control. | Reviewer real-process probe of the worktree hook. |
| Info | `extensions/drm-copilot/resources/templates/run-poshqc-test.ps1` | whole file | The MCP test template gained a lock branch but is outside the Pester coverage roots, so its new lines are not in the coverage denominator. The suite template is measured through its byte-identical copy `scripts/dev-tools/run-poshqc-suite.ps1` (91.07%). | No change required for this item; the coverage-root configuration predates the branch. `PoshQC.McpTemplateLock.Tests.ps1` exercises both templates (24 cases). | Coverage-root scope is a repository configuration matter, not introduced by this branch. | `artifacts/pester/powershell-coverage.xml` has no entry for the template path. |
| Info | `.claude/skills/test-execution-policy/scripts/Invoke-TestSuite.ps1` | built-in `pytest` suite (`poetry run pytest -n auto`) | The launcher inherits the caller environment; a caller that does not unset `VIRTUAL_ENV` runs pytest in the caller's virtual environment. | No change required; the skills and the hook hint name `env -u VIRTUAL_ENV sh ...run-test-suite.sh pytest`. | The repository convention places the `env -u VIRTUAL_ENV` prefix on the caller. | `.claude/skills/python-qa-gate/SKILL.md` line 81; `feature-review-workflow` line 118. |

---

## Implementation Audit

### Python implementation audit (if applicable)

#### What changed well
- `classify_launcher_exit` maps exit 75 and exit 2 with a `TEST_EXECUTION_POLICY_BLOCKED:` first line to launcher outcomes before any early return (D28); a pytest exit 2 without that line keeps its earlier handling.
- `run_fix_all` holds one shared `suite_lock` around the four launcher test steps, so a single run never starts two suites at once; the static steps still run concurrently.
- `FULL_TS_TEST` and the TypeScript branch use the launcher `jest` suite; `--coverage` replaces `test:unit:coverage`, which runs the same `node run-jest.cjs --coverage` at the root.

#### Typing and API notes
- New keyword parameters default to `None`, so existing callers are unchanged; pyright is clean.

#### Error handling and logging
- `QCRunner.run_full_loop` raises `RuntimeError` with the launcher message only for the `pytest` and `test-unit` steps; other failures return unchanged to the fix-prompt path.

### TypeScript implementation audit (if applicable)

#### What changed well
- N/A: no TypeScript file in the branch diff. The extension Jest suite ran as a regression gate (5616 passed).

#### Type safety and maintainability
- N/A.

#### Error handling and logging
- N/A.

### PowerShell implementation audit (if applicable)

#### What changed well
- The lock decision is a pure function over injected inputs with a separate driver loop; the I/O adapter routes every filesystem and process call through a seam with a real default.
- The launcher removes the holder record before disposing the lock stream in `finally`, so a waiter that acquires next never loses its own record.
- `Get-TestSuiteScriptArgument` recovers colon-bearing arguments that `pwsh -File` would split, by reading the process command line after the script operand.
- Suites start through `ProcessStartInfo.ArgumentList` with one entry per word and no shell string.

#### API and safety notes
- `Open-TestExecutionLock`, `Write-TestExecutionHolderRecord` and `Remove-TestExecutionHolderRecord` declare `SupportsShouldProcess`.
- The hook fails open on a malformed payload and fails closed when a dependency does not load, as the spec states.

#### Error handling and logging
- Every refusal carries the `TEST_EXECUTION_POLICY_BLOCKED:` prefix with "test-execution policy" and the launcher command; the queue timeout carries `TEST_EXECUTION_QUEUE_TIMEOUT:` with the holder description.

### C# implementation audit (if applicable)

#### What changed well
- N/A: no C# file in the branch diff.

#### Type safety and API notes
- N/A.

#### Error handling and logging
- N/A.

---

## Test Quality Audit

### Reviewed test and QA artifacts
- `evidence/qa-gates/pester-suite.2026-11-14T11-16.md` (26384 tests, 0 failures) and `artifacts/pester/pester-junit.xml`, parsed by the reviewer: the named suites ran with 0 failures, and none of the four integration-named Pester files ran.
- `evidence/qa-gates/pytest-suite.2026-11-14T11-27.md` and `pytest-suite.2026-11-14T11-20.md` (16927 passed; `--strict-markers` clean)
- `evidence/qa-gates/jest-extension-suite.2026-11-14T11-20.md`, `bats-suite.2026-11-14T10-59.md`, `bats-suite.2026-11-14T11-20.md`
- `evidence/qa-gates/powershell-static.2026-11-14T11-03.md`, `python-static.2026-11-14T11-27.md`, `shell-static.2026-11-14T11-03.md`, `coverage-comparison.2026-11-14T11-21.md`, `self-review.2026-11-14T11-28.md`
- `evidence/other/lock-two-process-proof.2026-11-11T05-21.md` (committed 2026-11-11, before the registration change, as AC2 requires)
- `artifacts/pester/powershell-coverage.xml` and `artifacts/python/lcov.info`, parsed by the reviewer

### Quality assessment prompts
- The lock-decision suite covers each state-model row and drives the wait loop with an injected clock; no test sleeps.
- The command-form and hook suites cover each D25 form; the reviewer's real-process probe confirmed the decisions outside the test harness, including the `poetry -C`, `npm --prefix`, `npm -w`, `find -exec`, `xargs` and variable-held runner forms.
- No test checks that agent and skill instruction text avoids direct runner commands; `parallel-gate-wording.Tests.ps1` forbids `Bash(poetry run pytest` only in the executor tool list, which is why F1 passed the gates.

---

## Security / Correctness Checks

| Check | Status | Evidence |
|---|---|---|
| No secrets in code | ✅ PASS | Leak scan exit 0; no credentials added. |
| No unsafe subprocess or command construction | ✅ PASS | `ProcessStartInfo` with `UseShellExecute` false and `ArgumentList` per word; Python callers pass argv lists. |
| Input validation at boundaries | ✅ PASS | Config validation per field; 262144-byte cap on wrapper reads; malformed payload fails open by design. |
| Error handling remains explicit | ✅ PASS | Prefixed refusal and queue lines; fail-closed dependency guard; lock released in `finally`. |
| Configuration / path handling is safe | ✅ PASS | Lock directory under the per-user state root; `workingDirectory` validated as relative without `..`; holder records are outside every worktree, and evidence does not quote absolute holder paths. |

---

## Research Log

- `git diff --name-status add7d7478..c03f350da` and the per-file diffs of the Python production modules, the atomic-executor agent and the registries.
- Direct reads of `enforce-test-execution-policy.ps1`, `test-execution-command-form.ps1`, `test-execution-lock.ps1`, `Invoke-TestSuite.ps1` and `config/test-execution-policy.json`.
- Real-process probe: 39 Bash payloads piped to `pwsh -NoProfile -File .claude/hooks/enforce-test-execution-policy.ps1` in the worktree through a scratch Node script.
- Coverage XML, lcov and JUnit parsed by scratch scripts; logical line counts of every changed covered file.
- `validate_evidence_locations.py --root <worktree>` (exit 0) and `check_quality_tiers` (OK, 35 entries).
- Repository-wide search of agent and skill surfaces for direct runner commands (source of F1).
- `gh pr list` and `gh run list` for the branch: no pull request and no CI run.

---

## Verdict

**Needs Revision.** Two blocking findings: F1 (stale direct-runner instructions, autonomous, design scope because the lines lie in ledger entry `0001` regions) and F2 (user-story AC4 not aligned with spec D31, autonomous, design scope because it changes AC text). The Minor and Info rows require no change for merge.
