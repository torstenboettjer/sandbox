# Operator Sandbox

The operator sandbox provides an development and execution environment for operation engineers, migrating applications to a hybrid cloud stack. It introduces an approach towards "infrastructure as coden (IaC)" that meets enterprise requirements. The focus is on automating management processes, retaining control over application deployments and centralize service provisioning. Usually, cloud engineers employ a combination of applications like Terraform, Ansible and Kubernetes to automate system configurations, topology designs and container deployments. Yet configuration management systems, provisioning tools and container platforms serve a similar purpose. These tools overlap significantly in functionality and the focus is on deploying- rather than on building services. While this might be applicable for cloud-native applications, it rises complexity for operator, managing a large number of third party applications. It makes it hard to retain control over applications and data, and address technical, commercial or regulatory requirements. IaC tools combine system definitions and execution instructions in a common code base, while ensuring regulatory compliance, testing security policies or providing commercial justifications are required to take place before launching a service. Hence, the definition of a service and the launch should be separated. Enabling continuous integrations and deployments for service operators requires an integrated toolchain rather than a single application with a common data source rather than a single code base. 

## Target System

Cloud infrastructure is a managed service, build on a programmable platform that orchestrates virtual artifacts. Resources are exposed through controller that are developed and maintained by the provider and cannot be accessed by the operator directly. The implications on the application design are described in the [Twelve-Factor](https://12factor.net/) manifesto. For software that does not meet these criteria a different delivery model is required. A hybrid platform uses cloud services where appropriate but without prescribing the use of an orchestrator for the entire portfolio. It distinguishes between distributed and decated resources where infrastructure controller is provided by a physical resource either directly or through a control computer. Declarative package managers like [Nix](https://github.com/NixOS/nix), [Guix](https://guix.gnu.org/) or [Lix](https://lix.systems/) enable operators to define the desired system state in configuration files that isolate the dependencies for software packages on operating system level and ensure clean and reproducible systems that include the user and the kernal space. A functional programming language allows system administrators to write templates for purpose build systems from a strip down version of Linux that only covers the most essential components for basic functionality. System templates trigger changes to the composition of the operating system that match the topology design and the runtime requirements without depending on specific communication patterns, packaging mechanisms or orchestration capabilities. This enables operators to centralize management tasks, to track and to roll back system configurations in a similar way like immutable artifacts but without abstraction of the runtime environment, network- and storage interfaces.

## Development Environment

The sandbox is a development for system templates and execution environment for service blueprints. Deployment workflows are enabled with layered architecture that addresses a separation of concerns, typically found in an enterprise IT organization. Development tools are employed independently from platform components and service configurations. Engineers avoid implicit dependencies on platform orchestrators or packaging mechansims. This allows service operator to retain control over the technology platform even if it is partially outsourced. 

![Technology Stack](./img/techStack.drawio.svg)

The development process is decentralized, configuration templates are shared via git repositories, external services can be integrated, sharing dotfiles enables administrators to manage accounts and secrets without unveiling them. Code contributors only need access to a Linux environment, a subsystem provided by [Windows](https://learn.microsoft.com/en-us/windows/wsl/about) or [ChromeOS](https://chromeos.dev/en/linux) is sufficient. The virtual maschine requires enough space to cache the platform components of a project though. A minimum size of *80 to 120GB* is recommended - however, this really depends on the number and the complexity of the service blueprints that are being developed. 

```sh
curl -L https://raw.githubusercontent.com/hcops/sandbox/main/setup | sh -s
```

The setup script contains a default toolset with VS-Code, gh and jq already and uses Github for code sharing. The github client is also used to load default parameter into the configuration. Automations are based on Nix, using the *Lix* package manager, a fork from the original nix package manager that is a bit more user friendly. The nix language allows engineers to manage dependencies on operating system level and trigger provisioning processes that either configure dedicated server or produce virtual artifacts. Storing declaration files in a repository together with the application code fosters the development of consistent blueprints that provide similar advantages like immutable infrastructure without introducing the same limitations. To activate the package manager after installation, the shell session requires a restart. 

```sh
exec bash && source ~/.bashrc
```

MacOS users cannot rely on the convenience of an isolated subsystem but refer to the [nix-darwin](https://github.com/LnL7/nix-darwin) project and arrive at the same point. Alternatively, a virtual maschine on a hypervisor can be considered. Nix provides features that address requirements like reproducibility, isolation, and atomic upgrades withour relying on an orchestrator or a cloud control plane. Nix was introduced in 2003 by [Eelco Dolstra](https://en.wikipedia.org/wiki/Nix_(package_manager)) to create a reliable system for software deployments. It ensures consistent package deployments through specification of package dependencies and build instructions. The supporting community has grown to nearly a thousand developers and has gathered several thousands of contributors. 

### Engineering Tools

A standard toolset in system engineering is an enabler for long term quality and maintainability of the infrastructure code. In the sandbox it is deployed using **[Home-manager](https://nix-community.github.io/home-manager/)**, a nix extension that configures user environments through the `home.nix` file. Home manager supports two ways of deploying applications, programs and the packages. `programs` is always the prefered method, it refers to modules that install the software and configure system wide features when applicable. The home manager [option search](https://home-manager-options.extranix.com/) provides an overview of available programs.
```ǹix
  programs = {
    direnv.enable = true; # https://direnv.net/

    vscode = {
      enable = true; # https://code.visualstudio.com/
      package = pkgs.vscodium;
      enableUpdateCheck = false;
    };

    jq.enable = true;     # https://jqlang.github.io/jq/
    fzf.enable = true;    # https://github.com/junegunn/fzf
    gh.enable = true;     # https://cli.github.com/manual/
  };
```

Referencing a application in the `home.packages` installs the software. Nix packages can be found in the nix [package directory](https://search.nixos.org/packages). The command `nix-env -qaP` lists packages at the command line, incl. the available attributes. Some packages allow fine-tuning, e.g. by applying overrides like the [Nerd Fonts](https://search.nixos.org/packages?channel=unstable&show=nerdfonts&from=0&size=50&sort=relevance&type=packages&query=nerdfonts) package allows to override the default list of fonts. The `override` and `overrideAttrs` functions are typically used with packages that are built from source and have attributes like `src`, `buildInputs`, `makeFlags`, etc.. 


```ǹix
  home.packages = with pkgs; [
    devenv       # https://devenv.sh/
    gnumake      # https://www.gnu.org/software/make/manual/make.html
    # lunarvim   # https://www.lunarvim.org/
    # zed-editor # https://zed.dev/

    # Override example
    # (nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    (writeShellScriptBin "mysbx" ''
      # Create the new remote repository on GitHub
      gh repo create "${gituser}/mysbx" --private

      # Check if the repository was created successfully
      if [ $? -ne 0 ]; then
          echo "Failed to create the remote repository on GitHub."
          exit 1
      fi

      # Unlink the local repository from the current origin
      cd ${homedir}/sandbox && git remote remove origin

      # Link the local repository with the new remote repository
      git remote add origin "https://github.com/${gituser}/mysbx.git"

      # Push the new branch to the new remote repository
      git push "https://github.com/${gituser}/mysbx.git" "main"

      # Check if the branch was pushed successfully
      if [ $? -ne 0 ]; then
          echo "Failed to push the local repository to GitHub."
          exit 1
      fi

      # Verify the new remote setup
      git remote -v

      echo "The sandbox directory has been successfully linked to your remote repository."
      echo "Remote repository: https://github.com/${gituser}/mysbx.git"
    '')
  ];
```

Beside the development tools, the home manager configuration triggers the deployment of the downstream tools direnv and devenv.sh. Small shell scripts add functionlaity to the user shell, e.g. the "mysbx" command replicates the shell configuration into a github repository, in order to share the personal configuration across multiple devices. *Handle with care! This command replicates the entire configuration without changes to the flake.nix, which only works if both device run on the same system platform.*


### Platform Components

System parameters are defined independently from the shwll configuration in the [flake.nix](./flake.nix) file, so that tools can be managed independent from the host system. Flakes are still classified as experimental feature, a respective flag is appended to `/etc/nix/nix.conf`. It should be mentioned that there are alternatives to define a default set of tools and services in nix, e.g. [Flakey](https://github.com/lf-/flakey-profile), which provides less automation but more control.  

A platform is defined adding system software to the host that are required to run all service components. **[Direnv](https://direnv.net/)** is a shell extension to load and unload system software and configurations automatically, moving in and out a directory, which enables system engineers to provide purpose build systems for multiple projects. The configuration is separated from development tools to ease the deployment together with the application code. Direnv is a nix based application that enables engineers to support multiple development projects. It isolates system configurations their dependencies in a directory and automatically loads and unloads the components, switching from one directory to another. This helps to overcome one of the complexity driver for DevOps in an enterprise context. Fast iterations with divergent structures in application development and service operation often leads to massive workload for operators. While development teams are organized around solutions to focus on the delivery of business functionality, operation teams are organized around technologies with specialists managing systems. Hence, operators required for 24x7 operation have to join multiple SCRUM teams with little time left to fulfill their day to day tasks. A tool like direnv allows operations enigneers to create per-project environments and relieve system specialists. Nix supports multiple concepts of separating environment definitions. E.g. the default [flake.nix](./flake.nix) file can be extended with nix packages and stored in a new package directory. However, devenv comes offers additional features to streamline the development process and comes an on devenv.nix. In most cases, this file serves the purpose, for more advanced requirements might require the definition of overlays or a a specific package.nix, which is not covered here.  

```sh
# uncomment when adding flake.nix to an existing configuration
# echo "use flake" >> .envrc
direnv allow
```

Files ending on *.nix are activated by appending the use command to a environment file inside a project directory. Direnv automatically reads files called default.nix or shell.nix, what might be useful to configure the appeearance of the shell and add tools like [starship](https://starship.rs/). The 'allow' flag authorizes direnv to automatically load and unload environment variables, when the directory is changed. It checks for the existence of a .envrc file and if the file exists, the defined variables are captured and made available in the current shell.  

### Service Configuration

**[Devenv.sh](https://devenv.sh/)** is a configuration tool that allows engineers to define development environments declaratively by toggling basic options for nix and process-compose. Devenv leverages Nix to create reproducible development environments, it is an extension of the Nix ecosystem, tailored for development workflows. A development environment is defined by creating a directory, setting up a git repository, and sharing the repository with other developers via Github.

```sh
devenv init
```

Will create the following files in a given repository: `.envrc, devenv.nix, devenv.yaml, .gitignore`. The nix file contains the system software and platform components, required to build an applications. Because the configuration is declarative, the entire system configuration is replicated over git repositories, which allows match the lifecycle and the technical requirements of the application code or binaries. Instantiation is triggered through "actions", configurations are shared across teams.

## Contribution
This is merely a setup script that helps operators to launch a nix based sandbox. The aim is to ease the adoption of a technology that resolves issues,  system administrators experience, migrating enterprise applications to a cloud provider. Any contribution is highly welcome, e.g.:
* *Add features* If you have an idea for a new feature, please [open an issue](https://github.com/hcops/sandbox/issues/new) to discuss it before creating a pull request.
* *Report bugs* If you find a bug, please [open an issue](https://github.com/hcops/sandbox/issues/new) with a clear description of the problem.
* *Fix bugs* If you know how to fix a bug, submit a [pull request](https://github.com/hcops/sandbox/pull/new) with your changes.
* *Improve documentation* If you find the documentation lacking, you can contribute improvements by editing the relevant files.
