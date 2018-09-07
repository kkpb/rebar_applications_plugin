# 今までの影響で `make` を叩いてしまう人が多そうなので `make` で `rebar3` のコマンドを促すようにする


APP=rebar_applications_plugin
DIALYZER_OPTS=-Werror_handling -Wrace_conditions -Wunmatched_returns

LIBS=$(ERL_LIBS):deps

.PHONY: all init refresh-deps compile xref clean distclean eunit ct edoc start dialyzer

all: compile xref eunit ct dialyzer edoc

init:
	@echo 'Warning: Deprecated make target'
	@echo 'Use `./rebar3 compile`'
	@./rebar3 compile

refresh-deps:
# 	./rebar refresh-deps
	@echo 'Please use `./rebar3 upgrade` or else'

compile:
	@echo 'Warning: Deprecated make target'
	@echo 'Use `./rebar3 compile`'
	@./rebar3 compile

xref:
	@echo 'Warning: Deprecated make target'
	@echo 'Use `./rebar3 xref`'
	@./rebar3 xref

clean:
	@echo 'Warning: Deprecated make target'
	@echo 'Use `./rebar3 clean`'
	@./rebar3 clean

distclean:
	git clean -df

eunit:
	@echo 'Warning: Deprecated make target'
	@echo 'Use `./rebar3 eunit`'
	@./rebar3 eunit

ct:
	@echo 'Warning: Deprecated make target'
	@echo 'Use `./rebar3 ct`'
	@./rebar3 ct

edoc:
	@echo 'Warning: Deprecated make target'
	@echo 'Use `./rebar3 as dev edoc`'
	@./rebar3 as dev edoc

start:
	@echo 'Warning: Deprecated make target'
	@echo 'Use `./rebar3 shell`'
	@./rebar3 shell

.dialyzer.plt:
# 	touch .dialyzer.plt
# 	ERL_LIBS=$(LIBS) dialyzer --build_plt --plt .dialyzer.plt --apps erts \
# 		$(shell ERL_LIBS=$(LIBS) erl -noshell -pa ebin -eval '{ok, _} = application:ensure_all_started($(APP)), [erlang:display(Name) || {Name, _, _} <- application:which_applications(), Name =/= $(APP)], halt().')
	@echo 'Please use `./rebar3 dialyzer` or else'

dialyzer:
	@echo 'Warning: Deprecated make target'
	@echo 'Use `./rebar3 dialyzer`'
	@./rebar3 dialyzer
