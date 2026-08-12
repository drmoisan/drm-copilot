# Parallel Run and Orchestrate Skill Contract Receipt

- Plan task: `[P2-T6]`
- Baseline HEAD: `fe0413d4aca1e76b2d02d05701fba79a887d5405`
- Timestamp: `2026-08-11T05:28:52.2140430Z`

## Root and bundle parity

- Command: `Get-FileHash -Algorithm SHA256` and physical line counts for both root/mirror pairs.
- EXIT_CODE: `0`
- Output Summary: `parallel-run` is `67` lines in both locations at SHA-256 `EA5AD61DECEFC24CE499544E014B13D5C0F0D909724CEBC06F17AA3457AA93CA`; `parallel-orchestrate` is `168` lines in both locations at SHA-256 `EC24399E9A3D6DCB6EF1DC6651CE75428212C2BA848CA746BEB1844220DC90AE`; both pairs are byte-identical.

## Skill structure

- Command: skill-creator `quick_validate.py` for both root skills and both mirrors.
- EXIT_CODE: `0`
- Output Summary: `4/4` skill folders reported `Skill is valid!`.

## Root provenance and persona routing

- Command: focused four-case Pester container for the existing root-only and routed-persona contracts.
- EXIT_CODE: `0`
- Output Summary: `4 passed, 0 failed, 0 skipped`.

Each skill contains exactly one project-custom-agent delegation statement, and
both select only `parallel-orchestrator`.

## Shared readiness and scheduling authorities

- Command: `poetry run pytest -q tests/scripts/dev_tools/test_parallel_manifest_contract.py tests/scripts/dev_tools/test_parallel_cohort_computation.py tests/scripts/dev_tools/test_parallel_kickoff_contract.py tests/scripts/dev_tools/test_validate_parallel_planner_state.py tests/scripts/dev_tools/test_validate_parallel_orchestrator_state.py tests/scripts/dev_tools/test_validate_parallel_orchestrator_state_cohort_barrier.py`
- EXIT_CODE: `0`
- Output Summary: `329 passed in 0.50s`.

- Command: static contract assertions over both skills.
- EXIT_CODE: `0`
- Output Summary: prepared-run committed-blob and readiness requirements passed; manual-entry equivalent readiness passed; `origin/main`/`main` enforcement, integration/fan-in rejection, and persist-before-launch cohort/batch order passed.

`parallel-run` rejects missing, uncommitted, byte-drifted, or not-ready
kickoffs before delegation. Manual `parallel-orchestrate` may omit a planner
kickoff but must satisfy the same repository-backed item-preparation and
planner-state readiness evidence before execution state or launch.

## Repository invariants

- Command: `git status --porcelain -- .claude` and `git diff --check`.
- EXIT_CODE: `0`
- Output Summary: `.claude` status count `0`; diff check exit `0`.
