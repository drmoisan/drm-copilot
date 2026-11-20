# P5-T3 Workflow Step Placement

Timestamp: 2026-10-02T03-18
Command: git grep -n -E "name: (Verify Codex agent deployment profiles|tier-classification|Run tests with Pytest)" -- .github/workflows/_quality-checks.yml
EXIT_CODE: 0
Output Summary: Exactly three lines, in the expected order:

- .github/workflows/_quality-checks.yml:69: `- name: Verify Codex agent deployment profiles`
- .github/workflows/_quality-checks.yml:74: `- name: tier-classification`
- .github/workflows/_quality-checks.yml:79: `- name: Run tests with Pytest`

Pass-after half of AC-09; P0-T29 (no match, exit 1) is the fail-before half.
