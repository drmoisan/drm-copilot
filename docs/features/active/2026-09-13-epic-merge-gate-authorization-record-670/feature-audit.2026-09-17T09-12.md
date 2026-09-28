# Feature Audit: Epic Merge Gate Standalone Authorization Record (#670)

---

**Audit Date:** 2026-09-17
**Feature Folder:** `docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670`
**Base Branch:** `origin/epic/worktree-scoped-state-resolution-integration`
**Head Branch:** `feature/2026-09-13-epic-merge-gate-authorization-record-670`
**Work Mode:** `full-bug`
**Audit Type:** Initial acceptance review

---

## Scope and Baseline

- **Base branch:** `origin/epic/worktree-scoped-state-resolution-integration` (commit `79fd5a95c00cd99238b69a3195788206ae96f4cd`). This is an epic child (F3 of `worktree-scoped-state-resolution`), so the PR base is the integration branch, not `main`.
- **Head branch/commit:** `feature/2026-09-13-epic-merge-gate-authorization-record-670` (commit `332ab835133af49092d8155c40ea0152560f5557`, 9 commits ahead of base)
- **Merge base:** `79fd5a95c00cd99238b69a3195788206ae96f4cd` (equal to the base tip; confirmed with `git merge-base HEAD origin/epic/worktree-scoped-state-resolution-integration`)
- **Evidence sources:**
  - Primary: `artifacts/pr_context.summary.txt` (generated 2026-09-17 12:59:35 UTC for head `332ab835`; current, not stale)
  - Secondary baseline diff: `artifacts/pr_context.appendix.txt`
  - Feature evidence: `docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/evidence/**` (40 executor files plus `evidence/qa-gates/review-clean-state-verification.2026-09-17T09-12.md` written by this review)
  - Additional evidence: `artifacts/pester/powershell-coverage.xml` and `artifacts/pester/pester-junit.xml` (parsed directly); commands run by this review (see the policy audit, Appendix B)
- **Feature folder used:** `docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670`
- **Requirements source:** `spec.md`, section `## Acceptance Criteria`
- **Work mode resolution note:** `issue.md` line 14 carries `- Work Mode: full-bug`, so `spec.md` is the sole AC source. `spec.md` line 111 confirms that no `user-story.md` exists.
- **Scope note:** Full branch diff against the resolved base (58 files). The branch's changes to `spec.md` are checkbox flips only (`- [ ]` to `- [x]`); no criterion text was altered (verified with `git diff ... -- spec.md`). Numbering AC-01 to AC-42 below follows document order and matches the executor's numbering in `evidence/issue-updates/ac-status-and-followups.2026-09-13T20-46.md`.

---

## Acceptance Criteria Inventory

**Authoritative AC source files for this run:**
- `docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/spec.md` (only source; 42 checkbox items)

### Acceptance criteria

#### Behaviour — the authorization record

