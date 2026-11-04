"""The python-cli analyzer: merges the argparse, Click and Typer sites into raw facts.

Reproduces the merge of DocsAnalyzerPythonCli.psm1 of issue 1022. A console script whose
module:attr target resolves to exactly one request file and names a root site attaches
that root: the root fact is not emitted, and its subcommands and options carry the
script name and the script element as parent. CLI_CONSOLE_SCRIPT_UNSUPPORTED is reported
on pyproject.toml by the PowerShell scanner, not here.
"""

from __future__ import annotations

from dataclasses import dataclass, field

from docs_python_native.cli_argparse import CliSite, recognize_argparse
from docs_python_native.cli_click import recognize_click
from docs_python_native.cli_typer import recognize_typer
from docs_python_native.imports import AnalyzedFile, AnalyzerOutput, module_dotted_name

ANALYZER_ID = "python-cli"


@dataclass(frozen=True)
class ConsoleScript:
    """One script-table entry of a pyproject.toml input."""

    name: str
    table: str
    path: str
    target: str


@dataclass(frozen=True)
class _Resolved:
    declaration: str
    path: str
    emit: bool
    source: str | None
    parent: tuple[str, str, str] | None


@dataclass
class _FileSites:
    analyzed: AnalyzedFile
    module: str | None
    sites: list[CliSite] = field(default_factory=lambda: [])
    by_id: dict[str, CliSite] = field(default_factory=lambda: {})
    attached: dict[str, ConsoleScript] = field(default_factory=lambda: {})


def root_name(
    site: CliSite, script: str | None, module: str | None
) -> tuple[str, str] | None:
    """Return (name, source): the script name, then the literal, then the module."""
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
    if site_id in memo:
        return memo[site_id]
    site = entry.by_id.get(site_id)
    if site is None or site_id in visiting:
        return None
    visiting.add(site_id)
    resolved: _Resolved | None = None
    path = entry.analyzed.path
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
    module = module_dotted_name(analyzed.path, source_roots, require_identifiers=False)
    entry = _FileSites(analyzed, module)
    for result in (
        recognize_argparse(analyzed.parsed, analyzed.tables),
        recognize_click(analyzed.parsed, analyzed.tables),
        recognize_typer(analyzed.parsed, analyzed.tables),
    ):
        for diagnostic in result.diagnostics:
            output.add_diagnostic(analyzed.path, diagnostic.code, diagnostic.line)
        for site in result.sites:
            site.site_id = site.framework + ":" + site.site_id
            if site.parent_id is not None:
                site.parent_id = site.framework + ":" + site.parent_id
            entry.sites.append(site)
            entry.by_id[site.site_id] = site
    return entry


def _attach(entries: list[_FileSites], scripts: list[ConsoleScript]) -> None:
    by_module: dict[str, list[_FileSites]] = {}
    for entry in entries:
        if entry.module is not None:
            by_module.setdefault(entry.module, []).append(entry)
    for script in scripts:
        separator = script.target.find(":")
        if separator <= 0:
            continue
        matches = by_module.get(script.target[:separator], [])
        if len(matches) != 1:
            continue
        attribute = script.target[separator + 1 :]
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
    """Return the python-cli facts and diagnostics of the parsed request files."""
    output = AnalyzerOutput(ANALYZER_ID)
    entries = [
        _collect(f, source_roots, output) for f in sorted(files, key=lambda f: f.path)
    ]
    _attach(entries, scripts)
    for entry in entries:
        memo: dict[str, _Resolved | None] = {}
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
