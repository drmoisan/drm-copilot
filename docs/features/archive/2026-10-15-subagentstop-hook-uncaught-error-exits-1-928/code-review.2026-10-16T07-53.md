# Code Review — Issue #928 (SubagentStop validator uncaught error exits 1), re-audit after remediation cycle 3

**Branch:** `bug/subagentstop-hook-uncaught-error-exits-1-928`
**Base:** `origin/main` @ `a880c46b919ca58b1144a925d54488ce51f02bfb`; merge base `5bc97774b8322e57abb94dfac3cd0a000a136c5b`
**Head reviewed:** `a210f5cf92fbbc09679dab9fa3b2756538b076f0` (code head `b43188f8377b5c2bbbfd5484f52b7fc226876353`)
**Scope:** full branch diff against `origin/main` (140 files), not only remediation cycle 3.
**Files reviewed:** eight validators under `.claude/hooks/` (discovery-artifact-gate, executor, orchestrator, planner, pr-author, prd-feature, required-artifact, task-researcher), `.claude/hooks/subagentstop-envelope.ps1`, `.claude/hooks/enforce-epic-wave-barrier.ps1`, `.claude/skills/epic-orchestrate/SKILL.md`, `.claude/agents/epic-orchestrator.md`, `.agents/skills/translate-claude-to-codex/SKILL.md`, `docs/engineering/claude-code-architecture.md`, `tests/scripts/claude-hooks/subagentstop-uncaught-error.Tests.ps1`, three edited Pester files, `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`, all bundle mirrors, and the feature documents.

## Total Blocking Findings: 2

No code defect blocks the change. The two blocking findings, CR4-B1 and CR4-B2, are the policy audit's PA-B1 and PA-B2. They concern the state of the local coverage artifacts. The local PowerShell report is a partial-scope run at 52.00% repo-wide, and the local Python lcov report is absent. Both findings are classified `autonomous`. The carried item CR-B1 (`awaiting_ci`; AC14 coverage clause) is resolved by the PR-head CI coverage artifact. The CI-failure item CI-1 is resolved by remediation cycle 3.

## Executive Summary

The production change is unchanged since the first review. Each of eight validators has a two-line tail edit that wraps the validation call in `try { ... }`. The `catch` calls `Exit-SubagentStopBlock` with the validator's S1 prefix, `validator error:`, the first line of the exception message, `the gate fails closed.`, and the report-and-halt line.

Remediation cycle 3 (`b43188f8`) edited one Python test-support module. It replaced the two SHA-256 constants in `PINNED_FROZEN_SURFACE_HASHES` and added a six-line `RE-BASELINED by issue #928` comment entry. The S9 commit `a210f5cf9` flipped AC14 and AC15 in `spec.md` and added the S9 coverage evidence file. Two Info-level non-blocking findings concern the merge step: CI on the final head was still pending at review time, and the branch is behind `main`.

## Prior Findings Verification

| Prior finding | Status | Verification by this review |
|---|---|---|
| CR-B1 (PowerShell coverage, `awaiting_ci`) | Resolved | Fresh download of CI run 38867388618 `poshqc-test-results/powershell-coverage.xml` (PR head `b43188f`); JaCoCo LINE parse: repo 90.45% (16434/18170); ten changed files 909/917 (99.13%); lowest file `validate-task-researcher-output.ps1` 98.08% (102/104). No catch line is in any missed list. |
| CI-1 (frozen epic-surface digests) | Resolved | `sha256sum .claude/agents/epic-orchestrator.md` = `c5b50974afe1718efce7023b2a7e6965d43979de333a84fb4d9fc2192eadd96d`; `sha256sum .claude/skills/epic-orchestrate/SKILL.md` = `b7af3a42d128a140951a07d592067a780429bc9beba0b6ec16afe54c3084b83f`; both equal the new pins at `parallel_orchestrator_surface_expectations.py:174` and `:178`. Local pytest on the contract and bundle-parity suites: 50 passed. CI `quality-checks7` 3.10-3.13 success on `b43188f`. |
| CR-N5 (literal halt sentence in four validators) | Accepted (orchestrator decision) | Literals at `validate-discovery-artifact-gate.ps1:253`, `validate-pr-author-output.ps1:129`, `validate-prd-feature-output.ps1:118`, `validate-task-researcher-output.ps1:290`. |
| CR2-N1 (U1-ST rows not run against pre-fix validators) | Accepted (orchestrator decision) | Characterization rows. |
| CR2-N2 (uneven rewrap, `subagentstop-envelope.Tests.ps1:9-11`) | Accepted (orchestrator decision) | Within the line limit. |
| CR2-N5 (`validate-bash.ps1:441-443` exit 1 fail-open) | Accepted as unrelated (orchestrator decision) | Not in the branch diff. |
| CR3-N1 (`remediation-plan.2026-10-16T06-40.md` stamp later than its commit) | Accepted (orchestrator decision) | No change. |
| CR3-N2 (`issue.md:11` `Last Updated: 2026-10-15`) | Accepted (orchestrator decision) | Unchanged at `a210f5cf9`. |