1. (AC-01) With a valid authorization record naming PR 691 present in any one of the three orchestrator checkpoints and a matching envelope `session_id`, `gh pr merge 691 --merge` is allowed, where it denies today. Pinned by a named case in `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1`.
2. (AC-02) The allow in the preceding criterion holds when the record is carried in the per-feature checkpoint, when it is carried in the epic checkpoint, and when it is carried in the parallel checkpoint. Three named cases, one per checkpoint.
3. (AC-03) A record naming a different PR denies with `STANDALONE_MERGE_AUTHORIZATION_PR_MISMATCH`, proved by the four-property discriminator: record naming 501 only, command `cd /repo/worktrees/501 && gh pr merge --merge 777`, all three read seams mocked with only one populated, and a paired positive case merging 501 that allows.
4. (AC-04) With no `standalone_merge_authorizations` key on any of the three checkpoints, an in-scope command naming an explicit PR denies with `STANDALONE_MERGE_AUTHORIZATION_ABSENT`, and the deny message states that an authorized path exists and how to take it.
5. (AC-05) Every non-PR-specific spelling denies with `STANDALONE_MERGE_AUTHORIZATION_NOT_PR_SPECIFIC`, with one named case for each of: block value `true`; block value a string; block value an object; empty array; entry not an object; `pr_number` absent; `pr_number` `null`; `pr_number` `0`; `pr_number` negative; `pr_number` a non-integer number; `pr_number` a digit-spelling string; `pr_number` the wildcard string `"*"`; `pr_number` an array.
6. (AC-06) Every field-shape failure on the matched entry denies with `STANDALONE_MERGE_AUTHORIZATION_MALFORMED` and a message naming the failing field, with one named case per field: `pr_url`, `issue_num`, `branch_name`, `authorized_by`, `authorized_at`, `basis` empty, `basis` below the stated minimum length, and `run_slug` present but empty.
7. (AC-07) A record whose `session_id` differs from the live envelope's denies with `STANDALONE_MERGE_AUTHORIZATION_MALFORMED` naming `session_id`; an envelope carrying no `session_id` at all also denies, naming `session_id`. Two named cases.
8. (AC-08) A bare `gh pr merge --merge` carrying no explicit PR number denies with the **existing** line-433 `EPIC_MERGE_GATE_BLOCKED` reason text even when a valid authorization record is present. Pinned by a named case that asserts the existing text, not merely the token.
9. (AC-09) Branch 4 is evaluated after branches 1, 2 and 3. Pinned by a named case in which a parallel checkpoint authorizes item 501 at `ci_green` and a standalone record names 777 only: the command merging 501 is allowed via branch 3, and the case asserts the allow carries no standalone-authorization reason.
10. (AC-10) The field-check evaluation order is fixed and the first failure wins, so a record failing two field checks emits a deterministic message. Pinned by a named case supplying a record that violates both `pr_url` and `basis` and asserting the message names `pr_url`.

#### Trigger scope

11. (AC-11) `gh pr merge 691 --squash` with a valid authorization record naming 691 present is **allowed** as out of trigger scope. New named case; this is the paired case proving the record does not widen trigger scope.
12. (AC-12) `tests/scripts/claude-hooks/enforce-epic-merge-gate.Tests.ps1:27` (`It 'allows gh pr merge without --merge (e.g., --squash)'`) is green and its text is unedited.
13. (AC-13) This spec contains no acceptance criterion asserting that `--squash` denies, and the corrected framing — that `--squash` is out of trigger scope and allowed today on both runtimes — is recorded in this spec and reflected in the hook's header comment.

#### Must not regress (carried verbatim from the epic)

14. (AC-14) **The `pr_number` matcher is unchanged.** Verified two ways, both of which can fail. (a) A named Pester case asserts `Get-EpicMergeGateCommandPrNumber` returns 410 for the number-before-flag form, 410 for the flag-before-number form, 410 for the equals-joined form, 688 for the cd-prefixed form, 777 for the false-allow form, and nothing for the bare form — the same six behaviours the existing suites pin, re-asserted after the change. (b) Running `git diff origin/epic/worktree-scoped-state-resolution-integration -- .claude/hooks/enforce-epic-merge-gate.ps1` produces no hunk whose context or changed lines fall inside the `Get-EpicMergeGateCommandPrNumber` function body, and the same diff is paired with `git status --porcelain` showing the file as modified, so a diff that returns nothing because the change was never written or never staged is distinguishable from a diff that returns nothing because the function is untouched.
15. (AC-15) **The pre-implementation gate's restrictions are not weakened.** No file matching `.claude/hooks/enforce-orchestration-preimplementation-gate*.ps1` or its Codex mirrors is modified by this change, verified by `git diff --name-only origin/epic/worktree-scoped-state-resolution-integration` listing none of them, and the gate's existing Pester suites are green and unedited.
16. (AC-16) **Epic and standalone topologies behave exactly as now when cwd and target coincide.** The three `$script:*CheckpointPath` assignments and the Codex repository-root anchoring are unchanged, and every branch-1, branch-2 and branch-3 allow and deny case in the existing suites is green and unedited.
17. (AC-17) **Gates still deny when the required evidence is genuinely absent.** All existing fail-closed cases stay green: both checkpoints absent; both checkpoints unreadable; parallel checkpoint absent; parallel checkpoint malformed; bare merge with a parallel checkpoint present; empty payload; unparseable payload; the end-to-end nested-envelope deny. A checkpoint carrying no `standalone_merge_authorizations` key produces the same decision for every command as before the change, pinned by at least one named case per existing branch.

