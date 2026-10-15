# Research: Epic Integration Branch Not Synced With Main (#902)

- Issue: #902
- Branch: `bug/epic-integration-branch-not-synced-with-main-902`
- Work Mode: minor-audit (`issue.md:3`)
- Requirements source: `docs/features/active/2026-10-11-epic-integration-branch-not-synced-with-main-902/issue.md` (Implementation Intent lines 15-24, Acceptance Criteria lines 26-33)
- Approved approach: operator decision A (`issue.md:17-22`). No hook change.

All line numbers below are the `Read` tool's numbering on this worktree at research time. Where a `Grep "^"` count is quoted it is one lower than the `Read` numbering for the same file (observed on every file measured; see Section 7).

## 1. Current State

`.claude/skills/epic-orchestrate/SKILL.md:90-111` ("## Epic Integration Branch Lifecycle") has five steps:

- Step 1 (`:92-94`) creates `epic/<epic-slug>-integration` from `origin/main` before wave 0.
- Step 2 (`:95-97`) runs `git fetch origin epic/<epic-slug>-integration` before each wave. It fetches only the integration branch; `origin/main` is not fetched or compared.
- Steps 3-4 (`:98-104`) set child branch base and PR base to the integration branch.
- Step 5 (`:105-111`) opens the final integration-to-`main` PR.

No step merges `origin/main` into the integration branch while waves run. This matches the defect statement in `issue.md:11-13`.

## 2. Parity Surfaces (Question 1)

Search scope: the whole worktree excluding `docs/**`. Patterns used: `Epic Integration Branch Lifecycle|git fetch origin epic/|-integration origin/main`, then `(?i)before (starting )?each wave|current remote integration tip|current integration tip`, then `Glob **/epic-orchestrate/**` and `Glob **/*epic-orchestrat*`. `.github/` has no epic-orchestrate surface. The only `.github` hit for "integration branch" is `.github/workflows/README.md:16`, which is about CI triggers. The `.github` epic files (`.github/agents/epic-review.agent.md` and `.github/prompts/*epic*.prompt.md`) are review and breakdown prompts and contain no lifecycle text.

