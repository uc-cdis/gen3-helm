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

It is important to understand that when a branch is merged into the main branch, a GitHub action will generate a new helm chart release if the helm chart version in the chart.yaml file has been incremented. Consider the following example where a change to the Helm chart has been made and the contributor wants a new version to be released:

The original Chart.yaml file:

   ```yaml
   apiVersion: v2
   name: Sheepdog
   description: A Helm chart for Kubernetes
   type: application
   version: 0.1.0
   ```

If a modification to the Helm chart is made (an update to the values.yaml file for instance) the version in Chart.yaml is incremented to `0.2.0`:

   ```yaml
   apiVersion: v2
   name: Sheepdog
   description: A Helm chart for Kubernetes
   type: application
   version: 0.2.0 # version updates to 0.2.0
   ```

Once the associated branch is merged into the main branch, the GitHub action packages and publishes an artifact, making it available for consumption. The release name is based off the 'name' field and the 'version' field in the Chart.yaml file. Given the example above, GitHub action will produce a release called `sheepdog-0.2.0`.


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
- If there are changes to the charts, it bumps the chart versions


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
