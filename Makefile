CC ?=gcc
CFLAGS = -msse2 --std gnu99 -O0 -Wall -Wextra

EXEC = naive_transpose sse_transpose sse_prefetch_transpose
GIT_HOOKS := .git/hooks/applied

all: $(GIT_HOOKS) $(EXEC)

$(GIT_HOOKS):
	@scripts/install-git-hooks
	@echo
SRCS_common = main.c
naive_transpose:$(SRCS_common)
	$(CC) $(CFLAGS) -o $@ \
                -D NAIVE  \
                $(SRCS_common)

sse_transpose:$(SRCS_common)
	$(CC) $(CFLAGS) -o $@ \
                -D SSE  \
                $(SRCS_common)

sse_prefetch_transpose:$(SRCS_common)
	$(CC) $(CFLAGS) -o $@ \
                -D SSE_PREFETCH	 \
                $(SRCS_common)


cache-naive: $(EXEC)
	perf stat --repeat 100 \
                -e cache-misses,cache-references,instructions,cycles \
                ./naive_transpose
cache-sse:
	perf stat --repeat 100 \
                -e cache-misses,cache-references,instructions,cycles \
                ./sse_transpose
cache-prefetch:
	perf stat --repeat 100 \
                -e cache-misses,cache-references,instructions,cycles \
                ./sse_prefetch_transpose

clean:
	$(RM) naive_transpose sse_transpose sse_prefetch_transpose
