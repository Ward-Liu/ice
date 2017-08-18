module app;

import std.stdio;
import std.json;
import std.file;
import std.conv;
import std.socket;
import std.bitmanip;

import ice;

StunServer[] stunServerList;
string trackerHost;
ushort trackerPort;

void main()
{
	writeln("ice example client.");
	loadConfig();
	
	Peer self = new Peer();
	//self.getNatInfo(stunServerList);
	
	writeln("peer id: ", self.peerId);
	writeln(self.natInfo);
	
	TcpSocket sock = new TcpSocket();
	sock.bind(new InternetAddress("0.0.0.0", 0));
	sock.connect(new InternetAddress(trackerHost, trackerPort));
	
	ubyte[] data = cast(ubyte[])"发送字符串测试。";
	ubyte[] buffer = new ubyte[4];
	buffer.write!int(cast(int)data.length, 0);
	buffer ~= data;
	sock.send(buffer);
	buffer = new ubyte[1024];
	sock.receive(buffer);
	sock.close();
	writeln(cast(string)buffer);
}

private void loadConfig()
{
	JSONValue j = parseJSON(std.file.readText("./ice_client.conf"));

	foreach(element; j["stun_servers_list"].array)
	{
		stunServerList ~= StunServer(element["host"].str, element["port"].str.to!ushort);
	}

	JSONValue jt = j["tracker"];
	trackerHost = jt["host"].str;
	trackerPort = jt["port"].str.to!ushort;
}