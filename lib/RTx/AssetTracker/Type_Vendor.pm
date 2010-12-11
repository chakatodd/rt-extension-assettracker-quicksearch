package RTx::AssetTracker::Type;

use strict;
no warnings qw(redefine);

use RTx::AssetTracker::QuickSearch;

sub _AddCustomFieldValue {
    my $self = shift;
    my %args = (
        Field             => undef,
        Value             => undef,
        LargeContent      => undef,
        ContentType       => undef,
        RecordTransaction => 1,
        Data              => undef,
        @_
    );

    my $remove = undef;
    my $add = undef;

    my $category = RT->Config->Get('AssetTrackerQuickSearchCustomField');

    my $cf = $self->LoadCustomFieldByIdentifier($args{'Field'});
    if ($cf->LookupType eq 'RTx::AssetTracker::Type' &&
        $cf->Name eq $category) {

        $remove = $self->FirstCustomFieldValue($category);
    }

    my ($new_value_id, $msg) = $self->SUPER::_AddCustomFieldValue(@_);

    if ($new_value_id) {
        $add = $args{Value};

        RTx::AssetTracker::QuickSearch->add_quicksearch($args{Value}, sub { $self->loc(shift) });

        if ($remove) {
            RTx::AssetTracker::QuickSearch->remove_quicksearch($remove);
        }
    }

    return ($new_value_id, $msg);
}

sub DeleteCustomFieldValue {
    my $self = shift;
    my %args = (
        Field   => undef,
        Value   => undef,
        ValueId => undef,
        Data    => undef,
        @_
    );

    my $remove = undef;

    my $category = RT->Config->Get('AssetTrackerQuickSearchCustomField');

    my $cf = $self->LoadCustomFieldByIdentifier($args{'Field'});
    if ($cf->LookupType eq 'RTx::AssetTracker::Type' &&
        $cf->Name eq $category) {

        $remove = $self->FirstCustomFieldValue($category);
    }

    my ($trans_id, $msg) = $self->SUPER::DeleteCustomFieldValue(@_);

    if ($trans_id) {
        RTx::AssetTracker::QuickSearch->remove_quicksearch($remove);
    }

    return ($trans_id, $msg);

}

1;
