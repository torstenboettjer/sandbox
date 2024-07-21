# Operator Sandbox

The operator sandbox provides an development and execution environment for operation engineers, migrating applications to a hybrid cloud stack. It introduces an approach towards "infrastructure as code (IaC)" that meets enterprise requirements. The focus is on automating management processes, retaining control over application deployments and centralize service provisioning. Usually, cloud engineers employ a combination of applications like Terraform, Ansible and Kubernetes to automate system configurations, topology designs and container deployments. Yet configuration management systems, provisioning tools and container platforms serve a similar purpose. These tools overlap significantly in functionality and the focus is on deploying- rather than on building services. While this might be applicable for cloud-native applications, it rises complexity for operator, managing a large number of third party applications. It makes it hard to retain control over applications and data, and address technical, commercial or regulatory requirements. A hybrid platform uses cloud services where appropriate but without prescribing a specific system design for the entire application portfolio. The delivery model distinguishes between dedicated- and distributed systems where controllers are either provided by the physical resource or exposed through an orchestrator. A public cloud is a managed platform, build on a programmable infrastructure with an orchestrator that provisions virtual artifacts. Resources controller that are developed, maintained on managed by the provider, service operator cannot build services with direct access to a resource. The implications on the application design are best described in the [Twelve-Factor](https://12factor.net/) manifesto. For software that does not meet these criteria, a different delivery model is required. While IaC tools combine system definitions and execution instructions in a common code base, ensuring regulatory compliance, testing security policies or providing commercial justifications need to take place before launching a service - hence, the service definitions and the code that launches has to be separated. Enabling continuous integrations and deployments for hybrid services requires an integrated toolchain, not a single application with a joined data source rather than a single code base. 

## Host System

Declarative package managers like [Guix](https://guix.gnu.org/) or [Nix](https://github.com/NixOS/nix) enable operators to define the desired system state in configuration files that isolate the dependencies for software packages on operating system level and ensure clean and reproducible systems that include the user and the kernal space. A functional programming language allows system administrators to write templates for purpose build systems from a strip down version of Linux that only covers the most essential components for basic functionality. System templates trigger changes to the composition of the operating system that match the topology design and the runtime requirements without depending on specific communication patterns, packaging mechanisms or orchestration capabilities. This enables operators to centralize management tasks, to track and to roll back system configurations in a similar way like immutable artifacts but without abstraction of the runtime environment, network- and storage interfaces.

### Development Environment

The layered architecture of the sandbox enables system engineers to develop service blueprints without prescribing an operating model. Development tools are employed independently from platform components and service configurations. Engineers avoid implicit dependencies on orchestrators and/or packaging mechansims. Application developers retain the freedom to employ system software, while service operator regain full control over the technology platform - even if it is partially outsourced to a cloud provider. The development process is decentralized, configuration templates are shared via git repositories, external services can be integrated, sharing dotfiles enables administrators to manage accounts and secrets without unveiling them. 

![Technology Stack](./img/techStack.drawio.svg)

Code contributors only need access to a Linux environment, a subsystem provided by [Windows](https://learn.microsoft.com/en-us/windows/wsl/about) or [ChromeOS](https://chromeos.dev/en/linux) is sufficient. The virtual maschine requires enough space to cache the platform components of a project though. A minimum size of *80 to 120GB* is recommended - however, this really depends on the number and the complexity of the service blueprints that are being developed. The setup script contains a default toolset with VS-Code, gh and jq already and uses Github for code sharing. The github client is also used to load default parameter into the configuration. 

```sh
curl -L https://raw.githubusercontent.com/hcops/sandbox/main/setup | sh -s
```

The script installs the [Lix](https://lix.systems/)  package manager, a fork from the original nix package manager. System configurations are written in nix. The nix language allows engineers to manage dependencies on operating system level and trigger provisioning processes that either configure dedicated server or produce virtual artifacts. Storing declaration files in a repository together with the application code fosters the development of consistent blueprints that provide similar advantages like immutable infrastructure without introducing the same limitations. To activate the package manager after installation, the shell session requires a restart. MacOS users cannot rely on the convenience of an isolated subsystem but refer to the [nix-darwin](https://github.com/LnL7/nix-darwin) project and arrive at the same point. Alternatively, a virtual maschine on a hypervisor can be considered. 

```sh
exec bash && source ~/.bashrc
```

A programmable package manager provides features that address requirements like reproducibility, isolation, and atomic upgrades withour relying on an orchestrator or a cloud control plane. Nix was introduced in 2003 by [Eelco Dolstra](https://en.wikipedia.org/wiki/Nix_(package_manager)) to create a reliable system for software deployments. It ensures consistent package deployments through specification of package dependencies and build instructions. The supporting community has grown to nearly a thousand developers and has gathered several thousands of contributors. 

### Engineering Tools

A standard toolset in system engineering is an enabler for long term quality and maintainability of the infrastructure code. In the sandbox it is deployed using **[Home-manager](https://nix-community.github.io/home-manager/)**, a nix extension that configures user environments through the `home.nix` file. Home manager supports two ways of deploying applications, programs and the packages. For a develoment environment `programs` are the prefered method, it refers to modules that install the software and configure system wide features when applicable. The home manager [option search](https://home-manager-options.extranix.com/) provides an overview of available programs.
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

Referencing a application in the `home.packages` installs additional software packages. Nix packages are published in a [package directory](https://search.nixos.org/packages). The command `nix-env -qaP` lists packages incl. the available attributes at the command line. `Override` and `overrideAttrs` functions enable engineers to build packages from source by processing attributes like `src`, `buildInputs`, `makeFlags`, etc.. Some packages use overrides for fine-tuning like a [fonts package](https://search.nixos.org/packages?channel=unstable&show=nerdfonts&from=0&size=50&sort=relevance&type=packages&query=nerdfonts) that allows to adjust the default list of fonts. 


```ǹix
  home.packages = with pkgs; [
    devenv       # https://devenv.sh/
    gnumake      # https://www.gnu.org/software/make/manual/make.html
    # lunarvim   # https://www.lunarvim.org/
    # zed-editor # https://zed.dev/

    # Override example
    # (nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    (writeShellScriptBin "create_project" ''
      # capture the project name with a first argument
      PROJECT=$1

      # Check whether sync repo already exist
      if [ $(gh api repos/${gituser}/$PROJECT --silent --include 2>&1 | grep -Eo 'HTTP/[0-9\.]+ [0-9]{3}' | awk '{print $2}') -eq 200 ]; then
        echo "project $PROJECT already exists!"
      else
        # Create the new remote repository on GitHub
        gh repo create "${gituser}/$PROJECT" --private
  
        # Check if the repository was created successfully
        if [ $? -ne 0 ]; then
            echo "Failed to create the remote repository on GitHub."
            exit 1
        fi
  
        # create projects directory if it doesn't exist
        mkdir -p ${projectdir} && cd ${projectdir}
  
        # Clone the project repository with gh
        gh repo clone ${gituser}/$PROJECT
  
        # Verify the new remote setup
        cd ${projectdir}/$PROJECT && git remote -v
  
        echo "The $PROJECT repository has been created."
        echo "Remote repository: https://github.com/${gituser}/$PROJECT.git"
    fi
    '')
  ];
```

The package section also allows to enhance the shell with small scripts. E.g. a "project \<name\>" pulls the code from a project repository, which allows DevOps team to rely on the version control system for the onboarding of new members. It should be mentioned that there are alternatives to define a default set of tools and services in nix, e.g. [Flakey](https://github.com/lf-/flakey-profile), which provides less automation but more control.


### Platform Composition

The definition of the host system separated from the home configuration and stored in the [flake.nix](./flake.nix) file. This allows to run the same toolset accross various hardware platforms. Flakes are still classified as experimental feature, a respective flag is appended to `/etc/nix/nix.conf`. Separating configuration files enables system engineers to  provide purpose build systems accross multiple projects, employing the **[direnv](https://direnv.net/)** tool. It is a shell extension that loads and unloads software and configurations automatically, moving in and out a directory. System configurations and their dependencies are isolated on directory level and the composition can be shared through a version control system. This helps to overcome one of the main complexity driver for DevOps in an enterprise context. Fast iterations with divergent structures in application development and service operation often leads to massive workload for operators. While development teams are organized around solutions to focus on the delivery of business functionality, operation teams are organized around technologies with specialists managing systems. Hence, operators required for 24x7 operation have to join multiple SCRUM teams with little time left to fulfill their day to day tasks. Direnv allows operations enigneers to provide environments through configurations and relieves system specialists. Direnv to reads nix configurations referenced in the `.envrc` file, which stored stored together with the application code to trigger the provisioning process together with the application deployment. 

While for system related development projects [flake.nix](./flake.nix) file can be extended, in cloud projects the host system and the platform components should be separated. Instead engineers need the freedom determine the configuration together wiht a selection of system software components during the development phase. Nix supports multiple concepts of separating environment definitions, and direnv only requires a rerference to the configuration file in .envrc. 

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
