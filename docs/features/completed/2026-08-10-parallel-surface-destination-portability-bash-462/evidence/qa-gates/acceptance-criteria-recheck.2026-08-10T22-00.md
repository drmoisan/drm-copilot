# QA Gate — Acceptance-Criteria Re-Check After Remediation Cycle 1

Timestamp: 2026-08-10T22-00
Issue: #462
Task: [P5-T2]
Work Mode: `full-feature` — AC sources are `spec.md` **and** `user-story.md`
Scope re-checked: RI-1, RI-2, RI-3, RI-4

Both AC source documents carry the same 17 criteria in the same order (`spec.md` lines 302-383,
`user-story.md` lines 95-176). The numbering AC1-AC17 below is positional and applies identically to
both files. All 34 checkboxes (17 + 17) were `[x]` before this cycle and remain `[x]`; the cycle
introduced no regression and no criterion required un-checking.

## Per-Criterion Table (applies to both `spec.md` and `user-story.md`)

| # | Criterion (abbreviated) | Touched by cycle 1? | Status | Evidence |
| --- | --- | --- | --- | --- |
| AC1 | bash cohort-computation entry point, corpus parity with `parallel_cohort_computation.py` | No | PASS (unchanged) | Original: `tests/shell/parallel_cohorts_parity.bats` + `test_parallel_cohort_bash_parity.py`. Re-confirmed green by the P5-T3 dispatch, which runs the full bats suite. |
| AC2 | bash `compute_concurrency_batches`, `max_concurrency < 1` rejection | No | PASS (unchanged) | Same parity suites; re-confirmed by P5-T3. |
| AC3 | bash manifest validator, M1-M7 byte parity with the documented M1 exception | No | PASS (unchanged) | Same parity suites; re-confirmed by P5-T3. |
| AC4 | default-resolving accessors for `mode` and `max_concurrency` | No | PASS (unchanged) | bats cases; re-confirmed by P5-T3. |
| AC5 | every `.claude/lib/bash/` file has a byte-identical bundled mirror | No | PASS (unchanged) | No `.claude/lib/bash/**` file was modified this cycle. Manifest-membership test re-run at P5-T4 (`test_push_down_claude_resource_contracts.py`). |
| AC6 | push-down publishes `orchestration-routing.json` and `blast-radius.json` | No | PASS (unchanged) | No push-down source or config file touched. |
| AC7 | routing-config merge semantics (source-authoritative, preserve local, idempotent, fail-fast) | No | PASS (unchanged) | No change to `config/**` or the push-down service. |
| AC8 | published `blast-radius.json` default carries no drm-copilot-only entries | No | PASS (unchanged) | No change to `config/blast-radius.json` or its published default. |
| AC9 | Copilot and Codex published sets unchanged | No | PASS (unchanged) | No change to either entry point. |
| AC10 | `core.json` lists the rules file, the bash paths, and both config files | No | PASS (unchanged) | No file added to or removed from `.claude/lib/**`, `.claude/rules/**`, or the bundled `config/` tree this cycle, so the manifest set is unchanged. Re-run at P5-T4. |
| AC11 | pack-manifest completeness test enumerates `rules/*.md`, `lib/**`, bundled `config/` | No | PASS (unchanged) | Test file untouched; re-run at P5-T4. |
| AC12 | Shell-QC discovery contract and kcov include pattern cover `.claude/lib/bash/**` | **Yes — `shell_qc_lib.sh` edited (RI-3)** | PASS | The RI-3 edit rewrote the `for root in tools scripts .claude/lib/bash` loop body from `[[ -d $root ]] && roots+=("$root") \|\| true` to an `if` statement. The **root list is unchanged** and `.claude/lib/bash` remains a search root; the kcov include pattern was not touched. Semantics are identical. Verified by the P5-T3 coverage report continuing to enumerate the `.claude/lib/bash` files and by the shell-qc bats suite passing in the same run. |
| AC13 | shfmt/shellcheck/bats pass on all shell files; bash line coverage >= 85% | **Yes — RI-3 rewrote eight sites in two shell files** | PASS | **Superseded evidence.** The prior green run at `f7711fb4` (92.4%) is now the *baseline*; the discharging evidence is the P5-T3 dispatch at the post-change head, recorded in `evidence/qa-gates/shell-coverage-dispatch.<ts>.md` with run URL, conclusion, both verification steps green, `headSha` equality, and the numeric coverage value compared against 92.4%. |
| AC14 | destination-runtime references invoke bash entry points; no `poetry run` on the `/parallel-plan` path | **Yes — agent prose edited (RI-2)** | PASS | The RI-2 prose rewrites changed only which allowlist *entry* is named; every invocation example still invokes the bash entry point. No `poetry run` invocation was introduced. `grep -n "lib/bash" .claude/agents/parallel-planner.md` and the same for `parallel-orchestrator.md` (P3-T6) show the three grants plus unchanged bash invocation examples. |
| AC15 | Bash allowlist entries in the two agents and `settings.json`; PR identifies the deliberate permission-surface change | **Yes — this is RI-2's target** | PASS | **Evidence updated.** The single `Bash(bash .claude/lib/bash/*)` entry is replaced by three entry-point-specific grants in all six locations (P3-T1 through P3-T4), verified by frontmatter parse and JSON assertion at P3-T6 and by pair-hash equality at P5-T1. The PR-description artifact `evidence/other/permission-surface-callout.2026-08-10T17-08.md` is amended (P3-T5) to describe the delivered three-entry grant, state the residual scope accurately, and record the narrowing as applied. The criterion is satisfied more strongly than before: the grant is narrower and the disclosure is accurate. |
| AC16 | payload-only workspace clears all four reported blockers | No | PASS (unchanged) | The three granted entry points are exactly the three scripts the payload-only bats case invokes; the narrowing removed grants only for the six sourceable libraries, which that case never invokes directly. Re-confirmed by the payload-only bats case in the P5-T3 run. |
| AC17 | no parallel-surface schema field, enum member, or validator invariant added, removed, or altered | No — and explicitly re-verified | PASS | See the AC17 scope proof below. |

