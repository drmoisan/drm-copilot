# Feature Audit — cleanup-worktrees-sanctioned-removal-manifest (Issue #635)

- Date: 2026-09-08
- Auditor: feature-review agent
- Feature folder: `docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635`

## Scope and Baseline

| Field | Value |
| --- | --- |
| Base branch (resolved) | `epic/cleanup-merged-worktrees-hardening-integration` |
| Merge base | `0ea7e577ea787017541c3164fbb97b7d12d8ab57` |
| Head under review | `4d5ecaca609cc1f2d61171be58effc545078771d` |
| Caller-supplied diff anchor | `d250cf72ee24139735e7f08b07d002ae0e4f1d00` |
| Code scope | 15 files, 1833 insertions, 18 deletions (`git diff --stat 0ea7e577 HEAD -- .claude .codex extensions scripts tests`) |
| Work mode | `full-bug` (marker `- Work Mode: full-bug` at `issue.md`) |
| AC source | `spec.md` only |
| AC source not used | `user-story.md` — present in the feature folder but not an AC source under `full-bug` |
| PR context | `artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt`, regenerated during this review against the resolved base; both carry `Head SHA: 4d5ecaca...` and an identical generated-context timestamp |

The branch is based on the epic integration branch, not `main`. `git merge-base main HEAD` resolves
to `0542c92a`, and diffing from there would attribute issue #545's merged edits to this feature. The
audit therefore uses the merge base with the resolved base branch, `0ea7e577`. That merge base and
the caller-supplied anchor `d250cf72` differ only by the integration branch's own `epic-status.md`
(7 lines) and yield an identical code scope; both were computed and cross-checked.

The branch also carries a clean merge of the integration branch at `0ea7e577`, which changed only
`epic-status.md`. No conflict arose and no file this feature changed was touched by it.

## Acceptance Criteria Inventory

- Source file: `docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/spec.md`
- Section: `## Acceptance Criteria` (line 873) through the next equal-or-shallower heading
  (`## Risks & Mitigations`, line 1037)
- Identifiers: **AC-01 through AC-37**
- Total checkbox items in the section: **37**
- Checked at review start: **37**
- Unchecked at review start: **0**

Excluded from the inventory, correctly: the severity radio-button block in `issue.md`
(`- [ ] Blocker`, `- [x] High`, `- [ ] Medium`, `- [ ] Low`). Those are a single-select control whose
unselected options render as unchecked boxes; they are not acceptance criteria, and under `full-bug`
`issue.md` is not an AC source in any case.

Also confirmed: no criterion text was modified during execution. `git diff d250cf72 4d5ecaca -- spec.md`
shows 37 lines changed, every one of them a `- [ ]` to `- [x]` transition on the criterion's first
line, with the criterion prose byte-identical on both sides. No criterion was added, removed, or
reworded.

## Acceptance Criteria Evaluation

Every criterion below was evaluated against the repository at head `4d5ecaca`, not against the
executor's evidence prose alone. Where a criterion asserts a test outcome, the test's presence and
shape were read in the suite file and its outcome read from the run's JUnit XML.

### Fail-before regression

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC-01 | PASS | `It 'allows removal when a fresh manifest record authorizes the target'` present in `enforce-epic-worktree-removal-gate.Tests.ps1` under the `manifest branch` Describe, asserting `permissionDecision -Be 'allow'` with both checkpoint seams mocked to record no target. Suite reports 50 tests, 0 failures. Fail-before recorded in `evidence/regression-testing/fail-before-manifest-allow.2026-09-06T23-09.md` (EXIT 4, node 1 of 4). |
| AC-02 | PASS | Same `It` name present in `enforce-parallel-worktree-removal-gate.Tests.ps1` for `Invoke-ParallelWorktreeRemovalGateDecision`. Suite reports 49 tests, 0 failures. Fail-before node 2 of 4 in the same artifact. |

### Condition 10 — narrow-scope deny pins

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC-03 | PASS | `It 'denies a manifest-covered removal whose target an epic checkpoint records'`. The checkpoint fixture is `{"features":[{"worktree_path":"/repo/worktrees/cleanup-target","merge_status":"in_progress"}]}` — `in_progress` is outside `{merged, worktree_removed}`, so the existing branch does not authorize either and the deny is attributable to the exclusion alone. Asserts `deny` and `-BeLike 'EPIC_WORKTREE_REMOVAL_BLOCKED*'`. The manifest fixture in the enclosing `BeforeEach` satisfies conditions 1-9 for the same path. |
| AC-04 | PASS | Parallel equivalent with `{"items":[{...,"merge_status":"in_progress"}]}`, asserting `deny` and `-BeLike 'PARALLEL_WORKTREE_REMOVAL_BLOCKED*'`. |

