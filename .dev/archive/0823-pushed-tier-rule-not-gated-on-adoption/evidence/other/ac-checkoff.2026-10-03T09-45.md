# Phase 9 Acceptance-criteria check-off (spec.md AC1-AC21)

Timestamp: 2026-10-03T09-45
Command: git grep --no-index -c -F "[x] ACn:" -- docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/spec.md (run once per AC, n = 1..21, after each edit)
EXIT_CODE: 0
Output Summary:
- Each AC box was changed from "- [ ] ACn:" to "- [x] ACn:" individually; each per-AC grep printed 1 (exit 0). Per-AC results are listed below.
- Evidence paths are relative to docs/features/active/2026-10-03-pushed-tier-rule-not-gated-on-adoption-823/evidence/.

- AC1 checked: other/p2-t1.2026-10-03T09-35.md, other/p5-t1.2026-10-03T09-38.md, other/p5-t6.2026-10-03T09-38.md, regression-testing/pass-after-tier-rule-adoption-gate.2026-10-03T09-39.md (grep "[x] AC1:" value=1 exit=0)
- AC2 checked: other/p2-t1.2026-10-03T09-35.md, regression-testing/pass-after-tier-rule-adoption-gate.2026-10-03T09-39.md (grep "[x] AC2:" value=1 exit=0)
- AC3 checked: other/p2-t2.2026-10-03T09-35.md, regression-testing/pass-after-tier-rule-adoption-gate.2026-10-03T09-39.md (grep "[x] AC3:" value=1 exit=0)
- AC4 checked: other/p2-t1.2026-10-03T09-35.md, other/p2-t3.2026-10-03T09-36.md, regression-testing/pass-after-tier-rule-adoption-gate.2026-10-03T09-39.md (grep "[x] AC4:" value=1 exit=0)
- AC5 checked: other/p2-t3.2026-10-03T09-36.md, regression-testing/pass-after-tier-rule-adoption-gate.2026-10-03T09-39.md (grep "[x] AC5:" value=1 exit=0)
- AC6 checked: other/p3-t1.2026-10-03T09-36.md, other/p3-t2.2026-10-03T09-36.md, other/p3-t3.2026-10-03T09-37.md, regression-testing/pass-after-tier-rule-adoption-gate.2026-10-03T09-39.md (grep "[x] AC6:" value=1 exit=0)
- AC7 checked: other/p3-t1.2026-10-03T09-36.md, other/p3-t2.2026-10-03T09-36.md, other/p3-t3.2026-10-03T09-37.md, regression-testing/pass-after-tier-rule-adoption-gate.2026-10-03T09-39.md (grep "[x] AC7:" value=1 exit=0)
- AC8 checked: other/p2-t1.2026-10-03T09-35.md, other/p3-t1.2026-10-03T09-36.md, regression-testing/pass-after-tier-rule-adoption-gate.2026-10-03T09-39.md (grep "[x] AC8:" value=1 exit=0)
- AC9 checked: other/p4-t1.2026-10-03T09-37.md, other/p4-t3.2026-10-03T09-38.md, other/p4-t4.2026-10-03T09-38.md, regression-testing/pass-after-tier-rule-adoption-gate.2026-10-03T09-39.md (grep "[x] AC9:" value=1 exit=0)
- AC10 checked: other/p4-t2.2026-10-03T09-37.md, regression-testing/pass-after-tier-rule-adoption-gate.2026-10-03T09-39.md (grep "[x] AC10:" value=1 exit=0)
- AC11 checked: other/p5-t1.2026-10-03T09-38.md, other/p5-t2.2026-10-03T09-38.md, other/p5-t3.2026-10-03T09-38.md, other/p5-t4.2026-10-03T09-38.md, other/p5-t5.2026-10-03T09-38.md, other/p5-t6.2026-10-03T09-38.md, other/p5-t7.2026-10-03T09-38.md, other/p5-t8.2026-10-03T09-38.md, qa-gates/mirror-identity.2026-10-03T09-44.md, qa-gates/contract-set-pytest.2026-10-03T09-41.md (grep "[x] AC11:" value=1 exit=0)
- AC12 checked: other/p2-t1.2026-10-03T09-35.md, qa-gates/contract-set-pytest.2026-10-03T09-41.md (grep "[x] AC12:" value=1 exit=0)
- AC13 checked: other/p4-t1.2026-10-03T09-37.md, qa-gates/contract-set-pytest.2026-10-03T09-41.md, qa-gates/pester-claude-architecture-doc.2026-10-03T09-43.md (grep "[x] AC13:" value=1 exit=0)
- AC14 checked: other/p1-t1.2026-10-03T09-33.md, other/p1-t2.2026-10-03T09-34.md, regression-testing/pass-after-tier-rule-adoption-gate.2026-10-03T09-39.md (grep "[x] AC14:" value=1 exit=0)
- AC15 checked: regression-testing/expect-fail-tier-rule-adoption-gate.2026-10-03T09-34.md, regression-testing/pass-after-tier-rule-adoption-gate.2026-10-03T09-39.md (grep "[x] AC15:" value=1 exit=0)
- AC16 checked: qa-gates/scope-check.2026-10-03T09-44.md (grep "[x] AC16:" value=1 exit=0)
- AC17 checked: other/p7-t2.2026-10-03T09-40.md, qa-gates/scope-check.2026-10-03T09-44.md (grep "[x] AC17:" value=1 exit=0)
- AC18 checked: qa-gates/scope-check.2026-10-03T09-44.md, qa-gates/check-quality-tiers.2026-10-03T09-40.md (grep "[x] AC18:" value=1 exit=0)
- AC19 checked: other/p6-t1.2026-10-03T09-39.md (grep "[x] AC19:" value=1 exit=0)
- AC20 checked: other/p6-t2.2026-10-03T09-39.md (grep "[x] AC20:" value=1 exit=0)
- AC21 checked: qa-gates/black-check.2026-10-03T09-40.md, qa-gates/ruff-check.2026-10-03T09-40.md, qa-gates/pyright.2026-10-03T09-40.md, qa-gates/check-quality-tiers.2026-10-03T09-40.md, qa-gates/codex-agent-variants.2026-10-03T09-40.md, qa-gates/regression-module-pytest.2026-10-03T09-41.md, qa-gates/contract-set-pytest.2026-10-03T09-41.md, qa-gates/pytest-full-coverage.2026-10-03T09-41.md, qa-gates/python-coverage-values.2026-10-03T09-43.md, qa-gates/python-coverage-gate.2026-10-03T09-43.md, qa-gates/pester-claude-architecture-doc.2026-10-03T09-43.md, qa-gates/jest-extension-coverage.2026-10-03T09-43.md, qa-gates/coverage-comparison.2026-10-03T09-43.md (grep "[x] AC21:" value=1 exit=0)