## Production Code Review

### Tail wrapper correctness (re-confirmed at `a210f5cf9`)

- Catch lines: discovery `:253`, executor `:322`, orchestrator `:344`, planner `:440`, pr-author `:129`, prd-feature `:118`, required-artifact `:199`, task-researcher `:290`. Each prefix equals the validator's S1 `-ReasonPrefix`.
- `Exit-SubagentStopBlock` takes a mandatory, non-empty `Message`; each composed message always contains the non-empty prefix.
- No `exit` is inside a `try` body.
- No validator changed in remediation cycles 1-3 after the cycle-1 code pass (`git diff --name-status e03d60829 HEAD` lists one Python file and Markdown only).

### Mirror parity

`cmp` by this review at `a210f5cf9`: all 12 changed `.claude` files are byte-identical to `extensions/drm-copilot/resources/claude-customizations/.claude/...`. `.agents/skills/translate-claude-to-codex/SKILL.md` is byte-identical to its `codex-and-agents-customizations` mirror. The expectations module has no bundle mirror (`pin-site-survey-cycle3.2026-10-16T07-19.md`).

### Remediation cycle 3: `parallel_orchestrator_surface_expectations.py`

- Lines 165-170: the new comment entry names the cause (the D4/D5 documentation edits), the edited line ranges, and the outcome ("Both digests moved, and the pin stays live for both entries"). It follows the format of the #690, #484, #787/#840, and #902 entries in the same block.
- Lines 171-180 (digests at 174 and 178): only the two digest strings changed; the tuple structure and file paths are unchanged.
- Black, Ruff, and Pyright are clean on the file (re-run by this review). The file is 387 lines.
- The re-baseline is the expected response to an intentional edit of a frozen surface. The test continues to detect any further unreviewed change to either file.

### Documentation edits

- `claude-code-architecture.md:237` and `:239` describe the PreToolUse and SubagentStop exit-code contracts consistently with the hooks.
- The epic skill and agent paragraphs, the wave-barrier comment, and the `.agents` table row state exit-2 blocking.
- The `subagentstop-envelope.ps1` citation names the archive path and the current active path. `docs/features/active/subagentstop-envelope-core-897/` exists on the branch and on `origin/main`.

## Test Design Review

`subagentstop-uncaught-error.Tests.ps1` (159 lines) has not changed since cycle 1. It builds both row tables in `BeforeDiscovery` and registers the #737 baseline seam mocks. It restores all swapped state, including `$global:LASTEXITCODE`. It asserts exit 2, the ordinal prefix, the injected text, one reader call, and no escaped exception. U2 discovers the dot-sourcing hooks by AST. On `origin/main` the same nine hooks dot-source the helper (`git grep` by this review), so U2 remains valid after the branch is updated from `main`.

## Findings Table

Blocking findings: 2 (autonomous; local artifact state). Non-blocking findings: 2 (Info).

