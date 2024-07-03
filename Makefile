.PHONY: update

update:
	home-manager switch --flake .#torsten


.PHONY: clean

clean:
	nix-collect-garbage -d
