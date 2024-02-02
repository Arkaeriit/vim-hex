LUA := -lm -ldl  

LDFLAGS += $(LUA)
CFLAGS += -Wall -Wextra -fPIC -g -I lua/src/ -L./

CC ?= gcc

all : stream_helper.so

%o : %c liblua.a
	$(CC) -c $< $(CFLAGS) -o $@

%.so : %.o liblua.a
	$(CC) -o $@ $(CFLAGS) $(LDFLAGS) -shared $^

clean :
	rm -rf *.o
	rm -rf *.so
	rm -rf lua*
	rm -rf liblua.a

lua_version : lua_version.vim $(shell which vim)
	vim --cmd "source $<"

lua.tar.gz: lua_version
	curl -R -L http://www.lua.org/ftp/lua-$(shell cat $<).tar.gz -o $@

liblua.a : lua.tar.gz lua_version
	tar xzf $< && \
		mv lua-$(shell cat lua_version) lua && \
		cd lua && \
		cat ../fix_lua_cflags.vim | vim src/Makefile && \
		$(MAKE) linux src/liblua.a || $(MAKE) src/liblua.a && \
		cp src/liblua.a ..

lua_version.vim :
	echo ":lua f = io.open('lua_version', 'w') \
	           if vim.lua_version then \
	               f:write(vim.lua_version) \
	           else \
	               local version = string.gsub(_VERSION..'.0', 'Lua ', '') \
	               f:write(version) \
	           end \
	           f:close()" > $@
	echo ":q" >> $@


