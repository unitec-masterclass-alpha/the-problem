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