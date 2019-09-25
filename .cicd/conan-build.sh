#!/bin/bash
set -eo pipefail

if [[ $IMAGE_TAG == 'amazon_linux-2-unpinned' ]]; then
    yum update -y
    yum install -y python3 python3-devel clang llvm-devel llvm-static git curl tar gzip automake make
CMAKE_EXTRAS="-DCMAKE_BUILD_TYPE='Release' -DCORE_SYMBOL_NAME='SYS' -DPKG_CONFIG_USE_CMAKE_PREFIX_PATH=ON -DCMAKE_CXX_COMPILER='clang++' -DCMAKE_C_COMPILER='clang' -DUSE_CONAN=true"
elif [[ $IMAGE_TAG == 'centos-7.6-unpinned' ]]; then
    yum update -y
    yum install -y epel-release && yum --enablerepo=extras install -y centos-release-scl && yum --enablerepo=extras install -y devtoolset-8
    yum install -y rh-python36 llvm-7.0-devel llvm-7.0-static git curl automake
    source /opt/rh/devtoolset-8/enable && source /opt/rh/rh-python36/enable
    CMAKE_EXTRAS="-DCMAKE_BUILD_TYPE='Release' -DCORE_SYMBOL_NAME='SYS' -DPKG_CONFIG_USE_CMAKE_PREFIX_PATH=ON -DLLVM_DIR='/usr/lib64/llvm7.0/lib/cmake/llvm' -DUSE_CONAN=true"
elif [[ $IMAGE_TAG == 'ubuntu-18.04-unpinned' ]]; then
    apt-get update && apt-get upgrade -y
    apt-get install -y python3 python3-dev python3-pip clang llvm-7-dev git curl automake
    CMAKE_EXTRAS="-DCMAKE_BUILD_TYPE='Release' -DCORE_SYMBOL_NAME='SYS' -DPKG_CONFIG_USE_CMAKE_PREFIX_PATH=ON -DCMAKE_CXX_COMPILER='clang++' -DCMAKE_C_COMPILER='clang' -DLLVM_DIR='/usr/lib/llvm-7/lib/cmake/llvm' -DUSE_CONAN=true"
fi
pip3 install conan
curl -LO https://github.com/Kitware/CMake/releases/download/v3.15.3/cmake-3.15.3-Linux-x86_64.sh
chmod +x cmake-3.15.3-Linux-x86_64.sh
mkdir /cmake && ./cmake-3.15.3-Linux-x86_64.sh --skip-license --prefix=/cmake
export PATH=$PATH:/cmake/bin
cd /workdir/build
cmake $CMAKE_EXTRAS ..
make -j$(getconf _NPROCESSORS_ONLN)
mv ~/.conan /workdir/conan