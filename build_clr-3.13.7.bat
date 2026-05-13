@echo off
setlocal

call "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Auxiliary\Build\vcvarsall.bat" x64

echo "====================================================="
echo "venv: C:\Develop\.venv-3.13.7\Scripts\activate"
call C:\Develop\.venv-3.13.7\Scripts\activate
echo "====================================================="

set ROCM_PATH=C:/Develop/.venv-3.13.7/Lib/site-packages/_rocm_sdk_devel
set WINSDK_BIN=C:\Program Files (x86)\Windows Kits\10\bin\10.0.22621.0\x64
set PATH=%ROCM_PATH%/bin;%WINSDK_BIN%;%PATH%
set HIP_CLANG_PATH=%ROCM_PATH%/lib/llvm/bin/
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:\=/%"
set HIP_DIR=%SCRIPT_DIR%projects/hip
set CLR_DIR=%SCRIPT_DIR%projects/clr
set HIPCC_BIN_DIR=%ROCM_PATH%/bin/
set CLR_BUILD=%SCRIPT_DIR%projects/clr/build

echo Cleaning build directory...
if exist "%CLR_BUILD%" rmdir /s /q "%CLR_BUILD%"
mkdir "%CLR_BUILD%" 2>nul
cd /d "%CLR_BUILD%"

echo Running CMake with Ninja + clang-cl...
cmake .. -G Ninja ^
    -DCMAKE_C_COMPILER=%ROCM_PATH%/lib/llvm/bin/clang-cl.exe ^
    -DCMAKE_CXX_COMPILER=%ROCM_PATH%/lib/llvm/bin/clang-cl.exe ^
    -DHIP_PLATFORM=amd ^
    -DHIP_COMMON_DIR=%HIP_DIR% ^
    -DCLR_BUILD_HIP=ON ^
    -DHIPCC_BIN_DIR=%ROCM_PATH%/bin ^
    -DUSE_PROF_API=OFF ^
    -D__HIP_ENABLE_PCH=OFF ^
    -DROCCLR_ENABLE_PAL=1 ^
    -DROCCLR_ENABLE_HSA=0 ^
    -DAMD_COMPUTE_WIN=C:/Develop/ROCm/rocm-systems/shared/amdgpu-windows-interop ^
    -DLLVM_BIN=%ROCM_PATH%/lib/llvm/bin ^
    -DClang_BIN=%ROCM_PATH%/lib/llvm/bin ^
    -DPKG_CONFIG_EXECUTABLE=C:/Users/AMD/AppData/Local/Programs/Python/Python313/Scripts/pkg-config.exe ^
    -DCMAKE_CXX_FLAGS="-Wno-narrowing" ^
    -DSIMDE_INCLUDE_DIR=C:/Develop/simde ^
    -DCMAKE_INSTALL_PREFIX=C:/opt/rocm-clr ^
    -DCMAKE_BUILD_TYPE=Release

cmake --build . --target all --config Release && cmake --install . --config Release

echo.
echo CMake finished with exit code: %ERRORLEVEL%
endlocal