| # | Path | Lines | Relationship | Restates per-wave lifecycle? | Edit needed |
|---|---|---|---|---|---|
| S1 | `.claude/skills/epic-orchestrate/SKILL.md` | 90-111 | Canonical | Yes (steps 1-5) | Yes (canonical edit) |
| S2 | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md` | 90-111 | Byte copy of S1 (same line numbers for the heading and steps, from the Grep hits at `:90`, `:93`, `:96`) | Yes | Yes (byte copy) |
| S3 | `.agents/skills/epic-orchestrate/SKILL.md` | 65-69 ("## Integration Branch and Child Worktrees") | Codex paraphrase of S1 steps 1-4: "Create a missing integration branch from current `origin/main` ... Before each wave, fetch the current remote integration tip. Create every child worktree from that tip ..." | Yes (paraphrase) | Yes (paraphrased step) |
| S4 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md` | 65-69 | Byte copy of S3 (Grep hits at `:67-68`) | Yes | Yes (byte copy) |
| P1 | `.claude/agents/epic-orchestrator.md` | 43-48, 89-94 | Reference only. `:45-48` says to apply the skill "as the canonical procedure for ... the integration-branch lifecycle" and that "the skill documents the *how* in full". `:80` and `:89` ("Do not recreate the integration branch; fetch and reuse it.") cover prepared-epic kickoff discovery, not the per-wave steps. | No | No (see Section 6) |
| P2 | `extensions/drm-copilot/resources/claude-customizations/.claude/agents/epic-orchestrator.md` | same | Byte copy of P1 | No | No |
| P3 | `.codex/agents/epic-orchestrator.toml` | 14, 58 | `:14` "Apply `epic-orchestrate` as the canonical execution procedure." `:58` is a one-line scheduling bullet: "Launch all ready features in a bounded wave concurrently from the current integration tip." | Partial (one launch bullet, no lifecycle steps) | Optional; not recommended (Section 6) |
| P4 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/agents/epic-orchestrator.toml` | same | Byte copy of P3 | Partial | Only if P3 is edited |
| R1 | `.claude/skills/epic-run/SKILL.md` | 26, 43-47, 54-56 | Reference. `:26` fetches the integration branch to discover the kickoff. `:54-56` says wave scheduling and fan-in "are governed entirely by the `epic-orchestrate` skill". | No | No |
| R2 | `extensions/.../claude-customizations/.claude/skills/epic-run/SKILL.md` | 26 | Byte copy of R1 | No | No |
| R3 | `.agents/skills/epic-run/SKILL.md` | 21, 29 | Reference ("Reuse the existing integration branch") | No | No |
| R4 | `.claude/skills/epic-plan/SKILL.md` | 81-89 | Separate "## Integration Branch Lifecycle" for the planning phase. Branch creation only; no waves. | No | No |
| R5 | `.agents/skills/epic-plan/SKILL.md` | 63 | Planning-phase branch creation | No | No |
| R6 | `extensions/.../claude-customizations/.claude/agent-memory/epic-orchestrator/feedback_worktree_isolation_branches_from_main.md` | 17-20 | Bundled agent memory: fetch and checkout inside the child prompt. Outside the `.claude/**` parity scope because agent-memory paths are filtered (`tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:5-7`, `:99-101`). | No | No |

Conclusion: the step must be added to S1 through S4. P1 through P4 and R1 through R6 only reference the skill, or restate unrelated sub-steps (kickoff discovery, planning-phase branch creation).

## 3. Sync Mechanism and Parity Enforcement (Question 2)

There is no repo-to-bundle generator.

- `scripts/dev_tools/push_down_claude_customizations.py:111-113` and `:145` read from the bundle (`extensions/drm-copilot/resources/claude-customizations`) and write to a destination workspace. They do not regenerate the bundle from the repository.
- `scripts/dev_tools/skill_bundle_contract_cli.py:1-13` is a read-only guard. It fails when a skill cites an unbundled script.
- `scripts/dev_tools/generate_codex_agent_variants.py:33-50` generates only the profile families listed in `CORE_FAMILIES` / `PACK_FAMILIES`. `epic-orchestrator` is not among them.
- `extensions/drm-copilot/package.json:203-204` (`compile` / `build`) bundles extension code only.
- `.gitignore:65-68` un-ignores the Codex bundle trees. Both bundle trees are tracked.

The mirrors are therefore hand-maintained byte copies. Precedent: plan task `[P1-T14]` of #659 (`docs/features/active/2026-09-08-epic-wave-barrier-violations-lack-start-guard-659/plan.2026-09-29T21-21.md:165`) applied "the same replacement (LF line endings)" to the bundled epic-orchestrate skill and verified it with `git hash-object` on both paths.

Parity enforcement:

| Mirror | Test file | Test name | Toolchain |
|---|---|---|---|
| S2 (and P2 if edited) | `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` | `test_bundled_claude_payload_contains_all_repo_runtime_contracts` (`:89-110`, text equality over all distributable `.claude/**` files) | pytest |
| S4 (and P4 if edited) | `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py` | `test_bundled_codex_and_agents_payload_contains_all_repo_runtime_contracts` (`:215-228`, scope `.codex` and `.agents` per `:35`) | pytest |
| S4 | `tests/scripts/dev_tools/test_codex_full_migration_inventory.py` | `test_all_repo_agent_skills_are_bundled_and_identical` (`:83-97`) | pytest |
| S4, P4 | `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` | `It 'keeps root and tracked bundle runtime copies byte-identical'` (`:175-183`, SHA256 over `RuntimePaths` `:21-45`, which include `.agents/skills/epic-orchestrate/SKILL.md` `:24` and `.codex/agents/epic-orchestrator.toml` `:28`) | Pester (CI only, per the operator constraint) |
| S1 (frozen digest) | `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py` | `test_frozen_epic_surface_matches_pinned_baseline_digest` (`:470-485`). Data: `PINNED_FROZEN_SURFACE_HASHES` in `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py:160-169` | pytest |
| S1 skill-script references | `tests/scripts/dev_tools/test_skill_bundle_contract_repo.py` (`:50` names `epic-orchestrate`) | read-only bundle guard | pytest |

Frozen digest (blocking finding for the plan). `parallel_orchestrator_surface_expectations.py:166-167` pins `.claude/skills/epic-orchestrate/SKILL.md` to SHA-256 `66c7baa9b6fe4340a479d7de62d73fbdf57dbf6c96aa6c747456ef9d425e1326`. The digest covers raw bytes (`parallel_orchestrator_surface_test_support.py:92-96`). Any edit to S1 fails this test until the digest is re-baselined. The established convention is to re-baseline rather than remove: append a `# RE-BASELINED by issue #902 ...` comment block in the same style as `:108-159` and replace only the skill digest. The agent digest (`:162-163`) does not move if P1 is not edited.

`.gitattributes:1` sets `* text=auto eol=lf`, so the working-tree bytes are LF. Compute the new digest with `Get-FileHash -Algorithm SHA256` (PowerShell tool) on the edited file, and cross-check it against the `found <digest>` value in the test's failure message (`test_parallel_orchestrator_surface_contracts.py:482-485`).

Commands to verify parity, with no regeneration command available:

- `poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py tests/scripts/dev_tools/test_codex_full_migration_inventory.py tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py tests/scripts/dev_tools/test_skill_bundle_contract_repo.py -q`
- Pairwise `git hash-object <root> <bundle>` for S1/S2 and S3/S4, as in the #659 precedent.

## 4. Existing Contract Tests Pinning epic-orchestrate Content (Question 3)

| File | Framework | What it reads | Affected by an additive lifecycle step |
|---|---|---|---|
| `tests/scripts/dev_tools/test_parallel_orchestrator_surface_contracts.py:470-485` | pytest | SHA-256 of S1 and P1 | Yes. Re-baseline the S1 digest. |
| `tests/scripts/dev_tools/test_epic_bounded_child_return_contract.py` (`:33-35` path constant; helpers `normalize_whitespace` `:110-128`, `contains_phrase` `:131-147`, `section_body` `:150-180`) | pytest | Sections `## Merge-on-Green Kickoff Parameter`, `## Bounded Child Return Contract`, `## Model Selection` of S1 | No |
| `tests/scripts/dev_tools/test_orchestrator_state_remediation_docs.py:44-45`, `:86-97` | pytest | Remediation-loop fragments in S1 and S3 | No |
| `tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py` | pytest | R1 and P1 fragments, plus byte parity of R1 and P1 with the bundle (`:107-120`) | No |
| `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1:39`, `:104`, `:186` | Pester | `## Epic-Level Checkpoint` fragments in S1 | No |
| `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1:175-183` | Pester | Byte parity of S3/S4 and P3/P4 | Yes. It passes when S4 is a byte copy of S3. Verify in CI only. |
| `tests/scripts/dev_tools/test_claude_rules_frontmatter.py:58`, `:72` | pytest | Skill name and path lists | No |

Conventions to follow for the new test, from the existing pytest Markdown contract tests:

- `REPO_ROOT = Path(__file__).resolve().parents[3]` (`test_epic_run_kickoff_discovery_contract.py:19`, `test_epic_bounded_child_return_contract.py:30`).
- Read files with `Path.read_text(encoding="utf-8")` through a small `read_repo_text` helper (`test_epic_run_kickoff_discovery_contract.py:28-38`).
- Assert fragments one at a time with a named failure message (`:63-65`).
- Match with collapsed whitespace so wrapped prose cannot turn an assertion into a no-op (`test_epic_bounded_child_return_contract.py:15-19`, `:110-147`).
- Scope assertions to one level-two section (`section_body`, `:150-180`).
- Add a discriminating negative test that runs the same assertion helper on synthetic text and shows it fails when the step is removed, using `pytest.raises(AssertionError, ...)` as in `tests/scripts/dev_tools/test_push_down_claude_parity.py:331-345`.
- No file creation (`test_epic_bounded_child_return_contract.py:21-22`).

Location: Markdown skill contract tests live in `tests/scripts/dev_tools/` (`test_epic_run_kickoff_discovery_contract.py`, `test_epic_bounded_child_return_contract.py`, `test_legacy_discovery_skills_contracts.py`, `test_parallel_issue_adoption_skill_contracts.py`). There is no `tests/.claude/skills/` tree. The natural home is a new file `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py`. A new file is preferred over extending `test_epic_bounded_child_return_contract.py` (437 lines by Grep count, close to the 500-line limit) or `test_parallel_orchestrator_surface_contracts.py` (485 lines by Grep count).

## 5. The epic-852 Main-Sync Pattern (Question 4)

Facts from local documents only:

- Feature folder `docs/features/active/epic-852-main-sync/`, Work Mode minor-audit, Issue #852 (the epic's own issue number), Branch `chore/epic-852-main-sync-852`, Base `epic/enforcement-hook-precision-integration` (`epic-852-main-sync/issue.md:3-7`).
- Why a child was used: "The epic coordinator cannot resolve the merge conflict itself, so this child performs the sync on its own branch and lands it through a PR into the integration branch" (`issue.md:11`). `#902 issue.md:13` records that the coordinator's direct merge attempt was denied by `PREIMPLEMENTATION_GATE_BLOCKED`.
- Merge mechanics: `git fetch origin main`, record `MAIN_TIP` (`plan.2026-10-10T22-52.md:127`). Then `git merge --no-ff --no-commit origin/main`, list conflicts with `git diff --name-only --diff-filter=U` (`:128`), resolve, stage, commit a two-parent merge whose message begins `Merge remote-tracking branch 'origin/main' into chore/epic-852-main-sync-852` (`:131`). The recorded result was merge commit `0ac05da8f` with parents `9add694e4` (branch head) and `daa6436cd` (origin/main) (`evidence/other/p1-merge.md:52-61`).
- Constraints: merge commit only, with no rebase and no force-push (`issue.md:19`, plan `:100`, `:184`). Conflicts are resolved by keeping both sides' intent and recorded (`issue.md:20`, plan `:130`). If `origin/main` moves before the PR merges, merge it again (no rebase) and re-run checks (`issue.md:27`, plan `:185`). One textual conflict occurred: `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json` (`p1-merge.md:34-40`).
- PR target and merge: "land the result through a green PR into the integration branch" (`issue.md:15`). AC 5 requires all checks green and the PR merged (`issue.md:23`). PR creation, CI, and merge are orchestrator-owned (plan `:25`).
- Scheduling: the epic status projection lists the sync as its own wave, `| 3 | in_progress | epic-852-main-sync |` (`docs/features/epics/enforcement-hook-precision/epic-status.md:18`). It also has a `features[]` row `epic-852-main-sync | 852 | 3 | worktree_created` (`:32`), with next step `E8b_await_sync_child` (`:8`). The PR number #882 appears only in `#902 issue.md:13`. The local epic-852 documents do not record it (no `#88x` match under `docs/features/active/epic-852-main-sync/`).

Generalized mechanics for the new step:

- Child branch created from `origin/<integration_branch>`.
- `git merge --no-ff origin/main` (merge commit, no rebase, no force-push).
- Conflicts resolved inside the child's own run through the existing R1-R5 loop. This is consistent with `.agents/skills/epic-orchestrate/SKILL.md:118-119`, "The epic agent must not resolve child conflicts locally".
- PR base is the integration branch.
- The child's own S9 step 6 merges it (`.claude/skills/epic-orchestrate/SKILL.md:120-124`).
- Recorded as a `features[]` row with its own wave entry before the next manifest wave launches.

## 6. Personas (Question 6)

- `.claude/agents/epic-orchestrator.md` does not restate the lifecycle steps. `:45-48` delegates "the integration-branch lifecycle" to the skill, and `:116-135` (Wave Scheduling) covers wave computation and the barrier only. Editing it would also move its pinned digest (`parallel_orchestrator_surface_expectations.py:162-163`). It does not satisfy the AC-3 condition "where it restates the lifecycle". Recommendation: no edit.
- `.codex/agents/epic-orchestrator.toml:14` names `epic-orchestrate` as the canonical procedure. `:52-67` is a scheduling summary, and `:58` mentions launching "from the current integration tip". This is a one-line paraphrase, not the lifecycle. Recommendation: no edit, which avoids a Pester-verified TOML parity change (P3/P4). If the planner nonetheless chooses to edit it, P4 must receive a byte copy, and parity is verified by pytest (`test_push_down_codex_and_agents_resource_contracts.py:215-228`) plus CI Pester (`codex-epic-runtime-contracts.Tests.ps1:175-183`).

## 7. Validators, Hooks, and Schema (Question 5)

- No production code names `main_sync`, `main-sync`, or `mainSync`. The only matches are under `docs/` (the Grep over the whole worktree returned 39 files, all under `docs/`).
- `scripts/dev_tools/validate_epic_orchestrator_state.py`:
  - Requires the keys at `:39-52` and the `merge_status` enum at `:54-63`.
  - Checks `feature_folder` uniqueness and `depends_on` resolution (`:155-215`), and `waves[]` against `wave_number` consistency (`:248-297`).
  - Does not recompute waves from the manifest DAG and does not enforce `issue_num` uniqueness. `_epic_orchestrator_state_resolution.py:99-108` maps `issue_num` to a folder, and a later duplicate overwrites the earlier one.
  - A sync child recorded as a `features[]` entry with a unique `feature_folder`, a matching `waves[]` entry, and a valid `merge_status` therefore validates without change. The epic-852 checkpoint projection did this (Section 5).
  - No validator change is required.
- TypeScript ports (`extensions/drm-copilot/src/lib/validate/epic-orchestrator-state-*.ts`) mirror the Python validator. No change is required for the same reason.
- `epic-status.md` has no generator in `scripts/`, `.claude/lib/`, `.claude/hooks/`, `.codex/`, or `extensions/drm-copilot/src/`. The only matches are template seeding in `scripts/dev_tools/new_active_feature_folder_docs.py:159` and its TypeScript equivalent. It is maintained by the agent from the checkpoint. No change.
- Hook interaction (reported, not changed). `.claude/hooks/enforce-epic-wave-barrier.ps1:286-331`:
  - Fires on epic-mode `Agent(orchestrator)` calls.
  - Requires the prompt to cite the target feature folder (`:302-305`).
  - Looks up that folder's `features[]` record and denies with `EPIC_WAVE_BARRIER_BLOCKED` when "the feature record was not found" (`:326-331`).
  - Consequence: the sync child's `features[]` row (with `depends_on: []`) must be written to the epic checkpoint before the delegation. The new skill step should state this, so the step works without a hook change.
  - The Codex surface launches children through `.codex/scripts/launch-epic-child-wave.ps1` (`.agents/skills/epic-orchestrate/SKILL.md:82-99`). The sync child uses the same launch path and receipts as any child.
- `issue_num` for the sync child: use the epic issue number, as epic-852 did, or a dedicated chore issue. Do not reuse a manifest child's `issue_num`, because `depends_on` resolution by `issue_num` would then resolve to the wrong row (`_epic_orchestrator_state_resolution.py:99-108`).

## 8. Line Counts (Question 7)

`Read` numbering, with the `Grep "^"` count in parentheses.

| File | Lines | Limit applies |
|---|---|---|
| `.claude/skills/epic-orchestrate/SKILL.md` | 342 (341) | No (Markdown) |
| `extensions/.../claude-customizations/.claude/skills/epic-orchestrate/SKILL.md` | 342 (341) | No |
| `.agents/skills/epic-orchestrate/SKILL.md` | 173 (172) | No |
| `extensions/.../codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md` | 173 (172) | No |
| `.claude/agents/epic-orchestrator.md` (not edited) | 169 (168) | No |
| `.codex/agents/epic-orchestrator.toml` (not edited) | 98 (97) | Yes (Pester `:185-196` caps `.codex/agents/*.toml` at 500) |
| `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` | 377 (376) | Yes. A comment block of about 6 lines keeps it under 500. |
| `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py` (new) | 0 | Yes. Target about 150-200 lines. |

## 9. Verification Constraints (Question 8)

- Every proposed new or edited test is pytest: the new contract test file and the digest re-baseline. Local verification is `poetry run pytest ...` with coverage, plus Ruff, Black, and Pyright on the new test file.
- Pester: `tests/scripts/codex-hooks/codex-epic-runtime-contracts.Tests.ps1` (S3/S4 byte parity) and `tests/scripts/claude-runtime/checkpoint-hygiene-skill-contract.Tests.ps1` (unaffected fragments) are existing suites. Per the operator constraint, they are verified only through PoshQC MCP tools plus CI evidence, with no `sh`/`bash`/`pwsh` wrapper scripts. The pytest parity test `test_codex_full_migration_inventory.py:83-97` covers the same S3/S4 equality locally. Under the plan below, no PowerShell file is edited, so no PowerShell format, lint, or coverage gate applies to changed files.
- bats: none of the bats suites under `tests/shell/` reads the epic skill. Only `parallel_manifest_validate.bats` and `parallel_items_validate.bats` match `epic`, for validation fixtures. No bats verification is needed beyond CI.
- CI runs pytest with branch coverage (`.github/workflows/_quality-checks.yml:81`) and PoshQC/Pester (`.github/workflows/_poshqc.yml:42`, `:82`).

## 10. Candidate Approaches and Selection

- Selected: Approach A, the operator decision.
  - Insert a new step 3 into S1/S2 (renumbering the existing steps 3-5 to 4-6) and a paraphrased sentence into S3/S4.
  - Re-baseline the S1 digest.
  - Add one pytest contract file.
  - A Grep for cross-references to lifecycle step numbers (`(?i)lifecycle.{0,40}step \d`) over `.claude/`, `.agents/`, `.codex/`, `tests/`, and `scripts/` returned no matches, so renumbering breaks no citation.
- Rejected: appending the sync text to step 2 without renumbering. It keeps the numbering but merges two distinct actions (fetch-before-branch and the main-sync gate) into one step, and it weakens the AC-1 wording "contains a pre-wave main-sync step".
- Rejected: a coordinator-local merge. It was denied by `PREIMPLEMENTATION_GATE_BLOCKED` in epic-852 (`#902 issue.md:13`), and the operator's no-hook-change ruling excludes it.

Proposed S1 step text (inserted after step 2; the planner may reword, but each fragment pinned in Section 12 must appear verbatim):

> 3. Before each wave launches (wave 0 included), `epic-orchestrator` runs `git fetch origin main` and then `git rev-list --count origin/epic/<epic-slug>-integration..origin/main`. A zero count proceeds directly to the wave. A non-zero count means `origin/main` has commits the integration branch lacks, and the main-sync runs as a dedicated chore child item before the wave launches (the `epic-852-main-sync` / PR #882 pattern): record a `features[]` entry for it in the epic checkpoint with `depends_on: []` and its own `waves[]` entry, then delegate it like any child. Its branch is created from the integration branch, merges `origin/main` with a merge commit (`git merge --no-ff origin/main`, no rebase, no force-push), resolves any conflict inside its own remediation loop, and opens a PR into the integration branch. The wave does not launch until that PR has merged into the integration branch and the sync entry's `merge_status` is `merged`; `epic-orchestrator` then re-runs step 2 so the wave branches from the synced tip.

Proposed S3 sentence, appended to the paragraph at `:67-69`: the same content in the Codex skill's terse style. It should name `git rev-list --count <integration>..origin/main`, "dedicated chore child", "merges `origin/main`", "PR into the integration branch", "must merge before the wave launches", and "a zero count proceeds directly to the wave".

## 11. Behavior Semantics

- Ordering: fetch the integration branch (step 2), fetch `origin/main`, count, then either launch the wave (count 0) or run the sync child, wait for its merge, re-fetch, and launch the wave.
- Success: the count is 0, or the sync child's PR is merged into the integration branch and confirmed by `gh pr view --json state,mergedAt,headRefOid` (re-derivation doctrine, `.claude/skills/epic-orchestrate/SKILL.md:145-147`).
- Failure: the sync child reports `blocked_conflict_loop_limit` or another blocked status. The wave does not launch, and the status is mirrored per the skill's existing merge-conflict procedure (`:227-230`).
- Edge cases:
  - Wave 0 on a prepared epic. The branch was created during planning and can already lag `origin/main`, so the check also runs before wave 0.
  - `origin/main` moves while the sync PR is open. The child re-merges per the epic-852 contingency (`plan.2026-10-10T22-52.md:185`).
  - The sync child's `feature_folder` must be unique per wave, because the validator rejects duplicates (`validate_epic_orchestrator_state.py:155-215`).

## 12. Testing Implications

New file `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py` (pytest):

1. A parametrized test over the canonical skill and its bundle copy (S1, S2). Within the `## Epic Integration Branch Lifecycle` section body (scoped by a section-extraction helper and matched with collapsed whitespace), assert these fragments: `git fetch origin main`, `git rev-list --count`, `..origin/main`, `dedicated chore child`, `epic-852-main-sync`, `merges \`origin/main\``, `PR into the integration branch`, `before the wave launches`, `zero count proceeds directly to the wave`.
2. The same test parametrized over the Codex skill and its bundle copy (S3, S4), scoped to `## Integration Branch and Child Worktrees`.
3. Ordering within S1: the `git rev-list --count` fragment appears after the step-2 fetch fragment `git fetch origin epic/<epic-slug>-integration` and before the step containing `branched from` / `origin/<integration_branch>`.
4. A negative control: the same assertion helper applied to the section text with the new step removed (a synthetic string built in-test) raises `AssertionError`. This satisfies AC-4 "fail when the step is removed".
5. A byte-parity check of S1==S2 and S3==S4 is optional, because the existing tests in Section 3 already enforce it. Do not duplicate it unless the planner wants an issue-local guard.

Edited file `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`: re-baseline the S1 digest with a `# RE-BASELINED by issue #902` comment.

Regression set to run: the new file, plus `test_parallel_orchestrator_surface_contracts.py`, `test_push_down_claude_resource_contracts.py`, `test_push_down_codex_and_agents_resource_contracts.py`, `test_codex_full_migration_inventory.py`, `test_skill_bundle_contract_repo.py`, `test_epic_bounded_child_return_contract.py`, `test_orchestrator_state_remediation_docs.py`, and `test_epic_run_kickoff_discovery_contract.py`. CI evidence is required for the Pester suites `codex-epic-runtime-contracts.Tests.ps1` and `checkpoint-hygiene-skill-contract.Tests.ps1`.

The new step must not cite any `scripts/...` path, so that `test_skill_bundle_contract_repo.py` stays green.

## Numeric Derivation Evidence

Numeric claim: "four Markdown skill surfaces carry the pre-wave main-sync step" (used by AC-3 and AC-4).

- Complete Family: every repository file, other than feature documentation under `docs/`, that restates the epic-orchestrate per-wave integration-branch lifecycle (skills, bundled skill copies, personas, bundled persona copies, entry skills).
- Exhaustive Search Scope: the whole worktree excluding `docs/**`. This covers `.claude/`, `.agents/`, `.codex/`, `.github/`, `extensions/drm-copilot/resources/`, `scripts/`, and `tests/`.
- Inclusion Rules: the file restates the per-wave lifecycle (the fetch-before-each-wave step or its paraphrase) as runtime procedure.
- Exclusion Rules: test files and fixtures; files that only reference the skill; planning-phase branch creation (`epic-plan`); kickoff-discovery fetches (`epic-run`, `.claude/agents/epic-orchestrator.md:80`); a one-line launch bullet in a persona that delegates the procedure to the skill (`.codex/agents/epic-orchestrator.toml:58`, with `:14` delegating).
- Primary Search Strategy or Query Expression: content Grep `(?i)before (starting )?each wave|current remote integration tip|current integration tip` with glob `!docs/**`.
- Primary Member Set: the raw hits are `.agents/skills/epic-orchestrate/SKILL.md`, `extensions/.../codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md`, `.claude/skills/epic-orchestrate/SKILL.md`, `extensions/.../claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`, `.codex/agents/epic-orchestrator.toml`, and `extensions/.../codex-and-agents-customizations/.codex/agents/epic-orchestrator.toml`. After the exclusion rules remove the two TOML launch bullets, the members are the four skill files.
- Primary Count: 4.
- Cross-check Search Strategy or Query Expression: path Glob `**/epic-orchestrate/**` (skill folders), followed by `Read` of each persona found by Glob `**/*epic-orchestrat*` to classify each one as restating or referencing.
- Cross-check Member Set: `.agents/skills/epic-orchestrate/SKILL.md`, `.claude/skills/epic-orchestrate/SKILL.md`, `extensions/.../claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`, and `extensions/.../codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md`. The four personas found by Glob (`.claude/agents/epic-orchestrator.md`, its bundle copy, `.codex/agents/epic-orchestrator.toml`, and its bundle copy) are classified as reference or launch-bullet only (Section 6) and excluded.
- Cross-check Count: 4.
- Member-set Comparison: the normalized primary set, {.claude skill, .claude skill bundle, .agents skill, .agents skill bundle}, equals the normalized cross-check set. The counts agree (4 = 4). The assertion is supported.

## Recommended change set

Edit:

1. `.claude/skills/epic-orchestrate/SKILL.md`: inside `## Epic Integration Branch Lifecycle` only, insert the new step 3 and renumber the existing steps 3-5 to 4-6.
2. `extensions/drm-copilot/resources/claude-customizations/.claude/skills/epic-orchestrate/SKILL.md`: byte copy of item 1 (LF).
3. `.agents/skills/epic-orchestrate/SKILL.md`: inside `## Integration Branch and Child Worktrees` only, add the paraphrased main-sync sentence.
4. `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/epic-orchestrate/SKILL.md`: byte copy of item 3 (LF).
5. `tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py`: replace the `.claude/skills/epic-orchestrate/SKILL.md` digest and add a `# RE-BASELINED by issue #902` comment.

