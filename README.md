# Operator Sandbox

The operator sandbox addresses operation engineers with an environment for the design and optimization of systems that should be migrated to a hybrid cloud. Cloud engineers usually employ a combination of applications like Terraform, Ansible and Kubernetes to automate system configurations, topology designs and container deployments. Yet configuration management systems, infrastructure-as-code and container platforms overlap significantly in functionality, these tools serve a similar purpose but with a different target platform in mind. The focus is merely on provisioning and deployment automation not on process automation for operators. This works well, when all applications follow cloud-native design patterns and the entire platform is operated by a single provider. It rises complexity, when service operator manage large quantities of applications that do not adhere to a common design or when only a subset of an entire software portfolio can be migrated for technical, commercial or regulatory reasons. The benefits of infrastructure as code are out of question, but a one-size-fits-all approach doesn't appear feasible in an enterprise environment. With code interpreters that do not separate system definitions and execution instructions, scaling an organization with a separation of duties between design, implementation and operation is hardly possible. And ensuring regulatory compliance, security and commercial justification without a separation between command and control is very doubtful. An integrated a toolchain that delivers on the promise of continuous integrations and deployments requires a common source for system definitions with execution modules, separated along delivery milestones like operational readiness, fulfillment and assurance. 

## Target System

A hybrid platform uses cloud services where appropriate without prescribing a complete migration of the entire software portfolio. Cloud infrastructure is a managed service, build on a programmable platform that orchestrates virtual artifacts. Resources are exposed through controller and cannot be accessed by the runtime directly. The implications on the application design are described in the [Twelve-Factor](https://12factor.net/) manifesto. For software that does not meet these criteria or cannot be outsourced, a different delivery model is required. Declarative package managers like [Nix](https://github.com/NixOS/nix), [Guix](https://guix.gnu.org/) or [Lix](https://lix.systems/) enable operators to define the desired system state in configuration files that isolate the dependencies for software packages and ensure a clean and reproducible environment. A functional programming language allows system administrators to write templates for purpose build systems from a strip down version of Linux that only covers the most essential components for basic functionality. System templates trigger changes to the composition of the operating system that match the topology design and the runtime requirements without depending on specific communication patterns, packaging mechanisms or orchestration capabilities. This enables operators to centralize management tasks, to track and to roll back system configurations in a similar way like immutable artifacts but without abstraction of the runtime environment, network- and storage interfaces.

## Development Environment

The sandbox is a development and execution environment for system templates. Deployment workflows are enabled with layered architecture that addresses a separation of concerns, typically found in an enterprise IT organization. Development tools are employed independently from platform components and service configurations. Engineers avoid implicit dependencies on platform orchestrators or packaging mechansims. This allows service operator to retain control over the technology platform even if it is partially outsourced. 

![Technology Stack](./img/techStack.drawio.svg)

The development process is decentralized, configuration templates are shared via git repositories, external services can be integrated, sharing dotfiles enables administrators to manage accounts and secrets without unveiling them. Code contributors only need access to a Linux environment, a subsystem provided by [Windows](https://learn.microsoft.com/en-us/windows/wsl/about) or [ChromeOS](https://chromeos.dev/en/linux) is sufficient. The virtual maschine requires enough space to cache the platform components of a project though. A minimum size of *80 to 120GB* is recommended - however, this really depends on the number and the complexity of the service blueprints that are being developed. 

```sh
curl -L https://raw.githubusercontent.com/hcops/sandbox/main/setup | sh -s
```

The setup script contains a default toolset with VS-Code, gh and jq already and uses Github for code sharing. The github client is also used to load default parameter into the configuration. Automations are based on Nix, using the *Lix* package manager, a fork from the original nix package manager that is a bit more user friendly. The nix language allows engineers to manage dependencies on operating system level and trigger provisioning processes that either configure dedicated server or produce virtual artifacts. Storing declaration files in a repository together with the application code fosters the development of consistent blueprints that provide similar advantages like immutable infrastructure without introducing the same limitations. To activate the package manager after installation, the shell session requires a restart. 

```sh
exec bash && source ~/.bashrc
```

MacOS users cannot rely on the convenience of an isolated subsystem but refer to the [nix-darwin](https://github.com/LnL7/nix-darwin) project and arrive at the same point. Alternatively, a virtual maschine on a hypervisor can be considered. Nix provides features that address requirements like reproducibility, isolation, and atomic upgrades withour relying on an orchestrator or a controller. Nix was introduced in 2003 by [Eelco Dolstra](https://en.wikipedia.org/wiki/Nix_(package_manager)) to create a reliable system for software deployments. It ensures consistent package deployments through specification of package dependencies and build instructions. The supporting community has grown to nearly a thousand developers and has gathered several thousands of contributors. 

### Standard Tools

A standard toolset in system engineering is an enabler for long term quality and maintainability of the infrastructure code. In the sandbox it is deployed using **[Home-manager](https://nix-community.github.io/home-manager/)**, a nix extension to the shell that configures user environments through the `home.nix` file. Software can be found in the Nix [package directory](https://search.nixos.org/packages) added in the *home.packages* section of the onfiguration file. Beside the development tools it triggers the deployment of the downstream tools direnv and devenv.sh. 

```nix
  home.packages = with pkgs; [
    direnv       # https://direnv.net/
    devenv       # https://devenv.sh/
    gh           # https://cli.github.com/manual/
    gnumake      # https://www.gnu.org/software/make/manual/make.html
    vscode       # https://code.visualstudio.com/
    # lunarvim   # https://www.lunarvim.org/
    # zed-editor # https://zed.dev/
    jq           # https://jqlang.github.io/jq/
    fzf          # https://github.com/junegunn/fzf
  ];
```

Some packages allow fine-tune, e.g. by applying overrides like install the [Nerd Fonts](https://search.nixos.org/packages?channel=unstable&show=nerdfonts&from=0&size=50&sort=relevance&type=packages&query=nerdfonts) only with a limited number of fonts.

```nix
  home.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })
  ];
```

And home manager allws engineers to write simple shell scripts directly inside th configuration liek adding a command 'my-hello' the shell.
    # # environment:

```nix
  home.packages = with pkgs; [
    (writeShellScriptBin "my-hello" ''
      echo "Hello, ${config.home.username}!"
    '')
  ];
```

System parameters are defined independently from the shwll configuration in the [flake.nix](./flake.nix) file, so that tools can be managed independent from the host system. Flakes are still classified as experimental feature, a respective flag is appended to `/etc/nix/nix.conf`. It should be mentioned that there are alternatives to define a default set of tools and services in nix, e.g. [Flakey](https://github.com/lf-/flakey-profile), which provides less automation but more control.  

### Platform Components

A platform is defined adding system software to the host that are required to run all service components. **[Direnv](https://direnv.net/)** is a shell extension to load and unload system software and configurations automatically, moving in and out a directory, which enables system engineers to provide purpose build systems for multiple projects. The configuration is separated from development tools to ease the deployment together with the application code. Direnv is a nix based application that enables engineers to support multiple development projects. It isolates system configurations their dependencies in a directory and automatically loads and unloads the components, switching from one directory to another. This helps to overcome one of the complexity driver for DevOps in an enterprise context. Fast iterations with divergent structures in application development and service operation often leads to massive workload for operators. While development teams are organized around solutions to focus on the delivery of business functionality, operation teams are organized around technologies with specialists managing systems. Hence, operators required for 24x7 operation have to join multiple SCRUM teams with little time left to fulfill their day to day tasks. A tool like direnv allows operations enigneers to ceate per-project environments and relieve system specialists. Nix supports multiple concepts of separating environment definitions. E.g. the default [flake.nix](./flake.nix) file can be extended with nix packages and stored in a new package directory. However, devenv comes offers additional features to streamline the development process and comes an on devenv.nix. In most cases, this file serves the purpose, for more advanced requirements might require the definition of overlays or a a specific package.nix, which is not covered here.  

```sh
# uncomment when adding flake.nix to an existing configuration
# echo "use flake" >> .envrc
direnv allow
```

Files ending on *.nix are activated by appending the use command to a environment file inside a project directory. Direnv automatically reads files called default.nix or shell.nix, what might be usefull to configure the appeearance of the shell and add tools like [starship](https://starship.rs/). The 'allow' flag authorizes direnv to automatically load and unload environment variables, when the directory is changed. It checks for the existence of a .envrc file and if the file exists, the defined variables are captured and made available in the current shell.  

### Service Configuration

**[Devenv.sh](https://devenv.sh/)** is a configuration tool that allows engineers to define development environments declaratively by toggling basic options for nix and process-compose. Devenv leverages Nix to create reproducible development environments, it is an extension of the Nix ecosystem, tailored for development workflows. A development environment is defined by creating a directory, setting up a git repository, and sharing the repository with other developers via Github.

```sh
devenv init
```

Will create the following files in a given repository: `.envrc, devenv.nix, devenv.yaml, .gitignore`. The nix file contains the system software and platform components, required to build an applications. Because the configuration is declarative, the entire system configuration is replicated over git repositories, which allows match the lifecycle and the technical requirements of the application code or binaries. Instantiation is triggered through "actions", configurations are shared accross teams.

## Contribution
This is merely a setup script that helps operators to launch a nix based sandbox. The aim is to ease the adoption of a technology that resolves issues,  system administrators experience, migrating enterprise applications to a cloud provider. Any contribution is highly welcome, e.g.:
* *Add features* If you have an idea for a new feature, please [open an issue](https://github.com/hcops/sandbox/issues/new) to discuss it before creating a pull request.
* *Report bugs* If you find a bug, please [open an issue](https://github.com/hcops/sandbox/issues/new) with a clear description of the problem.
* *Fix bugs* If you know how to fix a bug, submit a [pull request](https://github.com/hcops/sandbox/pull/new) with your changes.
* *Improve documentation* If you find the documentation lacking, you can contribute improvements by editing the relevant files.
