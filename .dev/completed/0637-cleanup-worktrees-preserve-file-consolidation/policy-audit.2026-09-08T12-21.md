# Policy Audit — issue 637, preserve-file consolidation

Timestamp: 2026-09-08T12-21
Reviewer: feature-review agent
Branch: `bug/cleanup-worktrees-preserve-file-consolidation-637-r2`
HEAD: `ed975b747b8b5915b8c6b592d9deb7bab2738aa0`
Base branch: `origin/epic/cleanup-merged-worktrees-hardening-integration`
Resolved merge base: `fff743141463c32da3b57a4cedd1c05ba58c9f78`
Work mode: `full-bug` (marker read at `issue.md:12`), so `spec.md` is the sole AC source.

Overall verdict: **PASS**. Zero blocking findings.

## Audit Scope

The audit scope is the full branch diff against the resolved merge base: 218 files,
7,646 insertions, 148 deletions. No caller instruction attempted to narrow this scope, so
there is no `## Rejected Scope Narrowing` section to record.

## PR Context Artifact Deviation

`artifacts/pr_context.summary.txt` and `artifacts/pr_context.appendix.txt` do not exist in
this worktree (`artifacts/` contains only `orchestration/`). The MCP context-collection
tool is not exposed to this agent, and `gh` invocations are refused in this worktree by the
`PR_AUTHOR_SKILL_BLOCKED` PreToolUse hook, so the artifacts could not be regenerated.

Substitute, recorded as a deviation: scope and evidence were derived directly from
`git diff` against the resolved merge base, which is the other authoritative scope source
named in this agent's contract. The merge base was resolved independently with
`git merge-base HEAD origin/epic/cleanup-merged-worktrees-hardening-integration`. No part
of this audit rests on a PR context artifact.

## Commit-Range Integrity

The recorded CI evidence names head SHA `c58ac6e58dd4831530509806143f4e32212bfeb0`, which
is not `HEAD`. Two commits follow it: `1fba4b66` (evidence and AC check-off) and `ed975b74`
(merge of the integration branch).

Verification performed: `git diff --name-status c58ac6e5 HEAD` returns eight paths, all
`.md`, all under `docs/`. No source file, test file, fixture, or `.gitattributes` changed
after the CI-verified commit. The CI evidence therefore remains applicable to the code
under review. **PASS.**

