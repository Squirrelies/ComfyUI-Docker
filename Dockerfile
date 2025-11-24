# syntax=docker/dockerfile:1

ARG CONT_UBUNTU_VER_MAJOR=0
ARG CONT_UBUNTU_VER_MINOR=0
ARG CONT_CUDA_VER_MAJOR=0
ARG CONT_CUDA_VER_MINOR=0
ARG CONT_CUDA_VER_PATCH=0
ARG CONT_TORCH_VER_MAJOR
ARG CONT_TORCH_VER_MINOR
ARG CONT_TORCH_VER_PATCH
ARG CONT_TORCH_INDEX_PREFIX
ARG CONT_TORCH_VERSION_DEP_STRING
ARG TORCH_CUDA_ARCH_LIST
ARG CONT_USER
ARG CONT_GROUP

FROM nvidia/cuda:${CONT_CUDA_VER_MAJOR}.${CONT_CUDA_VER_MINOR}.${CONT_CUDA_VER_PATCH}-devel-ubuntu${CONT_UBUNTU_VER_MAJOR}.${CONT_UBUNTU_VER_MINOR} AS comfyui-sage
ARG CONT_USER
ARG CONT_GROUP
ARG CONT_CUDA_VER_MAJOR
ARG CONT_CUDA_VER_MINOR
ARG CONT_TORCH_VER_MAJOR
ARG CONT_TORCH_VER_MINOR
ARG CONT_TORCH_VER_PATCH
ARG CONT_TORCH_INDEX_PREFIX
ARG CONT_TORCH_VERSION_DEP_STRING
ARG TORCH_CUDA_ARCH_LIST

