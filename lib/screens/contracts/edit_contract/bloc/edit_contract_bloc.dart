import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik_backend/repository/contract_repository.dart';

part 'edit_contract_event.dart';
part 'edit_contract_state.dart';

class EditContractBloc extends Bloc<EditContractEvent, EditContractState> {
  EditContractBloc({
    required ContractRepository contractsRepository,
    required Contract? initialContract,
  })  : _contractsRepository = contractsRepository,
        super(
          EditContractState(
            initialContract: initialContract,
            done: initialContract?.done ?? false,
            title: initialContract?.title ?? '',
            additionalInfo: initialContract?.additionalInfo ?? '',
          ),
        ) {
    on<EditContractTitleChanged>(_onTitleChanged);
    on<EditContractAdditionalInfoChanged>(_onAdditionalInfoChanged);
    on<EditContractSubmitted>(_onSubmitted);
  }

  final ContractRepository _contractsRepository;

  void _onTitleChanged(
    EditContractTitleChanged event,
    Emitter<EditContractState> emit,
  ) {
    final updatedErrors = Map<String, String?>.from(state.validationErrors)
      ..remove(event.fieldName);

    emit(state.copyWith(validationErrors: updatedErrors, title: event.title));
  }

  void _onAdditionalInfoChanged(
    EditContractAdditionalInfoChanged event,
    Emitter<EditContractState> emit,
  ) {
    emit(state.copyWith(additionalInfo: event.additionalInfo));
  }

  Map<String, String?> _validateFields() {
    final errors = <String, String?>{};

    if (state.title == '') {
      errors['title'] = 'Titel darf nicht leer sein';
    }

    return errors;
  }

  Future<void> _onSubmitted(
    EditContractSubmitted event,
    Emitter<EditContractState> emit,
  ) async {
    final validationErrors = _validateFields();

    if (validationErrors.isNotEmpty) {
      emit(
        state.copyWith(
          validationErrors: validationErrors,
          status: EditContractStatus.invalid,
        ),
      );
      return;
    }

    emit(state.copyWith(status: EditContractStatus.loading));

    final contract = (state.initialContract ?? Contract.empty()).copyWith(
      done: state.done,
      lastEdit: DateTime.now(),
      title: state.title,
      additionalInfo: state.additionalInfo,
    );

    try {
      await _contractsRepository.saveContract(contract);
      emit(state.copyWith(status: EditContractStatus.success));
    } catch (e) {
      emit(state.copyWith(status: EditContractStatus.failure));
    }
  }
}
