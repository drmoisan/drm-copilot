# Remediation Cycle 1 — Pre-Remediation Diff Inventory

Timestamp: 2026-08-09T06-29

Task: [P0-T8]
Feature: docs/features/active/2026-08-07-parallel-mutation-protocol-442
Remediation cycle: 1
HEAD at capture: a9e2463c
Working tree at capture: clean (no remediation edit applied yet)

Base used by this task: **`c939b5b8`** (the wave-0-3 integration head). This is the
whole-branch confinement base. Per the plan's `## Conventions Used in This Plan`, for any path
this feature CREATED, `git diff c939b5b8 -- <path>` reports the WHOLE FILE as an addition,
because the path is absent from `c939b5b8` and present at `a9e2463c`. Such full-addition
numstats are the CORRECT recorded pre-remediation inventory value for those paths, not an
anomaly, and `c939b5b8` is never used to prove byte-identity or to isolate a change this
remediation cycle made.

## Check 1 — Whole-branch diff stat

Command: `git diff --stat c939b5b8 -- .`
EXIT_CODE: 0
Output Summary: `67 files changed, 12041 insertions(+), 151 deletions(-)`. This matches the base
plan's delivered inventory of 67 paths.

## Check 2 — Per-path numstat before remediation

Command: `git diff --numstat c939b5b8 -- <path>` for each of the nine listed paths (issued as a
single multi-path invocation, which produces one line per changed path and no line for an
unchanged path).
EXIT_CODE: 0

| Path | Pre-remediation numstat (added / removed) vs `c939b5b8` | Note |
| --- | --- | --- |
| `.claude/skills/parallel-orchestrate/SKILL.md` | `144 1` | Pre-existing at `c939b5b8` (F5-owned); the single removal is the F6 placeholder line |
| `.claude/skills/parallel-add/SKILL.md` | `122 0` | Feature-CREATED path — full-addition value, matching the plan's measured `122 0` |
| `.claude/skills/parallel-remove/SKILL.md` | `168 0` | Feature-CREATED path — full-addition value |
| `scripts/dev_tools/validate_parallel_orchestrator_state.py` | `2 0` | Pre-existing (F3-owned); exactly one added import line and one added call line, zero removals |
| `.claude/settings.json` | `4 0` | Pre-existing; exactly one added Bash-matcher hook entry (4 lines), zero removals |
| `pyproject.toml` | **(no diff line emitted — UNCHANGED at baseline)** | Confirms `pyproject.toml` is unchanged before remediation; [P6-T4] adds exactly three lines |
| `poetry.lock` | **(no diff line emitted — UNCHANGED at baseline)** | Confirms no dependency change before remediation; must stay empty ([P6-T4], [P7-T10] Check F) |
| `docs/features/active/2026-08-07-parallel-mutation-protocol-442/plan.md` | `170 114` | Feature-created-then-revised path. Retained as an INFORMATIONAL baseline only. [P7-T10] Check G does NOT use this value as its proof: numstat equality against `c939b5b8` cannot detect a line-count-preserving edit inside the added-line set. Check G proves byte-identity with `git diff a9e2463c -- <FEATURE>/plan.md` producing empty output. |
| `tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py` | `500 0` | Feature-CREATED path — full-addition value, exactly the measured `500 0` the plan records as correct. This is NOT an anomaly and NOT a violation. Byte-identity for this path is proven at [P7-T10] Check I against `a9e2463c`. |

## Check 3 — Every listed path exists at `a9e2463c`

Command: `git ls-tree -r --name-only a9e2463c -- <the nine paths>`
EXIT_CODE: 0
Output Summary: all nine paths are listed, so all nine exist at `a9e2463c`:

```
.claude/settings.json
.claude/skills/parallel-add/SKILL.md
.claude/skills/parallel-orchestrate/SKILL.md
.claude/skills/parallel-remove/SKILL.md
docs/features/active/2026-08-07-parallel-mutation-protocol-442/plan.md
poetry.lock
pyproject.toml
scripts/dev_tools/validate_parallel_orchestrator_state.py
tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py
```

**No ABSENT-AT-BASE condition can arise for any of this cycle's `a9e2463c`-based checks.** Every
path this cycle examines against `a9e2463c` is present in that commit, so `git diff a9e2463c --`
and `git show a9e2463c:` are both sound on every one of them, including the paths this feature
created.

Output Summary: Whole-branch diff against `c939b5b8` is 67 files / +12041 / -151. Per-path
pre-remediation numstats recorded for all nine listed paths, including the confirmation that
`pyproject.toml` and `poetry.lock` are UNCHANGED at baseline (no diff line emitted for either)
and that the two feature-created paths report full-addition values (`122 0` for
`parallel-add/SKILL.md`, `500 0` for `test_parallel_mutation_protocol_ops.py`), which is the
correct recorded value. All nine paths exist at `a9e2463c`.