RUN rm -f /etc/apt/apt.conf.d/docker-clean
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
     --mount=type=cache,target=/var/lib/apt,sharing=locked \
     apt-get update && \
     DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
     build-essential \
     git \
     python3 \
     python3-pip \
     python3-venv \
     python3-dev \
     python-is-python3 && \
     apt-get clean && \
     rm -Rf /var/lib/apt/lists/*

RUN --mount=type=cache,target=/root/.cache/pip \
     python -m venv /opt/venv

ENV CUDA_HOME=/usr/local/cuda-${CONT_CUDA_VER_MAJOR}.${CONT_CUDA_VER_MINOR}
ENV PATH=/opt/venv/bin:${PATH}:${CUDA_HOME}/bin
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${CUDA_HOME}/lib64

WORKDIR /opt
RUN --mount=type=cache,target=/root/.cache/pip \
     python -m pip install --pre -U pip setuptools wheel && \
     python -m pip install --pre --index-url ${CONT_TORCH_INDEX_PREFIX}/cu${CONT_CUDA_VER_MAJOR}${CONT_CUDA_VER_MINOR} --extra-index-url https://pypi.org/simple -U numpy packaging pybind11 ${CONT_TORCH_VERSION_DEP_STRING} "triton>=3.4.0" && \
     python -m pip install --no-build-isolation -U git+https://github.com/facebookresearch/xformers.git@main#egg=xformers && \
     python -m pip install --no-build-isolation -U git+https://github.com/woct0rdho/SageAttention.git@main#egg=SageAttention && \
     python -m pip uninstall -y ninja numpy packaging pybind11

FROM nvidia/cuda:${CONT_CUDA_VER_MAJOR}.${CONT_CUDA_VER_MINOR}.${CONT_CUDA_VER_PATCH}-devel-ubuntu${CONT_UBUNTU_VER_MAJOR}.${CONT_UBUNTU_VER_MINOR} AS comfyui-app
ARG CONT_USER
ARG CONT_GROUP
ARG CONT_CUDA_VER_MAJOR
ARG CONT_CUDA_VER_MINOR
ARG CONT_TORCH_INDEX_PREFIX

ENV CONT_CUDA_VER_MAJOR=${CONT_CUDA_VER_MAJOR}
ENV CONT_CUDA_VER_MINOR=${CONT_CUDA_VER_MINOR}
ENV CONT_TORCH_INDEX_PREFIX=${CONT_TORCH_INDEX_PREFIX}
RUN rm -f /etc/apt/apt.conf.d/docker-clean
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
     --mount=type=cache,target=/var/lib/apt,sharing=locked \
     apt-get update && \
     DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
     git \
     python3 \
     python3-pip \
     python3-venv \
     python3-dev \
     python-is-python3 && \
     apt-get clean && \
     rm -Rf /var/lib/apt/lists/*

COPY --from=comfyui-sage --chown=${CONT_USER}:${CONT_GROUP} /opt /opt
WORKDIR /opt/ComfyUI
ENV PATH=/opt/venv/bin:${PATH}
RUN git clone https://github.com/comfyanonymous/ComfyUI.git .
COPY --chown=${CONT_USER}:${CONT_GROUP} --chmod=550 install-dependencies.sh install-dependencies.sh
RUN --mount=type=cache,target=/root/.cache/pip \
     ./install-dependencies.sh /opt/ComfyUI && \
     rm -f install-dependencies.sh
RUN mkdir -p user/default/workflows /home/${CONT_USER}/.config /home/${CONT_USER}/.local/bin

FROM nvidia/cuda:${CONT_CUDA_VER_MAJOR}.${CONT_CUDA_VER_MINOR}.${CONT_CUDA_VER_PATCH}-devel-ubuntu${CONT_UBUNTU_VER_MAJOR}.${CONT_UBUNTU_VER_MINOR} AS comfyui
ARG CONT_USER
ARG CONT_GROUP
ARG CONT_CUDA_VER_MAJOR
ARG CONT_CUDA_VER_MINOR

ENV CONT_USER=${CONT_USER}
ENV CONT_GROUP=${CONT_GROUP}
ENV CONT_CUDA_VER_MAJOR=${CONT_CUDA_VER_MAJOR}
ENV CONT_CUDA_VER_MINOR=${CONT_CUDA_VER_MINOR}
RUN rm -f /etc/apt/apt.conf.d/docker-clean
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
     --mount=type=cache,target=/var/lib/apt,sharing=locked \
     apt-get update && \
     DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
     gosu \
     build-essential \
     git \
     python3 \
     python3-pip \
     python3-venv \
     python3-dev \
     python-is-python3 \
     libgl1 \
     libglx-mesa0 \
     libglib2.0-0 \
     fonts-dejavu-core \
     fontconfig \
     iptables \
     iproute2 \
     iputils-ping && \
     apt-get clean && \
     rm -Rf /var/lib/apt/lists/*

COPY --from=comfyui-app --chown=${CONT_USER}:${CONT_GROUP} /home/${CONT_USER}/.local/bin /home/${CONT_USER}/.local/bin
COPY --from=comfyui-app --chown=${CONT_USER}:${CONT_GROUP} /home/${CONT_USER}/.config /home/${CONT_USER}/.config
COPY --from=comfyui-app --chown=${CONT_USER}:${CONT_GROUP} /opt /opt
WORKDIR /opt/ComfyUI
ENV PATH=/home/${CONT_USER}/.local/bin:/opt/venv/bin:${PATH}
COPY --chown=${CONT_USER}:${CONT_GROUP} --chmod=440 torch_compile_optimization.py custom_nodes/torch_compile_optimization.py
COPY --chown=${CONT_USER}:${CONT_GROUP} --chmod=440 extra_model_paths.yaml extra_model_paths.yaml
COPY --chown=${CONT_USER}:${CONT_GROUP} --chmod=550 entrypoint.sh /opt/entrypoint.sh

USER root
EXPOSE 8188/tcp
VOLUME [ "/opt/ComfyUI/models", "/opt/ComfyUI/output", "/opt/ComfyUI/user/default", "/opt/ComfyUI/user/default/workflows" ]
ENTRYPOINT [ "/opt/entrypoint.sh" ]
CMD ["python", "main.py", "--listen", "0.0.0.0", "--base-directory", "/opt/ComfyUI"]
