# Parallel Codex Readiness and Checkpoint Receipt

- Plan task: `[P2-T8]`
- Baseline HEAD: `fe0413d4aca1e76b2d02d05701fba79a887d5405`
- Verified at: `2026-08-11T03-15-04:00`
- Result: `PASS`

## Contract and ownership

- The shared parallel planner and orchestrator checkpoint schemas remain
  runtime-neutral and do not add Codex-only required fields.
- Version `2` external Codex launch records are loaded only from guarded
  `launch_receipt_path` and `launch_status_path` values.
- Version `1` committed kickoff identity binds the conventional kickoff path,
  plan-home ref, planning commit, committed blob, and worktree content.
- `scripts/dev_tools/validate_parallel_codex_readiness.py` and
  `extensions/drm-copilot/src/lib/validate/parallel-codex-readiness.ts` own the
  pure readiness decisions.
- The focused Python and TypeScript filesystem helpers own repository reads and
  Git identity checks. The public Python dispatcher and TypeScript
  direct/service/MCP paths compose those helpers only for explicit planner-ready
  or orchestrator-complete validation.

The explicit gates require complete item preparation, guarded launch and status
records, authority/delegation/topology/model-routing receipts, committed kickoff
identity, valid mutation and drift state, and one normalized enforceability
ledger with zero `LOST` rows. Epic and fan-in keys, unsafe paths, stale bindings,
missing or malformed records, inconsistent ledgers, and Git drift fail closed.

## Python terminal loop

- Black command: `poetry run black --check` over the 12 P2-T8 Python production
  and test files.
  - Exit code: `0`
  - Result: `12 files would be left unchanged`.
- Ruff command: `poetry run ruff check` over the same 12 files after restarting
  from formatting following one import-order autofix.
  - Exit code: `0`
  - Result: `All checks passed!`
- Pyright command: `poetry run pyright` over the same 12 files.
  - Exit code: `0`
  - Result: `0 errors, 0 warnings, 0 informations`.
- Import smoke: imported
  `scripts.dev_tools.parallel_codex_readiness_filesystem` and
  `scripts.dev_tools.validate_orchestration_artifacts`.
  - Exit code: `0`
  - Result: `parallel readiness imports: OK`.
- Focused regression command:
  `poetry run pytest -q tests/scripts/dev_tools -k "parallel or codex_topology or codex_deployment"`.
  - Exit code: `0`
  - Result: `1455 passed, 5 skipped, 2308 deselected in 1.88s`.
- Previously failing public/core boundary rerun:
  - Exit code: `0`
  - Result: `10 passed in 0.15s`.

## TypeScript and MCP terminal loop

- Prettier: `npx.cmd prettier --check "src/**/*.ts" "test/**/*.ts"`.
  - Exit code: `0`
  - Result: all matched files use Prettier style.
- ESLint: `npm.cmd run lint`.
  - Exit code: `0`.
- TypeScript: `npm.cmd run typecheck`.
  - Exit code: `0`.
- Full Jest: `npm.cmd run test:unit -- --runInBand`.
  - Exit code: `0`
  - Result: `187/187` suites and `2594/2594` tests passed, with zero
    snapshots.

## Focused cross-runtime and public-path proof

- Python readiness, filesystem, kickoff, and public-dispatch files:
  - Exit code: `0`
  - Result: `75 passed in 0.27s`.
- TypeScript readiness, filesystem, kickoff, direct dispatch, in-process
  service, input-builder, registered MCP handler, and outer service files:
  - Exit code: `0`
  - Result: `8/8` suites and `113/113` tests passed.

These focused suites assert matching versioned readiness rules and ordered
reason strings across the Python and TypeScript authorities. They also prove
that valid file-backed evidence passes and missing or mismatched evidence is
rejected through direct dispatch, the in-process service, and the registered
MCP handler without adding a new MCP input field.

## Repository invariants

- Changed code-file size scan: `51` files scanned; maximum `500` lines; `0`
  violations.
- Protected `.claude/` diff: `0` paths.
- Protected `.claude/` SHA-256 comparison: `150` expected, `150` current, `0`
  deltas.
- Routing configuration byte parity: all three `12048`-byte copies have SHA-256
  `C42C37D542FBD361568883AE3D8AC9C69DB0EA129CE901EA5AB4E2AF0D4E618F`.
- `git diff --check`: exit code `0`.
- Filesystem tests use injected in-memory filesystem and Git seams; no temporary
  files, network calls, or external processes are used.
