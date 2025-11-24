#!/usr/bin/env bash

set -e

CUI_DIR=$1
CN_DIR=${CUI_DIR}/custom_nodes

echo "↳ Installing ComfyUI and custom node dependencies in $CUI_DIR..."

declare -A REPOS=(
  ["comfyui-manager"]="https://github.com/ltdrdata/ComfyUI-Manager.git"
  ["rgthree-comfy"]="https://github.com/rgthree/rgthree-comfy.git"
  ["comfyui-kjnodes"]="https://github.com/kijai/ComfyUI-KJNodes.git"
  ["wanblockswap"]="https://github.com/orssorbit/ComfyUI-wanBlockswap.git"
  ["cg-use-everywhere"]="https://github.com/chrisgoringe/cg-use-everywhere.git"
  ["comfyui-custom-scripts"]="https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git"
  ["ComfyUI-GGUF"]="https://github.com/city96/ComfyUI-GGUF.git"
  ["comfyui-impact-subpack"]="https://github.com/ltdrdata/ComfyUI-Impact-Subpack.git"
  ["comfyui-mxtoolkit"]="https://github.com/Smirnov75/ComfyUI-mxToolkit.git"
  ["ComfyUI-WanMoeKSampler"]="https://github.com/stduhpf/ComfyUI-WanMoeKSampler.git"
  ["crt-nodes"]="https://github.com/plugcrypt/CRT-Nodes.git"
)

echo "↳ Initializing custom_nodes…"
mkdir -p "$CN_DIR"
for name in "${!REPOS[@]}"; do
  url="${REPOS[$name]}"
  target="$CN_DIR/$name"
  echo "  ↳ Cloning $name"
  git clone --depth 1 "$url" "$target"
done

echo "↳ Installing/upgrading dependencies…"
req="-r ${CUI_DIR}/requirements.txt "
for dir in "$CN_DIR"/*/; do
  if [ -f "${dir}requirements.txt" ]; then
    req+="-r ${dir}requirements.txt "
  fi
done
echo "  ↳ python -m pip install --pre --index-url ${CONT_TORCH_INDEX_PREFIX}/cu${CONT_CUDA_VER_MAJOR}${CONT_CUDA_VER_MINOR} --extra-index-url https://pypi.org/simple -U $req"
python -m pip install --pre --index-url ${CONT_TORCH_INDEX_PREFIX}/cu${CONT_CUDA_VER_MAJOR}${CONT_CUDA_VER_MINOR} --extra-index-url https://pypi.org/simple -U $req
