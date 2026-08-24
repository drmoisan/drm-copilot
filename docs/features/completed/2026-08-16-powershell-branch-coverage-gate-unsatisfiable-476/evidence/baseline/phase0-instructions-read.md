# Phase 0 — Policy Instructions Read (Issue #476)

Timestamp: 2026-08-16T17-07

Policy Order: The repository policy-compliance order defined in `.claude/skills/policy-compliance-order/SKILL.md` and `CLAUDE.md` was followed: standing instructions first, then cross-language code-change policy, then cross-language unit-test policy, then the language- and domain-specific rules in scope for this change, then the structural precedent named by the plan.

## Files Read (in order)

1. `CLAUDE.md` — standing instructions: tone policy, policy compliance reading order, language-specific rule routing, four-layer runtime architecture.
2. `.claude/rules/general-code-change.md` — cross-language code change policy: design principles, module rigor tiers, mandatory seven-stage toolchain loop, file size limit, error handling, naming, dependencies, I/O boundaries.
3. `.claude/rules/general-unit-test.md` — cross-language unit test policy: core principles, coverage requirements (line >= 85%, branch >= 75%), Coverage Exclusion Policy, scenario completeness, AAA structure, test file location, determinism infrastructure.
4. `.claude/rules/powershell.md` — PowerShell toolchain and coding standards. Primary edit target. Current Testing Standards lines 63-65: line coverage >= 85% (line 63), branch coverage >= 75% (line 64), changed-lines coverage regression blocking (line 65).
5. `.claude/rules/quality-tiers.md` — module rigor tiers T1-T4, uniform-vs-tier-dependent gate matrix. Edit target at the uniform-thresholds statement, the uniform branch bullet, and the rationale paragraph.
6. `.claude/rules/tonality.md` — tonality policy: professional tone required; humor, hyperbole prohibited; metaphors tightly restricted; evidence-first wording. Governs all amended prose in this change.
7. `.claude/rules/shell.md` (lines 60-70, Coverage Expectations) — structural precedent for the carve-out. Lines 68-70 read: "kcov reports **line coverage only**. The uniform line-coverage threshold (>= 85% per `.claude/rules/quality-tiers.md`) applies. Branch coverage is not measurable by kcov for bash; there is no bash branch-coverage gate." This is the four-part shape the PowerShell carve-out must parallel: (1) name the tool and its actual capability, (2) preserve the uniform line threshold with cross-reference, (3) state the incapability as a fact about the tool, (4) disclaim the gate's existence.

## Binding Constraints Carried Into Execution

- The `>= 85%` line-coverage threshold must not be lowered, removed, or made conditional anywhere. `.claude/rules/powershell.md:63` must remain byte-unchanged.
- No amended wording may read as excluding PowerShell files from coverage *measurement*; the Coverage Exclusion Policy in `.claude/rules/general-unit-test.md` prohibits excluding a production file from measurement.
- Only the branch clause is qualified. The line clause and the no-regression-on-changed-lines clause remain unconditional for all coverage languages including PowerShell.
- Python, TypeScript, and C# remain gated at branch `>= 75%`; their rule files are not modified.
- Every root-file edit is paired with its bundle-mirror edit in the same task; no intermediate state may break byte parity.
- `.claude/hooks/validate-feature-review-coverage.ps1` and its mirror, all paths under `.github/**`, and `.claude/rules/shell.md` are not modified.
- No command-coverage threshold is introduced; command (instruction) coverage may appear only descriptively.
- Repository tone policy applies to all amended prose.

EXIT_CODE: 0

Output Summary: All seven policy files read in the required order. No conflicts between the policy set and the planned change were identified. The change is Markdown-only, so the format, lint, and type-check stages of the seven-stage loop have no in-scope inputs; the binding QA surface is the test stage.
