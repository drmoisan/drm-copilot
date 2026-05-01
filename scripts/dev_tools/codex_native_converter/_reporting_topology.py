"""Render Mermaid topology charts for the Codex-native conversion report.

Purpose:
    Provide the pure Mermaid rendering helpers extracted from ``reporting.py``
    so that the parent module stays within the 500-line size policy.

Usage:
    Import from ``scripts.dev_tools.codex_native_converter.reporting``; these
    helpers are not part of the public package surface.

Flow:
    Each helper accepts a tuple of ``TopologyEdge`` values and returns a list
    of Markdown lines forming a fenced Mermaid block.

Invariants / Constraints:
    All functions are pure and side-effect-free.  Node IDs are generated from
    enumeration indices so output is stable for the same input sequence.

Side Effects:
    None.
"""

from __future__ import annotations

import json
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from scripts.dev_tools.codex_native_converter.models import TopologyEdge


def mermaid_label(text: str) -> str:
    """Escape one Mermaid node label deterministically.

    Purpose:
        Produce a JSON-string-escaped label so special characters do not break
        the Mermaid graph syntax.

    Args:
        text (str): Raw label text.

    Returns:
        str: Escaped label text without surrounding quotes.

    Side Effects:
        None.
    """

    return json.dumps(text)[1:-1]


def render_source_to_destination_chart(
    topology_edges: tuple[TopologyEdge, ...],
) -> list[str]:
    """Render a Mermaid chart with shared source and destination nodes.

    Purpose:
        Show how multiple source paths map to the same destination path by
        collapsing duplicate nodes.

    Args:
        topology_edges (tuple[TopologyEdge, ...]): Edges to render.

    Returns:
        list[str]: Markdown lines for a fenced Mermaid code block.

    Side Effects:
        None.
    """

    source_node_ids: dict[str, str] = {}
    destination_node_ids: dict[str, str] = {}
    lines = ["```mermaid", "graph LR"]

    # Emit one node per unique source or destination path; connect with arrows.
    for index, topology_edge in enumerate(topology_edges):
        source_path = topology_edge.source_path
        target_label = topology_edge.destination_path
        source_node_id = source_node_ids.get(source_path)
        if source_node_id is None:
            source_node_id = f"source_{index}"
            source_node_ids[source_path] = source_node_id
            lines.append(f'    {source_node_id}["{mermaid_label(source_path)}"]')

        destination_node_id = destination_node_ids.get(target_label)
        if destination_node_id is None:
            destination_node_id = f"destination_{index}"
            destination_node_ids[target_label] = destination_node_id
            lines.append(f'    {destination_node_id}["{mermaid_label(target_label)}"]')

        lines.append(f"    {source_node_id} --> {destination_node_id}")

    lines.append("```")
    return lines


def render_source_to_repeated_destination_chart(
    topology_edges: tuple[TopologyEdge, ...],
) -> list[str]:
    """Render a Mermaid chart that repeats destination nodes per mapping.

    Purpose:
        Highlight all destinations for each source, showing one distinct
        destination node even when the same destination path appears multiple
        times.

    Args:
        topology_edges (tuple[TopologyEdge, ...]): Edges to render.

    Returns:
        list[str]: Markdown lines for a fenced Mermaid code block.

    Side Effects:
        None.
    """

    source_node_ids: dict[str, str] = {}
    lines = ["```mermaid", "graph LR"]

    # Collapse source nodes but repeat destination nodes per edge.
    for index, topology_edge in enumerate(topology_edges):
        source_path = topology_edge.source_path
        target_label = topology_edge.destination_path
        source_node_id = source_node_ids.get(source_path)
        if source_node_id is None:
            source_node_id = f"source_{index}"
            source_node_ids[source_path] = source_node_id
            lines.append(f'    {source_node_id}["{mermaid_label(source_path)}"]')

        destination_node_id = f"destination_{index}"
        lines.append(f'    {destination_node_id}["{mermaid_label(target_label)}"]')
        lines.append(f"    {source_node_id} --> {destination_node_id}")

    lines.append("```")
    return lines


def render_destination_to_repeated_source_chart(
    topology_edges: tuple[TopologyEdge, ...],
) -> list[str]:
    """Render a Mermaid chart that repeats source nodes per mapping.

    Purpose:
        Highlight all sources that map to each destination by collapsing
        destination nodes and repeating source nodes per edge.

    Args:
        topology_edges (tuple[TopologyEdge, ...]): Edges to render.

    Returns:
        list[str]: Markdown lines for a fenced Mermaid code block.

    Side Effects:
        None.
    """

    destination_node_ids: dict[str, str] = {}
    lines = ["```mermaid", "graph LR"]

    # Collapse destination nodes but repeat source nodes per edge.
    for index, topology_edge in enumerate(topology_edges):
        source_path = topology_edge.source_path
        target_label = topology_edge.destination_path
        destination_node_id = destination_node_ids.get(target_label)
        if destination_node_id is None:
            destination_node_id = f"destination_{index}"
            destination_node_ids[target_label] = destination_node_id
            lines.append(f'    {destination_node_id}["{mermaid_label(target_label)}"]')

        source_node_id = f"source_{index}"
        lines.append(f'    {source_node_id}["{mermaid_label(source_path)}"]')
        lines.append(f"    {destination_node_id} --> {source_node_id}")

    lines.append("```")
    return lines
