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
            title: initialContract?.title ?? '',
            additionalInfo: initialContract?.additionalInfo ?? '',
            startDate: initialContract?.startDate,
            endDate: initialContract?.endDate,
            availableQuantity: initialContract?.availableQuantity ?? 0,
          ),
        ) {
    on<EditContractTitleChanged>(_onTitleChanged);
    on<EditContractDateRangeChanged>(_onDateRangeChanged);
    on<EditContractAvailableQuantityChanged>(_onAvailableQuantityChanged);
    on<EditContractAdditionalInfoChanged>(_onAdditionalInfoChanged);
    on<EditContractContractFinishedUpdate>(_onContractFinishedUpdate);
    on<EditContractSubmitted>(_onSubmitted);
    on<EditContractCanceled>(_onCanceled);
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

  Future<void> _onDateRangeChanged(
    EditContractDateRangeChanged event,
    Emitter<EditContractState> emit,
  ) async {
    emit(
      state.copyWith(
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );
  }

  void _onAvailableQuantityChanged(
    EditContractAvailableQuantityChanged event,
    Emitter<EditContractState> emit,
  ) {
    emit(
      state.copyWith(
        availableQuantity: event.availableQuantity,
      ),
    );
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

    if (state.availableQuantity == 0) {
      errors['quantity'] = 'Menge darf nicht 0 sein';
    }

    return errors;
  }

  void _onContractFinishedUpdate(
    EditContractContractFinishedUpdate event,
    Emitter<EditContractState> emit,
  ) {
    emit(
      state.copyWith(contractFinished: event.contractFinished),
    );
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

    late final double bookedQuantity;
    late final double shippedQuantity;

    if (state.initialContract != null) {
      bookedQuantity = state.initialContract!.bookedQuantity;
      shippedQuantity = state.initialContract!.shippedQuantity;
    } else {
      bookedQuantity = 0;
      shippedQuantity = 0;
    }

    final contract = (state.initialContract ?? Contract()).copyWith(
      done: state.contractFinished,
      lastEdit: DateTime.now(),
      title: state.title,
      additionalInfo: state.additionalInfo,
      startDate: state.startDate,
      endDate: state.endDate,
      availableQuantity: state.availableQuantity,
      bookedQuantity: bookedQuantity,
      shippedQuantity: shippedQuantity,
    );

    try {
      await _contractsRepository.saveContract(contract);
      emit(state.copyWith(status: EditContractStatus.success));
    } catch (e) {
      emit(state.copyWith(status: EditContractStatus.failure));
    }
  }

  void _onCanceled(
    EditContractCanceled event,
    Emitter<EditContractState> emit,
  ) {
    emit(
      state.copyWith(
        status: EditContractStatus.success,
      ),
    );
  }
}
