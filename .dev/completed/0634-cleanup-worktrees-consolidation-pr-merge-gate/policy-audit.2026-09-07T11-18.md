# Policy Audit — 2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate (Issue #634)

- Timestamp: 2026-09-07T11-18 (UTC)
- Reviewer: feature-review agent
- Feature folder: `docs/features/active/2026-09-06-cleanup-worktrees-consolidation-pr-merge-gate-634/`
- Work mode: `full-bug` (marker read from `issue.md` line `- Work Mode: full-bug`)
- AC source resolved: `spec.md` only
- Overall verdict: **PASS**

## Resolved Scope

Base branch (authoritative): `origin/epic/cleanup-merged-worktrees-hardening-integration`
@ `a36b6dca7809e456f00c7d5b01eec5da49f7fca0`.

Head: branch `exec-634`. `git rev-parse HEAD` also returns `a36b6dca`, i.e. **the branch carries
zero commits beyond the base**; the entire delivery exists as working-tree modifications plus
untracked files. `git diff <base>` therefore compares the working tree, which is the accurate
delivery scope and is what this audit uses.

Full branch diff against the resolved base (`git diff --name-only`):

| File | Kind |
|---|---|
| `.claude/skills/cleanup-merged-worktrees/SKILL.md` | Markdown (runtime skill doc) |
| `extensions/drm-copilot/resources/claude-customizations/.claude/skills/cleanup-merged-worktrees/SKILL.md` | Markdown (bundled mirror) |
| `docs/features/active/.../plan.2026-09-06T23-08.md` | Markdown (feature doc) |
| `docs/features/active/.../spec.md` | Markdown (feature doc) |

Untracked additions (all inside the canonical feature evidence tree): 8 files under
`evidence/baseline/`, 15 under `evidence/qa-gates/`, 1 under `evidence/regression-testing/`.
`git check-ignore` returns exit 1 for these paths, confirming they are committable and not
excluded by `.gitignore`.

## Rejected Scope Narrowing

**None detected.** The caller prompt enumerated a specific change surface (the two `SKILL.md`
copies) and a specific out-of-scope set. That enumeration was independently checked against the
full branch diff and found to be **identical** to it, not a subset of it: `git diff --name-only`
against the resolved base returns exactly four files, two of which are the named change surface
and two of which are the feature's own `spec.md`/`plan.md`. No language, file, or toolchain check
with changed files on the branch was excluded from this audit. No narrowing instruction was
issued and none was rejected.

## Evidence Location Compliance

**PASS.**

- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` — exit 0, no
  output, no violations reported.
- Manual scan for non-canonical paths: `artifacts/baselines/`, `artifacts/qa/`,
  `artifacts/evidence/`, and `artifacts/coverage/` do not exist in the worktree
  (`ls` reports "No such file or directory" for all four).
- All 24 evidence artifacts produced by execution live under
  `<FEATURE>/evidence/{baseline,qa-gates,regression-testing}/`, matching the canonical
  `<FEATURE>/evidence/<kind>/` layout in
  `.claude/skills/evidence-and-timestamp-conventions/SKILL.md`.
- No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose during this review.

## Coverage Verification

Coverage obligations attach to languages that have **changed files in the branch diff**. The
branch diff contains four files, all with the `.md` extension. Zero files changed in any
coverage language. The verdicts below are therefore `N/A (zero changed files on branch)`, which
is the one form of non-`PASS`/`FAIL` verdict the scope invariant permits, and each is supported
by the enumerated diff above rather than by assertion.

| Language | Changed files on branch | Coverage artifact | Verdict |
|---|---|---|---|
| TypeScript | 0 | `coverage/lcov.info` not required | N/A (zero changed files on branch) |
| Python | 0 | `artifacts/python/lcov.info` not required | N/A (zero changed files on branch) |
| PowerShell | 0 | `artifacts/pester/powershell-coverage.xml` not required | N/A (zero changed files on branch) |
| C# | 0 | `artifacts/csharp/coverage.xml` not required | N/A (zero changed files on branch) |
| bash | 0 | kcov output not required | N/A (zero changed files on branch) |

Independent confirmation that no coverage-language file changed: the out-of-scope no-diff checks
below return empty for `.claude/hooks`, `scripts/bash`, and `tests/scripts/claude-hooks`, which
are the only directories on this epic branch where a `.ps1`/`.sh` change for this feature could
plausibly have landed.

The plan's stated reasoning (`plan.2026-09-06T23-08.md`, section "Language-toolchain
applicability, stated with its reason") was checked and is accurate on an independently
verifiable point: `pyproject.toml` `addopts` supplies `--cov-report=lcov:artifacts/python/lcov.info`
with no `--cov` target, so a pytest run passing no `--cov` argument collects no coverage data. A
coverage percentage asserted for this feature would have had no source.

No coverage generation was rerun by this reviewer, per the evidence-verification model.

## Mandatory Toolchain Loop

The seven-stage loop in `.claude/rules/general-code-change.md` binds to code changes. This
feature changes only Markdown. Stage applicability, each with its reason:

| Stage | Applicable | Verdict | Evidence |
|---|---|---|---|
| 1. Formatting | No | N/A | No repository formatter (Black, Prettier, CSharpier, Invoke-Formatter) accepts a Markdown skill document as input. |
| 2. Linting | No | N/A | No `.py`/`.ts`/`.ps1`/`.cs` file changed; Ruff, ESLint, PSScriptAnalyzer, and .NET analyzers have no input. |
| 3. Type checking | No | N/A | No typed source file changed. |
| 4. Architecture-boundary tests | No | N/A | No module graph edge added or removed. |
| 5. Unit tests | Yes (one node) | **PASS** | `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts` — reviewer-executed, `1 passed in 0.10s`. |
| 6. Contract/schema checks | No | N/A | No public contract or schema changed. |
| 7. Integration tests | No | N/A | No adapter or external-system boundary changed. |

Stage 5 was executed by this reviewer independently of the executor's recorded run, and returned
the same result as `evidence/qa-gates/final-push-down-parity.2026-09-07T11-08.md`.

## Policy Compliance Findings

| # | Policy | Requirement | Verdict | Evidence |
|---|---|---|---|---|
| P-1 | `general-code-change.md` — file size limit | No production/test/reusable file exceeds 500 lines | **PASS** | `SKILL.md` is 283 lines. Markdown is additionally exempt from the cap by the rule's own exception clause. |
| P-2 | `general-code-change.md` — simplicity first | Prefer the simplest design that works | **PASS** | Option A (document the human step) adds no code, no new checkpoint shape, and no new trusted-input surface. Option B, rejected in `spec.md` `## Decision`, would have widened a merge gate's allow side. The simpler option was selected and the rejection is reasoned across R1–R5. |
| P-3 | `general-code-change.md` — dependencies | No new dependency added | **PASS** | No manifest changed. |
| P-4 | `general-unit-test.md` — coverage thresholds | Line >= 85%, branch >= 75% where measured; no regression on changed lines | **PASS (vacuous)** | Zero changed lines in any coverage language, so no file enters or leaves a coverage denominator. See Coverage Verification. |
| P-5 | `general-unit-test.md` — coverage exclusion policy | No `exclude` entry may match a production source path | **PASS** | No coverage configuration file changed on this branch (`pyproject.toml`, `jest.config.cjs`, and equivalents are absent from the diff). |
| P-6 | `general-unit-test.md` — test file location | Tests live under `tests/` mirroring source | **PASS (vacuous)** | No test file created, moved, or modified. |
| P-7 | `general-unit-test.md` — no temp files in tests | Prohibited | **PASS (vacuous)** | No test file changed. |
| P-8 | `quality-tiers.md` | Uniform gates applied, no tier-specific lowering | **PASS** | No tier-specific threshold was invoked or relaxed anywhere in the plan, spec, or evidence. |
| P-9 | `tonality.md` | Professional, factual, non-hyperbolic, metaphor-restricted | **PASS** | The added prose is declarative and evidence-matched ("is absent from", "carries no `gh` entry", "would deny"). No humor, hyperbole, or decorative metaphor. Reviewer read all 23 added lines. |
| P-10 | Push-down parity contract | Any `.claude/**` edit mirrored byte-identically into the bundled payload | **PASS** | SHA256 of both copies is `4189bd77094e98f8e589dddf282e21508d2b9db64adde837606805d64eb4d716`; `cmp` reports no difference; both are 17707 bytes / 283 lines. Verified by this reviewer, not taken from the executor's report. |
| P-11 | Policy documents unmodified | No edit to `.claude/rules/` or `.github/instructions/` | **PASS** | Absent from the branch diff. |
| P-12 | Out-of-scope surfaces untouched | Sibling-child-owned files carry zero diff | **PASS** | `git diff <base> -- .claude/hooks .claude/settings.json scripts/bash tests/scripts/claude-hooks` produces empty output. This covers `enforce-epic-merge-gate.ps1`, `enforce-epic-merge-gate.Tests.ps1`, `enforce-epic-worktree-removal-gate.ps1`, `cleanup_worktrees_*_lib.sh`, `cleanup-worktrees.sh`, and `settings.json`. |
| P-13 | Rejected-option token absence | `cleanup-worktrees-state` absent from runtime, script, test, extension trees | **PASS** | `grep -rn "cleanup-worktrees-state" .claude scripts tests extensions` exits 1 with no matches. |
| P-14 | Evidence location invariant | Canonical `<FEATURE>/evidence/<kind>/` only | **PASS** | See Evidence Location Compliance. |
| P-15 | AC-tracking protocol | Only `[ ]`->`[x]` flips; criterion text preserved; no phantom criteria | **PASS** | `git diff --word-diff=porcelain` on `spec.md` shows exactly 14 checkbox token changes and no other word-level change. The same check on `plan.2026-09-06T23-08.md` shows only checkbox flips. Fifteen AC items before, fifteen after. |

