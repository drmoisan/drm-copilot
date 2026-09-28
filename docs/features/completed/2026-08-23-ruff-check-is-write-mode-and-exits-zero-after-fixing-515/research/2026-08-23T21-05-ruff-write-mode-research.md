# Research: `ruff check` is write-mode and exits zero after fixing (Issue #515)

- Date: 2026-08-23
- Issue: #515
- Branch: `bug/ruff-check-is-write-mode-and-exits-zero-after-fixing-515`
- Work mode: full-bug
- Source of requirements: `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/issue.md`

## Evidence Method and Its Limits

This agent's tool allowlist contains no command-execution tool. Every finding below is
established by reading committed repository text, and each claim cites a repo-relative path
and line number. No command was run by this agent, so no exit code is recorded for a
command this agent executed.

The reproduction itself was executed and recorded by the issue author. It is cited as
reported evidence, not re-verified here: `issue.md` lines 22, 40, and 42-58 record
`poetry run ruff check <file>` deleting an unused import and exiting 0, and
`poetry run ruff check --no-fix <file>` leaving the file unchanged and exiting 1, with the
rewrite confirmed by before/after content comparison (`issue.md` line 60). That record also
establishes that the `--no-fix` flag is accepted by the installed ruff 0.15.12
(`issue.md` line 21).

## 1. Current Configuration State (Confirmed)

`pyproject.toml` lines 88-92:

```toml
[tool.ruff]
line-length = 88
target-version = "py310"
fix = true
show-fixes = true
```

- `fix = true` is present at `pyproject.toml:91`.
- `show-fixes = true` is present at `pyproject.toml:92`.

Both are still set exactly as the issue reports.

Two supporting facts fix the scope of this configuration:

- **`pyproject.toml` is the only Ruff configuration source in the repository.** A glob for
  `**/ruff.toml` returned no files, and a glob for
  `extensions/drm-copilot/resources/**/pyproject.toml` returned no files. There is no
  bundled or published second copy of the Ruff configuration, and no `ruff.toml` that could
  override or shadow it.
- **There is no committed editor configuration.** `.vscode/settings.json` does not exist
  (Read returned a path-does-not-exist error). The repository therefore commits no
  `codeActionsOnSave` / `source.fixAll.ruff` setting, so the only committed mechanism that
  makes the linter write is `fix = true` in `pyproject.toml`.

## 2. Call-Site Inventory

Classification key: **A** = agent-facing (an agent reads this to decide the command, or code
that spawns the command on an agent's behalf), **H** = human-facing (documentation or an
editor task a person invokes), **CI** = executed by GitHub Actions.

### 2.1 Bare (write-mode) invocations