Create:

6. `tests/scripts/dev_tools/test_epic_orchestrate_main_sync_contract.py`: the pytest contract tests in Section 12.

Feature-folder evidence under `docs/features/active/2026-10-11-epic-integration-branch-not-synced-with-main-902/evidence/<kind>/`.

Not edited:

- `.claude/agents/epic-orchestrator.md` and its bundle copy (reference only, and a pinned digest).
- `.codex/agents/epic-orchestrator.toml` and its bundle copy.
- `.claude/skills/epic-run/SKILL.md` and `.claude/skills/epic-plan/SKILL.md`, and their Codex and bundle copies.
- Every file under `.claude/hooks/`, `.codex/hooks/`, `.claude/rules/`, and `.github/instructions/` (AC-5).
- Validators under `scripts/dev_tools/` and `extensions/drm-copilot/src/lib/validate/`.

## Risks

- Frozen digest pin. Any S1 edit fails `test_frozen_epic_surface_matches_pinned_baseline_digest` until it is re-baselined. If concurrent item #900, or any other branch, also edits `.claude/skills/epic-orchestrate/SKILL.md` or `parallel_orchestrator_surface_expectations.py:166-167`, the digest line conflicts on merge and must be recomputed after the second merge. No #900 feature folder exists in this worktree, so its exact file set was not verified.
- Bundle drift. The mirrors are hand-maintained, and an edit to S1 or S3 without the byte copy fails three pytest parity tests and the CI Pester parity test. Verify with `git hash-object` on each pair.
- Wave-barrier hook. A sync child delegated without a prior `features[]` row is denied (`enforce-epic-wave-barrier.ps1:326-331`). The skill text must require writing the row first.
- `issue_num` collision. A sync child that reuses a manifest child's `issue_num` corrupts `depends_on` resolution by `issue_num` (`_epic_orchestrator_state_resolution.py:99-108`). Use the epic issue number or a dedicated issue.
- `origin/main` keeps moving. The count may be non-zero again after the sync merges. The step re-runs the check before the wave via the re-fetch. An unbounded loop is possible in principle. The plan may cap it at one sync per wave and accept the residual lag; this is a design decision for the planner.
- Pester verification is CI-only under the operator constraint. Local evidence for S3/S4 parity relies on the pytest equivalents (`test_codex_full_migration_inventory.py:83-97`, `test_push_down_codex_and_agents_resource_contracts.py:215-228`).
- Line-ending sensitivity. The digest is computed over raw bytes. `.gitattributes:1` enforces LF, but an editor that writes CRLF into the working tree produces a digest that differs from CI.