## Independent Re-Verification of Factual Claims in the Added Prose

The skill document makes four checkable assertions about the current tree and one about the
GitHub server state. Each was re-derived from primary sources rather than accepted as internally
consistent.

| Claim in `SKILL.md` | Verification | Result |
|---|---|---|
| The merge command "is absent from this skill's `allowed-tools`" | Read the YAML frontmatter (lines 1–24). The only `gh` entry is `"Bash(gh issue view *)"`. | **Accurate** |
| "the project permission allow-list (`permissions.allow` in `.claude/settings.json`) carries no `gh` entry" | Parsed `.claude/settings.json` as JSON: `permissions.allow` has 62 entries, of which the subset containing the substring `gh` (case-insensitive) is empty; `deny` and `ask` likewise contain no `gh` entry, and no `allow` entry contains the substring `merge`. | **Accurate** |
| "`.claude/hooks/enforce-epic-merge-gate.ps1` would deny the command with `EPIC_MERGE_GATE_BLOCKED`" | Read the hook. `Invoke-EpicMergeGateDecision` returns a `deny` decision whose reason string begins `EPIC_MERGE_GATE_BLOCKED:` when no checkpoint matches. Confirmed the hook is wired as a `PreToolUse` hook with matcher `Bash` in `.claude/settings.json`, so the Cross-References description "the PreToolUse gate" is correct. Additionally demonstrated live during this review — see O-4. | **Accurate, with a precision note — see O-1** |
| Cross-References: "A cleanup run satisfies none of its three checkpoint shapes" | Read the hook's three accept paths: `orchestrator-state.json` (`epic_mode` + `step9_status == "passed"`), `epic-orchestrator-state.json` (`epic_merge_pr.ci_gate.conclusion == "success"` + matching `pr_number`), `parallel-orchestrator-state.json` (`route_id == "parallel"` + item `merge_status == "ci_green"`). The document's three-shape summary matches the implementation term for term. | **Accurate** |
| Prohibited Shortcuts: the shape-1 evasion "the gate's child-feature accept shape would honour for any pull-request number" | `Test-ChildCheckpointAllowsEpicMerge` accepts a single `$Checkpoint` parameter and no PR-number parameter; the caller does not pass `$commandPrNumber` to it, unlike the epic and parallel paths. The child path is genuinely PR-number-agnostic. | **Accurate** |

