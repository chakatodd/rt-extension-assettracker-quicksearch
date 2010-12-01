package RTx::AssetTracker::QuickSearch;
use strict;
use warnings;
our $VERSION = '1.0.0';

use RTx::AssetTracker::System;
use RTx::AssetTracker::Type;
use RTx::AssetTracker::Asset;
use RT::Shredder;

use vars qw($VERSION
        $CORE_CONFIG_FILE
        $SITE_CONFIG_FILE
	$EtcPath
	$VarPath
	$LocalPath
	$LocalEtcPath
	$LocalLexiconPath
        $ATConfigDone
);

$LocalEtcPath = "$RT::LocalPluginPath/RTx-AssetTracker-QuickSearch/etc";
$CORE_CONFIG_FILE = "$LocalEtcPath/ATQS_Config.pm";
$SITE_CONFIG_FILE = "$LocalEtcPath/ATQS_SiteConfig.pm";

1;
