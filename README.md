# Workshop Phase 0


## Steps

1. Create the repo in GitHub
   1. Name: hook2026
   2. Visibility: Public
   3. README.md: True
   4. License: MIT
2. Clone the Repo
3. Edit License to include your name in the (c) = ©
4. Create the file system structure with the following empty files

```
project-root/
│
├── .devcontainer/              # VS Code Dev Container configuration
│   ├── devcontainer.json       # Dev container settings
│   └── Dockerfile              # Container build instructions
│
├── include/                    # Header files
│   └── buffer.h
│
├── src/                        # Source files
│   ├── buffer.cpp
│   └── main.cpp
│
├── makefile                    # Build configuration
├── .gitignore                  # Git ignored files
├── README.md                   # Project documentation
└── LICENSE                     # License file


```

The following sequence of commands executed at the command line with the repo's directory achieves this structure:
```bash
mkdir -p .devcontainer include src
touch makefile include/buffer.h src/main.cpp src/buffer.cpp 
touch .devcontainer/Dockerfile .devcontainer/devcontainer.json
```

:pushpin: `TAG step-00-01-structure`

At the end it should look like this:

![alt text](images/file-structure.png)

5. Write the following code on `.devcontainer/devcontainer.json`:
```json
{
  "name": "UNITEC C++ Workshop",
  "build": {
    "dockerfile": "Dockerfile"
  },
  "customizations": {
    "vscode": {
      "settings": {
        "terminal.integrated.defaultProfile.linux": "bash",
        "C_Cpp.default.compilerPath": "/usr/bin/g++"
      },
      "extensions": [
        "ms-vscode.cpptools",
        "ms-vscode.cmake-tools",
        "ms-azuretools.vscode-docker"
      ]
    }
  },
  "remoteUser": "vscode",
  "postCreateCommand": "make doctor || true"
}
```

6. Write the following code on `.devcontainer/Dockerfile`:
```dockerfile
FROM mcr.microsoft.com/devcontainers/base:ubuntu
# Why not ubuntu:latest? Because the devcontainer base image has some optimizations and tools pre-installed that are useful for development.

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    clang \
    gdb \
    llvm \
    libclang-rt-18-dev \
    valgrind \
    make \
    git \
    vim \
    curl \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Optional but nice: install GitHub CLI (gh)
RUN type -p curl >/dev/null || (apt-get update && apt-get install -y curl) \
 && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
 && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list \
 && apt-get update \
 && apt-get install -y gh \
 && apt-get clean && rm -rf /var/lib/apt/lists/*
```

:pushpin: `TAG step-00-02-configuration-files`

7. Add the following code to the `makefile`:
```makefile
CXX_GNU := g++
CXX_CLANG := clang++

CXXFLAGS := -std=c++20 -g -O0 -Wall -Wextra -pedantic -Iinclude
SANFLAGS  := -fsanitize=address,undefined -fno-omit-frame-pointer

LDFLAGS  :=

SRC := src/main.cpp src/buffer.cpp
BIN := hook
HOOK_ASAN := hook_asan

.PHONY: all run clean asan run-asan valgrind doctor

all: $(BIN)

$(BIN): $(SRC)
	$(CXX_GNU) $(CXXFLAGS) $(SRC) -o $(BIN) $(LDFLAGS)

run: $(BIN)
	./$(BIN)

# Build the asan binary as an actual file target
$(HOOK_ASAN): $(SRC)
	$(CXX_CLANG) $(CXXFLAGS) $(SANFLAGS) $(SRC) -o $(HOOK_ASAN)

asan: $(HOOK_ASAN)

run-asan: $(HOOK_ASAN)
	ASAN_SYMBOLIZER_PATH=$$(which llvm-symbolizer) \
	ASAN_OPTIONS=symbolize=1 \
	./$(HOOK_ASAN)


valgrind: $(BIN)
	valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes ./$(BIN)

doctor:
	@echo "== Toolchain doctor =="
	@echo "--- g++"; g++ --version | head -n 1
	@echo "--- clang++"; clang++ --version | head -n 1
	@echo "--- make"; make --version | head -n 1
	@echo "--- valgrind"; valgrind --version | head -n 1
	@echo "--- gdb"; gdb --version | head -n 1
	@echo "--- git"; git --version
	@echo "--- gh (optional)"; (gh --version | head -n 1) || echo "gh not installed"

clean:
	rm -f $(BIN) $(HOOK_ASAN)
```
8. Write the following code in their respective files:

`**include/buffer.h**`
```c++
#pragma once
#include <cstddef>
#include <iostream>

class Buffer {
public:
    explicit Buffer(std::size_t n);
    // Intentionally broken for the hook:
    // - no destructor
    // - no copy ctor
    // - no copy assignment
    // - no move operations
    void WriteFirst(int value);
    int  ReadFirst() const;
    void ExplodeForDemo();
private:
    std::size_t _n{0};
    int* _data{nullptr};
};
```
`**src/buffer.cpp**`
```c++
#include "buffer.h"
#include <iostream>

Buffer::Buffer(std::size_t n) : _n(n), _data(new int[n]) {
    for (std::size_t i = 0; i < _n; ++i) _data[i] = 0;
}

void Buffer::WriteFirst(int value) {
    _data[0] = value;
}

int Buffer::ReadFirst() const {
    return _data[0];
}

void Buffer::ExplodeForDemo() {
    delete[] _data;
    _data = nullptr;    
}


```
`**src/main.cpph**`
```c++
#include "buffer.h"
#include <iostream>

// Part 0 hook: guaranteed badness.
// This will shallow-copy the pointer. We'll manually delete in both objects
// to force a double-free (ASan will scream).
int main() {
    Buffer a(4);
    a.WriteFirst(42);

    Buffer b = a; // shallow copy of _data pointer (compiler-generated copy)

    a.ExplodeForDemo();
    b.ExplodeForDemo(); // double free: same pointer

    // Force the "certain crash" demonstration:
    // two deletes on the same pointer.
    // (Yes, it's intentionally evil for the hook.)
    std::cout << "a.first=" << a.ReadFirst() << "\n";
    std::cout << "b.first=" << b.ReadFirst() << "\n";

    // Manual delete hack (only for hook demo)
    // We can't access _data directly (private), so we simulate the effect by
    // adding a method in the next step if you prefer.
    std::cout << "Hook ready. Now run with ASan (make run-asan).\n";
    return 0;
}
```
:pushpin: `TAG step-00-03-source-code`
