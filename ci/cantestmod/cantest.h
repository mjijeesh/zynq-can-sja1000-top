#pragma once

#if __has_include(<optional>)
# include <optional>
#elif __has_include(<experimental/optional>)
# include <experimental/optional>
namespace std {
    using std::experimental::optional;
}
#else
# error No implementation of std::optional. Upgrade your compiler.
#endif

//#include <variant>
#include <string>
#include <linux/can.h>

#include <exception>

/*
    - open socket
    - close socket
    - receive message (with control info)
    - send message(fd, msg, time=None)
    -
*/

struct received_frame {
    struct canfd_frame frame;
    bool is_fd;
    std::optional<uint64_t> ts_kern;
};

struct error : std::exception {
    int errn; // fucking macros - cannot use errno
    std::string msg;
    error(int errn, std::string prefix) {
        msg = std::move(prefix);
        msg += ": ";
        msg += strerror(errn);
    }
    const char *what() const noexcept override {
        return msg.c_str();
    }
};

static inline int sock_get_if_index(int s, const char *if_name);
received_frame receive(int s);
int can_open(const char *ifc);
