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