#### Codex parity

18. (AC-18) `.codex/hooks/enforce-epic-merge-gate.ps1` gains the standalone branch in place, with the same activation condition as the Claude side (a well-formed record naming this PR, with a matching `session_id`), covered by named cases in `tests/scripts/codex-hooks/enforce-epic-merge-gate-authorization.Tests.ps1`.
19. (AC-19) All four reason-code tokens are spelled byte-identically on both runtimes, verified by a named assertion that compares the token literals extracted from the Claude helpers file and the Codex hook.
20. (AC-20) The Codex hook still has no parallel allow path: the tokens `route_id`, `items`, and `parallel` occur zero times in `.codex/hooks/enforce-epic-merge-gate.ps1` after the change, as they do before it.
21. (AC-21) The Codex allow representation stays `$null`, the `exit 2` throw channel is unchanged, the `step9_status` accepted set is unchanged, and the `epic_mode` type test is unchanged.

#### Registration, configuration, and file size

22. (AC-22) Both bundled Claude mirrors are updated: the modified `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate.ps1` and the new `extensions/drm-copilot/resources/claude-customizations/.claude/hooks/enforce-epic-merge-gate-authorization.ps1`, with `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py` green.
23. (AC-23) The bundled mirror of `.claude/rules/orchestrator-state.md` and of `.claude/skills/parallel-orchestrate/SKILL.md` are updated to match their repository-side files.
24. (AC-24) `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` is added to the `paths` array of `extensions/drm-copilot/resources/claude-customizations/pack-manifests/core.json`, with `tests/scripts/dev_tools/test_push_down_claude_pack_manifest_completeness.py` green.
25. (AC-25) `.claude/hooks/enforce-epic-merge-gate-authorization.ps1` is added to `CodeCoverage.Path` in `scripts/powershell/PoshQC/settings/pester.runsettings.psd1`, and the coverage baseline was taken after that entry was added.
26. (AC-26) The Codex bundled mirror `extensions/drm-copilot/resources/codex-and-agents-customizations/.codex/hooks/enforce-epic-merge-gate.ps1` is byte-identical to `.codex/hooks/enforce-epic-merge-gate.ps1`, with the Codex runtime-contract suite green.
27. (AC-27) Every file created or modified by this change is under 500 lines, verified by an enumerated per-file line count recorded in the evidence artifacts, because no automated test enforces the cap on `.claude/hooks/**`. The count explicitly includes `.claude/hooks/enforce-epic-merge-gate.ps1`, `.claude/hooks/enforce-epic-merge-gate-authorization.ps1`, `.codex/hooks/enforce-epic-merge-gate.ps1`, both new test suites, and all four bundled mirrors.
28. (AC-28) `.claude/settings.json` is unmodified.

#### Documentation and disclosure