## Policy Reading Order Applied

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/quality-tiers.md`, `.claude/rules/tonality.md`
5. Language-specific: bash. No Python, TypeScript, PowerShell, or C# source file is in the
   branch diff (verified by extension histogram over the changed-file list: `md` 100,
   `out` 38, `json` 37, `rc` 30, `sh` 3, `gitkeep` 3, `bats` 3, `txt` 1, `gitattributes` 1,
   plus two extensionless stub scripts). `grep -E '\.(py|ts|tsx|ps1|psm1|cs)$'` over the
   changed-file list returns nothing.

## Toolchain Gate Verdicts

The plan's `pwsh`-wrapped WSL route is denied in this worktree. That refusal is recorded in
the feature's own evidence at
`evidence/baseline/baseline-git-state.2026-09-08T09-36.md` (`EXIT_CODE: 1`,
`ExpectedExitCode: 1`, `ROUTE REFUSED`) and the substitution is carried forward explicitly
in `evidence/baseline/baseline-format-stage-note.2026-09-08T09-49.md` under a
`RouteSubstitution` heading. The deviation is recorded, not silent. **PASS.**

| Stage | Verdict | Evidence and independent verification |
|---|---|---|
| Format | PASS | `evidence/qa-gates/final-qc-format.2026-09-08T12-10.md`; the no-rewrite claim rests on a pre-format `shfmt -d` no-diff observation, not on `shfmt -w`'s exit code. The artifact states explicitly that `shfmt -w` cannot discriminate a clean run from a repairing run, which is correct. |
| Lint / check | PASS | Re-run independently by this reviewer: `bash scripts/bash/shell-qc.sh check` exited 0 with zero bytes of output. `shellcheck` and `shfmt` are both present on this host (verified with `command -v`), so the stage was not a silent skip. |
| Type check | N/A | Not applicable to bash; `.claude/rules/general-code-change.md` exempts PowerShell and the shell toolchain has no type stage. |
| Architecture boundary | PASS | Verified by diff: no change to `scripts/bash/cleanup_worktrees_lib.sh`, `.claude/hooks`, `.claude/rules`, or `.github/instructions` (`git diff --stat` over those pathspecs returns nothing). |
| Unit tests | PASS (CI) | CI run 34223163823 on `c58ac6e5`: plan line `1..386`, zero `not ok`. See the UNVERIFIED note below. |
| Contract / schema | PASS | Re-run independently: `poetry run python -m pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py -q` → `11 passed`, exit 0. |
| Integration | N/A | No adapter to an external system is introduced. All external tools (`git`, `jq`) are driven through checked-in stubs at the `CLEANUP_WT_GIT_BIN` / `CLEANUP_WT_JQ_BIN` seams. |

### UNVERIFIED: independent confirmation of the CI run results

`bats` and `kcov` are not installed on this host (`command -v` returns nothing for both),
so `bash scripts/bash/shell-qc.sh test` prints `bats not installed; skipping shell tests.`
and returns 0 having executed nothing. This reviewer therefore cannot re-derive the test or
coverage results locally.

`gh run view 34223163823` was also attempted and was refused by the
`PR_AUTHOR_SKILL_BLOCKED` PreToolUse hook, which matches on `gh` invocations regardless of
subcommand. The four CI runs (34211209394, 34213641449, 34219866134, 34223163823), their
plan lines, and their coverage headlines are therefore **UNVERIFIED by this reviewer** and
are accepted on the orchestrator's recorded observation plus the feature's own evidence
artifacts.

Concrete reason: no local `bats`/`kcov`, and `gh` is hook-denied in this worktree.

Mitigating observation: the local `check` stage, the push-down contract test, and the
evidence-location validator were all re-run successfully by this reviewer, and every
byte-level property claimed by the tests was re-derived directly from the repository (see
the code review artifact). The unverified portion is confined to the CI test/coverage
counts themselves.

## Coverage Verification

Languages with changed files in the branch diff: **bash only**.

| Language | Changed files | Coverage verdict | Basis |
|---|---|---|---|
| Bash | 3 `.sh`, 3 `.bats`, 2 stub scripts | **PASS** | CI run 34223163823, headline `Bash coverage (lines): 93.2%`, recorded in `evidence/qa-gates/final-qc-coverage.2026-09-08T12-10.md`. |
| TypeScript | 0 | N/A | Zero changed files on the branch. |
| Python | 0 | N/A | Zero changed files on the branch. |
| PowerShell | 0 | N/A | Zero changed files on the branch. |
| C# | 0 | N/A | Zero changed files on the branch. |

### Per-file line rates (new and modified modules)

| Module | Status | Line rate | Threshold | Verdict |
|---|---|---|---|---|
| `scripts/bash/cleanup_worktrees_preserve_lib.sh` | new | 0.906 | >= 0.85 | PASS |
| `scripts/bash/cleanup_worktrees_preserve_eol_lib.sh` | new | 0.870 | >= 0.85 | PASS |
| `scripts/bash/cleanup-worktrees.sh` | modified | 1.000 | >= 0.85, no regression | PASS (baseline 1.000, held) |

Branch coverage: not evaluated. `kcov` measures line coverage only, so no bash branch
figure exists. `.claude/rules/quality-tiers.md` records this exemption explicitly, and
`.claude/rules/general-unit-test.md` confirms it is a threshold exemption only, not a
measurement exclusion. Recording FAIL for an absent bash branch figure would be incorrect.

### Repo-wide movement, assessed for regression

The headline moved 93.5% (baseline run 34211209394) to 93.2% (final run 34223163823), a
0.3-point decrease. This is **not** a regression. The orchestrator joined the baseline and
final per-file rates on filename and found zero files regressed; the movement is
denominator dilution from admitting two new modules (0.906 and 0.870) below the prior
repository average. `evidence/qa-gates/coverage-comparison.2026-09-08T12-10.md` records
that join. Both new modules clear the 85% floor on their own.

### Recorded threshold conflict in this agent's instructions

This agent's Coverage Thresholds section states new-file line coverage >= 85%, citing
`.claude/rules/quality-tiers.md` Authoritative Decision #2 as the source. The Verification
Procedure section of the same instructions states "if line coverage is below 90%, flag as
FAIL" for new files and "below 80%" for repo-wide.

Resolution applied: the repository-authoritative threshold of **85%** governs, because
`.claude/rules/quality-tiers.md` and `.claude/rules/general-unit-test.md` are the canonical
policy source under the policy reading order, and this agent's own instructions name that
file as the governing authority. Both are stated here so the reader can see the judgement.

Consequence, stated plainly: under a 90% new-file reading,
`cleanup_worktrees_preserve_eol_lib.sh` at **0.870** would be flagged. Under the
repository's own 85% rule, which this audit applies, it passes. No other figure is affected
by the choice.

### No coverage exclusion was added (AC-41)

Verified by reading `scripts/bash/shell_qc_lib.sh:333-336`: the kcov invocation uses
`include_pattern` = `<root>/tools,<root>/scripts,<root>/.claude/lib/bash` and
`exclude_pattern` = `<root>/tests`. No path under `scripts/` is excluded. That file is not
in the branch diff at all, so the change added no exclusion of any kind. **PASS.**

The remediation that raised the principal library from 0.807 to 0.906 was accomplished by
adding eleven behavioural tests, not by excluding a production path. The remaining twenty
uncovered lines are documented in
`evidence/other/coverage-remediation-decision.2026-09-08T12-10.md` as nineteen
literal-data lines inside two multi-line statements plus one unreachable defensive branch,
and that attribution was confirmed by a `PS4='+LINE:${LINENO} '` / `set -x` probe rather
than asserted. This satisfies the Coverage Exclusion Policy in
`.claude/rules/general-unit-test.md`.

## Evidence Location Compliance

**PASS. Zero violations.**

- `git diff --name-only <merge-base> HEAD -- artifacts/` returns **nothing**. No file was
  written under `artifacts/baselines/`, `artifacts/qa/`, `artifacts/evidence/`, or
  `artifacts/coverage/` anywhere in the branch diff.
- All 63 evidence artifacts live under the canonical
  `docs/features/active/2026-09-07-cleanup-worktrees-preserve-file-consolidation-637/evidence/<kind>/`,
  in four kind directories: `baseline/`, `other/`, `qa-gates/`, `regression-testing/`.
- `poetry run python scripts/dev_tools/validate_evidence_locations.py --root .` exited **0**
  with no output.

No `EVIDENCE_LOCATION_OVERRIDE_REJECTED` condition arose.

## Evidence Integrity

| Check | Result |
|---|---|
| All artifacts carry `Timestamp:` | PASS — 0 artifacts missing |
| All artifacts carry `Command:` | PASS — 0 artifacts missing |
| All artifacts carry `EXIT_CODE:` | PASS — 0 artifacts missing |
| All artifacts carry `Output Summary:` | PASS — 0 artifacts missing |
| No artifact records `EXIT_CODE: PENDING-CI` | PASS |

Method: enumerated every `.md` under `evidence/` and tested for each of the four field
tokens. Zero artifacts were missing any field.

`EXIT_CODE` value histogram across the evidence tree: `0` × 75, `1` × 6. Each of the six
non-zero codes is paired with an `ExpectedExitCode: 1` — the three fail-before records, the
two `grep`-selects-nothing scans behind AC-43, and the Phase 0 route probe. A non-zero exit
that is the asserted outcome is correct evidence, not a failure.

The literal string `PENDING-CI` appears in five artifacts, but in every instance it is
historical narrative describing the discharge of a placeholder that no longer exists (for
example, "The enumeration also confirmed that no artifact carries `EXIT_CODE: PENDING-CI`").
A targeted `grep -rn "EXIT_CODE: *PENDING"` matches only those narrative lines, never a
field value. **No unresolved placeholder remains.**

## File Size Limit (`.claude/rules/general-code-change.md`, 500 lines)

| File | Lines | Verdict |
|---|---|---|
| `scripts/bash/cleanup_worktrees_preserve_lib.sh` | 492 | PASS |
| `scripts/bash/cleanup_worktrees_preserve_eol_lib.sh` | 212 | PASS |
| `scripts/bash/cleanup-worktrees.sh` | 163 | PASS |
| `tests/shell/test_cleanup_worktrees_preserve.bats` | 471 | PASS |
| `tests/shell/test_cleanup_worktrees_preserve_failures.bats` | 264 | PASS |
| `tests/shell/test_cleanup_worktrees_preserve_eol.bats` | 175 | PASS |
| `tests/fixtures/cleanup_worktrees/stub-bin/git` | 275 | PASS |
| `tests/fixtures/cleanup_worktrees/preserve/stub-bin/jq` | 79 | PASS |

`scripts/bash/cleanup_worktrees_lib.sh` remains at 490 lines and is unchanged by this
branch. Markdown files are exempt per the rule. **PASS.**

The 492-line principal library is 8 lines from the cap. This is a maintenance observation,
not a violation; see the code review artifact.

## Unit Test Policy (`.claude/rules/general-unit-test.md`)

| Requirement | Verdict | Basis |
|---|---|---|
| Independence | PASS | Each test sets its own seam environment and drives a scenario directory. The read-only `preserve_plan` phase is used wherever a full pass would mutate a checked-in fixture, which keeps the suite idempotent. |
| Isolation | PASS | Tests target single functions (`preserve_validate_record`, `preserve_derive_line_ending`, `preserve_scan_host_tokens`) or one driver path at a time. |
| Fast execution | PASS | No real `git` or `jq` is invoked; both resolve to checked-in stubs. |
| Determinism | PASS | No clock, no RNG, no network, no sleep. No banned API (`setTimeout`, `Thread.Sleep`, wall-clock wait) appears. |
| Readability | PASS | Every non-obvious assertion carries a comment stating why it can fail. See the code review artifact. |
| **No temporary files** | PASS | `grep` for `mktemp`, `BATS_TEST_TMPDIR`, `BATS_TMPDIR`, `TMPDIR`, and `/tmp/` across all three suites and the whole `preserve/` fixture tree returns **nothing**. Writable destinations are `/dev/null` and `/dev/stdout`, which are character devices, not temporary files. |
| Test file location | PASS | All three suites are under `tests/shell/`, mirroring `scripts/bash/`. No colocation in the production tree. |
| No production path excluded from coverage | PASS | See the AC-41 section above. |

## Design Principles (`.claude/rules/general-code-change.md`)

| Principle | Verdict | Basis |
|---|---|---|
| Simplicity first | PASS | Two-phase read-then-write driver. No inheritance, no indirection beyond function calls. |
| Reusability | PASS | `preserve_split_tsv`, `preserve_line_terminator`, and `preserve_relative_path_reason` are each used from more than one call site. |
| Extensibility | PASS | Every external dependency is behind a named environment seam (`CLEANUP_WT_GIT_BIN`, `CLEANUP_WT_JQ_BIN`, `CLEANUP_WT_MANIFEST_PATH`, `CLEANUP_WT_CONSOLIDATION_PATH`). |
| Separation of concerns | PASS | `preserve_plan` performs zero I/O writes; `preserve_commit_plan` contains no policy. This is the separation the rule asks for, and it is what makes the fail-closed ordering property provable. |
| Fail fast and explicitly | PASS | Every refusal emits a machine-readable `ACTION\|...` record on stdout and a human diagnostic on stderr. No broad catch-all. An unresolvable `jq` returns 127 with a diagnostic naming the tool rather than silently staging nothing. |
| Naming | PASS | Consistent `preserve_*` prefix; `snake_case` throughout, matching the sibling libraries. |
| Dependencies | PASS | `jq` is the only new external tool. It is resolved through a seam with an explicit 127 contract and is documented in the wrapper usage text. |

## Tonality

The delivered documentation, code comments, and evidence artifacts use measured,
evidence-proportionate language. Spot checks found no hyperbole, no humour, and no
decorative metaphor. Claims are qualified where the evidence is indirect — for example,
`final-qc-test.2026-09-08T12-10.md` states that a local emulation "was evidence for the
prediction, not the gate," which is the correct distinction. **PASS.**

## Findings Summary

**Blocking findings: 0.**

Non-blocking findings are recorded in `code-review.2026-09-08T12-21.md`. No
`remediation-inputs` artifact is produced, because no finding is remediation-required.
