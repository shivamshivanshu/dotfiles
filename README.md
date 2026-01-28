### To install neovim from source
```bash
# clean any previous cache
make distclean

# Option 1: use the Makefile wrapper (simplest)
make CMAKE_BUILD_TYPE=Release \
     CMAKE_INSTALL_PREFIX="$HOME/.local" \
     CMAKE_EXTRA_FLAGS="-DUSE_BUNDLED=ON"

make install
```
