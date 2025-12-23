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
ARG CONT_XFORMERS_COMMIT_HASH_FULL
ARG CONT_SAGEATTN_COMMIT_HASH_FULL
ARG CONT_COMFYUI_COMMIT_HASH_FULL
ARG CONT_COMFYUI_COMMIT_VERSION
ARG CONT_USER
ARG CONT_GROUP

FROM nvidia/cuda:${CONT_CUDA_VER_MAJOR}.${CONT_CUDA_VER_MINOR}.${CONT_CUDA_VER_PATCH}-devel-ubuntu${CONT_UBUNTU_VER_MAJOR}.${CONT_UBUNTU_VER_MINOR} AS comfyui-build
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
ARG CONT_XFORMERS_COMMIT_HASH_FULL
ARG CONT_SAGEATTN_COMMIT_HASH_FULL
ARG CONT_COMFYUI_COMMIT_HASH_FULL

ENV CONT_CUDA_VER_MAJOR=${CONT_CUDA_VER_MAJOR}
ENV CONT_CUDA_VER_MINOR=${CONT_CUDA_VER_MINOR}
ENV CONT_TORCH_INDEX_PREFIX=${CONT_TORCH_INDEX_PREFIX}

RUN rm -f /etc/apt/apt.conf.d/docker-clean
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
     --mount=type=cache,target=/var/lib/apt,sharing=locked \
     apt-get update && \
     DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends software-properties-common && \
     add-apt-repository ppa:git-core/ppa && \
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
RUN git clone https://github.com/comfyanonymous/ComfyUI.git --revision=${CONT_COMFYUI_COMMIT_HASH_FULL} /opt/ComfyUI && \
     mkdir -p /opt/ComfyUI/models2 /opt/ComfyUI/user/default/workflows /home/${CONT_USER}/.config /home/${CONT_USER}/.local/bin
COPY --chown=${CONT_USER}:${CONT_GROUP} --chmod=550 install-dependencies.sh /opt/ComfyUI/install-dependencies.sh
RUN --mount=type=cache,target=/root/.cache/pip \
     python -m pip install -U pip wheel pybind11 && \
     python -m pip install --pre --index-url ${CONT_TORCH_INDEX_PREFIX}/cu${CONT_CUDA_VER_MAJOR}${CONT_CUDA_VER_MINOR} -U \
     setuptools \
     numpy \
     packaging \
     xformers \
     ${CONT_TORCH_VERSION_DEP_STRING} \
     "triton>=3.4.0" \
     && \
     python -m pip install --pre --index-url ${CONT_TORCH_INDEX_PREFIX}/cu${CONT_CUDA_VER_MAJOR}${CONT_CUDA_VER_MINOR} --no-build-isolation -U \
     #git+https://github.com/facebookresearch/xformers.git@${CONT_XFORMERS_COMMIT_HASH_FULL}#egg=xformers \
     git+https://github.com/woct0rdho/SageAttention.git@${CONT_SAGEATTN_COMMIT_HASH_FULL}#egg=SageAttention \
     && \
     # python -m pip install --pre -U pybind11 && \
     # python -m pip install --pre --index-url ${CONT_TORCH_INDEX_PREFIX}/cu${CONT_CUDA_VER_MAJOR}${CONT_CUDA_VER_MINOR} -U setuptools numpy packaging "triton>=3.4.0" "xformers==0.0.34.dev20251204+cu${CONT_CUDA_VER_MAJOR}${CONT_CUDA_VER_MINOR}" ${CONT_TORCH_VERSION_DEP_STRING} && \
     python -m pip uninstall -y ninja numpy packaging pybind11 && \
     /opt/ComfyUI/install-dependencies.sh /opt/ComfyUI && \
     rm -f /opt/ComfyUI/install-dependencies.sh

FROM nvidia/cuda:${CONT_CUDA_VER_MAJOR}.${CONT_CUDA_VER_MINOR}.${CONT_CUDA_VER_PATCH}-runtime-ubuntu${CONT_UBUNTU_VER_MAJOR}.${CONT_UBUNTU_VER_MINOR} AS comfyui
ARG CONT_CUDA_VER_MAJOR
ARG CONT_CUDA_VER_MINOR
ARG CONT_XFORMERS_COMMIT_HASH_FULL
ARG CONT_SAGEATTN_COMMIT_HASH_FULL
ARG CONT_COMFYUI_COMMIT_HASH_FULL
ARG CONT_COMFYUI_COMMIT_VERSION
ARG CONT_USER
ARG CONT_GROUP

