LUA := -llua -lm -ldl  

LDFLAGS += $(LUA)
CFLAGS += -Wall -Wextra -fPIC -g

CC ?= gcc

all : stream_helper.so

%o : %c
	$(CC) -c $< $(CFLAGS) -o $@

%.so : %.o
	$(CC) -o $@ $(CFLAGS) $(LDFLAGS) -shared $<

clean :
	rm -rf *.o
	rm -rf *.so