### Non-regression of existing enforcement

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC-05 | PASS | `It 'emits the unchanged epic block reason'` and `It 'emits the unchanged parallel block reason'` reconstruct the pre-change **source** text as a single-quoted literal, apply the two substitutions the production double-quoted string performs (`$worktreePath` expansion and `""` to `"`), and assert `-BeExactly`. Independently confirmed: the reason strings are unchanged in the hook diff — both appear only as context lines, not as `+`/`-` lines. |
| AC-06 | PASS | The hook diff adds exactly three lines per file, all after the `$worktreePath` assignment; no pre-existing function body is touched. The test diff adds only new `Describe` blocks appended at end of file; no pre-existing `It`, assertion, or fixture is modified. Suite counts 50 and 49 minus 4 added each give 46 and 45 pre-existing, matching the pre-change values. `evidence/qa-gates/non-widening-pin.2026-09-06T23-09.md`. |
| AC-07 | PASS | `It 'keeps the merge_status allow-set unchanged'` in both suites asserts `HaveCount 2`, `[0] -BeExactly 'merged'`, `[1] -BeExactly 'worktree_removed'`. The hook diff confirms `$script:AllowedMergeStatuses = @('merged', 'worktree_removed')` appears only as a context line in both files. |

### Fail-closed matrix (conditions 1 through 9)

All nine evaluated against `CleanupWorktreeManifestGateMatrix.Tests.ps1`, whose `$script:DenyCases`
and `$script:AllowCases` tables are each run against **both** gates through `-ForEach`, producing
distinct Pester node names via the `<Case>` expansion. Suite reports 82 tests, 0 failures.

| AC | Condition | Required cases | Present | Verdict |
| --- | --- | --- | --- | --- |
| AC-08 | 1 | file absent, raw null/whitespace, `ConvertFrom-Json` throws | `'$null'`, `"'   '"`, `"'{not-json'"` | PASS |
| AC-09 | 2 | `tool` absent, `tool` other, `schema_version` absent, non-integer, `= 2` | all five present | PASS |
| AC-10 | 3 | `generated_at` absent, unparseable, future, at-bound, beyond-bound; clock injected; at-bound asserted explicitly | four deny cases plus `'generated_at sits exactly on the twenty-four hour bound'` in `$script:AllowCases`, asserted as **allow**. Every case fixes the clock at `2026-09-07T04:00:00Z` through the mocked seam; no wall-clock read | PASS |
| AC-11 | 4 | `removals` absent, non-array, empty | all three present | PASS |
| AC-12 | 5 | trailing-slash, quoted, Windows-separator targets allowed; non-matching denied; keyless record skipped and scan continues | four allow cases (`/` suffix, `"..."`, `C:\repos\wt\...` against a recorded `C:/repos/wt/...`, and a keyless record preceding the match) plus the deny case `'no recorded worktree_path matches the target'` | PASS |
| AC-13 | 6 | `removal_disposition` absent, `PRESERVE`, outside the set | all three present | PASS |
| AC-14 | 7 | `evidence` absent, empty, whitespace-only | all three present | PASS |
| AC-15 | 8 | `verdict` absent, out of vocabulary, `GENUINELY_NEW`, `STILL_RELEVANT` | all four present | PASS |
| AC-16 | 9 | `branch_state` absent, `PROTECTED_CURRENT`, the three merged states, outside vocabulary, each deny; `NOT_MERGED` and `HAS_UNIQUE_RESIDUALS` allowed | six deny cases and two allow cases, all present | PASS |

Note on AC-15 and the authorized-subset encoding: condition 8 is implemented as
`$script:AuthorizedRemovalVerdicts = @('DEAD_ONE_OFF', 'ALREADY_SOLVED_ELSEWHERE', 'STALE_OR_CONTRADICTED')`
rather than as the five-member vocabulary minus two exclusions. All four cases AC-15 requires pass
under this encoding, and the encoding is strictly safer for a future vocabulary extension. Assessed
in full in section 8.2 of `policy-audit.2026-09-08T09-04.md`. **PASS, and the choice is endorsed.**

