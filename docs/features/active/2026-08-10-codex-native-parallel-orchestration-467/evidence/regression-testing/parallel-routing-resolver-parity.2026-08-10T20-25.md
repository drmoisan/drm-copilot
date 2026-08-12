# Parallel Routing Resolver Parity Receipt

- Plan task: `[P2-T3]`
- Baseline HEAD: `fe0413d4aca1e76b2d02d05701fba79a887d5405`
- Canonical routing SHA-256: `C42C37D542FBD361568883AE3D8AC9C69DB0EA129CE901EA5AB4E2AF0D4E618F`
- Root/bundle byte parity: `true`

## Python gates

- Black check: exit `0`; four scoped files unchanged on the final pass.
- Ruff: exit `0`.
- Pyright: exit `0`; `0 errors, 0 warnings`.
- Focused resolver and configuration-parity tests: exit `0`; `76 passed`.

## TypeScript gates

- Prettier check: exit `0`; all four scoped files matched.
- ESLint: exit `0`; no findings.
- TypeScript typecheck: exit `0`.
- Focused topology/model-routing Jest suites: exit `0`; `2/2` suites and `70/70` tests passed.

## Cross-runtime decisions

Python and TypeScript emitted identical normalized decisions for both forced
root contexts:

- `parallel_planning` resolves to route `parallel`, topology
  `parallel_persona`, agent `parallel-planner`, model `gpt-5.6-sol`, reasoning
  effort `ultra`, and orchestration ceiling `C4`.
- `parallel_execution` resolves to route `parallel`, topology
  `parallel_persona`, agent `parallel-orchestrator`, model `gpt-5.6-sol`,
  reasoning effort `ultra`, and orchestration ceiling `C4`.
- Both runtimes reject an unavailable exact Sol deployment with
  `ModelUnavailableError` and reason `model_unavailable`; neither selects a
  fallback model.

## Repository invariants

- Production file line counts: Python topology `353`, Python deployment `298`,
  TypeScript topology `320`, TypeScript model routing `496`.
- Canonical and bundled configuration line counts: `379` each.
- `.claude` status entries: `0`.
- `git diff --check`: exit `0`.
