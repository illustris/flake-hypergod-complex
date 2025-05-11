{ target, ... }: builtins.toJSON {
	all.hosts.${target}.ansible_user = "root";
}
