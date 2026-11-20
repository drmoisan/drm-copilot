# Analyzers

Analyzers produce `inventory-snapshot` artifacts from captured, immutable source bytes under
the profile's roots. They are read-only, lexical and bounded: no analyzer compiles, restores,
installs, executes or resolves symbols, and no analyzer reads outside the configured roots.
The profile's `analyzers.enabled` list selects them by identifier; `dev.discovery.inventory
--analyzer <id>` runs a subset, and `dev.discovery.dotnet` and `dev.discovery.vsto` are fixed
selections of `dotnet` and `office-vsto`.

## Identifiers

| Identifier | Observes |
|---|---|
| `repository` | Files, project and solution declarations, test roots and relationships; the language-neutral inventory every other analyzer extends. |
| `dependencies` | Declared dependencies in .NET project files, `package.json` and Python configuration; classified by value shape without resolution. |
| `dotnet` | .NET build declarations (`dotnet_projects.py`) and the C# lexical inventory (`dotnet_inventory.py`). |
| `csharp-symbols` | Lexical C# declarations and explicitly inferred member candidates over masked source text. |
| `event-subscriptions` | Possible C# event handler subscriptions inferred from lexical assignments. |
| `configuration` | Configuration keys from bounded declarations; values are never exported. |
| `filesystem-access`, `registry-access` | Fixed API spellings for file and Windows registry access; arguments and runtime paths stay local. |
| `com-interop` | Generic COM candidates from C# and project declarations. |
| `ui-callbacks` | A finite WPF XAML dialect, observed without loading controls. |
| `test-references` | Declared project references and inferred C# test relevance (`detected` or `inferred`). |
| `office-vsto` | The optional Office/VSTO adapter (`analyzer/optional/`), imported only after it is explicitly enabled. |

## Guarantees

- **Captured inputs.** Each run captures the bounded bytes it reads
  (`analyzer/input_capture.py`) and records their digests in the snapshot's `capture`, so a
  later validation can prove the inventory is current or stale.
- **Deterministic identities.** Findings and components carry deterministic identifiers
  derived from path and declaration (`analyzer/findings.py`); reruns over the same bytes
  produce identical snapshots.
- **No value leakage.** Configuration, registry and dependency analyzers emit keys and
  shapes, never secrets or resolved values.
- **Bounded parsing.** Tokenizers, XML and solution readers enforce size and count limits;
  an input over the limit is a diagnostic, not a partial result.
- **Diagnostics over guesses.** What an analyzer cannot classify is recorded in
  `diagnostics` and left to a person; nothing is inferred as `verified`.

## Limits

- Lexical observation cannot see generated code, reflection, late binding, dynamic
  dispatch or behavior that depends on runtime configuration; those surface as `inferred`
  or `unknown` and require runtime characterization or human inspection.
- The .NET analyzers read C#, project, solution and XAML text; other languages are
  inventoried by `repository` and `dependencies` only.
- `office-vsto` recognizes bounded syntax candidates; it does not load Office, inspect a
  ribbon at runtime or evaluate add-in manifests beyond their text.
- Analyzers never write; publication of a snapshot requires `--write` and goes through the
  engine's mutation boundary like every other artifact.

## Extending

Separately produced inventories (another language's tooling, a commercial scanner) enter
through `extension-result-manifest` documents listed in
`analyzers.extension_result_manifests` and imported with `dev.discovery.import-inventory`.
The engine validates each manifest against the captured inputs it names and merges the
result as inert data; it never executes the producing tool. Adding a built-in analyzer is a
framework change described in [`maintainer-guide.md`](maintainer-guide.md).
