# Error Catalog — percy-style

This catalog lists known failure surfaces for `percy-style` and its
consumers. New entries should follow `_TEMPLATE.md`.

## E001 — Resolver conflict on `bundle update percy-style`

- **Where:** Consumer repo, during `bundle install` / `bundle update`.
- **Symptom:** Bundler reports it cannot find compatible versions of
  `rubocop` (or `rubocop-rspec`) given the consumer's other gems.
- **Cause:** A `percy-style` release tightened a pin in a way that
  conflicts with another gem in the consumer's lockfile.
- **Recovery:** Either relax the pin in `percy-style.gemspec` and PATCH
  release, or upgrade the conflicting consumer dep.

## E002 — "unknown cop" RuboCop crash

- **Where:** Consumer repo, during `bundle exec rubocop`.
- **Symptom:** RuboCop aborts with `unrecognized cop` referencing a key in
  `default.yml`.
- **Cause:** A RuboCop major upgrade renamed or removed the cop.
- **Recovery:** Update `default.yml` to the new cop name (or remove the
  entry) and PATCH release.

## E003 — Unexpected lint regressions in consumers

- **Where:** Consumer CI after `bundle update percy-style`.
- **Symptom:** Lint fails on previously-passing files.
- **Cause:** A new strict cop or tightened threshold landed in
  `default.yml`.
- **Recovery:** Run `rubocop --autocorrect` in the consumer; if too noisy,
  open a PR to relax the cop in `percy-style` and PATCH release.

## E004 — `gem push` rejected

- **Where:** Local machine during release.
- **Symptom:** `gem push` returns 401/403, or "version already exists".
- **Cause:** Missing/expired RubyGems credentials, or version not bumped.
- **Recovery:** Refresh credentials (`gem signin`), or bump
  `lib/percy/style/version.rb` and re-build.