### Contract and vocabulary pins

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC-17 | PASS | `It 'never reads preserved_files'` in both `Describe` blocks. Evaluates the same manifest twice — once with `preserved_files` set to `"not-an-array"`, once to `[]` — and asserts `$malformed \| Should -BeExactly $empty` and `$empty \| Should -Be 'allow'`. The second assertion matters: it proves the comparison is between two **allows**, not two vacuous denies. Structurally confirmed: the module references `preserved_files` nowhere. |
| AC-18 | PASS | `It 'resolves duplicate worktree_path records on the first match'` asserts `deny` when a `PRESERVE`-disposition record precedes the authorizing one and `allow` when the order is reversed. `Find-CleanupWorktreeManifestRemovalRecord` returns on the first normalized match. |
| AC-19 | PASS | `It 'exposes exactly SAFE_TO_DELETE as the allowed removal disposition'` in the module suite. Constant present: `$script:AllowedRemovalDispositions = @('SAFE_TO_DELETE')`. |
| AC-20 | PASS | `It 'exposes exactly NOT_MERGED and HAS_UNIQUE_RESIDUALS as the authorized branch states'`. Constant present: `$script:AuthorizedBranchStates = @('NOT_MERGED', 'HAS_UNIQUE_RESIDUALS')`. |

### Delivery obligations

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC-21 | PASS | Independently verified with `diff -q` for all four files: `CleanupWorktreeManifest.psm1`, both gate hooks, and `SKILL.md` are identical between `.claude/**` and `extensions/drm-copilot/resources/claude-customizations/.claude/**`. Test result recorded in `evidence/qa-gates/push-down-resource-contracts-state-exempt-final.2026-09-06T23-09.md`. |
| AC-22 | PASS | `core.json` diff shows `+ ".claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1"` inserted in the `.claude/lib/**` block. `evidence/qa-gates/pack-manifest-completeness.2026-09-06T23-09.md`. |
| AC-23 | PASS | `evidence/qa-gates/no-python-guard-final.2026-09-06T23-09.md`. The guard scans `.claude/hooks` and `.claude/lib`, so the new module is automatically in scope; the module contains no interpreter invocation, no `Start-Process`, no dynamic `&`, and no `Invoke-Expression`. Allowlist asserted empty by the suite's own test. |
| AC-24 | PASS | Verified in the diff: the identical five-line comment plus `'.claude/lib/cleanup-manifest/CleanupWorktreeManifest.psm1'` entry appears in both `scripts/powershell/PoshQC/settings/pester.runsettings.psd1` and `extensions/drm-copilot/resources/powershell/PoshQC/settings/pester.runsettings.psd1`. |
| AC-25 | PASS | 92.5926% (module), 95.2381% (epic gate), 93.6709% (parallel gate), all >= 85%. Route validity independently checked: `_poshqc.yml:41-42` imports the repository's own `PoshQC.psm1`, binding the repository runsettings, and calls the same `Invoke-PoshQCTest` the criterion names; the MCP runner was **not** used. Denominator presence independently confirmed by the `<package name=".claude/lib/cleanup-manifest">` / `<sourcefile name="CleanupWorktreeManifest.psm1">` pair and by the report-level `CLASS covered="97"` versus the baseline's 96. Report recorded under `evidence/qa-gates/`, which is the canonical sub-path the criterion itself specifies. |
| AC-26 | PASS | `git diff --stat 0ea7e577 HEAD -- .claude/lib/hook-payload/HookPayload.psm1` returns empty output. |
| AC-27 | PASS | `wc -l`: epic gate 467, parallel gate 335, module 415, epic suite 495, parallel suite 457, matrix suite 318, module suite 152. All seven under 500. |
| AC-28 | PASS | `grep -nE "TestDrive\|New-Item\|Out-File\|Set-Content\|GetTempPath\|New-TemporaryFile\|\[System\.IO\.File\]"` across all four suites returned no match. Every manifest fixture is a literal JSON string through the read seam; every clock value is a constructed `[datetime]::new(..., Utc)` through the clock seam. |

