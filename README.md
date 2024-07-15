# Operator Sandbox

The operator sandbox addresses operation engineers with an environment for the design and optimization of systems that should be migrated to a hybrid cloud. Cloud engineers usually employ a combination of applications like Terraform, Ansible and Kubernetes to automate system configurations, topology designs and container deployments. Yet configuration management systems, infrastructure-as-code and container platforms overlap significantly in functionality, these tools were developed with a different platform design in mind but serve a similar purpose. The focus is merely on provisioning and deployment automation not on process automation for operators. This works well, when all applications follow cloud-native design patterns and the entire platform is operated by a single provider. It rises complexity, when service operator manage large quantities of applications that do not adhere to a common design standard and when only a subset of an entire software portfolio can be migrated for technical, commercial or regulatory reasons. With code interpreters that do not separate system definitions and execution instructions, a separation of duties between design, implementation and operation, required to scale organizations with technology specialists is hardly possible. And a division between command and control, required to ensure regulatory compliance, security and commercial justification is very doubtful. The benefits of infrastructure as code are out of question, but a one-size-fits-all approach doesn't appear feasible in an enterprise environment. A integrated toolchain is required that delivers on the promise of continuous integrations and deployments by sharing system definitions through a common datamodel and separating execution modules along the delivery milestones like operational readiness, fulfillment and assurance. This sandbox adresses the first step and enables engineers to write code that ensures operational readiness without prescribing where and how the service will run.

## Host System

