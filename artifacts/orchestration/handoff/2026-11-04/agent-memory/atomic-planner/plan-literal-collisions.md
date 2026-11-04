---
name: plan-literal-collisions
description: Asserted search tokens and numeric literals in plans that collide with real tree content or validator rules (Pester -Skip vs -SkipX switches, all-digit seeds vs SHA rule)
metadata:
  type: project
---

Two literal choices that look safe in a plan but are not (seen while planning #1067, 2026-11-03):

- A zero-match search for Pester `-Skip` matches ordinary switches such as `-SkipNpmCi`, `-SkipCompile`, `-SkipProjectPoetryInstall` in `tests/scripts/dev-tools`. Use `git grep -E -e '-Skip([:[:space:]]|$)'`.
- A shuffle seed such as `20261103` is 8 hex-class characters and may be read as a commit SHA by G12 (the installed MCP validator may lack G12, so it will not report it). Use short seeds (`7`, `1067`, `2026`).

**Why:** each would make an acceptance condition unsatisfiable or fail the branch-current validator after the MCP validator passed.
**How to apply:** before quoting a zero-match token, grep the target files for it as a prefix; keep bare digit runs under 7 characters. Related: [[pester-junit-sources-on-failing-hosts]].
