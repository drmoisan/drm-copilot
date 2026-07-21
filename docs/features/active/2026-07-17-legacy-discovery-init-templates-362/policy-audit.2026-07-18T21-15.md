# Policy Audit — legacy-discovery-init-templates (#362) — Remediation Cycle 4 Reaudit

- Timestamp: 2026-07-18T21-15
- Scope: cycle 4's single deferred finding from the cycle 3 reaudit (`policy-audit.2026-07-18T14-30.md`) — a reintroduced `pyproject.toml` adjacent-insertion merge conflict against the integration branch's advanced tip (sibling #363, commit `c4ec9a2b`). This is a reaudit of cycle 4's fix, not a full re-review of the original feature.
- Branch: `feature/legacy-discovery-init-templates-362`, HEAD `da573298b182a22bb9fd3fc1b68e030e5fe6f6c2`.
- Base branch: `epic/legacy-discovery-and-parity-integration`, resolved tip at audit time `c4ec9a2bb46d68689d1ae095d1ecb1f409fecda3` (fetched locally, not re-fetched by this audit).
- PR: #380 against `epic/legacy-discovery-and-parity-integration`.

## Policy Reading Order Followed

1. `CLAUDE.md`
2. `.claude/rules/general-code-change.md`
3. `.claude/rules/general-unit-test.md`
4. `.claude/rules/python.md` (Python files in scope: `pyproject.toml`, no production `.py` changes in this cycle)
5. `.claude/rules/tonality.md`
6. `.claude/rules/quality-tiers.md` (coverage threshold cross-check)

## Rejected Scope Narrowing

None observed. The delegation prompt scoped this reaudit explicitly to cycle 4's single finding, consistent with the Scope Invariant's allowance for a reaudit of a specific remediation cycle's fix (this is not an attempt to narrow the *original* full-branch audit; it is the correct scope for a remediation-cycle reaudit, and the full-branch baseline was already established in the cycle 1–3 audits). No caller instruction to skip a toolchain stage, mark a language "out of scope," or omit coverage verification was present.

## Finding 1 — `pyproject.toml` Merge-Conflict Resolution (Independently Verified)

**Verdict: PASS**

- The two-parent merge commit that performed the conflict resolution is `30767881` (`Merge remote-tracking branch 'origin/epic/legacy-discovery-and-parity-integration' into feature/legacy-discovery-init-templates-362`), independently confirmed via `git cat-file -p 30767881` to have exactly two parent lines: `f17f1af08c67568fbc14140a25882c068a50d2b0` and `c4ec9a2bb46d68689d1ae095d1ecb1f409fecda3`.
- **Discrepancy note (Informational, not a defect):** the task description attributes this two-parent merge to commit `6a9a9e34`. Independent inspection (`git cat-file -p 6a9a9e34`) shows `6a9a9e34` has exactly **one** parent (`30767881`) and touches only `remediation-plan.2026-07-18T19-30.md` (a checklist-update commit, 2 insertions / 2 deletions). The actual conflict-resolving merge commit is `30767881`, immediately preceding `6a9a9e34` in history. The underlying substantive claim in the delegation prompt — that a two-parent merge commit with parents `f17f1af0` and `c4ec9a2b` resolved the conflict — is TRUE; only the specific SHA cited is off by one commit in the ancestry chain. This does not affect the verdict because the actual merge commit was independently located and verified.
- `git diff f17f1af0..30767881 -- pyproject.toml` shows exactly the additive change expected from HEAD's side: `+"dev.discovery.inventory" = "scripts.dev_tools.discovery.analyzer.cli:main"` and `+"^\\s*\\.\\.\\.\\s*$"` (coverage exclude_lines entry), with no other line touched.
- `git diff c4ec9a2b..30767881 -- pyproject.toml` shows exactly the additive change expected from the integration side: `+"dev.discovery.init" = "scripts.dev_tools.discovery.init_cli:main"`, plus a reordering of the `dev.discovery.validate-*` run into alphabetical order (no lines dropped, added lines only additive on this side).
- Current working-tree `pyproject.toml` `[tool.poetry.scripts]` `dev.discovery.*` run (lines 59-71) confirmed via direct read: `generate-acceptance-scenarios`, `init`, `inventory`, `profile`, `validate-all`, `validate-coverage-ledger`, `validate-evidence-reference`, `validate-feature-contract`, `validate-parity-matrix`, `validate-product-decision`, `validate-profile`, `validate-runtime-scenario`, `validate-unspecified-behavior` — strict alphabetical order, both `dev.discovery.init` and `dev.discovery.inventory` present, no duplicates.
- `grep -n '<<<<<<<\|=======\|>>>>>>>' pyproject.toml` at HEAD returns no matches — no residual conflict markers.
- Duplicate-key check independently corroborated by evidence `evidence/remediation-baseline/r4c1-phase1-duplicate-key-check.2026-07-18T18-47.md`: 33 key-assignment lines in `[tool.poetry.scripts]`, all with count 1.
- Coverage `exclude_lines` entry `"^\\s*\\.\\.\\.\\s*$"` from sibling #363 (commit `054eaa06`) confirmed present exactly once at line 135, corroborated by `evidence/remediation-baseline/r4c1-phase1-coverage-exclude-check.2026-07-18T18-47.md`.
- `poetry check` independently re-run at HEAD: **EXIT_CODE 0**. Output consists solely of pre-existing PEP 621 migration deprecation warnings (`[tool.poetry.name]`, `[tool.poetry.version]`, `[tool.poetry.description]`, `[tool.poetry.readme]`, `[tool.poetry.license]`, `[tool.poetry.authors]`, `[tool.poetry.scripts]` deprecated in favor of `[project.*]`), unrelated to the resolved conflict and pre-dating this remediation cycle. No `poetry check` errors. This matches the executor's self-reported evidence (`evidence/remediation-baseline/r4c1-phase1-poetry-check.2026-07-18T18-47.md`).

## Finding 2 — PR #380 Mergeability (Independently Verified)

**Verdict: PASS**

- Independently re-ran `gh pr view 380 --json mergeable,mergeStateStatus,baseRefName,headRefName,headRefOid`: `{"baseRefName":"epic/legacy-discovery-and-parity-integration","headRefName":"feature/legacy-discovery-init-templates-362","headRefOid":"da573298b182a22bb9fd3fc1b68e030e5fe6f6c2","mergeStateStatus":"CLEAN","mergeable":"MERGEABLE"}`.
- `headRefOid` matches current local HEAD, confirming the mergeability check reflects the current branch tip, not a stale state.
- Evidence file `evidence/qa-gates/r4c1-pr-mergeable-check.2026-07-18T18-47.md` is internally consistent with this independent re-check (`{"mergeable":"MERGEABLE"}`, EXIT_CODE 0, correctly attributes the resolution to the merge that landed the fix).

## Finding 3 — Toolchain Claims (Independently Re-Verified from Evidence Artifacts)

**Verdict: PASS**

All `r4c1-*` evidence artifacts under `evidence/remediation-baseline/` and `evidence/qa-gates/` were read directly and cross-checked for internal consistency (command, EXIT_CODE, and output-summary fields). No re-execution was performed, per this reaudit's read-only tool surface.

| Stage | Command | EXIT_CODE | Result |
|---|---|---|---|
| Black (post-merge) | `poetry run black --check .` | 0 | 307 files unchanged |
| Ruff (post-merge) | `poetry run ruff check .` | 0 | All checks passed |
| Pyright (post-merge) | `poetry run pyright` | 0 | 0 errors, 0 warnings, 0 informations |
| Pytest (post-merge) | `poetry run pytest --cov --cov-branch --cov-report=term-missing` | 0 | 1839 passed, 0 failed, 0 skipped |
| Coverage — line | (same pytest run) | n/a | 88.87% (>= 85% threshold) |
| Coverage — branch | (same pytest run) | n/a | 79.51% (>= 75% threshold) |
| Coverage delta vs. pre-merge baseline | `evidence/qa-gates/r4c1-coverage-delta.2026-07-18T18-47.md` | n/a | Line 88.53% -> 88.87% (+0.34pp); Branch 79.34% -> 79.51% (+0.17pp); no regression |

- The pre-merge baseline (`evidence/remediation-baseline/r4c1-phase0-pytest-baseline.2026-07-18T18-47.md`, 1783 passed) versus post-merge (1839 passed) delta of 56 additional passing tests is consistent with fanning in sibling feature #363's own test suite via the merge; no test count discrepancy observed.
- Repo-wide Python coverage (88.87% line / 79.51% branch) exceeds both the uniform tier threshold (>= 85% line / >= 75% branch, `.claude/rules/quality-tiers.md`) and the mandatory Coverage Verification thresholds in this skill (repo-wide >= 80%). No FAIL trigger.
- `dev.discovery.init` and its new-file surface (`init_cli.py`, `init_flow.py`, `init_models.py`, `__init__.py`) were not modified by this cycle's fix (the diff touched only `pyproject.toml` and the remediation-plan checklist doc); their coverage was already verified PASS in the cycle 3 reaudit (`policy-audit.2026-07-18T14-30.md`) and is unchanged here.

## Finding 4 — Evidence Location Compliance

**Verdict: PASS**

- `python scripts/dev_tools/validate_evidence_locations.py --root .` exit code 0, no violations reported.
- `git diff --name-only c4ec9a2b..da573298` scanned for `artifacts/baselines/`, `artifacts/qa/`, `artifacts/coverage/`, `artifacts/evidence/` paths: none found.
- All cycle 4 evidence artifacts are correctly located under `docs/features/active/2026-07-17-legacy-discovery-init-templates-362/evidence/remediation-baseline/` and `evidence/qa-gates/`, using the `r4c1-` prefix as required by the remediation plan.

## Finding 5 — Integration Branch Tip Advancement (Informational)

**Verdict: Informational — no further advancement detected**

- `origin/epic/legacy-discovery-and-parity-integration` currently resolves to `c4ec9a2bb46d68689d1ae095d1ecb1f409fecda3`.
- `git merge-base HEAD origin/epic/legacy-discovery-and-parity-integration` returns the same SHA `c4ec9a2bb46d68689d1ae095d1ecb1f409fecda3`, confirming the integration branch tip has **not** advanced past the merge parent since cycle 4's fix was committed — the tip is fully contained in this feature branch's history (as the merge-base equals the tip).
- `git log --oneline HEAD..origin/epic/legacy-discovery-and-parity-integration -- pyproject.toml` returns no commits, corroborating no new upstream `pyproject.toml` changes.
- This closes the specific recurrence risk flagged after cycle 3 (a third consecutive sibling fan-in reopening the same conflict shape) as of this audit. Because the local repository was not re-fetched by this reaudit (per the task's read-only instruction, "do not fetch"), this reflects the state as of the last local fetch (recorded in `evidence/remediation-baseline/r4c1-phase3-pre-commit-tip-recheck.2026-07-18T18-47.md`, timestamp 2026-07-18T18-47) and should be re-checked immediately before any fan-in merge is executed against the epic branch, consistent with the remediation plan's own re-check recommendation.

## Finding 6 — Remediation Plan Checklist Completion

**Verdict: PASS (with minor count discrepancy, Informational)**

- `remediation-plan.2026-07-18T19-30.md` contains 22 checklist items, all marked `[x]`, 0 remaining `[ ]` items.
- **Discrepancy note (Informational):** the task description states "all 17 tasks checked"; the actual plan document contains 22 checked tasks. This does not affect the verdict — all tasks in the actual plan document are complete and independently verified against evidence artifacts above. The count difference likely reflects a miscount in the delegation prompt, not a gap in delivered work.

## Evidence Location Compliance

No violations found (see Finding 4).

## Overall Policy Audit Verdict

**PASS** — cycle 4's fix for the reintroduced `pyproject.toml` merge conflict is independently verified as correct, complete, and policy-compliant. No Blocking or Major findings. Two Informational discrepancies noted in the delegation prompt's citations (merge-commit SHA and plan task count), neither of which reflects a defect in the delivered fix.
