Feature: Console connector passing messages
  In order for the conponents to comunicate
  The console connector should pass messages from internal to external bus and vice-versa

	Background:
		Given dms-console-connector has debug enabled
		And dms-console-connector is using linger time of 0
		And dms-console-connector external subscriber address is ipc:///tmp/dms-console-connector-ext-sub-test
		And dms-console-connector external publisher address is ipc:///tmp/dms-console-connector-ext-pub-test
		Given dms-console-connector internal subscriber address is ipc:///tmp/dms-console-connector-int-sub-test
		And dms-console-connector internal publisher address is ipc:///tmp/dms-console-connector-int-pub-test
		Given dms-console-connector is running

	Scenario: Passing messages from external to internal network
		When I keep publishing test message to external subscriber address
		Then I should eventually receive it on internal publisher address

	Scenario: Passing messages from internal to external network
		When I keep publishing test message to internal subscriber address
		Then I should eventually receive it on external publisher address