| # | Path:line | Class | Exact invocation | Note |
|---|---|---|---|---|
| 1 | `.github/workflows/_quality-checks.yml:61` | CI | `poetry run ruff check` | Step `Lint with Ruff`, job `quality-checks7`; see section 3 |
| 2 | `.claude/rules/python.md:14` | A | `` `poetry run ruff check .` `` | Policy rule; prohibited surface (section 5) |
| 3 | `.claude/skills/python-qa-gate/SKILL.md:31` | A | `` `poetry run ruff check .` `` | Step 2 of the QA-gate toolchain sequence |
| 4 | `.agents/skills/python/SKILL.md:15` | A | `` `poetry run ruff check .` `` | Codex/agents mirror of item 2 |
| 5 | `.agents/skills/python-qa-gate/SKILL.md:31` | A | `` `poetry run ruff check .` `` | Codex/agents mirror of item 3 |
| 6 | `.github/instructions/python-code-change.instructions.md:47` | A | `` Approved command: `poetry run ruff check` `` | Canonical policy; prohibited surface (section 5) |
| 7 | `.github/agents/commentary-remediation.agent.md:23` | A | `` `poetry run ruff check` `` | In a "validation loop (no shortcuts)" that says "If any step changes files or fails ... restart from Black" |
| 8 | `.github/agents/python-atomic-executor.agent.md:260` | A | `` `poetry run ruff check` `` | "Lint (`poetry run ruff check` or repo task equivalent)" |
| 9 | `.github/agents/staged-review.agent.md:158` | A | `` `poetry run ruff check .` `` | "If Ruff: ... (or repo-specific task)" |
| 10 | `.github/prompts/remediate-comments.prompt.md:38` | A | `` `poetry run ruff check` `` | |
| 11 | `scripts/dev_tools/atomic_executor/qc_toolchain.py:45` | A | `["poetry", "run", "ruff", "check"]` | `PYTHON_TOOLCHAIN_COMMANDS["ruff"]` |
| 12 | `scripts/dev_tools/atomic_executor/qc_runner.py:79` | A | `["poetry", "run", "ruff", "check"]` | `QCRunner.FULL_LINT` |
| 13 | `scripts/dev_tools/atomic_executor/qc_runner.py:141` | A | `["poetry", "run", "ruff", "check", *py_files]` | Scoped task gate, changed files only |
| 14 | `scripts/dev_tools/atomic_executor/qc_runner.py:367` | A | `["poetry", "run", "ruff", "check"]` | `full_lint=` argument into `run_full_loop_with_artifacts` |
| 15 | `scripts/dev_tools/atomic_executor/cli_preflight.py:119` | A | `("ruff", ["poetry", "run", "ruff", "check"])` | Preflight QC step list |
| 16 | `scripts/dev_tools/atomic_executor/cli_preflight.py:376` | A | `"   - \`poetry run ruff check\`"` | Remediation-guidance text emitted to the agent |
| 17 | `scripts/dev_tools/atomic_executor/prompt_builder.py:300` | A | `- python -m poetry run ruff check` | Text injected into the executor prompt |
| 18 | `scripts/dev_tools/fix_all_branches_extra.py:97` | A | `["poetry", "run", "ruff", "check"]` | See section 2.4 — this call site is actively miscomputing |
| 19 | `.vscode/tasks.json:328-332` | H | `poetry`, args `run`, `ruff`, `check` | Task label `QC: 2 Ruff: lint` (line 338) |
| 20 | `README.md:314` | H | `` - lint: `poetry run ruff check .` `` | |
| 21 | `.devcontainer/README.md:95` | H | `` `poetry run ruff check` `` | |
| 22 | `.devcontainer/post-create.sh:315` | H | `echo "  poetry run ruff check                     # Lint Python code"` | Help text printed after container create |

### 2.2 Bare invocations in the published/bundled destination copies

These are copies of the repo-root documents that ship inside the extension for push-down
into a destination workspace. They carry the same bare form.

