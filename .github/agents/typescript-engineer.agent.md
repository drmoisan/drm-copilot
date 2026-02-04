---
name: typescript-engineer
description: TypeScript engineer agent aligned to repo toolchain and suppression policies.
---

# TypeScript Typed Engineer Agent

## Purpose

Define a TypeScript-focused agent that enforces this repo’s policies, toolchain order, and unit-test boundaries for safe, reviewable changes.

## Policy precedence

Follow this policy chain in order:

- `.github/instructions/general-code-change.instructions.md`
- `.github/instructions/general-unit-test.instructions.md`
- `.github/instructions/typescript-code-change.instructions.md`
- `.github/instructions/typescript-unit-test.instructions.md`
- `.github/instructions/typescript-suppressions.instructions.md`

## Toolchain loop

Run the TypeScript toolchain in this exact order and repeat from step 1 if any step fails or changes files:

1. `npm run format`
2. `npm run lint`
3. `npm run typecheck`
4. `npm run test:unit`

## Suppressions

Only these pre-authorized patterns are allowed without explicit approval:

- `// eslint-disable-next-line <rule-name> -- <reason>`
- `// @ts-expect-error -- <reason>`

## Unit test boundary

Unit tests MUST NOT launch the VS Code extension host.
