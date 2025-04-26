part of 'location_details_bloc.dart';

sealed class LocationDetailsEvent extends Equatable {
  const LocationDetailsEvent();

  @override
  List<Object> get props => [];
}

final class LocationDetailsSubscriptionRequested extends LocationDetailsEvent {
  const LocationDetailsSubscriptionRequested();
}

final class LocationDetailsLocationUpdate extends LocationDetailsEvent {
  const LocationDetailsLocationUpdate(this.location);

  final Location location;

  @override
  List<Object> get props => [location];
}

final class LocationDetailsContractUpdate extends LocationDetailsEvent {
  const LocationDetailsContractUpdate(this.contract);

  final Contract contract;

  @override
  List<Object> get props => [contract];
}

final class LocationDetailsSawmillUpdate extends LocationDetailsEvent {
  const LocationDetailsSawmillUpdate(this.sawmills);

  final List<Sawmill> sawmills;

  @override
  List<Object> get props => [sawmills];
}

final class LocationDetailsOversizeSawmillUpdate extends LocationDetailsEvent {
  const LocationDetailsOversizeSawmillUpdate(this.oversizeSawmills);

  final List<Sawmill> oversizeSawmills;

  @override
  List<Object> get props => [oversizeSawmills];
}

final class LocationDetailsShipmentUpdate extends LocationDetailsEvent {
  const LocationDetailsShipmentUpdate(this.locationId);

  final String locationId;

  @override
  List<Object> get props => [locationId];
}

final class LocationDetailsPhotosChanged extends LocationDetailsEvent {
  const LocationDetailsPhotosChanged(this.locationId);

  final String locationId;

  @override
  List<Object> get props => [locationId];
}

final class LocationDetailsUserUpdate extends LocationDetailsEvent {
  const LocationDetailsUserUpdate(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}

final class LocationDetailsInitNames extends LocationDetailsEvent {
  const LocationDetailsInitNames();
}

final class LocationDetailsUsersUpdate extends LocationDetailsEvent {
  const LocationDetailsUsersUpdate(this.users);

  final Map<String, User> users;

  @override
  List<Object> get props => [users];
}

final class LocationDetailsSawmillsUpdate extends LocationDetailsEvent {
  const LocationDetailsSawmillsUpdate(this.sawmills);

  final Map<String, Sawmill> sawmills;

  @override
  List<Object> get props => [sawmills];
}

final class LocationDetailsLocationReactivated extends LocationDetailsEvent {
  const LocationDetailsLocationReactivated();
}