### Scope-boundary pins

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC-29 | PASS | `git diff --stat 0ea7e577 HEAD -- .codex/hooks/enforce-epic-worktree-removal-gate.ps1` returns empty output. |
| AC-30 | PASS | The same command over all six named paths (`validate-bash.ps1`, `enforce-epic-merge-gate.ps1`, and the four `scripts/bash/cleanup_worktrees*` files) returns empty output. |
| AC-31 | PASS | The full hook diff is three added lines per file — one `Import-Module`, one script-scope constant, one branch — all strictly after the `$worktreePath` assignment. Every construct named in D6's must-not-touch list that exists at the base commit is unchanged: the trigger guards, the bodies of `Get-EpicWorktreeRemovalCommandPath` and `Get-ParallelWorktreeRemovalCommandPath`, both deny reason strings, the four decision constructors, the entry points, and the thin tails. Two constructs named in the list — the extraction regex strings and their `.Trim('"''')` calls — do not exist at the base commit; verified directly by `git show d250cf72:<each hook> \| grep`, which returns only #545's structural helpers. The role they carried is unchanged. Assessed in full in section 8.2 of the policy audit. |

### Skill-text changes

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC-32 | PASS | The `## Sanctioned Removal Manifest` section names `artifacts/orchestration/cleanup-worktrees-manifest.json` and specifies all six top-level fields, all six `removals[]` fields, and all ten `preserved_files[]` fields, each with its type, requiredness, allowed values and fail-closed rule, plus a worked JSON example. The section opens with the bold ordering directive "Write the manifest before step 9 ... acts on any `SAFE_TO_DELETE` verdict." Placement is assessed under judgment call 2 in the policy audit and recorded as Low finding F-07; the substance the criterion requires is present. |
| AC-33 | PASS | Step 9's body now reads "...or remove the worktree itself through a manifest-authorized removal. A manifest-authorized removal is a single `git worktree remove <path>` covering one worktree, issued as its own Bash tool call, one call per worktree, and it is authorized only when the Sanctioned Removal Manifest below carries a record for that exact path whose `removal_disposition` is `SAFE_TO_DELETE` and whose `branch_state` is `NOT_MERGED` or `HAS_UNIQUE_RESIDUALS`." Every element the criterion names is present: per-worktree, own Bash tool call, `SAFE_TO_DELETE`, the two branch states, manifest coverage. |
| AC-34 | PASS | `allowed-tools` gains `- "Bash(git worktree remove *)"` with no force spelling in the grant string. The force prohibition is restated in the immediately following sentence of step 9: "Never pass a force flag to that command: a dirty worktree blocks deletion and is reported for manual handling, and it is never force-removed." Both halves of the criterion are met. Related non-criterion observation: the grant is a prefix glob and the gates do not reject `--force`; recorded as Medium finding F-02 in the code review, outside this criterion's assertion. |
| AC-35 | PASS | `grep -n "396" SKILL.md` returns no occurrence. The replacement text defers to `.claude/skills/pr-author/SKILL.md` ("which owns the body-file and receipt contract; defer to that skill for it rather than restating any value from it here"), directs use of the run's GitHub issue number when one exists, and states for the no-issue case that `<N>` is an arbitrary run-scoped identifier chosen by the pr-author agent, is not a pull-request number, and requires only agreement between the body-file path, the receipt's `number` field, and the body bytes. All five required elements present. |
| AC-36 | PASS | The `### Accepted residual` subsection states the indirection explicitly, and states the posture verbatim: "a policy-level integrity check, on the same terms `.claude/hooks/enforce-pr-author-skill.ps1` records for its own receipt mechanism: it prevents accidental bypass and requires a deliberate, documented act to circumvent. It is not a cryptographic or security boundary, and it must not be described as tamper-proof." It further records that routing a removal through such an indirection to avoid the manifest requirement is prohibited by the skill. |

### Toolchain

| AC | Verdict | Evidence |
| --- | --- | --- |
| AC-37 | PASS | Format, analyze, test completed in a single clean pass with no restart: `evidence/qa-gates/final-format.2026-09-06T23-09.md` (no auto-fixed files), `final-analyze.2026-09-06T23-09.md` (zero analyzer findings), `final-test-mcp.2026-09-06T23-09.md`. Post-format no-diff independently recorded in `post-format-no-diff.2026-09-06T23-09.md`. The local test exit code of 2 is the two-member Known-Local-Red Inventory, independently verified as environment-attributable (six checks, policy audit section 6); the same tree reports `failures="0"` over the identical 4460-test denominator in CI run `34205298954`. |

