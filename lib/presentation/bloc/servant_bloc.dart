import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/servant_repository.dart';

// Events
abstract class ServantEvent extends Equatable {
  const ServantEvent();
  @override
  List<Object> get props => [];
}

class LoadServants extends ServantEvent {}
class AddServant extends ServantEvent {
  final UserProfile servant;
  final String password;
  const AddServant(this.servant, this.password);
}
class UpdateServant extends ServantEvent {
  final UserProfile servant;
  const UpdateServant(this.servant);
}
class DeleteServant extends ServantEvent {
  final String id;
  const DeleteServant(this.id);
}

// States
abstract class ServantState extends Equatable {
  const ServantState();
  @override
  List<Object> get props => [];
}

class ServantInitial extends ServantState {}
class ServantLoading extends ServantState {}
class ServantLoaded extends ServantState {
  final List<UserProfile> servants;
  const ServantLoaded(this.servants);
  @override
  List<Object> get props => [servants];
}
class ServantError extends ServantState {
  final String message;
  const ServantError(this.message);
  @override
  List<Object> get props => [message];
}

// Bloc
class ServantBloc extends Bloc<ServantEvent, ServantState> {
  final ServantRepository _repository;

  ServantBloc({required ServantRepository repository})
      : _repository = repository,
        super(ServantInitial()) {
    on<LoadServants>(_onLoadServants);
    on<AddServant>(_onAddServant);
    on<UpdateServant>(_onUpdateServant);
    on<DeleteServant>(_onDeleteServant);
  }

  Future<void> _onLoadServants(LoadServants event, Emitter<ServantState> emit) async {
    emit(ServantLoading());
    try {
      final servants = await _repository.getServants();
      emit(ServantLoaded(servants));
    } catch (e) {
      emit(ServantError(e.toString()));
    }
  }

  Future<void> _onAddServant(AddServant event, Emitter<ServantState> emit) async {
    // Optimistic or waiting? Waiting is safer for Admin actions.
    try {
      await _repository.addServant(event.servant, event.password);
      add(LoadServants());
    } catch (e) {
      emit(ServantError(e.toString()));
    }
  }

  Future<void> _onUpdateServant(UpdateServant event, Emitter<ServantState> emit) async {
    try {
      await _repository.updateServant(event.servant);
      add(LoadServants());
    } catch (e) {
      emit(ServantError(e.toString()));
    }
  }

  Future<void> _onDeleteServant(DeleteServant event, Emitter<ServantState> emit) async {
    try {
      await _repository.deleteServant(event.id);
      add(LoadServants());
    } catch (e) {
      emit(ServantError(e.toString()));
    }
  }
}
