#! c:\perl\bin\perl.exe
#-----------------------------------------------------------
# packageshistory.pl
# Plugin for Registry Ripper, SOFTWARE 
# Packages History
#
# Change history
# 20220111 - (2022-01-11) created by Krzysztof Gajewski
#  
#-----------------------------------------------------------
package packageshistory;
use strict;
use Digest::MD5  qw(md5 md5_hex md5_base64);

my %config = (hive          => "Software",
              hasShortDescr => 1,
              hasDescr      => 0,
              hasRefs       => 0,
              osmask        => 22,
              version       => 20220111);

sub getConfig{return %config}
sub getShortDescr {
	return "Check all packages installed on the OS";	
}
sub getDescr{}
sub getHive {return $config{hive};}
sub getVersion {return $config{version};}

my $VERSION = getVersion();

sub pluginmain {
	
	my $class = shift;
	my $hive = shift;
	::logMsg("Launching packageshistory v.".$VERSION);
	my $reg = Parse::Win32Registry->new($hive);
	my $root_key = $reg->get_root_key;
	
	::rptMsg("");
 
	my $key;
	my $key_path = 'Microsoft\\Windows\\CurrentVersion\\Component Based Servicing\\Packages';
	
	my $UpgradePath;
	my $UpgradeTime;
	my $BuildUpdatePath;
	my $BuildUpdateTime;
	
	my $i = 0;
	
	my @empty = ();
	my @array = ();
	
	my $class = shift;
	my $hive = shift;

	if ($key = $root_key->get_subkey($key_path)) {
			
			my @subkeys = $key->get_list_of_subkeys();
			::rptMsg("");
			
			if (scalar(@subkeys) > 0) {
				foreach my $s (@subkeys) { 
					my $lw = $s->get_timestamp();
					my $str = $s->get_name();
					
					push(@empty, ::getDateFromEpoch($lw). " -> " . $str); 
					$i = $i + 1;
				}
			}
		
		@array = sort @empty;
		
		foreach (@array) {
			print "$_\n";
		}
		
		::rptMsg("\nFound " . $i . " entries.");
		
		::rptMsg("Key: " . $key_path);
			::rptMsg("LastWrite Time: ".::getDateFromEpoch($key->get_timestamp())." (UTC)");
	}
	else {
			::rptMsg($key_path." not found\.");
	}
}
1;