## Summary

| Verdict | Count |
| --- | --- |
| PASS | **37** |
| PARTIAL | 0 |
| FAIL | 0 |
| UNVERIFIED | 0 |
| **Total** | **37** |

All 37 acceptance criteria are satisfied. The verdicts above were reached by reading the repository
at head `4d5ecaca` — hook diffs, module source, test bodies, JUnit XML, coverage XML, and `diff -q`
mirror comparisons — rather than by accepting the executor's evidence prose. Where an evidence
artifact made a claim, the underlying raw artifact was consulted: the JUnit root elements and failed
`testcase` nodes for test outcomes, the koverage XML `counter` elements for coverage, and `git show`
against the anchor commit for the must-not-touch verification.

Three judgment calls were referred for independent evaluation and all three are resolved in the
implementation's favour, with reasoning recorded in section 8.2 of
`policy-audit.2026-09-08T09-04.md`:

1. **The authorized-verdict subset encoding of condition 8 is correct** and should not be reversed.
   It is the only encoding of the two that fails closed when the verdict vocabulary is later extended,
   and every other unknown-value rule in the module fails closed.
2. **The manifest-write section's placement is acceptable.** The stated reason — that inserting a
   numbered step before step 9 would renumber it and falsify both AC-33's and the plan's explicit
   references — is verified, and the forward reference inside step 9's own new text means a linear
   reader cannot silently miss the section. One Low finding (F-07) recommends a pointer at the head
   of the procedure.
3. **The D6 must-not-touch handling is correct and independently confirmed.** The extraction regex
   strings and `.Trim` calls do not exist at the anchor commit; `git show d250cf72:<each hook>`
   returns only #545's structural helpers. The protected role is unchanged, and the design composes
   with either D6 resolution because the manifest acceptance sits entirely below the detection call
   site.

Two verification facts were checked rather than assumed, and both hold:

- **The two local test failures are environment-attributable**, confirmed by six independent checks
  including the failure message that names `enforce-epic-wave-barrier.ps1` and this run's own feature
  key `'635'`, the absence of a `Get-PrAuthorCheckpointContent` mock in the affected suite, the
  `gh pr create` versus `gh pr edit` discriminator holding as predicted, and CI reporting zero
  failures over the identical 4460-test denominator.
- **The coverage figures apply to the head under review.** The measured head `05bbc4e1` differs from
  head `4d5ecaca` in eight paths, all Markdown under the feature folder. No PowerShell, JSON or
  `.psd1` file changed between them. The route is the one AC-25 names, and the new module's presence
  in the denominator is confirmed directly from the coverage XML rather than asserted.

On the feature's central question, the change adds a **real authorization decision, not an escape
hatch**. The distinguishing evidence is condition 10: it is implemented as a presence test over both
orchestration checkpoints rather than as an authorization test, which is deliberately broader than
the gates' own `merge_status` and `route_id` predicates and makes the manifest structurally unable to
authorize any removal the gates already protect. Both directions are pinned — 7 allow cases and 32
deny cases against both gates, plus two condition-10 deny pins that fail if the acceptance is written
too broadly, plus fail-before evidence proving the allow tests discriminate. The documented residuals
(the `bash <file>` indirection, the same-agent manifest author, the gitignored location) are all
recorded as accepted rather than claimed closed, and the sanctioned route is narrower than the
indirection that remains open, which is the correct relationship for a policy-level deterrent.

**Go / no-go: GO.** The feature is ready for PR. Remediation is not required; no
`remediation-inputs` artifact was produced. Two Medium follow-up candidates (F-01, F-02) and five
Low or informational findings are recorded in `code-review.2026-09-08T09-04.md` for separate
scheduling.

## Acceptance Criteria Check-off

No check-off action was required. All 37 criteria were already marked `- [x]` in `spec.md` at review
start, and this audit evaluates all 37 as PASS, so the recorded state and the audited state agree
with no row disagreeing. No criterion was newly checked off by this review, none was unchecked, and
no criterion text was modified.

### Acceptance Criteria Status

```
### Acceptance Criteria Status
- Source: docs/features/active/2026-09-06-cleanup-worktrees-sanctioned-removal-manifest-635/spec.md
- Total AC items: 37
- Checked off (delivered): 37
- Remaining (unchecked): 0
- Items remaining: none
```
