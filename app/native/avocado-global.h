#ifndef AVOCADO_GLOBAL_H
#define AVOCADO_GLOBAL_H

#include <stddef.h>
#include <stdexcept>

/**
 * @addtogroup Global
 * @{
 */

/** Macro to clean up dead code to keep warnings down about unused parameters. */
#define AVOCADO_UNUSED(__var) (void)(__var)

/** Stack frame alignment madness for bunk GCC versions on Windows. See
 *  <http://stackoverflow.com/questions/2386408/qt-gcc-sse-and-stack-alignment>.
 */
#if defined(_WIN32)
#  define AVOCADO_ENSURE_STACK_ALIGNED_FOR_SSE __attribute__ ((force_align_arg_pointer))
#else
#  define AVOCADO_ENSURE_STACK_ALIGNED_FOR_SSE
#endif

/**
 * @}
 */

#endif // AVOCADO_GLOBAL_H
