#include <iostream>
#include <openblas_config.h>
#include <cblas.h>

int main() {
    std::cout
        << OPENBLAS_VERSION << " "
        << openblas_get_config() << " "
        << openblas_get_parallel()
        << std::endl;
    return 0;
}
