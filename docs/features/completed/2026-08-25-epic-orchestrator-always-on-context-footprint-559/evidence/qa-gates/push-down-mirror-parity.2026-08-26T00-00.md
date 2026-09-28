# Push-Down Mirror Parity (Issue #559)

This artifact records two task closures against the bundled-payload byte-identity contract:
`[P2-T13]` for the five Phase 2 rules mirrors, and `[P3-T18]` for all eight mirrors after the
Phase 3 epic-surface edits. Each section is headed by the task that wrote it.

Both tasks branch on the `[P0-T11]` verdict. That verdict was corrected before either ran; see
`### Governing [P0-T11] verdict` below.

---

## Governing [P0-T11] verdict — corrected to PRESENT

The `[P0-T11]` record at
`docs/features/active/2026-08-25-epic-orchestrator-always-on-context-footprint-559/evidence/baseline/baseline-pytest-coverage.2026-08-26T00-00.md`
originally recorded `ABSENT` at 2026-08-25T23-44 and concluded that the strict branch applied.
That block is preserved verbatim in the artifact and was not rewritten.

A `Superseding Observation:` block, timestamped 2026-08-26T00-19, was appended to the same
artifact. It records that `.claude/state/python-batch-budget.default.json` exists in this
worktree (380 bytes, created 2026-08-25T23:48:01, modified 23:49:13), is untracked
(`git ls-files --error-unmatch` exits 1), and is gitignored by `.gitignore` line 68
(`.claude/state/`). The file is written by this repository's own PreToolUse hook
`.claude/hooks/enforce-python-batch-budget.ps1` (path composed at hook line 190), registered in
`.claude/settings.json` under the `"matcher": "Write|Edit"` block at settings line 136. It
therefore regenerates on the first Write or Edit any agent performs in a fresh worktree.

The Phase 0 baseline ran at approximately 23:40, before any `Write|Edit` hook had fired in this
worktree; the file's birth timestamp of 23:48:01 falls in Phase 1. The original reading was
accurate for a transient pre-hook condition and unrepresentative of the steady state.

**The operative verdict is PRESENT.** Both `[P2-T13]` and `[P3-T18]` therefore run on the
**exception branch**: exactly one failure is tolerated, and only if that failure is
`test_bundled_claude_payload_contains_all_repo_runtime_contracts`. Any second failure fails the
task outright under either branch.

No gitignored file was created, deleted, moved, or otherwise mutated by either task. Per
extraction note 4 of the plan, deleting the file is rejected as out-of-scope mutation of the
developer's environment, and the registered hook would regenerate it regardless.

---

## [P2-T13] — Five Phase 2 rules mirrors

Timestamp: 2026-08-26T00-19

### Command:

