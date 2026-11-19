/**
 * Host-neutral support for the push-down extension commands (issue #1029).
 *
 * Holds the Copilot pack QuickPick items and the conflict-line counters the
 * three push-down commands use. The module has no `vscode` import, so it is
 * unit-testable without the VS Code host.
 */

import { EXCLUSION_CONFLICT_LINE_PREFIX } from "./lib/push-down/claude-exclusion-filter";
import { PUSH_DOWN_CONFLICT_LINE_PREFIX } from "./lib/push-down/push-down-report";

/** One selectable pack of a push-down command QuickPick. */
export interface PushDownPackItem {
  readonly label: string;
  readonly pack: string;
}

/**
 * Selectable Copilot packs, in QuickPick order. `core` is always published and
 * is therefore not offered.
 */
export const COPILOT_PUSH_DOWN_PACK_ITEMS: ReadonlyArray<PushDownPackItem> = [
  { label: "Python", pack: "python" },
  { label: "PowerShell", pack: "powershell" },
  { label: "TypeScript", pack: "typescript" },
  { label: "C#", pack: "csharp" },
];

/**
 * Count the push-down conflict lines (conflict, unmanaged conflict, local
 * deletion) in a result's warnings.
 *
 * @param warnings Result warnings, or `undefined` when there are none.
 * @returns The number of lines that start with the push-down conflict prefix.
 */
export function countPushDownConflictLines(
  warnings: ReadonlyArray<string> | undefined,
): number {
  return (warnings ?? []).filter((line) =>
    line.startsWith(PUSH_DOWN_CONFLICT_LINE_PREFIX),
  ).length;
}

/**
 * Count the exclusion conflict lines in a result's warnings.
 *
 * @param warnings Result warnings, or `undefined` when there are none.
 * @returns The number of lines that start with the exclusion conflict prefix.
 */
export function countExclusionConflictLines(
  warnings: ReadonlyArray<string> | undefined,
): number {
  return (warnings ?? []).filter((line) =>
    line.startsWith(EXCLUSION_CONFLICT_LINE_PREFIX),
  ).length;
}

/**
 * Render the push-down conflict notification text.
 *
 * @param count Number of push-down conflict lines.
 * @returns The notification message.
 */
export function formatPushDownConflictMessage(count: number): string {
  return `Push-down conflicts: ${String(count)}. See the drm-copilot output channel for the affected paths.`;
}
