# 2026-02-04-typescript-engineer-agent - Agent Definition Plan

![Status: Planned](https://img.shields.io/badge/Status-Planned-blue)

- **Issue:** #10
- **Parent (optional):** none
- **Owner:** drmoisan
- **Last Updated:** 2026-02-04T16-20
- **Status:** Planned
- **Version:** 0.1

## Required References

All work must comply with these policies; do not duplicate their content here.

1. [`.github/copilot-instructions.md`](../../../../.github/copilot-instructions.md)
2. [`.github/instructions/general-code-change.instructions.md`](../../../../.github/instructions/general-code-change.instructions.md)
3. [`.github/instructions/general-unit-test.instructions.md`](../../../../.github/instructions/general-unit-test.instructions.md)
4. [`.github/instructions/typescript-code-change.instructions.md`](../../../../.github/instructions/typescript-code-change.instructions.md)
5. [`.github/instructions/typescript-suppressions.instructions.md`](../../../../.github/instructions/typescript-suppressions.instructions.md)
6. [`.github/instructions/typescript-unit-test.instructions.md`](../../../../.github/instructions/typescript-unit-test.instructions.md)

## Implementation Plan (Atomic Tasks)

Requirements and constraints are identified with the following prefixes:

- `REQ-` functional requirements
- `SEC-` security requirements
- `CON-` non-functional constraints

### Requirements Traceability

| ID | Description | Delivered by tasks |
|---|---|---|
| REQ-AGENT-001 | Add a TypeScript engineer agent definition under `.github/agents/` that is discoverable in-repo. | P1-T1, P1-T2 |
| REQ-AGENT-002 | Agent definition cites the repo policy chain and enforces policy precedence. | P1-T2 |
| REQ-AGENT-003 | Agent definition mandates the repo toolchain loop and ordering: `npm run format` → `npm run lint` → `npm run typecheck` → `npm run test:unit`. | P1-T2 |
| REQ-AGENT-004 | Agent definition enforces repo suppression governance using only pre-authorized patterns. | P1-T2 |
| REQ-AGENT-005 | Agent definition enforces the unit-test boundary: Jest unit tests under Node, no VS Code extension host. | P1-T2 |

### Constraints

- CON-NO-BROAD-SUPPRESSIONS: Do not introduce file-level ESLint disables, `// @ts-ignore`, or `// @ts-nocheck`. Only the pre-authorized single-line suppression formats may be used.

### Phase 0 — Context & Inputs

- [x] [P0-T1] Read `.github/copilot-instructions.md` and record the exact file path in `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/policy-read.agent-definition.txt`
  - Acceptance: `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/policy-read.agent-definition.txt` exists and contains the line `.github/copilot-instructions.md`.

- [x] [P0-T2] Read `.github/instructions/general-code-change.instructions.md` and record the exact file path in `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/policy-read.agent-definition.txt`
  - Acceptance: `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/policy-read.agent-definition.txt` contains the line `.github/instructions/general-code-change.instructions.md`.

- [x] [P0-T3] Read `.github/instructions/general-unit-test.instructions.md` and record the exact file path in `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/policy-read.agent-definition.txt`
  - Acceptance: `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/policy-read.agent-definition.txt` contains the line `.github/instructions/general-unit-test.instructions.md`.

- [x] [P0-T4] Read `.github/instructions/typescript-code-change.instructions.md` and record the exact file path in `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/policy-read.agent-definition.txt`
  - Acceptance: `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/policy-read.agent-definition.txt` contains the line `.github/instructions/typescript-code-change.instructions.md`.

- [x] [P0-T5] Read `.github/instructions/typescript-suppressions.instructions.md` and record the exact file path in `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/policy-read.agent-definition.txt`
  - Acceptance: `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/policy-read.agent-definition.txt` contains the line `.github/instructions/typescript-suppressions.instructions.md`.

- [x] [P0-T6] Read `.github/instructions/typescript-unit-test.instructions.md` and record the exact file path in `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/policy-read.agent-definition.txt`
  - Acceptance: `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/policy-read.agent-definition.txt` contains the line `.github/instructions/typescript-unit-test.instructions.md`.

### Phase 1 — TypeScript Engineer Agent Definition

- [x] [P1-T1] Create `.github/agents/typescript-engineer.agent.md` with a top-level heading `# TypeScript Typed Engineer Agent` and a short “Purpose” section
  - Acceptance: `.github/agents/typescript-engineer.agent.md` exists and contains the exact substring `# TypeScript Typed Engineer Agent`.

- [x] [P1-T2] Populate `.github/agents/typescript-engineer.agent.md` with repo-aligned guardrails and mandatory toolchain loop references
  - Implementation details (must appear verbatim in the file):
    - Include a “Policy precedence” section that lists these exact paths:
      - `.github/instructions/general-code-change.instructions.md`
      - `.github/instructions/general-unit-test.instructions.md`
      - `.github/instructions/typescript-code-change.instructions.md`
      - `.github/instructions/typescript-unit-test.instructions.md`
      - `.github/instructions/typescript-suppressions.instructions.md`
    - Include a “Toolchain loop” section that lists these exact commands in this exact order:
      - `npm run format`
      - `npm run lint`
      - `npm run typecheck`
      - `npm run test:unit`
    - Include a “Suppressions” section that includes these exact pre-authorized patterns:
      - `// eslint-disable-next-line <rule-name> -- <reason>`
      - `// @ts-expect-error -- <reason>`
    - Include a “Unit test boundary” section that states: `Unit tests MUST NOT launch the VS Code extension host.`
  - Acceptance: `grep -F` over `.github/agents/typescript-engineer.agent.md` finds each of the exact substrings listed above.

## Acceptance Proof

- `docs/features/active/2026-02-04-typescript-engineer-agent-10/baseline/policy-read.agent-definition.txt` contains all six required policy paths in order.
- `.github/agents/typescript-engineer.agent.md` contains the required heading, policy precedence list, toolchain loop commands, suppression patterns, and unit test boundary statement.

## Test Plan

- Unit: Not applicable. Agent definition is a markdown-only change.
- Integration: Not applicable.
- Manual/CLI: Not applicable.

## Open Questions / Notes

- None. This plan is fully specified and self-contained.