```
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py
```

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a48e43815591206c3`

EXIT_CODE: 1

ExpectedExitCode: 1

Exit code captured without a pipe (`cmd > outfile 2>&1; echo "EXIT=$?"`) so no downstream process
status could mask a failure.

### Failure count and complete failure list

| Metric | Observed value |
|---|---|
| Collected | 10 |
| Passed | 9 |
| Failed | 1 |
| Errors | 0 |
| Skipped | 0 |

Final pytest summary line:

```
========================= 1 failed, 9 passed in 0.14s =========================
```

The complete list of failing tests is exactly one entry:

1. `test_bundled_claude_payload_contains_all_repo_runtime_contracts`

```
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
```

**No second failure exists.** The observed failure count is 1, and the single failing test is the
one the exception branch names. The exception branch is satisfied.

### The failure names the anticipated environmental path

```
E  AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.default.json
tests\scripts\dev_tools\test_push_down_claude_resource_contracts.py:120: AssertionError
```

The path named is exactly the one the corrected `[P0-T11]` record identifies. The failure is the
known `list_scoped_files` defect — it enumerates the filesystem rather than consulting git, so a
gitignored, untracked, machine-local state file enters the repo-side set with no bundled
counterpart. That defect is out of scope for this plan and no task here fixes it.

### Independent byte-identity proof for the five Phase 2 mirrors

This proof does **not** rely on the failing test. Each pair was compared directly, byte for byte,
by `cmp`, and independently by SHA-256 digest. Both methods agree on all five pairs.

`cmp` results, one invocation per pair, exit 0 meaning byte-identical:

```
CMP_ci-workflows_EXIT=0
CMP_benchmark-baselines_EXIT=0
CMP_plan-acceptance-gates_EXIT=0
CMP_orchestrator-state_EXIT=0
CMP_parallel-orchestration_EXIT=0
```

SHA-256 digests, source against bundled mirror:

| Rules file | Source `.claude/rules/` digest | Bundled mirror digest | Match |
|---|---|---|---|
| `ci-workflows.md` | `f64cecee524bfa122c1bc624a04a16bc2845b30e34e9d2e02f8db90dd8716918` | `f64cecee524bfa122c1bc624a04a16bc2845b30e34e9d2e02f8db90dd8716918` | yes |
| `benchmark-baselines.md` | `c3d711744e7d9334cbaa2ef9e057865fd65913a6b3067193e4fa36b104256a6a` | `c3d711744e7d9334cbaa2ef9e057865fd65913a6b3067193e4fa36b104256a6a` | yes |
| `plan-acceptance-gates.md` | `888138b265d5e4b83622a3e71b8c1bc11e66d7061d7d6ed8e03b700e4b2b3b2a` | `888138b265d5e4b83622a3e71b8c1bc11e66d7061d7d6ed8e03b700e4b2b3b2a` | yes |
| `orchestrator-state.md` | `08a82f2f710fddde7e6ea42b39c1f3911a462c58efd47e384bf3e0cb7c67da12` | `08a82f2f710fddde7e6ea42b39c1f3911a462c58efd47e384bf3e0cb7c67da12` | yes |
| `parallel-orchestration.md` | `20d0e12ba4916b8a5383236b40b835ed4531031617e7c5995a748ceac6acafa0` | `20d0e12ba4916b8a5383236b40b835ed4531031617e7c5995a748ceac6acafa0` | yes |

The bundled mirror paths are under
`extensions/drm-copilot/resources/claude-customizations/.claude/rules/`.

All five Phase 2 mirrors satisfy the byte-identity contract. The single test failure is
attributable solely to the untracked state file and carries no information about these five pairs.

Output Summary: PASS on the exception branch. Exactly one failure, and it is
`test_bundled_claude_payload_contains_all_repo_runtime_contracts`, naming the untracked
gitignored path `.claude/state/python-batch-budget.default.json`. No second failure exists (1
failed, 9 passed of 10 collected). The five Phase 2 rules mirrors were independently proven
byte-identical to their sources by per-pair `cmp` (all exit 0) and by matching SHA-256 digests,
neither of which depends on the failing test. Branch selection cites the corrected `[P0-T11]`
verdict of PRESENT.

---

## [P3-T18] — All eight mirrors after the Phase 3 epic-surface edits

Timestamp: 2026-08-26T00-19

### Command:

```
poetry run pytest tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py
```

Working directory: `C:\Users\DanMoisan\repos\drm-copilot\.claude\worktrees\agent-a48e43815591206c3`

EXIT_CODE: 1

ExpectedExitCode: 1

Exit code captured without a pipe (`cmd > outfile 2>&1; echo "EXIT=$?"`).

### Failure count and complete failure list

| Metric | Observed value |
|---|---|
| Passed | 13 |
| Failed | 1 |
| Errors | 0 |
| Skipped | 0 |

Final pytest summary line:

```
======================== 1 failed, 13 passed in 0.17s =========================
```

The complete list of failing tests is exactly one entry, named explicitly:

1. `test_bundled_claude_payload_contains_all_repo_runtime_contracts`

```
FAILED tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py::test_bundled_claude_payload_contains_all_repo_runtime_contracts
E  AssertionError: Repo file missing from bundle: .claude\state\python-batch-budget.default.json
```

**No second failure exists.** The single tolerated failure is the one the exception branch names,
and it names the same untracked, gitignored, machine-local path as at `[P2-T13]`. It is
environmental and carries no information about mirror parity: `.claude/state/` is ignored by
`.gitignore` line 68 and has no bundled counterpart by design.

### Every test in `test_epic_run_kickoff_discovery_contract.py` passes

The exception branch additionally requires that no test in the kickoff-discovery module fails,
including the mirror assertion. Verified by a verbose run of that module alone:

```
poetry run pytest tests/scripts/dev_tools/test_epic_run_kickoff_discovery_contract.py -v
-> EXIT=0

