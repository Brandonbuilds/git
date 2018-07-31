#!/bin/sh

test_description='remote messages are colorized on the client'

. ./test-lib.sh

test_expect_success 'setup' '
	mkdir .git/hooks &&
	write_script .git/hooks/update <<-\EOF &&
	echo error: error
	echo hint: hint
	echo success: success
	echo warning: warning
	echo prefixerror: error
	exit 0
	EOF

	echo 1 >file &&
	git add file &&
	git commit -m 1 &&
	git clone . child &&
	cd child &&
	echo 2 >file &&
	git commit -a -m 2
'

test_expect_success 'push' '
	git -c color.remote=always \
		push -f origin HEAD:refs/heads/newbranch 2>output &&
	test_decode_color <output >decoded &&
	grep "<BOLD;RED>error<RESET>:" decoded &&
	grep "<YELLOW>hint<RESET>:" decoded &&
	grep "<BOLD;GREEN>success<RESET>:" decoded &&
	grep "<BOLD;YELLOW>warning<RESET>:" decoded &&
	grep "prefixerror: error" decoded
'

test_expect_success 'push with customized color' '
	git -c color.remote=always -c color.remote.error=white \
		push -f origin HEAD:refs/heads/newbranch2 2>output &&
	test_decode_color <output >decoded &&
	grep "<WHITE>error<RESET>:" decoded &&
	grep "<YELLOW>hint<RESET>:" decoded &&
	grep "<BOLD;GREEN>success<RESET>:" decoded &&
	grep "<BOLD;YELLOW>warning<RESET>:" decoded
'

test_done
