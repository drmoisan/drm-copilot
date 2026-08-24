# Phase 0 — Instructions Read (Remediation Cycle 1, 2026-07-09T15-35)

Timestamp: 2026-07-09T15-40

Policy Order:
1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/python.md`
5. `.claude/rules/python-suppressions.md`

Files Read:
1. `CLAUDE.md` — NOT FOUND at repo root. Confirmed absence with a filesystem
   existence check (`test -f`). This repository's root-level standing
   instructions file is `AGENTS.md`, not `CLAUDE.md`; no `CLAUDE.md` file
   exists anywhere in the repository root. Recorded here as a factual
   observation, not a plan deviation — the remaining four files were read in
   full as stated below.
2. `.claude/rules/general-code-change.md` — read in full. Key points:
   seven-stage mandatory toolchain loop (format, lint, type-check,
   architecture-boundary tests, unit tests, contract/schema checks,
   integration tests), 500-line file size limit, fail-fast error handling,
   naming conventions, dependency constraints, I/O boundary isolation.
3. `.claude/rules/general-unit-test.md` — read in full. Key points: five core
   test principles (independence, isolation, fast execution, determinism,
   readability), >= 85% line / >= 75% branch coverage uniformly across
   tiers, coverage exclusion policy (no production file may be excluded),
   scenario completeness requirements, Arrange-Act-Assert structure, test
   file location mirroring production source tree.
4. `.claude/rules/python.md` — read in full. Key points: Black -> Ruff ->
   Pyright -> Pytest toolchain in order, restart from step 1 on any failure
   or file change, PEP 8 naming, strong typing, dataclass/Protocol usage
   guidance, pytest rules.
5. `.claude/rules/python-suppressions.md` — read in full. Key points:
   pre-authorized `# noqa` / `# type: ignore` suppression patterns and their
   required comment formats; escalation path before requesting new
   suppression approval.

Output Summary: Four of the five listed policy files were read in full;
`CLAUDE.md` does not exist at the repo root in this working tree and its
absence was verified with a direct filesystem check rather than assumed.
This is a pre-existing repository condition unrelated to the remediation
scope of this plan (mirroring four `.claude/**` files into the bundled
extension payload) and does not block execution of Phase 0 through Phase 4.
