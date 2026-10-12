# Research: compute-concurrency-batches.sh kcov coverage gap (Issue #884, bash half)

- Date: 2026-10-11
- Target: `.claude/lib/bash/compute-concurrency-batches.sh` (122 lines)
- Requirements source: `docs/features/active/2026-10-11-compute-concurrency-batches-coverage-884/issue.md` (AC-1 to AC-4 and Scope note)
- Evidence: no evidence artifacts were produced by this research. Evidence conventions (`<FEATURE>/evidence/<kind>/`) apply to later plan phases. No non-canonical evidence path was supplied.

## 1. Current state: which suites invoke the script

All paths under `tests/shell/`. Every suite runs the script as a bash subprocess (`bash "$BATCHES" ...` or `"$BASH_BIN" <path>`), never by sourcing it. None sources `compute-concurrency-batches.sh` itself; `parallel_cohorts.bats:16` sources only `parallel-cohorts.sh`.

| Suite | Reference | Script branches driven |
|---|---|---|
| `parallel_cohorts.bats` | `BATCHES` defined at line 14; tests at 152-215, 241-244, 260-292, 295-300, 315 | Success path (152-192, exact multiple, short final batch, sort, cap 1, large cap, negative keys); empty `--keys ""` with cap (164-168); cap below 1, exit 1 with `PCOH_ERROR` text (194-201); leading-zero key and leading-zero cap, exit 2 (203-208); missing `--max-concurrency` (`--keys "1 2"` only) and missing `--keys` (`--max-concurrency 2` only), exit 2 (210-215); multi-separator keys via `batches_print` (231-234 and callers) |
| `parallel_cohorts_parity.bats` | `BATCHES` at line 42; run at line 78 | Success path and cap-below-1 error over the fixture corpus in `tests/fixtures/parallel_cohorts/*.json` |
| `parallel_payload_only.bats` | line 100 (runs the bundled copy under `extensions/drm-copilot/resources/claude-customizations/`, not the repo copy) | Success path only. Does not attribute to the repo file |
| `parallel_bash_manifest_membership.bats` | line 85 | File-existence check only; executes nothing |

Branches NOT driven by any suite for `compute-concurrency-batches.sh`:
- `--keys` with no value (lines 70-73). The only missing-value tests target `compute-cohorts.sh`, and its `--help` and `--unknown` cases are at `parallel_cohorts.bats:136-150`.
- `--max-concurrency` with no value (lines 79-82).
- `--help` / `-h` (lines 86-89). `parallel_cohorts.bats:143-150` drives `--help` for `COHORTS` only.
- Unknown option (lines 90-93). `parallel_cohorts.bats:139` drives `--unknown` for `COHORTS` only.
- Non-integer (non-leading-zero) cap or key, for example `abc`. This is the same `cb_require_integer` lines as the leading-zero tests, so no additional line is gained.
- Sourced-versus-executed guard (118-122): every suite executes the script, so lines 119-121 are covered. The false branch (sourced) executes no line; bash has no branch gate.

## 2. Derivation of uncovered lines and kcov mechanics

kcov configuration (verified):
- Job `Shell Coverage (Bats + kcov)` (job id `shell-coverage`) in `.github/workflows/_shell-coverage.yml:8-9`, called from `.github/workflows/ci.yml:26-27`.
- kcov v43 is built from source (lines 26-49).
- Step at line 51-52: `bash scripts/bash/shell-qc.sh check`. Step at line 54-55: `bash scripts/bash/shell-qc.sh test --coverage`.
- `scripts/bash/shell_qc_lib.sh:350-351`: `--include-pattern` is `$repo_root/tools,$repo_root/scripts,$repo_root/.claude/lib/bash,$repo_root/.claude/skills,$repo_root/.codex`; `--exclude-pattern` is `$repo_root/tests`.
- `shell_qc_lib.sh:355-365`: kcov wraps `bats tests/shell` and `bats tests/bash` as separate runs. Lines 374-385 merge them (`kcov --merge`) and copy the result to `artifacts/pester/kcov/cov.xml`.
- Child `bash` subprocesses started by `run bash ...` are traced through kcov's bash helper. The 81.82% figure for this file proves subprocess invocations are attributed.
- The script is attributed when executed. A test that sources it would also be attributed (same file path). No such test exists.