| Severity | File | Location | Finding | Recommendation | Rationale | Evidence |
|---|---|---|---|---|---|---|
| Blocking (autonomous) | `artifacts/pester/powershell-coverage.xml` (local) | repo-wide LINE counter | CR4-B1 (= PA-B1): the local report shows 52.00% repo-wide line coverage (6387/12283), below 85%. It was produced at 05:38 UTC by a run scoped to two test folders, and six changed hooks are absent from it. | Regenerate the report with a full-scope PoshQC coverage run at the code head, then re-run the review. Alternatively, the operator may accept the PR-head CI artifact as the source of record. | The review procedure and the `validate-feature-review-coverage.ps1` gate evaluate the local artifact. The CI artifact for the same PowerShell code reports 90.45%, so no code defect is indicated. | JaCoCo LINE parse by this review; CI run 38867388618 recomputation. |
| Blocking (autonomous) | `artifacts/python/lcov.info` (local) | file absent | CR4-B2 (= PA-B2): no local Python coverage artifact exists, although the branch changes one Python file (a test-support module excluded from measurement). | Generate the artifact with `poetry run pytest --cov --cov-branch` at the code head, then re-run the review, or apply the same operator decision as CR4-B1. | Coverage verification is mandatory for every language with changed files. The CI run on `b43188f` reports 93.72% lines, and its threshold step passed. | `ls artifacts/python/lcov.info` (not found); CI job 116863252017 log. |
| Non-blocking (Info) | PR #954 head `a210f5cf9` | CI check runs 38869605121 / 38869605151 | CR4-N1: at 2026-10-16 07:50 UTC, 8 of 20 checks on the final head were pending (`poshqc` x2, `quality-checks7` x4, `shell-coverage`, `Publish to Marketplace`); 12 had passed. The prior head `b43188f` was 20 of 20 success. | Before DONE, re-run the CI green gate so that `ci_gate.head_sha` equals the final PR head, as the CI-dependent criteria protocol requires. | `a210f5cf9` differs from `b43188f` only by `spec.md:219-220` and one evidence file, so no outcome change is expected; the gate record must still name the final head. | `gh pr checks 954`; `git diff --name-status b43188f83 a210f5cf9`. |
| Non-blocking (Info) | branch `bug/subagentstop-hook-uncaught-error-exits-1-928` | merge base `5bc97774` | CR4-N2: the branch is 55 commits behind `origin/main` (`git rev-list --left-right --count origin/main...HEAD` = `55 34`); `gh pr view 954` reports `mergeStateStatus: BEHIND`, `mergeable: MERGEABLE`. None of the 186 files changed on `main` overlaps the branch file list, and `main` changed no hook, hook suite, or frozen epic surface. | Update the branch from `main` before merge and gate on the resulting head's CI. | Branch protection that requires an up-to-date branch would block the merge; the absence of overlapping files means no conflict or pin drift is expected. | `git diff --name-only 5bc97774 origin/main` intersected with `git diff --name-only origin/main...HEAD` (empty). |

## Out-of-Loop Observation (accepted; not a finding of this branch's diff)

`.claude/hooks/validate-planner-output.ps1:186` matches the citation path against `^(?![A-Za-z]:)(?!/)(?!\\)(?:\.?[^/\\|\s]+)(?:/[^/\\|\s]+)+$`. The trailing `+` requires at least one `/`, so a root-level path such as `CLAUDE.md` is rejected as not repository-relative. The line is pre-existing: this branch's hunks in that file are at lines 33 and 439-440. The issue was noted during cycle 3 planning, and the loop guard (three completed remediation attempts) prevents another cycle. Record it for separate follow-up.

## Positive Observations

- Remediation cycle 3 is confined to the two pin constants and one comment entry. Fail-before evidence shows exactly the two CI-1 node IDs failing (`digest-fail-before-cycle3.2026-10-16T07-20.md`), and the pass-after evidence shows an empty fail set.
- The S9 check-off of AC14 and AC15 is backed by a recorded coverage evidence file whose figures this review reproduced exactly from the CI artifact.
- Mirror parity, excluded-path invariants, and evidence-location compliance hold at the final head.
