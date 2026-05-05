# Flow — Release rollout (percy-style)

## Trigger

A pull request that changes shared lint configuration (`default.yml`,
`default_rspec.yml`, the `Percy::Style` Ruby code, or gemspec
dependencies) is merged into `master`.

## Actors

- Engineer (PR author)
- Reviewer (CODEOWNERS for `percy-style`)
- GitHub Actions (Semgrep + RuboCop self-check on PRs)
- `master` branch on `percy/percy-style`
- Each consumer repo's owner and CI:
  - `percy-api`
  - `percy-hub`
  - `percy-hub-worker`
  - `percy-image-processor`
  - `percy-renderer`
  - `percy-workloads`

## Steps

`percy-style` is shipped **trunk-based**. There is no version bump, no
git tag, no `gem push`, and no staged / canary / production deploy.
Every merged commit on `master` is a candidate release; consumers pull
in changes by bumping the commit SHA in their own `Gemfile`.

1. Engineer drafts the change on a feature branch (e.g. edits to
   `default.yml` or `default_rspec.yml`).
2. Engineer dry-runs the change against at least one consumer by
   pointing that consumer's `Gemfile` at a local path of `percy-style`
   and running `bundle exec rubocop` there.
3. Engineer opens a PR. PR body lists the affected consumers and any
   recommended `rubocop --autocorrect` commands a consumer may need to
   run.
4. Reviewer applies the checklist in
   `.claude/skills/code-review/references/review-checklist.md`.
5. CI passes (Semgrep + RuboCop self-check).
6. PR is merged to `master`. The merge commit SHA on `master` is the
   release artifact — there is **no** version bump in
   `lib/percy/style/version.rb` tied to the release, **no** git tag,
   and **no** `gem push`.
7. Author notifies consumer owners (Slack / PR description) that a new
   SHA is available and summarises the impact.
8. Each consumer rolls out independently and at its own pace:
   a. Owner updates the `percy-style` line in their `Gemfile` to pin to
      the new commit SHA, e.g.
      `gem 'percy-style', git: 'https://github.com/percy/percy-style.git', ref: '<new-sha>'`.
   b. Runs `bundle install` to refresh `Gemfile.lock`.
   c. Runs `bundle exec rubocop` (and any recommended autocorrect)
      locally to surface lint changes.
   d. Opens a PR in the consumer repo with the SHA bump and any
      mechanical autocorrect commits.
   e. Consumer CI runs RuboCop with the new config — breaking config
      changes surface as a red CI on that consumer PR, scoped to that
      consumer.
   f. Consumer merges when green.

## Outputs / side effects

- A new commit SHA on `percy/percy-style@master`.
- No new gem version on RubyGems.org (this gem is not published).
- No git tag, no GitHub release.
- Eventually: one follow-up PR per consumer that chooses to adopt the
  new SHA.

## Failure modes

- **Consumer CI goes red on the SHA-bump PR.** Expected and intentional —
  this is how breaking lint changes are surfaced. Consumer either
  applies `rubocop --autocorrect`, adds targeted `# rubocop:disable`
  comments with justification, or asks `percy-style` to relax the rule.
- **A consumer adopts a SHA that introduces an unintended regression.**
  Rollback is purely on the consumer side: revert the SHA-bump PR (or
  open a new PR re-pinning to the previous SHA). No action is needed
  on `percy-style` itself unless the change should be reverted upstream
  too — in which case, open a revert PR against `percy-style@master`,
  producing a new SHA that consumers can pin to.
- **Resolver conflict in a consumer's `Gemfile.lock`.** Coordinate
  upgrades of co-dependent gems in the consumer; `percy-style` itself
  has no transitive runtime deps to negotiate.
- **Drift across consumers.** Because rollout is pull-based per
  consumer, different consumers will sit on different `percy-style`
  SHAs at any given time. This is expected. To converge, owners can
  bump SHAs in a coordinated sweep, but there is no central mechanism
  enforcing it.

## Related

- `docs/adrs/001-rubocop-1-61-and-rubocop-rspec-3-upgrade.md` — worked
  example of a real config change rolled out via this flow.
- `docs/product/DEPENDENCIES.md` — list of consumer repos.
- `docs/environment/DEPLOYMENT.md` — release flow narrative.
- `.claude/skills/feature-dev/SKILL.md` — author-side workflow,
  including consumer notification.
- `.claude/rules/commit-conventions.md` — versioning policy
  (no semver bumps tied to releases).
