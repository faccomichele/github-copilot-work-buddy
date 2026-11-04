---
name: yo-approve
description: "Approve an issue's latest plan and hand it to the implementer"
argument-hint: "Issue, e.g. 12 or owner/repo#12"
agent: Work Buddy
---
The human approves the latest plan for: ${input:issue}

1. Run `./scripts/yo-gh show <ref>`; the Status must be `Plan review` and a `## Plan v<n>` comment must exist. Otherwise explain what is missing and stop.
2. Follow the shared **Bolts** approval checklist: read every bolt listed in that version and verify its parent link, scope, resolved repos, acceptance criteria, verification, and dependencies. Stop if anything is missing or the human's approval scope is unclear; ask before changing more than three issues.
3. Post `## Approved` naming `Plan v<n>` and the exact covered bolt refs on the parent and each covered bolt, then set the parent and covered pending bolts to `Approved`. Do not reset already completed or running bolts.
4. Summarize the approved version, bolt refs, resolved repos, branches, and dependency order. Tell the human to click **Approve & implement** to start work on the approved bolts, not directly on the parent.
