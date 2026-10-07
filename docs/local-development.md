# Local development

Use this when changing the kit itself instead of using the published GHCR kit.

## Build and validate

```bash
docker build --pull --no-cache -t ghcr.io/rocknitive/pi-kit-image:latest .
sbx kit validate .
```

The local image tag must match `sandbox.image` in `spec.yaml`.

The build resolves the latest Pi and OpenSpec releases, installs `pi-docparser`,
`pdftotext`, and LibreOffice, and installs stable Rust with `rustfmt` and `clippy`.
Existing sandboxes must be stopped and recreated to use a rebuilt image.

## Run a local checkout

From the kit repo, pass the workspace explicitly:

```bash
sbx run . /path/to/project
```

Or clone the kit to a stable path and run it from project directories:

```bash
mkdir -p ~/.config/docker-sbx
git clone git@github.com:rocknitive/pi-kit.git ~/.config/docker-sbx/pi-kit
cd ~/.config/docker-sbx/pi-kit
docker build -t ghcr.io/rocknitive/pi-kit-image:latest .
sbx kit validate .

cd /path/to/project
sbx run ~/.config/docker-sbx/pi-kit
```

## Optional development helper

If you want one shell command that can switch between the published kit and a local checkout, use an environment override.

```zsh
sbx-pi-dev() {
  sbx run "${SBX_PI_KIT:-ghcr.io/rocknitive/pi-kit:latest}"
}
```

```fish
function sbx-pi-dev
    set -l kit "ghcr.io/rocknitive/pi-kit:latest"
    if set -q SBX_PI_KIT
        set kit "$SBX_PI_KIT"
    end
    sbx run "$kit"
end
```

Then point it at a local checkout:

```bash
export SBX_PI_KIT=$HOME/.config/docker-sbx/pi-kit
sbx-pi-dev
```

Unset it to return to the published kit:

```bash
unset SBX_PI_KIT
```
