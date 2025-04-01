import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:holz_logistik/edit_user/edit_user.dart';
import 'package:holz_logistik/l10n/l10n.dart';
import 'package:users_repository/users_repository.dart';

class EditUserPage extends StatelessWidget {
  const EditUserPage({super.key});

  static Route<void> route({User? initialUser}) {
    return MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) => BlocProvider(
        create: (context) => EditUserBloc(
          usersRepository: context.read<UsersRepository>(),
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
        tooltip: l10n.editUserSaveButtonTooltip,
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
              children: [_TitleField(), _DescriptionField()],
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleField extends StatelessWidget {
  const _TitleField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<EditUserBloc>().state;
    final hintText = state.initialUser?.title ?? '';

    return TextFormField(
      key: const Key('editUserView_title_textFormField'),
      initialValue: state.title,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: l10n.editUserTitleLabel,
        hintText: hintText,
      ),
      maxLength: 50,
      inputFormatters: [
        LengthLimitingTextInputFormatter(50),
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]')),
      ],
      onChanged: (value) {
        context.read<EditUserBloc>().add(EditUserTitleChanged(value));
      },
    );
  }
}

class _DescriptionField extends StatelessWidget {
  const _DescriptionField();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final state = context.watch<EditUserBloc>().state;
    final hintText = state.initialUser?.description ?? '';

    return TextFormField(
      key: const Key('editUserView_description_textFormField'),
      initialValue: state.description,
      decoration: InputDecoration(
        enabled: !state.status.isLoadingOrSuccess,
        labelText: l10n.editUserDescriptionLabel,
        hintText: hintText,
      ),
      maxLength: 300,
      maxLines: 7,
      inputFormatters: [
        LengthLimitingTextInputFormatter(300),
      ],
      onChanged: (value) {
        context.read<EditUserBloc>().add(EditUserDescriptionChanged(value));
      },
    );
  }
}
