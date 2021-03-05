# About

Please see the [Getting Started](docs/getting-started.md) document to learn more about the *automated service template generator*.

## Usage

If you run `make service` at the root of this repo, you will kick off the `service generator.py` script. This creates a new service from a Jinja template and places it into the `services/` folder. It will also populate the `gitlab-ci.yml` file with the necessary variables as well.
