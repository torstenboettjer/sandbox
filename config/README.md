# User Profiles

User profiles are represented by nix modules, e.g. */profiles/default.nix*, this is where common applications, aliases, and terminal configurations are defined. Creating a new profile:

1. **Fill out Profiles:** Duplicate profiles/default.nix into profiles/newprofile.nix and add the packages and configurations specific to the role. Example: In analyst.nix, you might add pkgs.r-project and pkgs.jupyter to home.packages.

2. **Activate the User Flake:** Activate your user profile by running the configuration name like `<username>-<profileName>`

```sh
home-manager switch --flake ~/.config#torsten-default
```

3. **Use in Dev Shells:** The homeManagerModules.default output is imported directly into the Environment Flakes to get all these shared tools inside project-specific shells!
