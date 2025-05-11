{ self, nix-install, ... }: builtins.toJSON (map (x: x // { hosts = "all"; }) [
	{
		name = "install nix";
		vars.flakes = true;
		roles = [{ role = "${nix-install}"; }];
	}
	{
		name = "install nix-system";
		tasks = [
			{
				name = "copy flake";
				"ansible.builtin.copy" = {
					src = "${self}/";
					dest = "/opt/config-flake";
				};
			}
			{
				name = "activate system config";
				"ansible.builtin.shell" = ''
					bash -lc "nix run /opt/config-flake#systemConfigs.default"
				'';
				register = "system_result";
				changed_when = "'Activating' in system_result.stdout";
				failed_when = "system_result.rc != 0";
			}
		];
	}
])
