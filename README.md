![Flutter CI](https://github.com/SEU_USUARIO/SEU_REPO/actions/workflows/flutter_ci.yml/badge.svg)
![Firebase Distribution](https://github.com/SEU_USUARIO/SEU_REPO/actions/workflows/firebase_distribution.yml/badge.svg)

# TaskFlow Flutter CI/CD

A Flutter study project focused on building a real CI/CD pipeline for mobile applications.

## Tech Stack

- Flutter
- Firebase Authentication
- Cloud Firestore
- BLoC / Cubit
- GitHub Actions
- Firebase App Distribution

## Features

- Anonymous authentication
- Task creation
- Task completion
- Task deletion
- Real-time task updates with Firestore

## CI

The CI workflow runs on pull requests and pushes to protected branches.

Steps:

- format check
- static analysis
- tests
- APK build

## CD

On pushes to `develop`, the pipeline:

- builds a release APK
- assigns an automatic build number
- distributes the build through Firebase App Distribution

## Branch Strategy

- `main`: stable branch
- `develop`: integration / beta branch
- `feature/*`: development branches

## Next Steps

- Android signing with keystore
- Flavors (`dev` / `prod`)
- Codemagic pipeline
  th keystore
- Flavors (`dev` / `prod`)
- Codemagic pipelineprod`)
- Codemagic pipeline
