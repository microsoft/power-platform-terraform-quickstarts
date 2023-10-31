# Mirroring Terraform Registry Modules

Because the `microsoft/power-platform` module is private and not yet published to the Terraform Registry, it is necessary to mirror the provider's registry information in a local file system.  The following steps will create a local mirror of the provider in the `/usr/share/terraform/providers/` directory.  You must login to GitHub CLI with an account that has read access to [microsoft/terraform-provider-power-platform](https://github.com/microsoft/terraform-provider-power-platform) GitHub Repo.  That may be a different account than the GitHub enterprise account you use to access this repository.

## Usage

```bash
sudo gh auth login
sudo -E bash -c 'source ./mirror.sh'
```

## Outputs

This script will set the `TF_CLI_CONFIG_FILE` environment variable to the path of the mirror configuration.  This path can be used in the `terraform` CLI to use the mirrored providers.

## Troubleshooting

* If `./mirror.sh` can't be executed, you may need to run `chmod +x ./mirror.sh` first
* `sudo` is required because `root` owns the `/usr/share/terraform/providers/` directory
* Using `sudo` with `gh auth login` will create the GitHub token in the `root` user's home directory.  This token will not be used by the `vscode` user for other github related tasks in this repo like adding secrets to GitHub Actions Workflows.