Executable-line inference (derived by reading the script; the kcov report itself was not available, so this is an inference consistent with the reported figure, not a measured fact):
- Counting lines that carry a traceable command and excluding comments, blanks, function-header lines (34, 51, 64), case labels, `;;`, `}`, `fi`, `done`, `esac`, and heredoc body lines (37-47), the executable set is 44 lines:
  24, 27, 30, 32, 36, 56, 57, 58, 60, 66, 67, 68, 70, 71, 72, 74, 75, 76, 79, 80, 81, 83, 84, 87, 88, 91, 92, 96, 97, 98, 101, 102, 103, 104, 105, 108, 109, 110, 112, 113, 118, 119, 120, 121.
- Multi-line `printf` at 58-59 counts once, at line 58 (reported-line attribution is a kcov particular; counting it once yields 44).
- 36 of 44 covered = 81.818%, which equals the reported 81.82%. This agreement supports the set.
- Uncovered by elimination (8 lines):
  - 71, 72: `cb_usage >&2` and `return 2` for `--keys` with no value.
  - 80, 81: same for `--max-concurrency` with no value.
  - 87, 88: `cb_usage` and `return 0` for `--help` / `-h`.
  - 91, 92: `cb_usage >&2` and `return 2` for an unknown option.
- Lines 70 and 79 (the `(($# >= 2)) ||` test) are covered already by the success path, as are 97-98 (missing flag) and 36 (heredoc `cat`, reached through line 97).
- Arithmetic: covering any one more line gives 37/44 = 84.09% (below 85%). Covering 2 gives 38/44 = 86.36%. Covering all 8 gives 44/44 = 100%.

## 3. Production change

None needed. All eight uncovered lines are reachable by black-box invocation (`bash <script> <args>`). Observable behavior (AC-3) stays unchanged because only test files are added.

## 4. Recommendation

Add a new file: `tests/shell/compute_concurrency_batches_cli.bats`.
- It mirrors production by name (`compute-concurrency-batches.sh` becomes `compute_concurrency_batches_cli`). Sibling files use underscore names with a `parallel_` prefix (`parallel_cohorts.bats`) or `test_` prefix. `tests/shell/` is flat. No `.bats` helper libraries or `load` calls exist anywhere in `tests/shell` (grep for `load`, `bats_load_library`, `bats_require_minimum_version`, and `--separate-stderr` found no matches).
- Do not extend `parallel_cohorts.bats`: it is 351 lines and covers two scripts, so adding cases there approaches the 500-line limit and mixes concerns. The new file is small and focused.

Setup convention (copy from `parallel_cohorts.bats:10-18`):
```
setup() {
    REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
    BATCHES="${REPO_ROOT}/.claude/lib/bash/compute-concurrency-batches.sh"
}
```
Header comment style: `#!/usr/bin/env bats`, then a comment block stating the purpose and that no temporary file is created. Use `run bash "$BATCHES" ...`. In the installed bats, `run` merges stderr into `$output`, which is the pattern used by every sibling file (for example `parallel_cohorts.bats:197`). Do not use `--separate-stderr`, because no sibling does and it needs a minimum-version declaration. Usage first line, from script line 37: `Usage: compute-concurrency-batches.sh --keys "<k1> <k2> ..." --max-concurrency <n>`.

Proposed cases (7; each maps to uncovered lines):

| # | Test name | Invocation | Expected status | Expected output |
|---|---|---|---|---|
| 1 | `--help exits 0 and prints usage` | `run bash "$BATCHES" --help` | 0 | starts with the usage line above (compare via `case` prefix as in `parallel_cohorts.bats:146-149`); also assert it contains `Options:` |
| 2 | `-h is equivalent to --help` | `run bash "$BATCHES" -h` | 0 | same usage prefix |
| 3 | `--keys with no value is a usage error` | `run bash "$BATCHES" --keys` | 2 | starts with `Usage: compute-concurrency-batches.sh` (usage goes to stderr, merged in `$output`) |
| 4 | `--max-concurrency with no value is a usage error` | `run bash "$BATCHES" --keys "1 2" --max-concurrency` | 2 | same usage prefix |
| 5 | `an unknown option is a usage error` | `run bash "$BATCHES" --bogus` | 2 | same usage prefix |
| 6 | `--help after valid flags still prints usage and exits 0` (optional) | `run bash "$BATCHES" --keys "1" --help` | 0 | usage prefix; asserts parse order |
| 7 | `a non-integer cap is rejected with the lexical error` (optional hardening; adds no new line) | `run bash "$BATCHES" --keys "1" --max-concurrency abc` | 2 | `compute-concurrency-batches.sh: max_concurrency must be a decimal integer matching -?(0\|[1-9][0-9]*); found: abc` (script lines 58-59) |

