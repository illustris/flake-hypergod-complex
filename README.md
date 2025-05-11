# Nix all the things: Flake Hypergod Complex

Demo code for the blog series "Nix all the things" which explores using Nix as a replacement for traditional DevOps tools.

## What's in this repo?

This repository contains the code for Part 1 of the series, which demonstrates how to use Nix to replace and enhance Ansible workflows:

- **Using Nix to generate Ansible configurations** - Replace YAML with more powerful Nix expressions
- **Reproducible deployment scripts** - Leveraging flakes for consistent dependencies
- **System-manager integration** - Declaratively manage services and packages on non-NixOS systems

The repository includes:
- A complete Nix flake setup with pinned dependencies
- Ansible inventory and playbook generation via Nix
- System-manager configuration for deploying services

## Usage

Run the Ansible deployment with:

```bash
nix run .#ansible-apply
```

The target host is defined in `flake.nix` at line 21:
```nix
target = "machine-1.example.com";
```
Change this value to point to your own server before deployment.

## Blog Post

For a detailed explanation of the code and concepts in this repository, read the accompanying blog post:

[Nix all the things (part 1): Ansible](https://illustris.tech/posts/nix-all-the-things-pt1/)

## License

[MIT](LICENSE)