29. (AC-29) The honest-disclosure text appears in all three required locations: the `.NOTES` block of `.claude/hooks/enforce-epic-merge-gate.ps1`, the header comment of `.claude/hooks/enforce-epic-merge-gate-authorization.ps1`, and the new section of `.claude/rules/orchestrator-state.md`. Each copy states that the record is a policy-level auditable declaration and not a cryptographic or security control, that `authorized_by` is a declaration the hook does not verify, that the record is not tamper-proof against a same-session writer, and what the `session_id` cross-check does and does not stop.
30. (AC-30) The hook's header comment block no longer says the gate allows the merge when "one of three" conditions holds; it documents four conditions, and the standalone-exclusion paragraph at the current lines 23-27 is rewritten so the file's own documentation is not left false.
31. (AC-31) `.claude/rules/orchestrator-state.md` gains a `standalone_merge_authorizations` scope-and-backward-compatibility section stating the invariants are additive and key-gated, plus one Enforcement bullet. No JSON Schema file is authored, imported, or read for the block, and the Enforcement bullet states that the Python checkpoint validator does not currently validate this block.
32. (AC-32) `.claude/skills/parallel-orchestrate/SKILL.md` documents the writer procedure: which fields a coordinating session writes, into which checkpoint, and that a blanket flag is rejected. The existing `**Merge-gate authorization.**` paragraph is updated to name four allow conditions rather than describing only the parallel one.
33. (AC-33) The writer surface is bounded to exactly the two authored surfaces named above plus their bundled mirrors. No other skill, agent, or rule file is edited to write or describe the record.
34. (AC-34) The two closed anti-patterns (synthetic `items[]` injection; switching to `--squash`) are recorded as closed in this spec, and the implementation introduces neither.
35. (AC-35) Follow-ups FU-1 through FU-4 are filed as issues, or their deferral is explicitly recorded in the pull-request description, before this feature is closed.

#### Tests, toolchain, and coverage

36. (AC-36) Every currently-passing case in all four existing suites (`enforce-epic-merge-gate.Tests.ps1`, `enforce-epic-merge-gate.TriggerScoping.Tests.ps1`, `enforce-epic-merge-gate-decision-surface.Tests.ps1`, `enforce-epic-merge-gate-trigger-scoping.Tests.ps1`) is green and its text is unedited, with the sole permitted exception being additions the matrix requires. Verified by `git diff origin/epic/worktree-scoped-state-resolution-integration` over those four files showing no deletion and no modification of an existing `It` block.
37. (AC-37) `tests/scripts/claude-hooks/enforce-epic-merge-gate.Authorization.Tests.ps1` exists, is table-driven, and carries a header determinism block stating that every case drives the pure decision seam, mocks every checkpoint read seam, writes nothing to disk, starts no process, and reads no clock.
38. (AC-38) No test in this change creates a temporary file, uses `Mock gh`, uses `Mock git`, uses `Start-Sleep`, or makes a network call, with the PowerShell test-purity check green.
39. (AC-39) No file under `.claude/hooks/**` added or modified by this change invokes Python by any route, with `tests/scripts/claude-runtime/enforcement-hooks-no-python-invocation.Tests.ps1` green and its allowlist still empty.
40. (AC-40) Line coverage is at least 85 percent for `.claude/hooks/enforce-epic-merge-gate-authorization.ps1`, `.claude/hooks/enforce-epic-merge-gate.ps1`, and `.codex/hooks/enforce-epic-merge-gate.ps1`, with baseline, post-change, and comparison artifacts stored under `docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/evidence/coverage/`. The baseline was taken after the new file was added to `CodeCoverage.Path`.
41. (AC-41) Coverage for the changed lines does not decrease relative to the recorded baseline.
42. (AC-42) The full toolchain loop completed in a single clean pass: format, lint, architecture and contract checks, unit tests, with no stage auto-fixing a file on the final pass. Type checking is not applicable to PowerShell.

---

## Acceptance Criteria Evaluation

All Pester results below come from this review's runs: 17 suites in the review worktree (434 passed, 0 failed) and 10 suites in a clean `git archive` export of HEAD (227 passed, 0 failed), unless stated otherwise.

