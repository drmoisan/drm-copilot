"""The python-cli analyzer: merges the argparse, Click and Typer sites into raw facts.

Reproduces the merge of DocsAnalyzerPythonCli.psm1 of issue 1022. A console script whose
module:attr target resolves to exactly one request file and names a root site attaches
that root: the root fact is not emitted, and its subcommands and options carry the
script name and the script element as parent. CLI_CONSOLE_SCRIPT_UNSUPPORTED is reported
on pyproject.toml by the PowerShell scanner, not here.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import TYPE_CHECKING

from docs_python_native.cli_argparse import recognize_argparse
from docs_python_native.cli_click import recognize_click
from docs_python_native.cli_typer import recognize_typer
from docs_python_native.facts import AnalyzerOutput
from docs_python_native.module_names import module_dotted_name

if TYPE_CHECKING:
    from docs_python_native.call_sites import CliSite
    from docs_python_native.imports import AnalyzedFile

ANALYZER_ID = "python-cli"


@dataclass(frozen=True)
class ConsoleScript:
    """One script-table entry of a pyproject.toml input, passed in by the adapter.

    Attributes:
        name: The script name (the command a user types).
        table: The TOML table that declares it.
        path: The pyproject.toml request path that holds the entry.
        target: The "module:attr" target.
    """

    name: str
    table: str
    path: str
    target: str


@dataclass(frozen=True)
class _Resolved:
    """The resolved declaration of one site.

    Attributes:
        declaration: The space-joined command path (root name first).
        path: The path the element belongs to (the pyproject.toml for an attached root).
        emit: False for an attached root, whose element the scanner emits.
        source: The root name source ("console-script", "literal" or "module"), or
            None for a non-root.
        parent: (kind, declaration, path) of the parent command, or None for a root.
    """

    declaration: str
    path: str
    emit: bool
    source: str | None
    parent: tuple[str, str, str] | None


@dataclass
class _FileSites:
    """The merged sites of one request file.

    Attributes:
        analyzed: The parsed file.
        module: Its dotted module name, or None.
        sites: Every site with framework-prefixed identifiers.
        by_id: The sites by prefixed identifier.
        attached: Root site identifier to the console script that attaches it.
    """

    analyzed: AnalyzedFile
    module: str | None
    sites: list[CliSite] = field(default_factory=lambda: [])
    by_id: dict[str, CliSite] = field(default_factory=lambda: {})
    attached: dict[str, ConsoleScript] = field(default_factory=lambda: {})


def root_name(
    site: CliSite, script: str | None, module: str | None
) -> tuple[str, str] | None:
    """Choose the name of a root command and record where it came from.

    Args:
        site: The root site.
        script: The attached console-script name, or None.
        module: The file's dotted module name, or None.

    Returns:
        (name, source) in priority order: the script name ("console-script"), the
        literal name ("literal"), the module name ("module"); None when none exists.
    """
    if script:
        return script, "console-script"
    if site.name:
        return site.name, "literal"
    if module:
        return module, "module"
    return None


def _resolve(
    site_id: str,
    entry: _FileSites,
    memo: dict[str, _Resolved | None],
    visiting: set[str],
) -> _Resolved | None:
    """Resolve the declaration of a site through its parent chain.

    Args:
        site_id: The prefixed site identifier.
        entry: The file's merged sites.
        memo: Resolved declarations by identifier; filled as sites resolve.
        visiting: Identifiers on the current path, to stop on a cycle.

    Returns:
        The resolved declaration, or None for an unknown site, a cycle, a root with no
        name, or a child without a resolvable parent or name segment.
    """
    if site_id in memo:
        return memo[site_id]
    site = entry.by_id.get(site_id)
    if site is None or site_id in visiting:
        return None
    visiting.add(site_id)
    resolved: _Resolved | None = None
    path = entry.analyzed.path
    # A root takes its name from root_name; a child appends its segment to the
    # resolved parent declaration.
    if site.parent_id is None:
        script = entry.attached.get(site_id)
        root = root_name(site, script.name if script else None, entry.module)
        if root is not None:
            root_path = script.path if script is not None else path
            resolved = _Resolved(root[0], root_path, script is None, root[1], None)
    else:
        parent = _resolve(site.parent_id, entry, memo, visiting)
        segment = site.name or site.default_name or ""
        if parent is not None and segment:
            resolved = _Resolved(
                parent.declaration + " " + segment,
                path,
                True,
                None,
                ("cli-command", parent.declaration, parent.path),
            )
    visiting.discard(site_id)
    memo[site_id] = resolved
    return resolved


def _collect(
    analyzed: AnalyzedFile, source_roots: list[str], output: AnalyzerOutput
) -> _FileSites:
    """Run the three recognizers over one file and merge their sites.

    Args:
        analyzed: The parsed file.
        source_roots: The configured source roots for the module name.
        output: Receives the recognizer diagnostics.

    Returns:
        The file's merged sites; identifiers are prefixed with the framework so that
        the three recognizers cannot collide.
    """
    module = module_dotted_name(analyzed.path, source_roots, require_identifiers=False)
    entry = _FileSites(analyzed, module)
    # Merge the results of the argparse, Click and Typer recognizers in that order.
    for result in (
        recognize_argparse(analyzed.parsed, analyzed.tables),
        recognize_click(analyzed.parsed, analyzed.tables),
        recognize_typer(analyzed.parsed, analyzed.tables),
    ):
        # Report every recognizer diagnostic under the python-cli analyzer.
        for diagnostic in result.diagnostics:
            output.add_diagnostic(analyzed.path, diagnostic.code, diagnostic.line)
        # Prefix site and parent identifiers with the framework, then index the site.
        for site in result.sites:
            site.site_id = site.framework + ":" + site.site_id
            if site.parent_id is not None:
                site.parent_id = site.framework + ":" + site.parent_id
            entry.sites.append(site)
            entry.by_id[site.site_id] = site
    return entry


def _attach(entries: list[_FileSites], scripts: list[ConsoleScript]) -> None:
    """Attach each console script to the root site its target names.

    Args:
        entries: The merged sites of every file; their attached maps are filled.
        scripts: The console scripts of the request.

    Returns:
        None. A script attaches only when its module matches exactly one file and a
        root of that file declares the target attribute.
    """
    by_module: dict[str, list[_FileSites]] = {}
    # Group files by module name so an ambiguous module attaches nothing.
    for entry in entries:
        if entry.module is not None:
            by_module.setdefault(entry.module, []).append(entry)
    # Resolve each script's module:attr target to one root site.
    for script in scripts:
        separator = script.target.find(":")
        if separator <= 0:
            continue
        matches = by_module.get(script.target[:separator], [])
        if len(matches) != 1:
            continue
        attribute = script.target[separator + 1 :]
        # The first root whose attach name equals the attribute takes the script.
        for site in matches[0].sites:
            if (
                site.kind == "root"
                and site.parent_id is None
                and site.attach == attribute
            ):
                matches[0].attached[site.site_id] = script
                break


def analyze_cli(
    files: list[AnalyzedFile], source_roots: list[str], scripts: list[ConsoleScript]
) -> AnalyzerOutput:
    """Return the python-cli facts and diagnostics of the parsed request files.

    Args:
        files: The parsed request files.
        source_roots: The configured source roots.
        scripts: The console scripts the adapter read from pyproject.toml.

    Returns:
        One cli-command or cli-option fact per resolvable site, except attached roots.
    """
    output = AnalyzerOutput(ANALYZER_ID)
    # Collect every file's merged sites in path order, for deterministic output.
    entries = [
        _collect(f, source_roots, output) for f in sorted(files, key=lambda f: f.path)
    ]
    _attach(entries, scripts)
    # Emit each file's sites; resolution is memoized per file.
    for entry in entries:
        memo: dict[str, _Resolved | None] = {}
        # Emit one fact per site that resolves and is not an attached root.
        for site in entry.sites:
            resolved = _resolve(site.site_id, entry, memo, set())
            if resolved is None or not resolved.emit:
                continue
            properties = dict(site.properties)
            if site.parent_id is None and resolved.source is not None:
                properties["name_source"] = resolved.source
            is_option = site.kind == "option"
            name = (
                (site.name or "") if is_option else resolved.declaration.split(" ")[-1]
            )
            output.add_fact(
                entry.analyzed.path,
                "cli-option" if is_option else "cli-command",
                resolved.declaration,
                name,
                site.span,
                properties,
                resolved.parent,
            )
    return output
