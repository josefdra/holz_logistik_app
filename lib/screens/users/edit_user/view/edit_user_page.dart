import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/screens/users/edit_user/edit_user.dart';
import 'package:holz_logistik/widgets/user/user_widgets.dart';
import 'package:holz_logistik_backend/repository/user_repository.dart';

class EditUserPage extends StatelessWidget {
  const EditUserPage({super.key});

  static Route<void> route({User? initialUser}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => EditUserBloc(
          userRepository: context.read<UserRepository>(),
          initialUser: initialUser,
        ),
        child: const EditUserPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditUserBloc, EditUserState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == EditUserStatus.success,
      listener: (context, state) => Navigator.of(context).pop(),
      child: const EditUserView(),
    );
  }
}

class EditUserView extends StatelessWidget {
  const EditUserView({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select((EditUserBloc bloc) => bloc.state.status);
    final isNewUser = context.select(
      (EditUserBloc bloc) => bloc.state.isNewUser,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewUser
              ? 'Neuen Nutzer hinzufügen'
              : 'Nutzer bearbeiten',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'editUserPageFloatingActionButton',
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        onPressed: status.isLoadingOrSuccess
            ? null
            : () => context.read<EditUserBloc>().add(const EditUserSubmitted()),
        child: status.isLoadingOrSuccess
            ? const CircularProgressIndicator()
            : const Icon(Icons.check),
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const _RoleField(),
                const _NameField(),
                if (!isNewUser) const _IdField(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleField extends StatelessWidget {
  const _RoleField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditUserBloc>().state;
    final role = state.initialUser?.role ?? Role.basic;

    return RoleDropdown(
      initialValue: role,
      onChanged: (value) {
        context.read<EditUserBloc>().add(EditUserRoleChanged(value));
      },
    );
  }
}

class _NameField extends StatelessWidget {
  const _NameField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditUserBloc>().state;
    final hintText = state.initialUser?.name ?? '';

    return TextFormField(
      initialValue: state.name,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: 'Name',
        hintText: hintText,
      ),
      maxLength: 50,
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
      ],
      onChanged: (value) {
        context.read<EditUserBloc>().add(EditUserNameChanged(value));
      },
    );
  }
}

class _IdField extends StatelessWidget {
  const _IdField();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EditUserBloc>().state;
    final userId = state.initialUser?.id ?? '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Id: $userId'),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.copy, size: 18),
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(4),
          tooltip: 'Copy ID',
          onPressed: () {
            Clipboard.setData(ClipboardData(text: userId));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('ID kopiert'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }
}
