#! c:\perl\bin\perl.exe
#-----------------------------------------------------------
# IDMHistory.pl
# Plugin for Registry Ripper, NTUSER.DAT 
# IDM - downloaded files
#
# Change history
# 20220308 - (2022-03-08) created by Krzysztof Gajewski
#
# https://github.com/gajos112/RegRipperPlugins
# https://www.linkedin.com/in/krzysztof-gajewski-537683b9/
# 
#-----------------------------------------------------------
package idmhistory;
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
	::logMsg("Launching idmhistory v.".$VERSION);
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
	my $UA = "";
	my $Host = "";
	my $Error = 0;
	
	my $count = 0;
	my @table;
	
	if ($key = $root_key->get_subkey($key_path)) {
			::rptMsg("Key: " . $key_path);
			::rptMsg("LastWrite Time: ".::getDateFromEpoch($key->get_timestamp())." (UTC)");
			my @subkeys = $key->get_list_of_subkeys();
			::rptMsg("");
			
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
										if($value_data eq ""){
											$FileName = "File was not downloaded properly";
										}
										else{
											$FileName = $value_data;
										}
									}
									
									if ($value_name eq "Referer")
									{
										$Referer = $value_data;
									}
									
									if ($value_name eq "UA")
									{
										$UA = $value_data;
									}
									
									if ($value_name eq "lastResult")
									{
										$Error = 1;
									}
									else{
										$Error = 0;
									}
							
								}
								
									if ($URL ne ""){
									$count = $count + 1;
									
									::rptMsg("");

									::rptMsg("Subkey:    : ".$valuename);
									
									if ($FileName ne ""){
										::rptMsg("File name  : ".$FileName."");
									}
									if ($time ne ""){
										::rptMsg("Time       : ".::getDateFromEpoch($time));
									}
									
									if ($URL ne ""){
										::rptMsg("URL        : ".$URL);
									}
									
									if ($Host ne ""){
										::rptMsg("Host       : ".$Host);
									}
									
									if ($Referer ne ""){
										::rptMsg("Referer    : ".$Referer);
									}
									
									if ($UA ne ""){
										::rptMsg("User-agent : ".$UA);
									}
																	
									::rptMsg("");
									
									$FileName = "";
									$URL = "";
									$Referer = "";
								}
							}
							
				}
			::rptMsg("Found ".$count." entries.");
			}
		}
	else {
			::rptMsg($key_path." not found\.");
	}
}
1;