# Phase 0 — Policy Instructions Read

- Timestamp: 2026-07-19T06-59
- Policy Order:
  1. `CLAUDE.md`
  2. `.claude/rules/general-code-change.md`
  3. `.claude/rules/general-unit-test.md`
  4. `.claude/rules/tonality.md`

## Files Read

- `CLAUDE.md` — repository standing instructions (tone policy, policy-compliance reading order, four-layer runtime architecture).
- `.claude/rules/general-code-change.md` — cross-language code change policy (design principles, toolchain loop, file size limit, error handling, naming, public APIs, dependencies, I/O boundaries).
- `.claude/rules/general-unit-test.md` — cross-language unit test policy (coverage requirements, scenario completeness, test structure, external dependencies, test file location, determinism infrastructure).
- `.claude/rules/tonality.md` — required professional tone policy (no humor, no hyperbole, restricted metaphor, evidence-first wording).

## Applicability Statement

This feature delivers Markdown documentation only (six files under
`docs/engineering/legacy-discovery-and-parity/`). No Python, PowerShell, TypeScript, or
C# source files are in scope. Consequently, no language-specific code rule
(`.claude/rules/python.md`, `.claude/rules/powershell.md`, `.claude/rules/typescript.md`,
`.claude/rules/csharp.md`) applies to this feature. The mandatory seven-stage toolchain
loop in `.claude/rules/general-code-change.md` and the coverage policy in
`.claude/rules/general-unit-test.md` apply to code; no code is authored by this plan
(the optional P2-T6 pytest contract test, if authored, would be the sole exception and
would be run through `poetry run pytest` at that time). The tone policy in
`.claude/rules/tonality.md` applies to all six authored documentation pages.