test_epic_run_skill_discovers_kickoff_across_integration_branch PASSED [ 25%]
test_epic_run_skill_tolerates_missing_integration_branch        PASSED [ 50%]
test_epic_orchestrator_precondition_establishes_kickoff_presence PASSED [ 75%]
test_discovery_fix_is_mirrored_into_bundled_payload             PASSED [100%]
============================== 4 passed in 0.05s ==============================
```

All four pass, including `test_discovery_fix_is_mirrored_into_bundled_payload`, which asserts the
agent file is byte-identical to its bundled copy. That module exits 0 on its own.

### Independent byte-identity proof for the three Phase 3 mirrors

Computed without relying on the failing test. `cmp`, one invocation per pair, exit 0 meaning
byte-identical:

```
CMP_agent_EXIT=0
CMP_epicskill_EXIT=0
CMP_orchskill_EXIT=0
```

SHA-256 digests, source against bundled mirror:

| File | Source digest | Bundled mirror digest | Match |
|---|---|---|---|
| `.claude/agents/epic-orchestrator.md` | `5318b458a8ccfdf5270677a3b90ba130367a0857dea0acbcf4db1a8e68a97dec` | `5318b458a8ccfdf5270677a3b90ba130367a0857dea0acbcf4db1a8e68a97dec` | yes |
| `.claude/skills/epic-orchestrate/SKILL.md` | `d8d3425b5cc70bccfa1d1ab19266f9c90a0134d98a510aedcea636d24d5d078b` | `d8d3425b5cc70bccfa1d1ab19266f9c90a0134d98a510aedcea636d24d5d078b` | yes |
| `.claude/skills/orchestrate/SKILL.md` | `df0be165f88b09a43fb5ec6e803a0fa336571622b88511cec1b46a2d452e2be1` | `df0be165f88b09a43fb5ec6e803a0fa336571622b88511cec1b46a2d452e2be1` | yes |

The first two digests are the same values recorded in
`frozen-epic-digest-repin.2026-08-26T00-00.md` and written into the re-baselined pin by
`[P3-T13]`, which cross-confirms that the pinned constants, the working-tree files, and the
bundled mirrors all agree.

Combined with the five Phase 2 pairs proven in the `[P2-T13]` section above, **all eight declared
mirrors are byte-identical to their originals.**

Output Summary: PASS on the exception branch. Exactly one failure across both modules, and it is
`test_bundled_claude_payload_contains_all_repo_runtime_contracts`, naming the untracked gitignored
path `.claude/state/python-batch-budget.default.json`; no second failure exists (1 failed, 13
passed). Every test in `test_epic_run_kickoff_discovery_contract.py` passes, including
`test_discovery_fix_is_mirrored_into_bundled_payload` (that module exits 0 standalone, 4 passed).
All eight mirrors were independently proven byte-identical by per-pair `cmp` and matching SHA-256
digests. Branch selection cites the corrected `[P0-T11]` verdict of PRESENT recorded in
`evidence/baseline/baseline-pytest-coverage.2026-08-26T00-00.md`.
