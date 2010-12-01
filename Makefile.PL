use inc::Module::Install;
RTx('RTx-AssetTracker-QuickSearch');
name('RTx-AssetTracker-QuickSearch');
license('GPL version 2');
perl_version('5.008003');
version '1.000000';
all_from('lib/RTx/AssetTracker/QuickSearch.pm');
requires(
    'RTx::AssetTracker'                => '1.2.5',
);

WriteAll();
