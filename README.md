# rest-fixture

[![License](http://img.shields.io/badge/license-EPL-blue.svg?style=flat)](https://www.eclipse.org/legal/epl-v10.html)
[![Build Status](https://travis-ci.org/test-editor/rest-fixture.svg?branch=master)](https://travis-ci.org/test-editor/rest-fixture)
[![Download](https://api.bintray.com/packages/test-editor/Fixtures/rest-fixture/images/download.svg)](https://bintray.com/test-editor/Fixtures/rest-fixture/_latestVersion)

## Development

### Build

    ./gradlew build

### Release process

In order to create a release switch to the `master` branch and execute

    ./gradlew release

and enter the new version. After the commit and tag is pushed Travis will automatically build and deploy the tagged version to Bintray.
