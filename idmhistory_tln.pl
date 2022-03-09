#! c:\perl\bin\perl.exe
#-----------------------------------------------------------
# idmhistory_tln.pl
# Plugin for Registry Ripper, NTUSER.DAT 
# IDM downloaded files
#
# Change history
# 20220308 - (2022-03-08) created by Krzysztof Gajewski
#  
#-----------------------------------------------------------
package idmhistory_tln;
use strict;
use Digest::MD5  qw(md5 md5_hex md5_base64);

my %config = (hive          => "NTUSER.DAT",
              hasShortDescr => 1,
              hasDescr      => 0,
              hasRefs       => 0,
              osmask        => 22,
              version       => 20220308);
sub getConfig{return %config}
sub getShortDescr {
	return "Checks IDM downloaded files";	
}
sub getDescr{}
sub getHive {return $config{hive};}
sub getVersion {return $config{version};}

my $VERSION = getVersion();

sub pluginmain {
	
	my $class = shift;
	my $hive = shift;
	::logMsg("Launching idmhistory_tln v.".$VERSION);
	my $reg = Parse::Win32Registry->new($hive);
	my $root_key = $reg->get_root_key;
	
	::rptMsg("");
 
	my $key;
	my $key_path = 'Software\\DownloadManager';
	
	my $class = shift;
	my $hive = shift;

	my $downloadedfile = 0;
	my $FileName = "";
	my $URL = "";
	my $Referer = "";
	my $Error = 0;

	
	if ($key = $root_key->get_subkey($key_path)) {
			my @subkeys = $key->get_list_of_subkeys();
		
			if (scalar(@subkeys) > 0) {
				foreach my $s (@subkeys) { 
					my $time = $s->get_timestamp();
					my $valuename = $s->get_name();

						my @vals = $s->get_list_of_values();
							if (scalar(@vals) > 0) 
							{
								foreach my $v (@vals) 
								{
									my $value_name = $v->get_name();
									my $value_data = $v->get_data();
									
									if ($value_name eq "Url0")
									{
										$URL = $value_data;
									}

									if ($value_name eq "FileName")
									{
											$FileName = $value_data;
									}
									
									if ($value_name eq "lastResult")
									{
										$Error = 1;
									}

								}
								
								if (($FileName ne "") && ($URL ne "") && ($Error == 0))
								{
									::rptMsg(::getDateFromEpoch($time).",REG,,,Internet Download Manager - \"".$FileName."\" was downloaded from \"".$URL."\"");
									$FileName = "";
									$URL = "";
								}
								
								elsif (($FileName eq "") && ($URL ne "") && ($Error == 0))
								{
									::rptMsg(::getDateFromEpoch($time).",REG,,,Internet Download Manager - There was an attempt to download a file from \"".$URL."\"");
									$FileName = "";
									$URL = "";
								}
								
								elsif (($URL ne "") && ($Error == 1))
								{
									::rptMsg(::getDateFromEpoch($time).",REG,,,Internet Download Manager - There was an attempt to download a file from \"".$URL."\"");
									$FileName = "";
									$URL = "";
									$Error = 0;
								}
							}
				}
			}
	}
	else {
			::rptMsg($key_path." not found\.");
	}
}
1;