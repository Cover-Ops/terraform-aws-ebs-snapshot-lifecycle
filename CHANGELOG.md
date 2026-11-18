# Changelog

Semantic versions. Every release lists its sandbox test result.

## 0.1.0 (2026-11-18)
- First release: Daily snapshots of every volume you tag Backup=daily, keeping the last 7, with AWS Data Lifecycle Manager. Old snapshots stop piling up; snapshots made any other way are never touched.
- Sandbox test: **passed 2026-11-18** (AWS ap-south-1: apply, re-plan with no changes, destroy, nothing left).
