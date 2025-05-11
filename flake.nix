{
	description = "OVH VPS";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
		system-manager = {
			url = "github:numtide/system-manager";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		pvemon = {
			url = "github:illustris/pvemon";
			inputs.nixpkgs.follows = "nixpkgs";
		};
		nix-install = {
			url = "github:danielrolls/nix-install";
			flake = false;
		};
	};

	outputs = { self, nixpkgs, system-manager, pvemon, ... }@args: let
		target = "machine-1.example.com";
	in {
		packages.x86_64-linux = let
			pkgs = nixpkgs.legacyPackages.x86_64-linux;
		in with nixpkgs.lib; {
			ansible-apply = pkgs.writeShellApplication {
				name = "ansible-apply";
				runtimeInputs = [ pkgs.ansible ];
				text = readFile (pkgs.replaceVars ./ansible/ansible.sh {
					inventory = pkgs.writeText "inventory.yml"
						(import ./ansible/inventory.nix {
							inherit target;
						});
					playbook = pkgs.writeText "playbook.yml"
						(import ./ansible/playbook.nix args);
				});
			};
		};

		systemConfigs.default = with nixpkgs.lib; (system-manager.lib.makeSystemConfig {
			modules = [({ pkgs, lib, ... }: {
				nixpkgs.hostPlatform = "x86_64-linux";
				system-manager.allowAnyDistro = true;
				environment.systemPackages = with pkgs; [
					htop
					tmux
					sysstat
				];

				systemd.services = {
					node-exporter = {
						serviceConfig = {
							Type = "simple";
							Restart = "on-failure";
						};
						script = concatStringsSep " " [
							(lib.getExe pkgs.prometheus-node-exporter)
							"--web.listen-address=127.0.0.1:9100"
						];
						wantedBy = [ "system-manager.target" ];
						unitConfig = {
							Description = "Prometheus Node Exporter";
							After = "network-online.target";
						};
					};
					pvemon = {
						serviceConfig = {
							Type = "simple";
							Restart = "on-failure";
						};
						script = "/bin/bash -lc '${lib.getExe pvemon.packages.${pkgs.system}.pvemon} --host 127.0.0.1'";
						wantedBy = [ "system-manager.target" ];
						unitConfig = {
							Description = "PVEmon";
							After = "network-online.target";
						};
					};
				};
			})];
		}).overrideAttrs (old: {
			meta = (old.meta or {}) // {
				mainProgram = "activate";
			};
		});
	};
}
