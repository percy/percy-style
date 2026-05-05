# ADR 001 — Upgrade to RuboCop 1.61+ and rubocop-rspec 3.0+

- **Status:** accepted
- **Date:** 2026-02-04
- **Deciders:** Team Percy (PR #59)

## Context

`percy-style v0.7.0` pinned an older RuboCop and a `rubocop-rspec 2.x`
release. Two pressures accumulated:

1. The Percy Ruby fleet had been moving toward Ruby 3.x. `percy-api` runs
   on Ruby 3.0 and `percy-hub` / `percy-image-processor` were tracking
   newer Ruby versions. The pinned RuboCop pre-1.61 was lagging on
   3.x-aware cops.
2. `rubocop-rspec 3.0` reorganized the RSpec cops into split departments.
   Staying on 2.x meant divergence from upstream documentation and from
   the cop names recommended in newer Ruby/RSpec guides.

This is a config-only gem (`docs/product/PRODUCT.md`), so a major version
bump was the appropriate vehicle: `default.yml` is the public API and a
simultaneous RuboCop major + rubocop-rspec major qualifies as breaking by
the policy in `.claude/rules/api-design.md`.

## Decision

- Pin `rubocop ~> 1.61` and `rubocop-rspec ~> 3.0` in
  `percy-style.gemspec`.
- Set `AllCops.TargetRubyVersion: 3.3` in `default.yml`.
- Switch plugin loading from the legacy `require:` key to the supported
  `plugins:` key.
- Bump the gem version `0.7.0 → 1.0.0`.

## Consequences

What gets easier:

- New RSpec cops introduced in rubocop-rspec 3.x are now reachable.
- Cops that key off Ruby 3.x semantics behave correctly for consumers on
  Ruby 3.x.
- The `plugins:` key is forward-compatible with future RuboCop releases
  that deprecate `require:`.

What gets harder:

- Consumers on older Ruby (notably `percy-renderer`, which still pins
  `TargetRubyVersion: 2.6` in its local `.rubocop.yml`) cannot adopt
  `1.0.0` without coordinating their own Ruby upgrade or pinning to
  `0.7.0`.
- The fleet rolls forward asynchronously — at the time of this ADR, only
  `percy-api` had absorbed `1.0.0` (via a git ref pin); `percy-hub`,
  `percy-image-processor`, `percy-renderer`, and `percy-workloads`
  remained on `0.7.0`. See `docs/product/DEPENDENCIES.md` for the
  rollout matrix.

Trade-offs explicitly accepted:

- A short-term split where `0.7.0` and `1.0.0` are both live in
  production lockfiles is acceptable. Future PATCH releases on the
  `0.7.x` line are not planned; consumers are expected to migrate.

## Alternatives considered

- **Stay on `rubocop-rspec 2.x`.** Rejected: continuing divergence from
  upstream and from the broader Ruby community's cop names.
- **Split the upgrade into two PRs (RuboCop first, then rubocop-rspec).**
  Rejected: both crossed major boundaries and would each justify a major
  bump, doubling the consumer rollout cost.
- **Hold the bump until every consumer is on Ruby 3.3.** Rejected:
  unbounded wait; `default.yml` evolution would stall.
