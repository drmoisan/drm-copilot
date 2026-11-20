# Frozen Epic Surface Digest Re-pin (Issue #559)

Timestamp: 2026-08-26T00-19

Tasks: `[P3-T11]` (agent file digest), `[P3-T12]` (skill file digest)

Per Decision 1 of the approved plan, the two pinned SHA-256 constants in
`tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` are **re-baselined, not
removed**, and the consuming test
`test_parallel_orchestrator_surface_contracts.py::test_frozen_epic_surface_matches_pinned_baseline_digest`
is retained. The pin stays live as a guard against an unintended future edit to either epic file.

## Why the epic surface legitimately changed

F1, F2, F4, and F6 each edit one or both pinned files:

- F1 removed the two `## Startup Protocol` read steps from the agent file and the whole
  `## Prerequisites` block from the skill file. The Claude Code runtime already injects `CLAUDE.md`
  and the path-scoped `.claude/rules/` files, so those steps ordered reads the runtime had already
  satisfied and cost context on every turn.
- F2 trimmed the agent's `skills:` frontmatter from six preloads to three.
- F4 replaced three unqualified `spec.md` section citations with resolvable authorities.
- F6 added the `## Bounded Child Return Contract` section to the skill file and appended the
  child-facing constraint to the epic-mode kickoff line.

## Digest ordering

Both digests were computed as the **last** step touching either epic file. No edit to
`.claude/agents/epic-orchestrator.md` or `.claude/skills/epic-orchestrate/SKILL.md` follows this
measurement in Phase 3.

### Line-ending risk retired

Both files are LF-only in the working tree and `.gitattributes` sets `eol: lf` for them
(`git check-attr text eol` reports `text: auto`, `eol: lf`). Working-tree bytes therefore equal
committed bytes, so a digest taken from `read_bytes()` on the working tree is the digest the
committed blob will carry.

## [P3-T11] — `.claude/agents/epic-orchestrator.md`

### Command:

```
poetry run python -c "import hashlib,pathlib;print(hashlib.sha256(pathlib.Path('.claude/agents/epic-orchestrator.md').read_bytes()).hexdigest())"
```

EXIT_CODE: 0

The `-c` payload is a **single line**. A multi-line `-c` payload is a known silent no-op in this
environment that exits 0 without executing, which would fabricate the digest rather than compute
it. Non-empty stdout below is the positive proof the payload actually ran.

Digest:

```
5318b458a8ccfdf5270677a3b90ba130367a0857dea0acbcf4db1a8e68a97dec
```

Length: 64 hexadecimal characters.

## [P3-T12] — `.claude/skills/epic-orchestrate/SKILL.md`

### Command:

```
poetry run python -c "import hashlib,pathlib;print(hashlib.sha256(pathlib.Path('.claude/skills/epic-orchestrate/SKILL.md').read_bytes()).hexdigest())"
```

EXIT_CODE: 0

Single-line payload, for the reason recorded above.

Digest:

```
d8d3425b5cc70bccfa1d1ab19266f9c90a0134d98a510aedcea636d24d5d078b
```

Length: 64 hexadecimal characters.

## Independent cross-check

Because a fabricated or stale digest is the specific failure mode this task guards against, both
values were recomputed with a second, unrelated tool and compared:

```
sha256sum .claude/agents/epic-orchestrator.md .claude/skills/epic-orchestrate/SKILL.md

5318b458a8ccfdf5270677a3b90ba130367a0857dea0acbcf4db1a8e68a97dec *.claude/agents/epic-orchestrator.md
d8d3425b5cc70bccfa1d1ab19266f9c90a0134d98a510aedcea636d24d5d078b *.claude/skills/epic-orchestrate/SKILL.md
```

Both tools agree on both files.

## Re-pin summary

| Pinned file | Re-baselined SHA-256 |
|---|---|
| `.claude/agents/epic-orchestrator.md` | `5318b458a8ccfdf5270677a3b90ba130367a0857dea0acbcf4db1a8e68a97dec` |
| `.claude/skills/epic-orchestrate/SKILL.md` | `d8d3425b5cc70bccfa1d1ab19266f9c90a0134d98a510aedcea636d24d5d078b` |

These are the two values written into
`tests/scripts/dev_tools/parallel_orchestrator_surface_expectations.py` by `[P3-T13]`, whose
rewritten block comment records that issue #559 re-baselined the pin and why. That file is owned by
the still-active feature 441 and is the highest contention point in this item; only the two
constants and their comment were touched.

Output Summary: PASS. Both SHA-256 digests recomputed from the exact working-tree bytes that will
be committed, each 64 hexadecimal characters, each `EXIT_CODE: 0`, each cross-checked against
`sha256sum` with agreement. Agent file:
`5318b458a8ccfdf5270677a3b90ba130367a0857dea0acbcf4db1a8e68a97dec`. Skill file:
`d8d3425b5cc70bccfa1d1ab19266f9c90a0134d98a510aedcea636d24d5d078b`. Both computed as the last step
touching either epic file, with the LF-only line-ending risk retired beforehand.
