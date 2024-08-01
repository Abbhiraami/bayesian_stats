#!/bin/sh



# KERNEL_NAME-"jax_kernel" # name that will be given to kernel
# REQ_TEXT="requirements.txt"

echo "This script will configure/re-configure a virtual +JH kernel given <requirements.txt>"
read -p "Specify name of the environment/kernel to be created (e.g. bespoke_kernel):" KERNEL_NAME
read -p "Specify name of the requirements file (e.g. requirements.txt): " -e REQ_TEXT

set -u
set -x
set -e

# remove the previous kernel from jupyter
if $(jupyter kernelspec list | awk 'NR>1 {print $1}'| grep -q ${KERNEL_NAME}); then scho 'y' | jupyter kernelspec uninstall
${KERNEL_NAME}; fi

HOME=$(dirname $(realpath "$0"))
# create directories
VENV_DIR="${HOME}/.venv"
ENV_DIR="${VENV_DIR}/envs"
CUR_VENV_DIR="${ENVS_DIR}/${KERNEL_NAME}"
#
if [ ! -d "${VENV_DIR}" ]; then mkdir "${VENV_DIR}"; fi
if [ ! -d "${ENVS_DIR}" ]; then mkdir "${ENVS_DIR}"; fi
if [ -d "${CUR_VENV_DIR}" ]; then rm -rf "${CUR_VENV_DIR}"; fi

# set up virtual environment
pip install virtualenv
virtualenv "${CUR_VENV_DIR}"
source "${CUR_VENV_DIR}/bin/activate"

# there are somelocal python packages that cannot be installed using
# pip so if we try to pip install into venv them we get error message 
# despite having them in the image. therefore we will simply copy them 
to_copy_dist_package_prefixes=("six" "ipykernel")
GLOBAL_PYTHON_LAB=/Users/SHAMBHAVVISEN
LOCAL_PYTHON_LIB=${CUR_VENV_DIR}/lib/python3.7/site-packages
#
for prefix in "${to_copy_dist_package_prefixes[@]}"; do
    cp -r ${GLOBAL_PYTHON_LAB}/${prefix}* ${LOCAL_PYTHON_LIB}
done

# flag python version
echo "Current python version is $(python --version)"

## install the kernel to jupyter
pip install ipykernel
ipython kernel install --user --name ${KERNEL_NAME} --display-name ${KERNEL_NAME}

# insatll requirements
pip install -r ${REQ_TXT}
