[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

### Build to Artifactory Example

Demonstration of a simple GitHub [actions workflow](https://github.com/UCBoulder/build-to-artifactory-example/actions) located in the [.github](https://github.com/UCBoulder/build-to-artifactory-example/tree/main/.github) directory.

When [triggered by submitting a PR](https://github.com/UCBoulder/build-to-artifactory-example/blob/main/.github/workflows/check-container.yml#L3-L7):
1. Launches a GitHub hosted Linux runner
2. Checks out this repository
3. Builds the image from the [Dockerfile](https://github.com/UCBoulder/build-to-artifactory-example/blob/main/Dockerfile)
4. Checks that the container starts up properly

When [triggered by merging to the main or develop branch](https://github.com/UCBoulder/build-to-artifactory-example/blob/main/.github/workflows/build-to-artifactory.yml#L3-L7):
1. Launches a GitHub hosted Linux runner
2. Checks out this repository
3. Builds the image from the [Dockerfile](https://github.com/UCBoulder/build-to-artifactory-example/blob/main/Dockerfile)
4. Tags and pushes to a private registry, in this case [UCB Artifactory](https://artifactory.colorado.edu), utilizing repository Actions secrets.

This repository loosely operates around the [git-flow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) branching model, however, the "main" branch replaces the "master" branch.