A design neutral delivery model is based on system templates to trigger changes that match the topology and the lifecycle of an application automatically, without depending on specific communication patterns, packaging mechanisms or orchestration capabilities. The development of modern cloud controllers is based on the assumption that every system can be virtualized. While this is certainly true for public internet services that scale to millions of users, this not a well suited infrastructure foundation for many enterprise applications. Nevertheless, technologies have evolved and raise the question today, whether virtualization is still the only way to deliver a programmable platform. The package managers like [Nix](https://github.com/NixOS/nix), [Guix](https://guix.gnu.org/) or [Lix](https://lix.systems/) enable engineers to compose operating systems declaratively, without abstracting the runtime environment, network and storage interfaces. A functional programming language allows to write templates for purpose build operating systems. Adding the package manager together with a [process orchestrator](https://f1bonacc1.github.io/process-compose/) to a strip down version of a Linux system that covers the most essential components for basic functionality enables operators to centralize management tasks, to track and to roll back system configurations in a similar way like immutable artifacts.

The sandbox is using Nix, which provides access to a [large collection of packages](https://search.nixos.org/packages). Engineers need a git account and access to a virtual machine, running Linux. The simplest option is the subsystem provided with [Windows](https://learn.microsoft.com/en-us/windows/wsl/about) or [ChromeOS](https://chromeos.dev/en/linux). The recommendation for the size is *80 to 120GB* but this varies with the use case. The package mananger is installed via command line interface. MacOS can use [nix-darwin](https://github.com/LnL7/nix-darwin) community project to arrive at the same point. The [setup script](./setup) uses Github for replication and contains some common tools like VS-Code, gh and jq to be deployed on either a `x86_64-linux` or `aarch64-linux` based system. The github client is used to load the default parameter into the configuration. 

```sh
curl -L https://raw.githubusercontent.com/hcops/sandbox/main/setup | sh -s -- x86_64-linux
```

Nix provides features that address requirements like reproducibility, isolation, and atomic upgrades beyond the scope of a cloud controller and is therefor a solid foundation for the development of hybrid services. Key features are ensuring a consistent package deployments through precise specification of dependencies and build instructions. To activate the package manager after installation, the shell session requires a restart.

```sh
exec bash && source ./.bashrc
```

Nix was introduced in [2003 by Eelco Dolstra](https://en.wikipedia.org/wiki/Nix_(package_manager)) to create a reliable system for software deployments. Since than the open source initiative has grown to nearly a thousand developers and has gathered several thousands of contributors. The nix language allows engineers to manage dependencies on operating system level, which is the foundation to trigger provisioning processes that either configure dedicated server or produce artifacts for a cloud deployment. Storing declaration files in a repository together with the application code fosters the development of consistent blueprints that provide similar advantages like immutable infrastructure without introducing the same limitations.

### Foundation

The sandbox is build with a layered architecture in mind, separating development tools from platform components and service configurations. It avoids any dependencies on platform orchestrators or packaging mechansims and does not touch on the topology design. This helps to re-introduces the necessary seperation of duties for technology and service operator and allows enterprises to retain control over the technology platform even when is is partially outsources to a managed service- or a cloud provider. Given the flexibility of a programmable operating system, there are more than one possible toolset to provide such an environment. This proposal is focussed on ease of use and combines the following three tools:

![High-Level Architecture for the Operator Sandbox](./img/techStack.drawio.svg)

A standard toolset in system engineering is key for long term quality and maintainability for system administrators. Home-Manager is used to define a standard set of engineering tools accross the organization, direnv automatically loads a set platform components for project related work and devenv.sh adds the service configuration that can vary according to the lifecycle stage and between individuals or teams contributing to a project. 

* **[Home-manager](https://nix-community.github.io/home-manager/)**: A nix extension that pre-configures user environments with the Nix package manager and allows teams or organizations to define a standard toolset.
* **[Direnv](https://direnv.net/)**: A shell extension to load and unload system software and configurations automatically, moving in and out a directory, which enables system engineers to provide purpose build systems for multiple projects.
* **[Devenv.sh](https://devenv.sh/)**: A configuration tool that allows engineers to define development environments declaratively by toggling basic options for nix and process-compose.

The default toolset is defined in the [home.nix](./home.nix) file under *home.packages*. Beside the development tools it triggers the deployment of the downstream tools direnv and devenv.sh. The system layer is defined independent from the application layer, in [flake.nix](./flake.nix). This allows to run the same configuration on different host systems. Flakes are still classified as experimental feature, a respective flag is appended to `/etc/nix/nix.conf`. It should be mentioned that there are alternatives to define a default set of tools and services in nix, e.g. [Flakey](https://github.com/lf-/flakey-profile), which provides less automation but more control.  

### Platform Components

A platform is defined adding system software to the host that are required to run all service components. The configuration is separated from development tools to ease the deployment together with the application code. Direnv is a nix based application that enables engineers to support multiple development projects. It isolates system configurations their dependencies in a directory and automatically loads and unloads the components, switching from one directory to another. This helps to overcome one of the complexity driver for DevOps in an enterprise context. Fast iterations with divergent structures in application development and service operation often leads to massive workload for operators. While development teams are organized around solutions to focus on the delivery of business functionality, operation teams are organized around technologies with specialists managing systems. Hence, operators required for 24x7 operation have to join multiple SCRUM teams with little time left to fulfill their day to day tasks. A tool like direnv allows operations enigneers to ceate per-project environments and relieve system specialists. Nix supports multiple concepts of separating environment definitions. E.g. the default [flake.nix](./flake.nix) file can be extended with nix packages and stored in a new package directory. However, devenv comes offers additional features to streamline the development process and comes an on devenv.nix. In most cases, this file serves the purpose, for more advanced requirements might require the definition of overlays or a a specific package.nix, which is not covered here.  

```sh
# uncomment when adding flake.nix to an existing configuration
# echo "use flake" >> .envrc
direnv allow
```

Files ending on *.nix are activated by appending the use command to a environment file inside a project directory. Direnv automatically reads files called default.nix or shell.nix, what might be usefull to configure the appeearance of the shell and add tools like [starship](https://starship.rs/). The 'allow' flag authorizes direnv to automatically load and unload environment variables, when the directory is changed. It checks for the existence of a .envrc file and if the file exists, the defined variables are captured and made available in the current shell.  

### Service Configuration

Devenv is a tool that leverages Nix to create reproducible development environments, it is an extension of the Nix ecosystem, tailored for development workflows. A development environment is defined by creating a directory, setting up a git repository, and sharing the repository with other developers via Github.

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
