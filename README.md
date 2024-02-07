# Bitbucket Pipelines Pipe:  CycloneDX Cdxgen sBOM Generator

A lightweight wrapper acount the popular @cyclonedx/cdxgen tool which will allow you to
generates a CycloneDX compliant Software Bill of Materials directely from a Bitbucket Pipe.
In order to keep the image size reasonalble, only node/npm, java, python and go is currently
supported. To request new support be added file an issue in GitHub. Other languages/frameworks may
work but they have not been formally tested.

The official copy this project is hosted on [Bitbucket]
(https://bitbucket.org/ccideas1/cyclonedx-pipe/src/main/).
In order to reach a diverse audience a copy of the repo also exists in [GitHub]
(https://github.com/ccideas/cyclonedx-cdxgen-bitbucket-pipe).
Pull Requests and issues should be opened in the GitHub copy and they will be synced back to Bitbucket.

## YAML Definition

The following is an example of a bitbucket pipeline which installs npm dependencies and caches those
dependencies in one step then uses those cached depdencies in the next step to build a CycloneDX
sBOM. The following code snip would need to be added to the `bitbucket-pipelines.yml` file

```yaml
pipelines:
  default:
    - step:
        name: Build and Test
        caches:
          - node
        script:
          - npm install
          - npm test
    - step:
        name: Gen CycloneDX sBom
        caches:
          - node
        script:
          - pipe: docker://ccideas/cyclonedx-cdxgen-bitbucket-pipe:1.0.0
            variables:
              CDXGEN_PROJECT_TYPE: 'node'
              CDXGEN_PATH_TO_SCAN: 'samples/node'
              CDXGEN_SPEC_VERSION: '1.4'
              CDXGEN_PRINT_AS_TABLE: 'true'
              CDXGEN_DEBUG_MODE: 'debug'
              DEBUG_BASH: 'false'
              OUTPUT_DIRECTORY: 'build'
        artifacts:
          - build/*
```

Another example without specifying the project type or a directory to scan. This will just recursively
scan your directory, identify components and write them to the sBOM

```yaml
pipelines:
  default:
    - step:
        name: Gen CycloneDX sBom
        script:
          - pipe: docker://ccideas/cyclonedx-cdxgen-bitbucket-pipe:1.0.0
            variables:
              CDXGEN_PATH_TO_SCAN: '.'
              CDXGEN_SPEC_VERSION: '1.4'
              CDXGEN_PRINT_AS_TABLE: 'true'
              CDXGEN_DEBUG_MODE: 'debug'
              DEBUG_BASH: 'false'
              OUTPUT_DIRECTORY: 'build'
        artifacts:
          - build/*
```

In both examples above the sBOM is written to the build directory. This directory will be archived.

## Variables

| Variable                  | Usage                                                               | Options                                           | Default               |
| ---------------------     | -----------------------------------------------------------         | -----------                                       | -------               |
| CDXGEN_SPEC_VERSION       | CycloneDX Specification version to use                              | 1.4, 1.5                                          | 1.5                   |
| CDXGEN_PROJECT_TYPE       | Used to specify the project type                                    | [See Docs](https://github.com/CycloneDX/cdxgen)   | none                  |
| CDXGEN_PATH_TO_SCAN       | Used to specify the path to scan                                    | <path to directory>                               | none                  |
| CDXGEN_PRINT_AS_TABLE     | Print the SBOM as a table with tree                                 | true, false                                       | false                 |
| CDXGEN_DEBUG_MODE         | Set to debug to enable debug messages                               | debug                                             | none                  |
| DEBUG_BASH                | Set to true to enable debug mode in bash                            | true, false                                       | false                 |
| OUTPUT_DIRECTORY          | Used to specify the directory to place all output in                | <directory name>                                  | build                 |
| SBOM_FILENAME             | Used to specify the name of the sbom file                           | <filename>                                        | ${bitbucket-repo-name-sbom   |

## Details

Generates a CycloneDX compliant Software Bill of Materials
for a various project types. The generated sBOM will be created in the
build directory and be named `${BITBUCKET_REPO_SLUG}-sbom.json`

## Example

A working pipeline for the popular [auditjs](https://www.npmjs.com/package/auditjs)
tool has been created as an example. The pipeline in
this fork of the [auditjs](https://www.npmjs.com/package/auditjs) tool will install the required
dependencies then generate a CycloneDX sBOM containing all the ingredients which make up the
product.

* [Repository Link](https://bitbucket.org/ccideas1/fork-auditjs/src/main/)
* [Link to bitbucket-pipelines.yml](https://bitbucket.org/ccideas1/fork-auditjs/src/main/bitbucket-pipelines.yml)
* [Link to pipeline](https://bitbucket.org/ccideas1/fork-auditjs/pipelines/results/4)

## Support

If you'd like help with this pipe, or you have an issue, or a feature request, [let us know](https://github.com/ccideas/cyclonedx-cdxgen-bitbucket-pipe).

If you are reporting an issue, please include:

the version of the pipe
relevant logs and error messages
steps to reproduce

## Credits

This Bitbucket pipe is a collection and integration of the following open source tools

* [@cyclonedx/cdxgen](https://github.com/CycloneDX/cdxgen)

A big thank-you to the teams and volunteers who make these amazing tools available
