---
name: yo-plan
description: "Write an implementation plan for an issue (default: highest-priority Todo) and post it for approval"
argument-hint: "Optional issue, e.g. 12 or owner/repo#12"
agent: Work Buddy
---
Plan an issue from the GitHub Project. Issue: ${input:issue}

1. Pick the issue: the one given above, otherwise the output of `./scripts/yo-gh next`. Tell the human which one and why.
2. Run `./scripts/yo-gh show <ref>` and read the issue, all comments, and the code in every involved repo clone (read-only). If the repos are unclear, ask the human before planning.
3. If requirements are unclear, ask the human now instead of guessing.
4. Follow the shared **Bolts** rules: reuse existing sub-issues or create one or more `Bolt: <outcome>` sub-issues in `Plan review`, with scope, resolved `repo:*` targets, acceptance criteria, verification, and dependencies. A repo may need several bolts; do not split solely by repo. If the selected issue is already a bolt, plan it without creating nested bolts.
5. Post a `## Plan v<n>` comment with `./scripts/yo-gh comment`: goal, exact bolt refs and parent links, files to change, dependency order, branch `<branchPrefix>/<bolt-number>-<slug>` per target clone, verification, risks, and open questions. Re-read the parent and bolts to verify the links exist.
6. Run `./scripts/yo-gh status <ref> "Plan review"`; no implementation or bolt approval yet.
7. Show the plan and bolt links in chat and offer **Approve & implement** or **Revise plan** only when the bolt checklist is complete.
