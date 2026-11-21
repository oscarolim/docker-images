# piwigo-php

PHP-FPM images for running Piwigo behind nginx, built and pushed to GitHub
Container Registry by GitHub Actions.

| Tag | Meaning |
| --- | --- |
| `ghcr.io/<owner>/piwigo-php:8.3` | Always the newest 8.3 build (use this in Portainer) |
| `ghcr.io/<owner>/piwigo-php:8.1` | Always the newest 8.1 build (PHP 8.1 is end-of-life) |
| `ghcr.io/<owner>/piwigo-php:8.3-YYYYMMDD` | A fixed build you can roll back to |

Builds run every Monday, on every push that changes the `Dockerfile` or the
workflow, and on demand via **Actions → Build PHP images → Run workflow**.

## One-time setup

1. **Create a GitHub repo** and push these files (`Dockerfile`,
   `.github/workflows/build-php-image.yml`, this README) to `main`.
2. **Run the workflow once** with the *Run workflow* button and check that both
   jobs pass. The packages then appear under your profile → *Packages*.
3. **Choose package visibility.** New ghcr.io packages are private.
   - *Public:* package → *Package settings* → *Change visibility*. Portainer
     can then pull without credentials.
   - *Private:* create a classic personal access token with only the
     `read:packages` scope, then in Portainer go to **Registries → Add registry →
     Custom**, URL `ghcr.io`, your GitHub username and the token.
4. **Point your stacks at the new images:**

   ```yaml
   services:
     php:
       image: ghcr.io/<owner>/piwigo-php:8.3
   ```

## Updating

After a build (or when a PHP security release is announced: run the workflow
manually first), open the stack in Portainer → **Update the stack** → enable
**Re-pull image and redeploy**.

To roll back, change the tag to a dated one such as `8.3-20261123` and redeploy.

## Notes

- **Scheduled runs pause in quiet public repos.** GitHub disables `schedule`
  triggers in a public repo after 60 days with no commits. GitHub emails you
  first, and you can re-enable it from the Actions tab. Private repos are not
  affected, but their build minutes count against your free allowance (a run
  takes a few minutes).
- **PHP 8.1 gets no more PHP fixes.** It went end-of-life on 31 Dec 2025, so
  the upstream `php:8.1` images are no longer rebuilt. The `apt-get upgrade`
  step still pulls in Debian security fixes, but PHP itself stays unpatched.
  Move whatever still needs 8.1 to 8.3 when you can, then delete `"8.1"` from
  the matrix in the workflow.
- **ARM hosts:** add `linux/arm64` to `platforms` in the workflow. The build is
  emulated, so expect it to take noticeably longer.
