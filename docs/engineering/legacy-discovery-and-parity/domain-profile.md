# Authoring the Domain Profile

The domain profile is the single configuration contract through which a consumer
repository supplies all domain specificity to the discovery/parity workflow. Every stage
in [`workflow.md`](workflow.md) reads the domain profile; no stage contains a
domain-specific default. This page documents the contract fields and domain-neutral
authoring guidance; it defers parser internals and the profile-format decision to the
domain-profile configuration-contract feature's own reference documentation.

## Starting Point

`dev.discovery.init` scaffolds a new discovery workspace from the bundled template at
`docs/discovery/templates/domain-profile/domain-profile.yaml`. A consumer repository
copies and edits this template rather than authoring a profile from a blank file.

## Contract Fields

The profile is authored as YAML with four domain-neutral contract fields, each mapping to
one of the four configuration areas from the epic's shared design:

| Field | Meaning |
|---|---|
| `legacy_source.root` | The legacy source location: the path (or path-like identifier) to the repository or codebase being discovered. |
| `target.root` | The target location: the path (or path-like identifier) to the modern repository or codebase the migration targets. |
| `technology_stack.legacy` | The technology stack: an ordered list of technology identifiers (for example a language or framework name) that selects which stack-specific analyzers run against the legacy source during the repository-inventory stage. |
| `artifacts.root` | The artifact conventions: the output directory under which every discovery artifact (feature contracts, the coverage ledger, runtime-characterization scenarios, the parity matrix, unspecified-behavior records, product-decision records, evidence references) is written. |

A `profile_version` field is also present at the top level of the profile and is read by
the profile loader; its versioning semantics are owned by the domain-profile
configuration-contract feature.

## Domain-Neutral Authoring Guidance

- Every value in the profile is consumer-supplied configuration. The framework treats
  `legacy_source.root`, `target.root`, and `technology_stack.legacy` as opaque strings; it
  does not special-case any particular path, repository, or technology name.
  `technology_stack.legacy` is what selects which stack-specific analyzers run — for
  example, listing a .NET/C# identifier is what causes the .NET stack analyzer to run
  against `legacy_source.root`, not a hardcoded rule tied to any specific consumer.
- Author the profile once per consumer repository. TaskMaster's profile and TMW's profile
  are two independent instances of the same domain-neutral contract; see
  [`consumer-onboarding.md`](consumer-onboarding.md) for how they are used as worked
  examples.
- Keep `artifacts.root` inside the discovery workspace so that every stage in
  [`workflow.md`](workflow.md) and every validator in
  [`artifacts-and-schemas.md`](artifacts-and-schemas.md) resolves artifact paths
  consistently.

## Parser Internals (Deferred)

The profile is parsed with PyYAML (`yaml.safe_load`), not the repository's separate
hand-rolled frontmatter-regex convention used elsewhere. The parser implementation, the
full field schema, validation rules (via `dev.discovery.validate-profile`), and the
decision record comparing PyYAML against the frontmatter-regex convention are owned by the
domain-profile configuration-contract feature; this page does not restate them.
