# Contributing

We welcome contributions to the gen3-helm repository! This document outlines the guidelines for contributing to this project.

## Git and GitHub resources

Before starting a new contribution, you need to be familiar with [Git](https://git-scm.com/) and [GitHub](https://github.com/) concepts like: ***commit, branch, push, pull, remote, fork, repository***, etc. There are plenty of resources online to learn Git and GitHub, for example:
- [Git Guide](https://github.com/git-guides/)
- [GitHub Quick start](https://docs.github.com/en/get-started/quickstart)
- [GitHub on YouTube](https://www.youtube.com/github)
- [Git and GitHub learning resources](https://docs.github.com/en/get-started/quickstart/git-and-github-learning-resources)
- [Collaborating with Pull Requests](https://docs.github.com/en/github/collaborating-with-pull-requests)
- [GitHub Documentation, guides and help topics](https://docs.github.com/en/github)
- And many more...


## Before You Begin


If you have an idea for a new feature or a bugfix, it is best to communicate with the University of Chicago Center for Translational Data Science (CTDS) developers early. The primary venue for this is the [GitHub issue tracker](https://github.com/uc-cdis/gen3-helm/issues). Browse through existing GitHub issues and if one seems related, comment on it. For more direct communication, CTDS developers are generally available via Slack.


## Reporting a New Issue

If you have identified a potential new issue the first step is to ask the community whether this is something they are familiar with and for which they may already have a solution.  The slack channel #gen3_helm_ext is the preferred forum for communication regarding helm.  Please inquire in #gen3_community if you would like access ([request access here](https://docs.google.com/forms/d/e/1FAIpQLSczyhhOXeCK9FdVtpQpelOHYnRj1EAq1rwwnm9q6cPAe5a7ug/viewform)).

If the community has no solution and no existing gen3-helm issue seems appropriate, a new issue can be opened using [this form](https://github.com/uc-cdis/gen3-helm/issues/new). Please be specific in your comment and include instructions on how to reproduce the issue.  Please also make sure to add a short descriptive title.

## How to Contribute

All changes to the gen3-helm repository should be made through pull requests.

1. Fork the [gen3-helm repository](https://github.com/uc-cdis/gen3-helm) on GitHub to make your changes.

4. Run the relevant tests for the features added or bugs fixed by your pull request.

5. Write a descriptive commit message.

6. Commit and push your changes to your fork.

7. Open a pull request with these changes.

8. Your pull request will be reviewed by a project maintainer and merged if it is deemed appropriate.

## Style Guidelines

### Helm

- `gen3-helm` follows [General Conventions](https://helm.sh/docs/chart_best_practices/) for helm charts.

## Documentation

Documentation is found in the ``docs/`` directory.

The documentation source files are written in [Markdown](https://daringfireball.net/projects/markdown/syntax) format.

Each chart has its own README.md that is automatically built with [helm-docs](https://github.com/norwoodj/helm-docs). This happens in the pre-commit so make sure to check in all the changed files.

## Helm chart release strategy

**You do not need to bump any chart versions.** Every `Chart.yaml` in this repo
is frozen at the placeholder `version: 0.0.0`, and dependencies between charts
in this repo are declared as `version: "*"`:

   ```yaml
   apiVersion: v2
   name: sheepdog
   description: A Helm chart for Kubernetes
   type: application
   version: 0.0.0        # placeholder -- never edit this
   dependencies:
     - name: common
       version: "*"      # resolved locally, stamped at release time
       repository: file://../common
   ```

The real version is worked out when the chart is published. On a merge to
`master`, the release workflow:

1. Diffs the merge to find which charts changed.
2. Adds every chart that depends on a changed chart -- so a change to `common`
   republishes everything that uses it, and any subchart change republishes the
   `gen3` umbrella.
3. Looks up the highest existing `<chart>-X.Y.Z` git tag for each of those
   charts and increments the patch number.
4. Stamps those versions into `Chart.yaml` (in the CI working tree only -- this
   is never committed), packages, and publishes.

So if `sheepdog-0.1.47` is the latest tag and you change something under
`helm/sheepdog/`, merging produces `sheepdog-0.1.48` plus a new `gen3` release.
Nothing in the repo records that number.

To see exactly what your PR would publish, check the **job summary** on the
"Lint and Test Charts" run -- it lists every chart that would be released, the
version it would get, and whether it was pulled in directly or by the
dependency cascade.

Two consequences worth knowing:

- A one-line change to `helm/common/` republishes ~43 charts. That is
  intentional -- previously those dependents were silently left unpublished.
- Chart READMEs no longer show a version badge, since the in-repo version is
  always the placeholder. Published versions are listed at
  <https://helm.gen3.org> and on the [releases page](https://github.com/uc-cdis/gen3-helm/releases).


## Branch Naming Conventions

Branches are named as `type/scope`, and commit messages are written as `type(scope): explanation`, where

- `scope` identifies the thing that was added or modified,
- `explanation` is a brief description of the changes in imperative present tense (such as “add function to _”, not “added function”),
- and `type` is defined as:
    ```
    type = "chore" | "docs" | "feat" | "fix" | "refactor" | "style" | "test"
    ```

Some example branch names:

- `refactor/db-calls`
- `test/user`
- `docs/deployment`

Some example commit messages:

- `fix(scope): remove admin scope from client`
- `feat(project_members): list all members given project`
- `docs(generation): fix generation script and update docs`

## Pull Requests (PRs)


Before submitting a PR for review, try to make sure you’ve accomplished these things:

The PR:
- contains a brief description of what it changes and/or adds
- passes status checks
- If there are changes to the charts, the release preview in the job summary looks right (chart versions are derived at release time -- do not bump them by hand)


To merge the PR:

If the branch now has conflicts with the master branch, follow these steps to update it:

```bash
git checkout master
git pull origin master
git checkout $YOUR_BRANCH_NAME
git merge master
git commit
# The previous command should open an editor with the default merge commit
# message; simply save and exit
git push

```
