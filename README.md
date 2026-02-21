# Workshop Phase 0


## Steps

1. Create the repo in GitHub
   1. Name: hook2026
   2. Visibility: Public
   3. README.md: True
   4. License: MIT
2. Clone the Repo
3. Edit License to include your name in the (c)= ©
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

