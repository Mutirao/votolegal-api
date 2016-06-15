package VotoLegal::Controller::API;
use Moose;
use namespace::autoclean;

BEGIN { extends 'CatalystX::Eta::Controller::REST' }

=head1 NAME

VotoLegal::Controller::API - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub root : Chained('/') : PathPart('api') : CaptureArgs(0) {
    my ($self, $c) = @_;
    $c->response->headers->header(charset => "utf-8");
}

sub logged : Chained('root') : PathPart('') : CaptureArgs(0) {
    my ($self, $c) = @_;

    my $api_key = $c->req->param('api_key') || $c->req->header('X-API-Key');

    if (!defined($api_key)) {
        $self->status_forbidden($c, message => "access denied");
        $c->detach();
    }

    my $user_session = $c->model('DB::UserSession')->search({
        api_key      => $api_key,
        valid_for_ip => $c->req->address,
    })->first;

    if (!$user_session) {
        $self->status_forbidden($c, message => "access denied");
        $c->detach();
    }

    my $user = $c->find_user({ id => $user_session->user_id });

    $c->set_authenticated($user);
}

=encoding utf8

=head1 AUTHOR

Junior Moraes,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;