package RTx::AssetTracker::QuickSearch;
use strict;
use warnings;
our $VERSION = '1.0.0';

use RTx::AssetTracker;
use RTx::AssetTracker::AssetQuickSearch;
use RTx::AssetTracker::AssetQuickSearches;

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


sub remove_quicksearch {
    my ($class, $category) = @_;

    #warn "Remove asset quick search for $category";
    #if category does exist for another type, don't remove it.
    if ( my $search = $class->search_exists($category) ) {
        return $search->Delete;
    }
}

sub add_quicksearch {
    my ($class, $category, $loc) = @_;

    #warn "Add asset quick search for $category";
    #if quicksearch doesn't exist, create it
    return $class->search_exists($category) || $class->create_search($category, $loc);
}

sub create_search {
    my ($class, $category, $loc) = @_;

    my $search = RTx::AssetTracker::AssetQuickSearch->new($RT::SystemUser);
    my ($status, $msg) = $search->Save(
            Privacy      => $class->privacy_string,
            Name         => "$category " . $loc->("Quick search"),
            SearchParams => { Category => $category },
    );

    return $search;
}

sub search_exists {
    my ($class, $category) = @_;

    my $searches = RTx::AssetTracker::AssetQuickSearches->new($RT::SystemUser);
    $searches->LimitToPrivacy( $class->privacy_string, 'AssetQuickSearch' );
    while (my $search = $searches->Next) {
        return $search if $search->GetParameter('Category') eq $category;
    }

    return 0;
}

sub privacy_object {
    my ($class) = @_;

    my $group = RT::Group->new($RT::SystemUser);
    my ($status, $msg) = $group->LoadUserDefinedGroup("AssetQuickSearch");
    return $group;
}

sub privacy_string {
    my ($class) = @_;

    my $privacy_object = $class->privacy_object();
    return ref($privacy_object).'-'.$privacy_object->id;
}

1;
