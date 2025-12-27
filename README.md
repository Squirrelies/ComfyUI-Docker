# ComfyUI Docker

A Docker container setup for ComfyUI. This was tested and designed to run on a Windows host with WSL2 but technically, with some small modifications, could be ran on a Linux host.

## Prerequisites

* Docker w/ WSL2 integration.
* WSL2.
* Nvidia Container Toolkit installed within your WSL2 distro. Instructions to install: <https://docs.nvidia.com/cuda/cuda-installation-guide-linux/#wsl-installation-prepare>.

## Customization

You can edit the `install-dependencies.sh` file prior to building the image if you wish to add custom nodes.
Cuda, distro, and Torch versions are controlled by values in the `.env` file.

## Building

If this is your first time building this, you'll want to run `prerequisites.ps1` as that will setup the docker networks for these containers.
Create a copy of `.env-sample` and rename to `.env`.
Minimally, you'll want to edit the `.env` file to adjust `TORCH_CUDA_ARCH_LIST` to match your GPU's architecture version.
Run the `build.ps1` PowerShell script.
This builds the image, and then creates the containers.
This may take a while.

## Changing command-line parameters/arguments for ComfyUI

You may change the command-line parameters/arguments via the `docker-compose.yml` file's `services`->`comfyui`->`command` array. This ensures that the arguments are applied not to the image but to the container that references the image allowing you to change these arguments without having to rebuild the image.

If you have already ran the build steps above to build the image, just run the `recompose.ps1` script which will tear down the container and recreate it using the already built image but with the adjustments made to the `docker-compose.yml` file.

## Starting

Start the container group in Docker, then navigate to <http://127.0.0.1:8188/> and begin using ComfyUI.
