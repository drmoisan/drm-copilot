import { describe, expect, it } from "@jest/globals";

import {
  promotePotential,
  PromotionError,
} from "../../../src/lib/potential-to-issue/promotion";
import {
  buildBugContent,
  buildFeatureContent,
  FakeGhClient,
  FakePotentialFileSystem,
  type RecordedGhCall,
  WORKSPACE,
} from "./promotion-test-support";

/**
 * Defect B (promotion_type x work_mode) routing matrix guard. Confirms the
 * branch reorder leaves every verified-correct cell unchanged while the
 * previously broken (bug, minor-audit) cell (covered in promotion.test.ts)
 * renders the bug body. Kept in a dedicated file so promotion.test.ts stays
 * under the 500-line limit.
 */
function promoteAndGetBody(
  promotionType: string,
  workMode: string,
  content: string,
): string {
  const fs = new FakePotentialFileSystem();
  const potential = "/workspace/docs/features/potential/matrix.md";
  fs.files.set(potential, content);
  const gh = new FakeGhClient(
    { output: ["Created: https://example.com/issues/1"], exitCode: 0 },
    { output: [], exitCode: 0 },
  );
  promotePotential({
    potentialPath: potential,
    promotionType,
    fs,
    gh,
    workspace: WORKSPACE,
    workMode,
  });
  return (gh.calls[0] as RecordedGhCall)[1][1] ?? "";
}

describe("buildIssueBody routing matrix (AC-2)", () => {
  // Non-bug minor-audit promotions still route to the minor-audit body.
  it.each(["feature", "refactor", "epic"])(
    "routes (%s, minor-audit) to the minor-audit body",
    (promotionType) => {
      const body = promoteAndGetBody(
        promotionType,
        "minor-audit",
        buildFeatureContent("Matrix Minor"),
      );
      expect(body).toContain("## Implementation Intent");
      expect(body).toContain("## Verification Steps");
      expect(body).not.toContain("## Summary\n");
    },
  );

  // Bug promotions in non-minor-audit modes still route to the bug body.
  it.each(["full-bug", "full"])(
    "routes (bug, %s) to the bug body",
    (workMode) => {
      const body = promoteAndGetBody(
        "bug",
        workMode,
        buildBugContent("Matrix Bug"),
      );
      expect(body).toContain("## Summary\nsummary details");
      expect(body).toContain("## Logs / Screenshots\nscreenshot attached");
      expect(body).not.toContain("## Implementation Intent");
    },
  );

  // Non-bug full-mode promotions route to the standard full-feature body.
  it.each(["full-feature", "full"])(
    "routes (feature, %s) to the full-feature body",
    (workMode) => {
      const body = promoteAndGetBody(
        "feature",
        workMode,
        buildFeatureContent("Matrix Feature"),
      );
      expect(body).toContain("## Proposed Behavior");
      expect(body).toContain("## Test Conditions");
      expect(body).not.toContain("## Implementation Intent");
    },
  );

  // Invalid mode/type combinations throw before any body build.
  it("throws for (bug, full-feature) before building a body", () => {
    expect(() =>
      promoteAndGetBody("bug", "full-feature", buildBugContent("Bad Bug")),
    ).toThrow(PromotionError);
  });

  it("throws for (feature, full-bug) before building a body", () => {
    expect(() =>
      promoteAndGetBody(
        "feature",
        "full-bug",
        buildFeatureContent("Bad Feature"),
      ),
    ).toThrow(PromotionError);
  });
});

describe("buildIssueBody bug minor-audit partial sections (AC-1 edge)", () => {
  it("emits placeholders only for empty bug sections while populated ones carry content", () => {
    const body = promoteAndGetBody(
      "bug",
      "minor-audit",
      buildBugContent("Partial Bug", {
        Environment: "",
        "Logs / Screenshots": "",
      }),
    );
    expect(body.split("\n")[0]).toBe("- Work Mode: minor-audit");
    expect(body).toContain("## Summary\nsummary details");
    expect(body).toContain("## Environment\n(not provided in potential file)");
    expect(body).toContain(
      "## Logs / Screenshots\n(not provided in potential file)",
    );
    expect(body).toContain("## Steps to Reproduce\n1. step one");
  });
});
