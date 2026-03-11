---
type: muscle
name: pipeline-test
status: draft
heat-default: cold
breadcrumb: "Test muscle for verifying the hub live-loading pipeline. Safe to delete after verification."
author: Curtis Mercier
license: CC BY 4.0
version: 0.0.1
tier: core
topic: [testing, pipeline]
keywords: [pipeline-test, e2e, hub-index]
heat: 0
loads: 0
created: 2026-03-11
updated: 2026-03-11
---

# Pipeline Test

<!-- digest:start -->
Test muscle for verifying the hub live-loading pipeline. Safe to delete after verification.
<!-- digest:end -->

This muscle exists solely to test the hub publishing pipeline. If you see this card on the hub, the pipeline works.

## TL;DR
- Push content → build-hub-index.yml fires → hub-index.json updates → HubGrid fetches live → card appears
- Vercel deploy hook triggers website rebuild for static props
- Delete this file after verification
