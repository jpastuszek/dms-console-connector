Feature: Console connector passing messages
  In order for the conponents to comunicate
  The console connector should pass messages from internal to external bus and vice-versa

	Background:
		Given dms-console-connector program
		And debug enabled
		And use linger time of 0

	Scenario: Passing messages from external to internal network
		Given external subscriber address is ipc:///tmp/dms-console-connector-ext-sub-test
		And external publisher address is ipc:///tmp/dms-console-connector-ext-pub-test
		Given internal subscriber address is ipc:///tmp/dms-console-connector-int-sub-test
		And internal publisher address is ipc:///tmp/dms-console-connector-int-pub-test
		And it is started
		When I keep publishing test message to external subscriber address
		Then I should eventually receive it on internal publisher address