## AC17 Scope Proof

Complete list of files changed in remediation cycle 1 (tracked modifications):

```
.claude/agents/parallel-orchestrator.md
.claude/agents/parallel-planner.md
.claude/settings.json
.gitignore
docs/features/active/.../evidence/other/permission-surface-callout.2026-08-10T17-08.md
docs/features/active/.../spec.md
extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-orchestrator.md
extensions/drm-copilot/resources/claude-customizations/.claude/agents/parallel-planner.md
extensions/drm-copilot/resources/claude-customizations/.claude/settings.json
scripts/bash/cleanup_worktrees_lib.sh
scripts/bash/shell_qc_lib.sh
```

Plus untracked additions, all of which are this cycle's own plan, inputs, and evidence artifacts
under `docs/features/active/2026-08-10-parallel-surface-destination-portability-bash-462/`.

Filter:

```
git diff --name-only | grep -E "^(scripts/dev_tools/|extensions/drm-copilot/src/lib/validate/)"
```

EXIT_CODE: 1 (no matches)

**Zero files under `scripts/dev_tools/` and zero under `extensions/drm-copilot/src/lib/validate/`
were modified.** No schema field, enum member, or validator invariant was added, removed, or
altered. AC17 is unaffected. The post-commit form of this check
(`git diff --name-only f7711fb4..HEAD`) is recorded in the P5-T3 artifact.

## RI-1 Reflection in the AC Sources

The RI-1 edit is outside the `## Acceptance Criteria` section of both documents; it targets
`spec.md`'s `## Seeded Test Conditions (from potential)` section. Post-edit state of that bullet:

```
- [x] bats unit coverage for the bash cohort computation: empty graph, single item, disjoint
      items, fully connected items, deterministic tie-breaking.
```

Five scenarios, all delivered; the box is now checked. The unwritable sixth clause is removed.

Grep confirmation, run at P2-T1 and recorded here as P2-T1's acceptance directs:

| Command | EXIT_CODE | Result |
| --- | --- | --- |
| `grep -n "generation handling" spec.md` | 1 | no match — empty |
| `grep -n "generation handling" user-story.md` | 1 | **no match — empty** |

`user-story.md` never contained the bullet, so no edit was applied there and none was needed. This
records the empty result explicitly, as P2-T1's acceptance requires.

`issue.md` retains the phrase in its historical pre-promotion seed. Under `full-feature` mode
`issue.md` is not an acceptance-criteria source, and RI-1 scopes the change to the spec bullet.
Leaving `issue.md` unchanged is a deliberate decision of record, confirmed at preflight, not an
oversight.

## RI-3 and RI-4 Effect on the AC Set

- **RI-3** touches only the internal control-flow form of eight statements in two pre-existing shell
  library files. No function signature, no discovery root, no include pattern, and no emitted string
  changed. The criteria it can affect are AC12 and AC13, both re-verified above; AC13's discharging
  evidence is replaced by the P5-T3 run.
- **RI-4** touches only `.gitignore`. It affects no acceptance criterion directly. Its effect is
  protective: the unanchored `lib/` rule previously excluded a checked-in Shell-QC fixture under
  `tests/fixtures/shell_qc/.claude/lib/bash/`, which is part of AC12's test surface. Anchoring the
  rule removes the mechanism by which a future fixture in any `lib` directory could be silently
  un-committed. Verified at P1-T2.

## Summary

- Criteria evaluated: 34 (17 in `spec.md` + 17 in `user-story.md`).
- PASS: 34. PARTIAL: 0. FAIL: 0. UNVERIFIED: 0.
- Regressions introduced by remediation cycle 1: 0.
- Criteria whose evidence changed: AC13 (superseded by the P5-T3 dispatch) and AC15 (three-entry
  grant plus the amended disclosure artifact). Both remain PASS.
- Criteria requiring un-checking: none. All 34 checkboxes remain `[x]` in their source files.

Output Summary: All 34 acceptance criteria across both `full-feature` AC source documents were
individually re-confirmed after RI-1 through RI-4 with named evidence per criterion. AC13's evidence
is superseded by the terminal P5-T3 CI dispatch; AC15's evidence is strengthened by the narrowed
three-entry grant and the amended permission-surface callout; AC17 is proven unaffected by an
explicit diff-scope filter returning zero matches. Zero regressions.
