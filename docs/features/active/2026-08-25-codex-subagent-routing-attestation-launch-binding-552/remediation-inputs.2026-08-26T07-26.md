# Issue #552 re-review remediation inputs

Timestamp: 2026-08-26T07-26
Source review artifacts:

- `policy-audit.2026-08-26T07-21.md`
- `code-review.2026-08-26T07-21.md`
- `feature-audit.2026-08-26T07-21.md`

## Required fix

1. Split `tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py` into cohesive pytest modules so every production, test, and reusable script file modified by the feature is no more than 500 lines.
   - Preserve the full behavior and assertions of `test_push_down_customizations_excludes_ephemeral_codex_state` and all existing push-down customization coverage.
   - Keep the resulting tests deterministic, isolated, and free of temporary-file usage.
   - Do not change production behavior, routing policy, generated profile definitions, bundle payload rules, test expectations, or acceptance-criteria text.

## Required verification

Run the affected Python loop in this order and restart at formatting if a command changes files:

1. `poetry run black <split test modules and related Python scope>`
2. `poetry run ruff check <split test modules and related Python scope>`
3. `poetry run pyright <split test modules and related Python scope>`
4. `poetry run pytest tests/scripts/dev_tools/test_push_down_codex_and_agents_customizations.py <new split test module> --cov=scripts.dev_tools.push_down_codex_filesystem --cov-branch --cov-report=term-missing`
5. Verify each modified test file is at most 500 lines and run `git diff --check`.

## Do not do

- Do not weaken or remove existing assertions to reduce file size.
- Do not change the Issue #552 routing behavior or relax exact-profile enforcement.
- Do not add dependencies, policy exceptions, temporary files, aliases, package publication, or merge actions.
- Do not modify the canonical policy documents.
