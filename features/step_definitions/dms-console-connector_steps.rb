# Copyright (c) 2012 Jakub Pastuszek
#
# This file is part of Distributed Monitoring System.
#
# Distributed Monitoring System is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Distributed Monitoring System is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Distributed Monitoring System.  If not, see <http://www.gnu.org/licenses/>.

Given /^external subscriber address is (.*)$/ do |address|
	@external_sub_address = address
	@program_args << ['--external-sub-bind-address', address]
end

Given /^external publisher address is (.*)$/ do |address|
	@external_pub_address = address
	@program_args << ['--external-pub-bind-address', address]
end

Given /^internal subscriber address is (.*)$/ do |address|
	@internal_sub_address = address
	@program_args << ['--internal-sub-bind-address', address]
end

Given /^internal publisher address is (.*)$/ do |address|
	@internal_pub_address = address
	@program_args << ['--internal-pub-bind-address', address]
end

When /^I keep publishing test message to external subscriber address$/ do
	@message = Discover.new('abc', 'xyz')
	@publisher_thread = Thread.new do
		ZeroMQ.new do |zmq|
			zmq.pub_connect(@external_sub_address, linger: 0) do |pub|
				loop do
					pub.send @message
					sleep 0.2
				end
			end
		end
	end
end

Then /^I should eventually receive it on internal publisher address$/ do
	message = nil
	Timeout.timeout 4 do
		ZeroMQ.new do |zmq|
			zmq.sub_connect(@internal_pub_address) do |sub|
				sub.on Discover do |msg|
					message = msg
				end.receive!
			end
		end
	end

	@publisher_thread.kill
	@publisher_thread.join

	message.host_name.should == @message.host_name
	message.program.should == @message.program
end

When /^I keep publishing test message to internal subscriber address$/ do
	@message = Discover.new('xyz', 'abc')
	@publisher_thread = Thread.new do
		ZeroMQ.new do |zmq|
			zmq.pub_connect(@internal_sub_address, linger: 0) do |pub|
				loop do
					pub.send @message
					sleep 0.2
				end
			end
		end
	end
end

Then /^I should eventually receive it on external publisher address$/ do
	message = nil
	Timeout.timeout 4 do
		ZeroMQ.new do |zmq|
			zmq.sub_connect(@external_pub_address) do |sub|
				sub.on Discover do |msg|
					message = msg
				end.receive!
			end
		end
	end

	@publisher_thread.kill
	@publisher_thread.join

	message.host_name.should == @message.host_name
	message.program.should == @message.program
end

