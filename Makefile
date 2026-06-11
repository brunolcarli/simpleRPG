test:
	forge test -vv

coverage:
	forge coverage --ir-minimum

coverage-summary:
	forge coverage --ir-minimum --report summary