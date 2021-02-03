$ScriptDir = Split-Path $MyInvocation.MyCommand.Source -Parent -Resolve
$SrcDir = Join-Path $ScriptDir "src"
$BuildDir = Join-Path $ScriptDir "build"
$InstallDir = Join-Path $ScriptDir "install"
$Url = "https://github.com/llvm/llvm-project.git"
$Branch = "origin/release/11.x"
$CMakeArgs = @(
    "-D", "LLVM_ENABLE_PROJECTS=clang",
    "-D", "CMAKE_INSTALL_PREFIX=`"$InstallDir`"",
    "$SrcDir\llvm"
)

if (-not (Test-Path $SrcDir -PathType Container)) {
    git clone $Url $SrcDir
} else {
    git -C $SrcDir fetch
}

git -C $SrcDir checkout $Branch

if (-not (Test-Path $BuildDir -PathType Container)) {
    New-Item $BuildDir -ItemType Directory
} else {
    Remove-Item "$BuildDir\*" -Recurse
}

if (-not (Test-Path $InstallDir -PathType Container)) {
    New-Item $InstallDir -ItemType Directory
} else {
    Remove-Item "$InstallDir\*" -Recurse
}

Push-Location $BuildDir

cmake -G"Visual Studio 16 2019" -T"ClangCL,host=x64" -A"x64" @CMakeArgs

cmake --build . --config Release -- /p:CL_MPCount=16 /m:8

cmake --install . --config Release

Pop-Location

Write-Output "Done!"