Cases 1-5 cover all eight lines (87-88, 71-72, 79-82, 91-92). That brings the file from 36/44 to 44/44 by the inference above. Cases 6-7 are optional; the plan may drop them to keep the change minimal. Each test body: Arrange (REPO_ROOT in setup), Act (`run`), Assert (status and output).

Assertion note: a single missing-value case at the end of the argument list is required for lines 70-73 and 79-82 (the `(($# >= 2))` guard fails only when the flag is last). Case 4 places `--max-concurrency` last after a valid `--keys`, so it also drives line 74-76 and then 80-81.

## 5. Lint, format, and CI evidence

- `.bats` files are not linted or formatted by CI. `shell-qc.sh check` discovers files only under `tools`, `scripts`, `.claude/lib/bash`, `.claude/skills`, `.codex` (`shell_qc_lib.sh:85`), and accepts a file only if it ends in `.sh` or its shebang resolves to bash or sh (`shell_qc_lib.sh:54-73`). `tests/` is not a root, and `#!/usr/bin/env bats` resolves to `bats`. Follow sibling style (four-space indent, as in `parallel_cohorts.bats`) for consistency.
- Pass evidence for AC-2 (bats): the CI job `Shell Coverage (Bats + kcov)` (check name appears as `shell-coverage / Shell Coverage (Bats + kcov)` when called from `ci.yml`), step `Run shell-qc test with coverage`. bats runs under kcov in that step; a bats failure fails the step. There is no separate bats-only job.
- Per-file kcov figure for AC-1: artifact `shell-coverage` (uploaded from `artifacts/pester/kcov/**`) contains `cov.xml` (Cobertura, copied from `kcov-merged/cov.xml`) and the kcov HTML report. In `cov.xml`, find the `<class ... filename=".claude/lib/bash/compute-concurrency-batches.sh" line-rate="0.xxxx">` element; its `line-rate` attribute is the per-file ratio (assert `>= 0.85`). The job log line `Bash coverage (lines): NN.N%` (`shell_qc_lib.sh:293-306`) is the aggregate across all files, not per file, so it cannot prove AC-1. Exact attribute layout of the kcov-merged `cov.xml` class element was not verified (no sample available); the plan should treat the filename form (repo-relative versus absolute) as to be confirmed from the artifact.

## 6. Constraints to record in the plan

- Verification is Option A only: no local `sh`, `bash`, `pwsh`, `bats`, or `kcov` invocation. Bats and kcov results come from the PR's CI run (`CLAUDE.md` memory notes the worktree guard denies those commands).
- Scratch files must include `884` in their path.
- `.codex/hooks/validate-feature-review-coverage.ps1` and its tests are out of scope (AC-4). The PR must reference #884 without a closing keyword.
- No temporary files in tests (`.claude/rules/general-unit-test.md`); every input is a literal.
- AC-3: production script is untouched; existing suites listed in section 1 must pass unchanged.
- Tier and gate note: bash line coverage floor is 85%; no bash branch gate.

## Rejected alternatives (brief)

- Extend `parallel_cohorts.bats`: rejected for file size (351 lines) and mixed concerns.
- Refactor `cb_main` for testability: rejected as unnecessary; every uncovered line is reachable black-box.
- Source the script in tests: rejected; it adds no covered lines beyond executing it and the guard false-branch has no line.

## Open items

- The 44-line executable set and the 8 uncovered lines are inferred (they reproduce the reported 81.82% exactly) and not read from the kcov report. The CI kcov report for the PR head is the authoritative check.
