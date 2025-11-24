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

Create a copy of `.env-sample` and rename to `.env`.
Minimally, you'll want to edit the `.env` file to adjust `TORCH_CUDA_ARCH_LIST` to match your GPU's architecture version.
Run the `build.bat` script.
This builds the image, and then creates the containers.
This may take a while. It takes approximately 45 minutes on my machine.

## Starting

Start the container group in Docker, then navigate to <http://127.0.0.1:8188/> and begin using ComfyUI.