| # | Path:line | Class | Exact invocation | Mirror of |
|---|---|---|---|---|
| 23 | `extensions/drm-copilot/resources/claude-customizations/.claude/rules/python.md:14` | A | `` `poetry run ruff check .` `` | item 2 |
| 24 | `extensions/drm-copilot/resources/claude-customizations/.claude/skills/python-qa-gate/SKILL.md:31` | A | `` `poetry run ruff check .` `` | item 3 |
| 25 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/python/SKILL.md:15` | A | `` `poetry run ruff check .` `` | item 4 |
| 26 | `extensions/drm-copilot/resources/codex-and-agents-customizations/.agents/skills/python-qa-gate/SKILL.md:31` | A | `` `poetry run ruff check .` `` | item 5 |
| 27 | `extensions/drm-copilot/resources/customizations/.github/instructions/python-code-change.instructions.md:47` | A | `` `poetry run ruff check` `` | item 6 |
| 28 | `extensions/drm-copilot/resources/customizations/.github/agents/commentary-remediation.agent.md:23` | A | `` `poetry run ruff check` `` | item 7 |
| 29 | `extensions/drm-copilot/resources/customizations/.github/agents/python-atomic-executor.agent.md:260` | A | `` `poetry run ruff check` `` | item 8 |
| 30 | `extensions/drm-copilot/resources/customizations/.github/agents/staged-review.agent.md:158` | A | `` `poetry run ruff check .` `` | item 9 |
| 31 | `extensions/drm-copilot/resources/customizations/.github/prompts/remediate-comments.prompt.md:38` | A | `` `poetry run ruff check` `` | item 10 |
| 32 | `extensions/drm-copilot/resources/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md:209, 439, 622` | A/H | `poetry run ruff check` | template, mirrored at `docs/features/templates/policy_audit/policy-audit.yyyy-MM-ddTHH-mm.md` |

Two distinct mirror-enforcement regimes apply to this set, and they are not equivalent:

- **`.claude/**`, `.agents/**`, `.codex/**` are byte-parity enforced.**
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:101-126` enumerates
  every repo-root `.claude/**` file (excluding `.claude/settings.local.json` and
  `.claude/agent-memory/**`) and asserts `read_text(BUNDLED_ROOT, p) == read_text(REPO_ROOT, p)`.
  `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:207-220`
  does the same for `SCOPED_ROOTS = (Path(".codex"), Path(".agents"))` (line 35). Any edit to
  items 2, 3, 4, or 5 therefore **requires** a byte-identical edit to items 23, 24, 25, or 26,
  or these two tests fail.
- **`.github/**` is not byte-parity enforced.** The only mirror assertion for the Copilot
  surface is `test_thinking_beast_mode_bundle_mirror_matches_root_agent`
  (`tests/scripts/dev_tools/test_push_down_copilot_customizations_helpers.py:625-638`), which
  covers exactly one file, `.github/agents/5.1-Thinking-Beast-Mode-adjusted.agent.md`. Items
  27 through 31 can therefore drift from items 6 through 10 silently. This is the same
  stale-published-copy failure class already recorded for the blast-radius truth table in
  `.claude/rules/parallel-orchestration.md` under "The published truth table is not a copy of
  this one (issue #500)".

### 2.3 Read-only and deliberate-fix invocations (no defect)

`--no-fix` appears **nowhere** in the repository outside `docs/**`. A content search for
`ruff.{0,40}--fix|--no-fix` across the tree with `!docs/**` returned exactly three hits, all
deliberate `--fix`:

| Path:line | Class | Invocation |
|---|---|---|
| `scripts/dev_tools/fix_all.py:473` | A | `["poetry", "run", "ruff", "check", "--fix"]` (`_ruff_fix`) |
| `.vscode/tasks.json:349-353` | H | `poetry run ruff check --fix`, task label `QC: 2 Ruff: fix` (line 360) |
| `.devcontainer/QUICKSTART.md:35` | H | `poetry run ruff check --fix` |

**Every path in the repository that intends to auto-fix already passes `--fix` explicitly.**
Nothing depends on `fix = true` to obtain auto-fix behavior. This is the single most
important fact for the remediation decision.

`.vscode/tasks.json` is decisive on intent: it defines two separate tasks, `QC: 2 Ruff: lint`
(bare, line 338) and `QC: 2 Ruff: fix` (`--fix`, line 360). Under `fix = true` those two tasks
are behaviorally identical. The task file was authored on the assumption that the bare form
does not write.

### 2.4 Two call sites where the defect is already miscomputing, in code

These are not merely documentation exposure. They are live logic whose control flow is wrong
under `fix = true`.

**(i) `scripts/dev_tools/fix_all_branches_extra.py:75-127.`** The function comment at lines
75-76 states the design: "a Ruff auto-fix can change formatting, so the loop restarts Black
and Ruff until Ruff passes without applying fixes." The loop runs the **bare** form at line 97
and branches on the return code at line 101: `returncode == 0` logs "Ruff linting passed" and
breaks out of the loop (line 127); non-zero calls `api.ruff_fix(...)` and then restarts Black
(lines 106-125). Under `fix = true`, a run that fixes everything it found returns 0, so the
loop takes the `break` branch. The files were rewritten and Black is never re-run. The
restart-on-auto-fix behavior the comment describes is unreachable for the fixable case.

**(ii) `scripts/dev_tools/atomic_executor/qc_runner_loop.py:199-250.`** The full QC loop takes
a `diff_signature_fn` snapshot *before* the format step (lines 204-208) and *after* it (lines
227-231), and restarts the loop when they differ (lines 232-233). No such snapshot pair
brackets the lint step at lines 235-240. A write performed by the linter is structurally
invisible to this loop, which proceeds to the type and test steps and returns
`QCLoopResult(success=True, ...)` at line 287.

Together these are the mechanism behind the issue's severity claim 1. The restart-on-auto-fix
requirement in `.claude/rules/general-code-change.md` line 42 and in
`.github/instructions/general-code-change.instructions.md:236-239` ("If the linter fails **or
auto-fixes** anything ... restart the toolchain pass from step 1") has no corresponding
detection anywhere in the executor.

### 2.5 Test and matching-pattern call sites (informational)

These reference the command form but assert nothing about write mode. They are recorded so a
later change does not surprise the executor.

- `scripts/dev_tools/atomic_executor/qc_toolchain.py:31` —
  `"ruff": re.compile(r"poetry\s+run\s+ruff\s+check\b", re.IGNORECASE)`. The trailing `\b`
  means the pattern still matches if a flag is appended, so adding `--no-fix` to plan text
  would not break plan-step detection.
- `scripts/dev_tools/atomic_executor/plan_parser.py:456` — `r"black.*ruff.*pyright.*pytest"`.
- `tests/scripts/dev_tools/test_plan_gate_commands.py:199, 209, 224` and
  `extensions/drm-copilot/test/lib/validate/plan-gate-commands.test.ts:169, 181` — use
  `"poetry run ruff check scripts"` as arbitrary extractor sample text.
- `tests/scripts/dev_tools/atomic_executor/test_prompt_builder.py:365` — asserts
  `"python -m poetry run ruff check" in prompt`, pinning call site 17. A change to call site
  17 requires a matching change here.
- `tests/scripts/dev-tools/sync-agents-from-instructions.Tests.ps1:474-500` — contains the
  literal `Approved command: poetry run ruff check` at line 482, but as inline **mock** input
  fed through `Mock -CommandName Get-DiscoveredInstructionFile`. It does not read the real
  instruction file, so editing call site 6 does not break it.
- `.claude/agents/atomic-executor.md:12` — permission grant `"Bash(poetry run ruff *)"`. The
  trailing wildcard admits any flag; no grant change is needed under any remediation.
- `.claude/hooks/enforce-orchestration-preimplementation-gate.ps1:67` — blocking pattern
  `'(^|\s)(poetry\s+run\s+)?(black|ruff|pyright|pytest)\b'`. Unaffected by an added flag.

### 2.6 Committed atomic-plan exposure (characterization only)

A repository-wide count of `ruff check` returned 1363 occurrences across 786 files, the
large majority under `docs/features/archive/**` and `docs/features/active/**` (plans,
policy audits, and captured QA-gate evidence). Representative examples:
`docs/features/archive/2026-04-05-potential-to-issue-missing-label-123/plan.2026-04-05T13-30.md`
(4 occurrences) and
`docs/features/archive/2026-02-22-testing-missing-mock-injections-42/plan.2026-02-22T15-25.md`
(3 occurrences).

The exposure is that every committed plan whose acceptance gate reads "`poetry run ruff check`
exits 0" was satisfiable by a run that rewrote production files. The issue records one
concrete instance where this mattered: a plan for issue #502 gated a task on an anticipated
`F401` using the bare command, so the gate would have repaired the defect it was written to
detect (`issue.md` line 79). **No historical plan should be edited.** Plans are point-in-time
records, and `.claude/rules/plan-acceptance-gates.md` section "Scope of Invocation" is
explicit that no sweep evaluates the committed plan corpus. The correct response is to make
the bare form read-only going forward, which retroactively gives every one of those gates the
meaning its author intended.

## 3. CI Exposure

**Yes. One workflow runs the bare form.**

- Workflow: `.github/workflows/_quality-checks.yml` (`name: Quality Checks (reusable)`, line 1)
- Job: `quality-checks7` (line 8), `name: Code Quality & Tests` (line 9),
  `runs-on: ubuntu-latest` (line 10), matrix over Python 3.10 / 3.11 / 3.12 / 3.13 (lines 11-13)
- Step: `Lint with Ruff` (line 59), `run: poetry run ruff check` (line 61),
  `continue-on-error: false` (line 62)

Consequence. On every matrix leg, the linter rewrites fixable violations inside the runner's
checkout and the step exits 0. Three specific effects follow:

1. **A fixable finding never fails CI.** Only violations with no available autofix can fail
   this step. A pull request introducing, for example, an unused import (`F401`) or an
   unsorted import block (`I001`) passes the lint gate.
2. **The rewrite is discarded.** The runner's working tree is ephemeral and nothing commits or
   uploads it, so the branch merges carrying the original, unlinted content. The next
   developer to run the linter locally sees the finding the CI leg hid.
3. **The contrast with the immediately preceding step makes the asymmetry visible.** Line 56
   runs `poetry run black --check .`, the explicitly read-only form of the formatter. Line 61
   runs the linter with no equivalent guard. This is exactly the "reviewers read 'which stages
   write' as 'which formatters write'" observation recorded at `issue.md` line 62.

Note that the workflow does contain a working precedent for detecting an in-runner rewrite:
the `Verify poetry.lock is in sync` step at lines 45-52 runs `git diff --exit-code poetry.lock`
and fails explicitly. No such check brackets the lint step.

## 4. Remediation Directions

### (a) Remove `fix` from the shared configuration — RECOMMENDED

Delete `fix = true` from `pyproject.toml:91`.

- **Interactive human use:** the bare `poetry run ruff check` becomes read-only. Every
  intentional human auto-fix path is unaffected because all three pass `--fix` explicitly
  (`.vscode/tasks.json:349-353`, `.devcontainer/QUICKSTART.md:35`,
  `scripts/dev_tools/fix_all.py:473`; see section 2.3). The `QC: 2 Ruff: fix` task keeps
  working; the `QC: 2 Ruff: lint` task starts doing what its label says. There is no committed
  `.vscode/settings.json`, so no fix-on-save behavior is affected.
- **Agents:** all 22 bare call sites in section 2.1 and all 9 in section 2.2 become read-only
  simultaneously, with no edit to any of them. Acceptance gates phrased as "the lint stage
  exits 0" recover their intended meaning, including in every historical plan.
- **Call sites touched:** one — `pyproject.toml`.
- **Repairs the two logic defects in section 2.4 at no extra cost.**
  `fix_all_branches_extra.py` starts taking its non-zero branch on a fixable finding, calling
  `api.ruff_fix()` and then restarting Black, which is the behavior its own comment at lines
  75-76 describes. `qc_runner_loop.py`'s missing lint-step diff snapshot becomes moot for the
  configured toolchain, because the lint step no longer writes.
- **Failure mode when a new call site is added later:** none. A new bare call site inherits
  read-only behavior automatically. This is the direction's decisive advantage: it is the only
  one of the four that is closed by default rather than by discipline.
- **Residual risk:** the setting can be reinstated. A caller can also override with
  `--fix` or `--config`. Both are addressed in section 6.

### (b) Require `--no-fix` at every agent-facing call site — REJECTED

Rejected on three grounds. First, cardinality and drift: it touches at least 18 agent-facing
call sites (items 2-18) plus 9 published mirrors (items 23-31), and a new call site added
later defaults back to write mode, so the guarantee decays. Second, it does not fix CI: item 1
is a workflow step, not an agent-facing document, so a separate change is still required.
Third, and decisively, it requires editing `.claude/rules/python.md` and
`.github/instructions/python-code-change.instructions.md`, both of which are inside the
modification prohibition (section 5). Direction (a) achieves a strictly stronger guarantee
without touching either.

### (c) Dedicated Poetry script or task target for the agent path — REJECTED

Rejected. It adds a `[tool.poetry.scripts]` entry or `.vscode/tasks.json` task that agents
must be told to prefer, which means editing the same policy documents direction (b) requires,
and it leaves the bare form write-mode for anyone who does not use the new target. It adds a
surface without closing the default. `.vscode/tasks.json` already has both a lint task and a
fix task; the problem is not a missing target, it is that the two targets currently behave
identically.

### (d) Add a lint-step diff snapshot to the executor QC loop — a fourth direction, deferred

`qc_runner_loop.py:199-250` could bracket the lint step with the same
`diff_signature_fn` pair it already applies to the format step at lines 204-233, making an
auto-fix by *any* linter detectable and the restart-on-auto-fix rule genuinely enforceable
rather than merely moot.

This is real hardening and is the only direction that would survive a future re-enabling of
fix mode by a path the configuration test does not observe. It is nonetheless **not folded
into this fix**, for two reasons. It changes execution-control logic in the atomic executor,
which is a materially larger and riskier diff than a one-line configuration deletion, and it
would require its own test coverage for the restart path. Recommend filing it as a separate
follow-up issue rather than expanding this bug's scope.

### Recommendation

**Adopt direction (a): delete `fix = true` from `pyproject.toml:91`, and add a configuration
regression test that fails if fix mode is reintroduced.**

The justification that carries the most weight is the one established in section 2.3: every
path that intends to auto-fix already passes `--fix` explicitly, so the setting is providing
no capability that would be lost. `.vscode/tasks.json`'s two distinct lint and fix tasks show
the repository already assumes the bare form is read-only. Direction (a) makes the
implementation match that assumption in one line, fixes CI and all 31 call sites at once,
repairs both logic defects in section 2.4, requires no edit to any prohibited policy document,
and is closed by default against new call sites.

Retain `show-fixes = true` at `pyproject.toml:92`. With fix mode off it reports which findings
are fixable rather than which fixes were applied, which preserves the diagnostic value the
issue asks for in its third validation idea ("still reports fixable violations rather than
hiding them", `issue.md` line 98) while removing the write. Removing it as well would be a
larger diff for no stated benefit.

**Explicit residual risk of the recommendation.** Direction (a) removes the *default*; it does
not remove the *capability*. Three ways the write can return:

1. `fix = true` is re-added to `[tool.ruff]` in `pyproject.toml`. Closed by the regression
   test in section 6.
2. A `ruff.toml` or `.ruff.toml` is added at the repository root, or under a subdirectory, and
   enables `fix`. No such file exists today (verified by glob), and the regression test should
   assert its continued absence at the root.
3. A caller passes `--fix` or `--config` explicitly. This is out of scope and correctly so:
   an explicit `--fix` is a visible, intentional request to write, which is the behavior the
   issue wants. Only the *silent* form is the defect.

A fourth residual is that direction (a) does not make an auto-fix *detectable* — it makes it
not happen under the configured commands. If a future change reintroduces a writing linter
step by a route the test does not observe, `qc_runner_loop.py` still has no snapshot around
the lint step. That is precisely what direction (d) would close, and it is the reason to file
(d) rather than drop it.

## 5. Policy-Document Constraint

Two prohibitions apply, and they are consistent with each other:

- `CLAUDE.md`, "Policy Compliance Reading Order": the `.github/instructions/**` files "are the
  canonical policy source. Do not modify them."
- `.claude/skills/policy-compliance-order/SKILL.md:32`: "Do NOT modify policy documents under
  `.claude/rules/` or `.github/instructions/`."

Documents that fall inside the prohibition and would need to change under each direction:

| Direction | Prohibited documents it would require editing | Verdict |
|---|---|---|
| (a) remove the setting | none | **Clear.** No policy document changes. |
| (b) `--no-fix` at every call site | `.claude/rules/python.md:14`; `.github/instructions/python-code-change.instructions.md:47` | **Blocked** without an explicit exception. |
| (c) dedicated target | `.claude/rules/python.md:14`; `.github/instructions/python-code-change.instructions.md:47` (agents must be told to prefer the new target) | **Blocked** without an explicit exception. |
| (d) loop snapshot | none | Clear, but deferred on scope grounds. |

The recommended direction is confined entirely to non-policy surfaces. **No exception request
is needed, and the spec should not request one.** This is an additional argument for (a) over
(b) and (c) beyond the mechanical ones in section 4.

Documents that name the bare command but sit **outside** the prohibition, and so could be
edited if a later change wanted to (none are edited under the recommendation):
`.claude/skills/python-qa-gate/SKILL.md`, `.agents/skills/python/SKILL.md`,
`.agents/skills/python-qa-gate/SKILL.md`, the four `.github/agents/*.agent.md` files,
`.github/prompts/remediate-comments.prompt.md`, `README.md`, `.devcontainer/README.md`,
`.devcontainer/post-create.sh`, `.vscode/tasks.json`, and `.github/workflows/_quality-checks.yml`.

Note for the spec: `.claude/rules/**`, `.github/instructions/**`, and `.agents/skills/**` are
all listed in `config/blast-radius.json` `mandate_reads` (lines 20-31). Citing them, as this
document does, is a read and is correctly excluded from the blast radius. Under the
recommendation none of them is written, so no explicit re-enumeration is required — see
section 7.

## 6. Testability

### 6.1 The two hard constraints

- `.claude/rules/general-unit-test.md`, "External Dependencies": "**Creation and use of
  temporary files in tests is strictly prohibited.**" Restated in `.claude/rules/python.md:87`
  and again as a prohibited behavior at `.claude/rules/python.md:99`.
- `.claude/rules/general-unit-test.md`, "Test File Location": tests live in a `tests/` tree
  mirroring the production structure; colocation is not permitted.

There is a third, softer constraint worth naming: the same policy prohibits dependence on
"external processes". Every `subprocess.run` occurrence found under `tests/scripts/` is a
`monkeypatch.setattr("subprocess.run", mock_run)` mock — for example
`tests/scripts/dev_tools/atomic_executor/test_cli.py:144, 161, 182` and
`tests/scripts/dev_tools/atomic_executor/test_qc_runner.py:52`. No test in the repository was
found that spawns a real toolchain binary. A test that actually invokes `ruff` would be
without precedent here and would be an integration test, not a unit test.

### 6.2 Concrete file path

**`tests/scripts/dev_tools/test_ruff_config_alignment.py`** (new file).

The naming and location follow a direct, exact precedent:
`tests/scripts/dev_tools/test_pyright_config_alignment.py` is a 26-line module that resolves
`Path(__file__).resolve().parents[3] / "pyproject.toml"`, reads its text, and asserts on
configuration content (lines 8-25). A Ruff analogue belongs beside it.

A second, closely related precedent is
`tests/scripts/dev_tools/test_typescript_toolchain_instruction_contracts.py`, written for
issue #422 to lock a corrected toolchain-command statement across six committed instruction
mirrors. Its docstring at lines 9-12 records the useful fact that bundled copies "are covered
transitively by the two push-down parity tests" — so a test of this class asserts on the
repo-root file only.

### 6.3 What the test should assert (verified mechanism, no subprocess)

Primary assertions, all satisfiable by reading committed text:

1. Parse `pyproject.toml` and assert the `[tool.ruff]` table does not set `fix` to a truthy
   value. Prefer a real TOML parse (`tomllib`, standard library from Python 3.11) over a
   substring check so that whitespace and comment variants cannot slip through. Note the
   supported floor is `python = ">=3.10,<4.0"` (`pyproject.toml:17`) and the CI matrix includes
   3.10 (`.github/workflows/_quality-checks.yml:13`), so `tomllib` needs a `tomli` fallback or
   the test must use text assertions in the style of `test_pyright_config_alignment.py:17-18`.
   The text-assertion style is the lower-risk choice and matches existing precedent.
2. Assert no `ruff.toml` or `.ruff.toml` exists at the repository root, closing residual 2 from
   section 4.
3. Assert `.github/workflows/_quality-checks.yml` still runs a lint step, so a later change
   cannot satisfy the test by deleting the gate.

These are deterministic, spawn no process, create no file, and depend on no external service.

### 6.4 The differential test the issue proposes

The issue asks for a differential: bare form rewrites a fixture and exits 0; `--no-fix` leaves
it byte-identical and exits 1 (`issue.md` line 97). Under the recommended fix the first half
becomes false by construction, since the bare form is no longer the write-mode form. The
differential that remains meaningful after the fix is: **bare form leaves content unchanged and
exits non-zero on a fixable violation; explicit `--fix` rewrites and exits 0.**

Two mechanisms were evaluated for supplying content without a temporary file:

- **Committed fixture file — not recommended.** A `.py` file under `tests/fixtures/` carrying
  a deliberate `F401` would itself be flagged by the repository-wide
  `poetry run ruff check` in CI (`.github/workflows/_quality-checks.yml:61`), so it would need
  a `[tool.ruff.lint.per-file-ignores]` entry (`pyproject.toml:106-112`) or a non-`.py`
  extension. Worse, if the test ever ran the write-mode form against it, the committed fixture
  would be rewritten in the working tree — the test would be causing the very defect it
  checks. `tests/fixtures/` does exist as a location (for example
  `tests/fixtures/blast_radius/derivation-cr-only.json`), so the directory convention is
  available; the objection is to the fixture being a lintable `.py`, not to the location.
- **Standard input — the mechanism that satisfies the no-temp-file rule.** Ruff accepts source
  on stdin via `ruff check --stdin-filename <name> -`, resolving configuration from the
  supplied filename's directory. In fix mode with stdin, ruff emits the fixed source to stdout
  rather than writing to disk. The content can be an inline string constant in the test module
  — a Python string literal containing `import os` is not itself an import, so it is invisible
  to a repository-wide lint and needs no per-file ignore. No file is created, so the no-temp-file
  rule is satisfied exactly.

  **This stdin behavior is stated from the tool's documented interface and was NOT verified in
  this environment** (this agent has no execution tool). It must be confirmed at implementation
  time before the differential test is written. If the stdin fix-output behavior does not hold
  as described, fall back to the section 6.3 assertions alone.

### 6.5 Recommended test strategy

1. **`tests/scripts/dev_tools/test_ruff_config_alignment.py`** — the section 6.3 assertions.
   Deterministic, no subprocess, no fixture, direct precedent. This is the regression gate that
   closes residual 1 and residual 2 and is the mandatory part of the fix.
2. **The section 6.4 differential** — worth adding only if the stdin mechanism verifies, and
   only with a clear note that it spawns a real process and is therefore an integration test
   rather than a unit test. It should be treated as optional hardening, not as the gate. The
   configuration assertion in item 1 is strictly more reliable and has zero environmental
   dependency.
3. **Manual verification after the fix**, per `issue.md` line 98: confirm the lint stage still
   fails on an unfixable violation and still reports fixable violations rather than hiding
   them. Record the output as QA-gate evidence under
   `docs/features/active/2026-08-23-ruff-check-is-write-mode-and-exits-zero-after-fixing-515/evidence/qa-gates/`.

### 6.6 Coverage note

`pyproject.toml` is configuration, not measured production source
(`[tool.coverage.run] source = ["src", "scripts/dev_tools"]`, `pyproject.toml:120`), so this
change adds no uncovered production lines and the >= 85% line and >= 75% branch thresholds in
`.claude/rules/quality-tiers.md` are not affected.

## 7. Write-Target Inventory (Blast-Radius Input)

Under the recommended direction (a), a fix WRITES exactly these two files:

```
pyproject.toml
tests/scripts/dev_tools/test_ruff_config_alignment.py
```

- `pyproject.toml` — delete line 91 (`fix = true`). No other line changes.
- `tests/scripts/dev_tools/test_ruff_config_alignment.py` — new file, the section 6.3
  regression assertions.

Notes bearing on the scheduling computation:

- **No policy document is written.** `.claude/rules/python.md` and
  `.github/instructions/python-code-change.instructions.md` are read and cited, not written.
  Both fall under `config/blast-radius.json` `mandate_reads` (lines 21 and 24), so the citation
  is correctly excluded and no explicit re-enumeration obligation is triggered.
- **No published mirror is written**, and none needs to be. The byte-parity tests at
  `tests/scripts/dev_tools/test_push_down_claude_resource_contracts.py:101-126` and
  `tests/scripts/dev_tools/test_push_down_codex_and_agents_resource_contracts.py:207-220` scope
  only to `.claude/**`, `.agents/**`, and `.codex/**`. Neither `pyproject.toml` nor
  `tests/**` is in scope for either. A glob confirmed no bundled `pyproject.toml` exists under
  `extensions/drm-copilot/resources/`.
- **`pyproject.toml` is not a declared shared surface.** `config/blast-radius.json`
  `shared_surfaces` (lines 3-14) lists `poetry.lock` but not `pyproject.toml`, and no entry in
  `shared_surface_globs` (lines 15-19) matches it. It is recorded here as an observation about
  the truth table, not as a change request against it.
- **`tests/` is not a module** in `config/blast-radius.json` `modules` (lines 32-40); the
  location-bucket modules `docs` and `tests` were removed by issue #472 under the granularity
  criterion recorded in `.claude/rules/parallel-orchestration.md`. Neither write target resolves
  to a module, so this item's radius is path-level only.

## Automation Feasibility

**Every step of the recommended fix is automatable. No human interaction is required.**

Basis, step by step:

1. **Delete `fix = true` from `pyproject.toml:91`** — a single-line deletion in a
   non-prohibited configuration file. No approval gate applies: the file is not under
   `.claude/rules/` or `.github/instructions/`, so the prohibition in
   `.claude/skills/policy-compliance-order/SKILL.md:32` is not engaged, and no exception
   request is needed.
2. **Add `tests/scripts/dev_tools/test_ruff_config_alignment.py`** — a new test file in the
   standard `tests/` tree with an exact structural precedent at
   `tests/scripts/dev_tools/test_pyright_config_alignment.py`. Ordinary agent-authored code.
3. **Verify via the seven-stage toolchain** — Black, Ruff, Pyright, Pytest all run under
   `poetry run` and are covered by the `Bash(poetry run *)` grants already present, for example
   `.claude/agents/atomic-executor.md:12` (`"Bash(poetry run ruff *)"`).

No step requires a policy exception, a scope change, a credential, an external service, a
maintainer decision, or a merge into a protected surface beyond the normal pull-request flow.

The one item that could require human input is explicitly **excluded** from the recommended
scope: direction (d), the `qc_runner_loop.py` lint-step snapshot, is a judgment call about
whether to widen this bug's scope. The recommendation is to file it as a separate issue, which
is itself an automatable action, and the decision to accept or reject that recommendation is a
review decision on the spec, not a blocking interaction inside the fix.

## Open Items for the Spec

1. Confirm whether direction (d) should be filed as a follow-up issue, and whether the
   `fix_all_branches_extra.py` break-branch behavior (section 2.4(i)) warrants its own note in
   that issue given that direction (a) repairs it incidentally.
2. Decide whether the optional stdin differential (section 6.4) is in scope, contingent on
   verifying ruff's stdin fix-output behavior at implementation time.
3. Decide whether the unenforced `.github/**` published-mirror drift noted in section 2.2 is
   worth a separate issue. It is not caused by this defect and is not fixed by it, but it is
   the same failure class as issue #500 and this investigation surfaced it.
