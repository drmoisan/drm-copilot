# Synthetic acceptance rendering examples

These files are exact `render_acceptance` output from schema-valid, captured in-memory fixtures. They demonstrate data rendering and do not represent executed acceptance tests, production observations, or publication authority.

- `observed-source/` uses a declared synthetic source observation.
- `approved-target/` retains the observed criterion and a separately approved target criterion, including their original references and ownership.
- `pending-target/` keeps the unresolved target criterion in `acceptance.md`; only the independently ready observed criterion has a `.feature` file.

Every authored step is a single JSON string literal. No implementation step definitions are supplied. The canonical P5-T5 example receipt records input and output hashes and exact retained input bytes.
