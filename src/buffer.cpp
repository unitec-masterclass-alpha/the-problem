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

