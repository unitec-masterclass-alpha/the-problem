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