| # | Criterion | Status | Evidence | Verification command(s) | Notes |
|---|-----------|--------|----------|--------------------------|-------|
| AC-01 | Valid 691 record allows `gh pr merge 691 --merge` | PASS | `Authorization.Tests.ps1:79-81` rows allow; parent lines 420-424 | `Invoke-Pester` (Authorization suite: 15/15) | The fail-first artifact shows these rows failing before the change. |
| AC-02 | Allow holds in each of the three checkpoints | PASS | Three named rows: per-feature, epic, parallel (`:79`, `:80`, `:81`) | same | The Codex suite adds child and epic placements. |
| AC-03 | PR mismatch via the four-property discriminator | PASS | `:87` (777 denies `..._PR_MISMATCH`, only the epic seam populated) and `:88` (501 allows) | same | The unauthorized number is the operand, and 501 appears in the `cd` path. |
| AC-04 | Absent key denies `..._ABSENT` with guidance | PASS | `:83` row; `:116-127` asserts both tokens and `orchestrator-state\.md`. Message: "an authorized standalone merge path exists. To authorize a standalone merge, write a standalone_merge_authorizations record ..." | same | The cited rule section exists. |
| AC-05 | 13 non-PR-specific spellings | PASS | `AuthorizationFields.Tests.ps1:60-80`, 13 named rows matching the list exactly | `Invoke-Pester` (AuthorizationFields: 37/37) | Row 5 of the matrix also names `pr_number` object; the AC list does not require it. The block-value object row covers object shape. |
| AC-06 | Field-shape failures name the field | PASS | `AuthorizationFields.Tests.ps1:84-100`, 8 named rows (`pr_url`, `issue_num`, `branch_name`, `authorized_by`, `authorized_at`, `basis` empty, `basis` short, `run_slug` blank) | same | Asserted at predicate level: code plus `'<Field>'` in the message. |
| AC-07 | Session differs or absent denies naming `session_id` | PASS | `Authorization.Tests.ps1:85-86` with `'session_id'` assertion at `:105-107` | `Invoke-Pester` (Authorization) | Two more predicate cases cover a blank record session and a case-only mismatch. |
| AC-08 | Bare merge keeps the existing fall-through text | PASS | `:129-140`, `Should -BeExactly $script:Line433Text`; parent line 429 unchanged | same | The text sits at line 429 after the factory move (433 in the base). |
| AC-09 | Branch 4 evaluated after branches 1-3 | PASS | `:142-155`: branch 3 allows 501; branch 4 mocked to throw; `Should -Invoke ... -Times 0 -Exactly`; JSON has no `STANDALONE_MERGE_AUTHORIZATION` | same | Stronger than the AC requires. |
| AC-10 | Fixed order, first failure wins | PASS | `AuthorizationFields.Tests.ps1:102-111` (`pr_url` named, `basis` not) | `Invoke-Pester` (AuthorizationFields) | Code order at helpers lines 299-328 matches the spec. |
| AC-11 | `--squash` with a valid record is allowed | PASS | `Authorization.Tests.ps1:89` row; Codex `:84` row | `Invoke-Pester` | Scope filter unchanged (parent 386-399). |
| AC-12 | Existing line-27 squash test green and unedited | PASS | `enforce-epic-merge-gate.Tests.ps1:27` present; `git diff --stat ... -- tests/` lists only the three new files; suite 56/56 | `git diff --stat origin/epic/worktree-scoped-state-resolution-integration...HEAD -- tests/`; `Invoke-Pester` | |
| AC-13 | No squash-denies AC; corrected framing recorded and in the header | PASS | `spec.md` "Corrected framing" section; no AC asserts a squash deny; parent header line 34: "Trigger scope: --squash is out of scope for this gate and is allowed on both runtimes." | Read of `spec.md` AC section and hook lines 1-51 | Executor's `Select-String` check recorded in `ac-status-and-followups`. |
| AC-14 | `pr_number` matcher unchanged | PASS | (a) `Authorization.Tests.ps1:159-166` six spellings, green. (b) Base-anchored diff hunks start at old lines 5, 19, 35, 44, 324, and 430; the function body spans old lines 131-175, so no hunk touches it. The file is listed as `M` in `git diff --name-status`, which distinguishes a written change from an absent one. | `git diff origin/epic/worktree-scoped-state-resolution-integration...HEAD -- .claude/hooks/enforce-epic-merge-gate.ps1`; `git diff --name-status ...` | The change is committed, so `git status --porcelain` is clean; the committed `M` status serves the same purpose. The executor's staged-state proof is in `p4-parent-cap-and-matcher`. |
| AC-15 | Pre-implementation gate not weakened | PASS | `git diff --stat ... -- '.claude/hooks/enforce-orchestration-preimplementation-gate*' '.codex/hooks/enforce-orchestration-preimplementation-gate*'` lists nothing; three gate suites green in this review (43, 35, 19 passed); six green in `p7-must-not-regress` | same, plus `Invoke-Pester` | |
| AC-16 | Topologies unchanged when cwd and target coincide | PASS | Parent lines 63-65 appear only as diff context; the Codex diff is additions only (no anchoring lines touched); four existing suites 88/88 green and unedited | `git diff ...` for both hooks; `Invoke-Pester` | |
| AC-17 | Gates still deny when evidence is absent | PASS | Existing fail-closed cases green in both runs; no existing suite edited. Key-absent behaviour is pinned by existing suites for each branch (no fixture carries the key) and by the Codex branch-1 and branch-2 guard rows | `Invoke-Pester` (worktree and clean export) | For explicit-PR commands, deny reasons now append a standalone code after the unchanged `EPIC_MERGE_GATE_BLOCKED` token; the decision is unchanged. |
| AC-18 | Codex standalone branch in place, same activation | PASS | Codex lines 166-182 and 289-358; suite rows `:75-81` | `Invoke-Pester` (Codex authorization: 28/28) | Reads only the child and epic checkpoints. |
| AC-19 | Byte-identical reason tokens, named assertion | PASS | Codex suite `:185-192` compares sorted unique token sets (4 = 4) | same | |
| AC-20 | Codex has zero `route_id`/`items`/`parallel` tokens | PASS | `[regex]::Matches` counts: 0, 0, 0 | review script `verify.ps1` | |
| AC-21 | Codex `$null` allow, exit 2, `step9_status`, `epic_mode` unchanged | PASS | Codex diff is additions only (no removed lines); allow rows assert `Should -BeNullOrEmpty`; throw-channel rows `:119-125` | `git diff ... -- .codex/hooks/enforce-epic-merge-gate.ps1`; `Invoke-Pester` | |
| AC-22 | Both bundled Claude hook mirrors updated; resource-contract test green | PASS | SHA-256 match for both pairs (`77C30E885901...`, `08FB2DE608B3...`). `test_push_down_claude_resource_contracts.py` passes in the clean export (17/17 across the three files). In the review worktree it fails only on the gitignored `.claude/state/` file (issue #510; `git check-ignore` confirms `.gitignore:68`) | `Get-FileHash`; `python -m pytest <three files>` in the clean export | See `evidence/qa-gates/review-clean-state-verification.2026-09-17T09-12.md`. |
| AC-23 | Rule and skill mirrors match | PASS | SHA-256 match (`0085540BBEC5...`, `6A9743D8A85A...`) | `Get-FileHash` | |
| AC-24 | `core.json` entry; manifest-completeness test green | PASS | `core.json` line 30; test green in both the worktree and the clean export | `pytest test_push_down_claude_pack_manifest_completeness.py` | |
| AC-25 | `CodeCoverage.Path` entry; baseline after registration | PASS | `pester.runsettings.psd1` lines 45-46. `p1-post-registration-coverage` (08:05, after commit `540c915c`) shows the helpers `sourcefile` row and an analyzed-file count rising from 101 to 102 | Read of the diff and evidence | |
| AC-26 | Codex bundle byte-identical; runtime-contract suite green | PASS | SHA-256 `AF9E593748E0...` both paths; `codex-epic-runtime-contracts.Tests.ps1` 10/10 | `Get-FileHash`; `Invoke-Pester` | |
| AC-27 | Every created or modified file under 500 lines | PASS | 483, 443, 379, 483, 443, 379, 177, 295, 295, 168, 203, 194; Markdown exempt. Enumerated in `evidence/qa-gates/p7-line-counts.2026-09-13T20-46.md` (with addendum) and re-counted by this review | `@(Get-Content -LiteralPath $f).Count` | |
| AC-28 | `.claude/settings.json` unmodified | PASS | Not in the branch diff | `git diff --stat ... -- .claude/settings.json` (empty) | |
| AC-29 | Disclosure in three locations with all four elements | PASS | Parent `.NOTES` lines 46-50; helpers header lines 20-35; rule file new section. Each states policy-level and not a security control, `authorized_by` unverified, not tamper-proof against a same-session writer, and what the `session_id` check does and does not stop | Read of the three files | |
| AC-30 | Header documents four conditions; exclusion paragraph rewritten | PASS | Parent line 8 "one of four"; conditions 1-4 at lines 11-26; the rewritten paragraph at lines 28-34 no longer claims standalone runs cannot merge | Read of hook lines 1-51 | |
| AC-31 | Rule section plus Enforcement bullet; no schema; Python validator gap stated | PASS | `## Standalone-Merge-Authorization Scope and Backward Compatibility` ("The invariants are additive and key-gated", "No JSON Schema file is authored, imported, or read"); Enforcement bullet states the Python validator "does not currently validate standalone_merge_authorizations entries" and names FU-3 | `git diff ... -- .claude/rules/orchestrator-state.md` | No schema file in the diff. |
| AC-32 | Writer procedure in parallel-orchestrate; four conditions named | PASS | SKILL.md paragraph names four allow conditions in order; writer steps 1-4 (checkpoint, fields, `session_id`, explicit PR); blanket flag rejected | `git diff ... -- .claude/skills/parallel-orchestrate/SKILL.md` | |
| AC-33 | Writer surface bounded | PASS | The only non-hook, non-test documentation edits are the rule file, the skill, and their mirrors | `git diff --name-status ...` | |
| AC-34 | Anti-patterns closed and absent | PASS | `spec.md` "Closed anti-patterns". The diff writes no `items[]` entries (the only `items` literal in new code is a test fixture for branch 3). `--squash` handling unchanged | Diff inspection | |
| AC-35 | FU-1 to FU-4 filed or deferral in PR description | UNVERIFIED | No pull request exists yet. The deferral paragraph is prepared verbatim in `evidence/issue-updates/ac-status-and-followups.2026-09-13T20-46.md`. The criterion's deadline is feature closure, which has not occurred | Search of the PR-context summary: "PRs in range: (none)" | Hand-off to PR authoring; not a defect in the delivered change. Left unchecked. |
| AC-36 | Four existing suites green and unedited | PASS | `git diff --stat ... -- tests/` shows only 3 added files; suites 56 + 12 + 13 + 7 = 88 passed | `git diff`; `Invoke-Pester` | |
| AC-37 | Authorization suite table-driven with determinism header | PASS | `-ForEach` matrix at `:78-90`; header lines 11-17 state all five properties | Read of the file | |
| AC-38 | No temporary files, `Mock gh`/`git`, `Start-Sleep`, or network; purity check green | PASS | Pattern scan: 0 matches per new file; `Invoke-PowerShellTestPurityDecision` returned no denial for all three | review script `purity.ps1`, `verify.ps1` | |
| AC-39 | No Python invocation from changed hooks; guard green | PASS | Token scan 0 in both hook files; `enforcement-hooks-no-python-invocation.Tests.ps1` 27/27 | `Invoke-Pester` | |
| AC-40 | Line coverage at least 85% for three files; artifacts stored; baseline after registration | PASS | Parsed `artifacts/pester/powershell-coverage.xml`: helpers 100.00% (100/100), parent 96.67% (116/120), Codex 99.34% (150/151). Baseline, post-change, and comparison artifacts exist under `evidence/baseline/` and `evidence/qa-gates/` | Coverage XML parse (`cov.ps1`) | The spec's `evidence/coverage/` path is non-canonical. The executor recorded `EVIDENCE_LOCATION_OVERRIDE_REJECTED` and used canonical folders, as the non-overridable evidence rule requires. |
| AC-41 | Changed-line coverage does not decrease | PASS | Changed executable lines 187/187 = 100.00%. Per file, the post-change figure is at least the post-registration baseline (100.00 ≥ 100.00; 96.67 ≥ 96.49; 99.34 ≥ 98.59). No previously covered line became uncovered | `coverage-comparison.2026-09-13T20-46.md`; review parse | The parent's Phase 0 figure of 96.72% differs only because 8 covered lines moved to the helpers file; the same 4 entry-point lines are uncovered throughout. |
| AC-42 | Full toolchain loop in a single clean pass | PASS | On the committed tree, every stage is clean with no auto-fix: format check 6/6 already formatted; lint 0 diagnostics; contract tests 17/17 (clean export); unit tests 434/434 targeted. The whole-tree run's only 2 failures (JUnit) pass 227/227 in the clean export, so they depend on the live gitignored checkpoint, not on the tree. The executor's pass 2 also had no auto-fix | See `evidence/qa-gates/review-clean-state-verification.2026-09-17T09-12.md` | The executor left this unchecked because its plan task required every row to exit 0 in the orchestrated worktree. This review isolated the environmental cause and verified each stage directly. |

---

## Summary

**Overall Feature Readiness:** PASS

**Criteria summary:**
- **PASS:** 41 criteria
- **PARTIAL:** 0 criteria
- **UNVERIFIED:** 1 criterion (AC-35, pending PR authoring)
- **FAIL:** 0 criteria

**Top gaps preventing PASS:**

1. None in the delivered change. AC-35 is a PR-description hand-off: the PR author must include the FU-1 to FU-4 deferral paragraph (or file the four issues) before the feature is closed.

**Recommended follow-up verification steps:**

1. At PR authoring, copy the deferral paragraph from `evidence/issue-updates/ac-status-and-followups.2026-09-13T20-46.md` into the PR description, then check off AC-35.
2. Confirm CI is green on the PR head, dispatching the workflow manually if the epic-child PR into `epic/worktree-scoped-state-resolution-integration` does not trigger it.
3. At rollout, watch the first real standalone merge for `..._MALFORMED` naming `session_id`, which would indicate the Bash envelope lacks `session_id` (spec risk table).

---

## Acceptance Criteria Check-off

Per the acceptance-criteria tracking rules:
- Criteria evaluated as **PASS** may be checked off in the authoritative source file(s) if they are represented as markdown checkboxes and are not already checked.
- Criteria evaluated as **PARTIAL**, **FAIL**, or **UNVERIFIED** must remain unchecked.

Actions taken by this review in `spec.md`:
- Newly checked off: AC-42 ("The full toolchain loop completed in a single clean pass ..."), evaluated PASS above.
- Left checked: AC-01 to AC-34 and AC-36 to AC-41 (checked by the executor; each independently re-evaluated as PASS here).
- Left unchecked: AC-35 (UNVERIFIED).
- No criterion text was modified, and no checked item was reverted.

### AC Status Summary

- Source: `docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/spec.md`
- Total AC items: 42
- Checked off (delivered): 41
- Remaining (unchecked): 1
- Items remaining: "Follow-ups FU-1 through FU-4 are filed as issues, or their deferral is explicitly recorded in the pull-request description, before this feature is closed."

| Source File | Total AC | Checked (PASS) | Unchecked | Notes |
|-------------|----------|----------------|-----------|-------|
| `docs/features/active/2026-09-13-epic-merge-gate-authorization-record-670/spec.md` | 42 | 41 | 1 | Checkbox-backed; sole source for `full-bug` |
