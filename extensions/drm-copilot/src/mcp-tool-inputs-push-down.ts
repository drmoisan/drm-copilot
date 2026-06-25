import {
  normalizeRequiredText,
  normalizeWorkspaceRoot,
} from "./workflow-command-arguments";
import {
  asToolArgumentObject,
  type WorkspaceToolInput,
} from "./mcp-tool-inputs";

export interface PushDownClaudeCustomizationsToolInput extends WorkspaceToolInput {
  readonly packs?: ReadonlyArray<string>;
  readonly csharpVariant?: "modern" | "legacy";
  readonly memoryMode?: "overwrite" | "merge" | "skip";
}

function resolveClaudePacksField(
  rawValue: unknown,
): ReadonlyArray<string> | undefined {
  // An absent packs field yields the backward-compatible publish-everything
  // default (undefined). When present it must be an array of strings.
  if (rawValue === undefined) {
    return undefined;
  }
  if (!Array.isArray(rawValue)) {
    throw new Error("Field 'packs' must be an array of strings when provided.");
  }
  return rawValue.map((entry, index) =>
    normalizeRequiredText(entry, `packs[${index}]`),
  );
}

function resolveCsharpVariantField(
  rawValue: unknown,
): "modern" | "legacy" | undefined {
  // An absent variant leaves the field undefined so the engine default applies.
  if (rawValue === undefined) {
    return undefined;
  }
  const variant = normalizeRequiredText(rawValue, "csharp_variant");
  if (variant !== "modern" && variant !== "legacy") {
    throw new Error("Field 'csharp_variant' must be 'modern' or 'legacy'.");
  }
  return variant;
}

function resolveMemoryModeField(
  rawValue: unknown,
): "overwrite" | "merge" | "skip" | undefined {
  // An absent memory mode leaves the field undefined so the engine default
  // (overwrite) applies.
  if (rawValue === undefined) {
    return undefined;
  }
  const mode = normalizeRequiredText(rawValue, "memory_mode");
  if (mode !== "overwrite" && mode !== "merge" && mode !== "skip") {
    throw new Error(
      "Field 'memory_mode' must be 'overwrite', 'merge', or 'skip'.",
    );
  }
  return mode;
}

export function resolvePushDownClaudeCustomizationsToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): PushDownClaudeCustomizationsToolInput {
  const args = asToolArgumentObject(rawInput);
  const packs = resolveClaudePacksField(args["packs"]);
  const csharpVariant = resolveCsharpVariantField(args["csharp_variant"]);
  const memoryMode = resolveMemoryModeField(args["memory_mode"]);
  // Spread each optional field only when present so a workspace_root-only
  // invocation resolves to an input with every new field left undefined.
  return {
    workspaceRoot: normalizeWorkspaceRoot(
      args["workspace_root"],
      fallbackWorkspaceRoot,
    ),
    ...(packs === undefined ? {} : { packs }),
    ...(csharpVariant === undefined ? {} : { csharpVariant }),
    ...(memoryMode === undefined ? {} : { memoryMode }),
  };
}
