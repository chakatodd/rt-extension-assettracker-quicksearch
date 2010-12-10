=head1 NAME

RTx::AssetTracker::AssetQuickSearch

=head1 SYNOPSIS

  use RTx::AssetTracker::AssetQuickSearch

=head1 DESCRIPTION

SavedSearch is an object based on L<RT::SharedSetting> that can belong
to either an L<RT::User> or an L<RT::Group>. It consists of an ID,
a description, and a number of search parameters.

=cut

package RTx::AssetTracker::AssetQuickSearch;

use strict;
use warnings;
use base qw/RT::SavedSearch/;

=head1 METHODS

=cut

sub SaveAttribute {
    my $self   = shift;
    my $object = shift;
    my $args   = shift;

    $args->{Type} = 'AssetQuickSearch';

    return $self->SUPER::SaveAttribute($object, $args);
}

sub _GetObject {
    my $self = shift;
    my $privacy = shift;

    my ($obj_type, $obj_id) = split(/\-/, ($privacy || ''));

    unless ($obj_type && $obj_id) {
        $privacy = '(undef)' if !defined($privacy);
        $RT::Logger->debug("Invalid privacy string '$privacy'");
        return undef;
    }

    my $object = $self->_load_privacy_object($obj_type, $obj_id);

    unless (ref($object) eq $obj_type) {
        $RT::Logger->error("Could not load object of type $obj_type with ID $obj_id, got object of type " . (ref($object) || 'undef'));
        return undef;
    }

    # Do not allow the loading of a user object other than the current
    # user, or of a group object of which the current user is not a member.

    if ($obj_type eq 'RT::User' && $object->Id != $self->CurrentUser->UserObj->Id) {
        $RT::Logger->debug("Permission denied for user other than self");
        return undef;
    }

    #if ($obj_type eq 'RT::Group' && !$object->HasMemberRecursively($self->CurrentUser->PrincipalObj)) {
        #$RT::Logger->debug("Permission denied, ".$self->CurrentUser->Name.
                           #" is not a member of group");
        #return undef;
    #}

    return $object;
}

sub Save {
    my $self = shift;
    my %args = (
        'Privacy' => 'RT::User-' . $self->CurrentUser->Id,
        'Name'    => "new " . $self->ObjectName,
                @_,
    );

    my $privacy = $args{'Privacy'};
    my $name    = $args{'Name'};
    my $object  = $self->_GetObject($privacy);

    return (0, $self->loc("Failed to load object for [_1]", $privacy))
        unless $object;

    return (0, $self->loc("Permission denied"))
        unless $self->CurrentUserCanCreate($privacy);

    my ($att_id, $att_msg) = $self->SaveAttribute($object, \%args);

    if ($att_id) {
        $self->{'Attribute'} = $object->Attributes->WithId($att_id);
        $self->{'Id'}        = $att_id;
        $self->{'Privacy'}   = $privacy;
        return ( 1, $self->loc( "Saved [_1] [_2]", $self->ObjectName, $name ) );
    }
    else {
        $RT::Logger->error($self->ObjectName . " save failure: $att_msg");
        return ( 0, $self->loc("Failed to create [_1] attribute", $self->ObjectName) );
    }
}

sub Type { 'AssetQuickSearch' }

1;
