# NCF2 focused proof

Timestamp: 2026-10-21T05-13

Command: `SCRATCH/issue-980-p6t1-gateway-ncf2-proof.py`

EXIT_CODE: 0

Output Summary: 34 controls passed; eight new IDs and 26 retained IDs are recorded exactly.

The changed helper has fresh executable BODY coverage. All original test callable ASTs and assertions remain unchanged. The same inserted-prefix node failed under the archived prior helper and passes after repair.

```json
{
  "named_bodies": {
    "_canonical_state_location": {
      "declaration_line": 359,
      "body_first_line": 369,
      "body_last_line": 383,
      "executable_ast_sha256": "d6231d6e8f3047f414fd802957d7ab21b47dae34c334c752566ab05dfd10608f",
      "covered_lines": 8,
      "statements": 8,
      "line_percent": 100.0,
      "covered_branches": 2,
      "branches": 2,
      "branch_percent": 100.0,
      "missing_lines": [],
      "missing_branches": [],
      "executed_body_lines": [
        369,
        371,
        372,
        373,
        374,
        377,
        382,
        383
      ],
      "executed_body_branches": [
        [
          377,
          382
        ],
        [
          377,
          383
        ]
      ]
    }
  },
  "file_coverage": {
    "fresh_34_controls": {
      "covered_lines": 62,
      "statements": 140,
      "line_percent": 44.285714285714285,
      "covered_branches": 8,
      "branches": 40,
      "branch_percent": 20.0,
      "missing_lines": [
        65,
        97,
        105,
        106,
        109,
        110,
        140,
        142,
        143,
        144,
        145,
        146,
        151,
        153,
        154,
        155,
        160,
        161,
        178,
        184,
        185,
        199,
        200,
        208,
        212,
        213,
        214,
        215,
        219,
        220,
        221,
        222,
        223,
        238,
        239,
        240,
        241,
        243,
        244,
        252,
        253,
        254,
        269,
        270,
        278,
        280,
        285,
        293,
        301,
        303,
        311,
        312,
        313,
        314,
        315,
        316,
        318,
        319,
        321,
        322,
        323,
        324,
        325,
        326,
        327,
        328,
        329,
        330,
        332,
        333,
        334,
        335,
        336,
        337,
        338,
        339,
        340,
        341
      ],
      "missing_branches": [
        [
          64,
          65
        ],
        [
          128,
          140
        ],
        [
          142,
          143
        ],
        [
          142,
          161
        ],
        [
          144,
          145
        ],
        [
          144,
          146
        ],
        [
          153,
          154
        ],
        [
          153,
          160
        ],
        [
          178,
          184
        ],
        [
          178,
          185
        ],
        [
          212,
          213
        ],
        [
          212,
          221
        ],
        [
          213,
          214
        ],
        [
          213,
          215
        ],
        [
          221,
          222
        ],
        [
          221,
          223
        ],
        [
          243,
          244
        ],
        [
          243,
          254
        ],
        [
          270,
          278
        ],
        [
          270,
          280
        ],
        [
          313,
          -303
        ],
        [
          313,
          314
        ],
        [
          323,
          324
        ],
        [
          323,
          325
        ],
        [
          326,
          327
        ],
        [
          326,
          328
        ],
        [
          334,
          335
        ],
        [
          334,
          337
        ],
        [
          337,
          338
        ],
        [
          337,
          339
        ],
        [
          339,
          340
        ],
        [
          339,
          341
        ]
      ]
    },
    "retained_baseline": {
      "covered_lines": 137,
      "statements": 138,
      "line_percent": 99.27536231884058,
      "covered_branches": 39,
      "branches": 40,
      "branch_percent": 97.5,
      "missing_lines": [
        145
      ],
      "missing_branches": [
        [
          144,
          145
        ]
      ]
    },
    "qualified_fresh_plus_unchanged_history": {
      "covered_lines": 139,
      "statements": 140,
      "line_percent": 99.28571428571429,
      "covered_branches": 39,
      "branches": 40,
      "branch_percent": 97.5,
      "missing_lines": [
        145
      ],
      "missing_branches": [
        [
          144,
          145
        ]
      ]
    },
    "retained_only_lines": [
      65,
      97,
      105,
      106,
      109,
      110,
      140,
      142,
      143,
      144,
      146,
      151,
      153,
      154,
      155,
      160,
      161,
      178,
      184,
      185,
      199,
      200,
      208,
      212,
      213,
      214,
      215,
      219,
      220,
      221,
      222,
      223,
      238,
      239,
      240,
      241,
      243,
      244,
      252,
      253,
      254,
      269,
      270,
      278,
      280,
      285,
      293,
      301,
      303,
      311,
      312,
      313,
      314,
      315,
      316,
      318,
      319,
      321,
      322,
      323,
      324,
      325,
      326,
      327,
      328,
      329,
      330,
      332,
      333,
      334,
      335,
      336,
      337,
      338,
      339,
      340,
      341
    ],
    "retained_only_branches": [
      [
        64,
        65
      ],
      [
        128,
        140
      ],
      [
        142,
        143
      ],
      [
        142,
        161
      ],
      [
        144,
        146
      ],
      [
        153,
        154
      ],
      [
        153,
        160
      ],
      [
        178,
        184
      ],
      [
        178,
        185
      ],
      [
        212,
        213
      ],
      [
        212,
        221
      ],
      [
        213,
        214
      ],
      [
        213,
        215
      ],
      [
        221,
        222
      ],
      [
        221,
        223
      ],
      [
        243,
        244
      ],
      [
        243,
        254
      ],
      [
        270,
        278
      ],
      [
        270,
        280
      ],
      [
        313,
        -303
      ],
      [
        313,
        314
      ],
      [
        323,
        324
      ],
      [
        323,
        325
      ],
      [
        326,
        327
      ],
      [
        326,
        328
      ],
      [
        334,
        335
      ],
      [
        334,
        337
      ],
      [
        337,
        338
      ],
      [
        337,
        339
      ],
      [
        339,
        340
      ],
      [
        339,
        341
      ]
    ]
  }
}
```

The changed helper claims fresh declaration-exclusive BODY coverage. Qualified whole-file coverage composes exact AST-identical unchanged ranges with retained NCF1 proof; this is not a new whole-module run. No previous helper coverage is carried into the changed body.