ENV CONT_CUDA_VER_MAJOR=${CONT_CUDA_VER_MAJOR}
ENV CONT_CUDA_VER_MINOR=${CONT_CUDA_VER_MINOR}
ENV CONT_USER=${CONT_USER}
ENV CONT_GROUP=${CONT_GROUP}

RUN rm -f /etc/apt/apt.conf.d/docker-clean
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
     --mount=type=cache,target=/var/lib/apt,sharing=locked \
     apt-get update && \
     DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
     gosu \
     build-essential \
     python3 \
     python3-pip \
     python3-dev \
     python-is-python3 \
     libgl1 \
     libglx-mesa0 \
     libglib2.0-0 \
     fonts-dejavu-core \
     fontconfig && \
     apt-get clean && \
     rm -Rf /var/lib/apt/lists/*

COPY --from=comfyui-build --chown=${CONT_USER}:${CONT_GROUP} /home/${CONT_USER}/.local/bin /home/${CONT_USER}/.local/bin
COPY --from=comfyui-build --chown=${CONT_USER}:${CONT_GROUP} /home/${CONT_USER}/.config /home/${CONT_USER}/.config
COPY --from=comfyui-build --chown=${CONT_USER}:${CONT_GROUP} /opt/venv /opt/venv
COPY --from=comfyui-build --chown=${CONT_USER}:${CONT_GROUP} /opt/ComfyUI /opt/ComfyUI
WORKDIR /opt/ComfyUI
ENV CUDA_HOME=/usr/local/cuda-${CONT_CUDA_VER_MAJOR}.${CONT_CUDA_VER_MINOR}
ENV PATH=/home/${CONT_USER}/.local/bin:/opt/venv/bin:${CUDA_HOME}/bin:${PATH}
ENV LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${CUDA_HOME}/lib64
COPY --chown=${CONT_USER}:${CONT_GROUP} --chmod=440 torch_compile_optimization.py custom_nodes/torch_compile_optimization.py
COPY --chown=${CONT_USER}:${CONT_GROUP} --chmod=440 extra_model_paths.yaml extra_model_paths.yaml
COPY --chown=${CONT_USER}:${CONT_GROUP} --chmod=550 entrypoint.sh /opt/entrypoint.sh

LABEL org.opencontainers.image.title="ComfyUI" \
     org.opencontainers.image.description="A ComfyUI docker image." \     
     org.opencontainers.image.authors="Squirrelies" \
     org.opencontainers.image.url="https://github.com/Squirrelies/ComfyUI-Docker" \
     org.opencontainers.image.source="https://github.com/comfyanonymous/ComfyUI" \
     org.opencontainers.image.revision="${CONT_COMFYUI_COMMIT_HASH_FULL}" \
     org.opencontainers.image.version="${CONT_COMFYUI_COMMIT_VERSION}" \
     com.github.components.comfyanonymous.ComfyUI.source="https://github.com/comfyanonymous/ComfyUI" \
     com.github.components.comfyanonymous.ComfyUI.revision="${CONT_COMFYUI_COMMIT_HASH_FULL}" \
     com.github.components.comfyanonymous.ComfyUI.version="${CONT_COMFYUI_COMMIT_VERSION}" \
     com.github.components.woct0rdho.SageAttention.source="https://github.com/woct0rdho/SageAttention" \
     com.github.components.woct0rdho.SageAttention.revision="${CONT_SAGEATTN_COMMIT_HASH_FULL}"
#     com.github.components.facebookresearch.xformers.source="https://github.com/facebookresearch/xformers" \
#     com.github.components.facebookresearch.xformers.revision="${CONT_XFORMERS_COMMIT_HASH_FULL}"

USER root
EXPOSE 8188/tcp
VOLUME [ "/opt/ComfyUI/models", "/opt/ComfyUI/output", "/opt/ComfyUI/user/__manager", "/opt/ComfyUI/user/default", "/opt/ComfyUI/user/default/workflows" ]
ENTRYPOINT [ "/opt/entrypoint.sh" ]
CMD ["python", "main.py", "--listen", "0.0.0.0", "--base-directory", "/opt/ComfyUI"]
