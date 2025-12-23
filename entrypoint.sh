#!/usr/bin/env bash
set -euo pipefail

### Run commands as root before handing off execution to the non-root user.
# Ensure libcuda.so is available for Triton / SageAttention at runtime
fix_libcuda_symlinks() {
  # WSL driver path (injected at runtime)
  if [ -d /usr/lib/wsl/drivers ]; then
    for d in /usr/lib/wsl/drivers/*; do
      if [ -f "$d/libcuda.so.1" ] && [ ! -f "$d/libcuda.so" ]; then
        ln -s "$d/libcuda.so.1" "$d/libcuda.so" || true
      fi
    done
  fi

  # CUDA compat path inside the container
  if [ -d /usr/local/cuda-13.0/compat ]; then
    if [ -f /usr/local/cuda-13.0/compat/libcuda.so.1 ] && \
       [ ! -f /usr/lib/x86_64-linux-gnu/libcuda.so ]; then
      mkdir -p /usr/lib/x86_64-linux-gnu
      ln -s /usr/local/cuda-13.0/compat/libcuda.so.1 \
            /usr/lib/x86_64-linux-gnu/libcuda.so || true
    fi
  fi
}

fix_libcuda_symlinks

# Hand off to the main process defined by CMD
exec gosu ${CONT_USER} "$@"
