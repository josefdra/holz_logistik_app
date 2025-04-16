import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/edit_user_bloc.dart';
import '../edit_user.dart';
import '../../../../../lib_old/category/core/l10n/l10n.dart';
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
    final l10n = context.l10n;
    final status = context.select((EditUserBloc bloc) => bloc.state.status);
    final isNewUser = context.select(
      (EditUserBloc bloc) => bloc.state.isNewUser,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNewUser
              ? l10n.editUserAddAppBarTitle
              : l10n.editUserEditAppBarTitle,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'editUserPageFloatingActionButton',
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(32)),
        ),
        onPressed: status.isLoadingOrSuccess
            ? null
            : () => context.read<EditUserBloc>().add(const EditUserSubmitted()),
        child: status.isLoadingOrSuccess
            ? const CupertinoActivityIndicator()
            : const Icon(Icons.check_rounded),
      ),
      body: const CupertinoScrollbar(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [_RoleField(), _NameField()],
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
    final l10n = context.l10n;
    final state = context.watch<EditUserBloc>().state;
    final hintText = state.initialUser?.name ?? '';

    return TextFormField(
      initialValue: state.name,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: l10n.editUserNameLabel,
        hintText: hintText,
      ),
      maxLength: 50,
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
      ],
      onChanged: (value) {
        context.read<EditUserBloc>().add(EditUserNameChanged(value));
      },
    );
  }
}