Section-boundary claims in the executor's evidence artifacts were also spot-checked and found
correct: `evidence/qa-gates/ac-01-human-performed.2026-09-07T11-02.md` states the step 5 item
starts at line 107 and ends at line 120 with item 6 at line 122. Independent line-numbered
inspection confirms exactly that (line 121 is the blank separator).
| Step 5: "The ruleset on `main` sets `strict_required_status_checks_policy`" | Re-queried `gh api repos/drmoisan/drm-copilot/rules/branches/main` in this review session. The `required_status_checks` rule returns `"strict_required_status_checks_policy": true`, and `docs-validation / Documentation Validation` is present in the required-context list. | **Accurate (independently re-verified, not merely inherited from `spec.md` R1)** |

## Observations (non-blocking)

**O-1 — The generic phrase "the command" is broader than the hook's actual scope filter.**
Step 5 states the gate "would deny the command"; `## Prohibited Shortcuts` says "Never issue the
consolidation merge command"; `## Cross-References` says "the PreToolUse gate on the
consolidation merge command". The hook's scope filter requires **two** substrings to be present
together: the three-word merge invocation **and** the merge-commit flag. Every other Bash command
returns an allow decision. The repository ruleset reports
`allowed_merge_methods: ["merge", "squash", "rebase"]`, so a squash-flavoured or rebase-flavoured
invocation would **not** be denied by this hook. The document's operative conclusion is
unaffected, because the other two stated blockers — absence from `allowed-tools` and absence from
`permissions.allow` — are flag-independent and hold for every merge form. The imprecision is
confined to the third of three reasons and only for non-merge-commit flags. `issue.md` scopes its
own reproduction to "the merge-commit flag", so the underlying analysis is precise; only the
generalized skill phrasing is loose. No AC asserts flag-level precision. Suggested future edit,
not required for this delivery: qualify the phrase as the merge-commit form.

**O-2 — One added line exceeds the document's wrap convention.** Line 111 is 98 characters. It is
the only body line in the 283-line file above 90 characters; the next longest is 90. Cosmetic.

**O-3 — Task count in the relayed execution report is understated.** The delegation prompt
reports "all 24 plan tasks (P0-T1..P3-T5)". The plan actually carries 34 task checkboxes
(P0: 8, P1: 6, P2: 15, P3: 5). All 34 are `[x]`; zero remain `[ ]`. The artifact state is
complete; only the count in the relayed summary is wrong.

**O-4 — Informational, directed at the epic rather than at this feature: the gate matches on raw
command text, including documentation payloads.** While writing this audit, a Bash heredoc whose
*document content* quoted both matched substrings was denied by the live hook with
`EPIC_MERGE_GATE_BLOCKED`. No merge was being attempted; the tokens appeared only inside prose
being written to a file. This confirms the hook's deny path operates as documented, and it also
shows the scope filter is a substring test over the whole command string with no awareness of
quoting or heredoc boundaries. That is a property of `enforce-epic-merge-gate.ps1`, which is
owned by a sibling epic child (issue #545) and carries zero diff in this feature. It is recorded
here only because this review produced direct evidence of it; it is **not** a finding against
issue #634, and no remediation is requested of this feature.

## Required Follow-Up Before PR Authoring (not a policy violation)

**F-1 — The delivery is uncommitted.** `HEAD` equals the base SHA `a36b6dca`, so the branch has an
empty commit range. Consequences the orchestrator must handle:

1. The regenerated PR-context artifacts (`artifacts/pr_context.summary.txt`,
   `artifacts/pr_context.appendix.txt`) report `Core logic changes: 0 files` and
   `Range: a36b6dca..a36b6dca`, because the collector reads the commit range. They cannot
   describe this delivery until it is committed. This audit therefore derived scope from the
   resolved base branch via `git diff`, which is the other authoritative scope source.
2. The 24 untracked evidence files require an explicit `git add`; they will not be picked up by
   a commit that stages only tracked modifications.
3. After committing, re-run the two cheap invariants to confirm they survived the commit: the
   push-down parity pytest node, and the out-of-scope no-diff check over `.claude/hooks`,
   `.claude/settings.json`, `scripts/bash`, and `tests/scripts/claude-hooks`.

This is recorded as a handoff condition, not a finding against the delivery: every acceptance
assertion in `spec.md` is satisfied by the working tree as it stands, and the executor was not
tasked with committing.

## Blocking Findings

**None.**
