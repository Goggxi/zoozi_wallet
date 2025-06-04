import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  final BuildContext context;

  const LoginEvent({
    required this.email,
    required this.password,
    required this.context,
  });

  @override
  List<Object?> get props => [email, password, context];
}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;
  final String? name;
  final BuildContext context;

  const RegisterEvent({
    required this.email,
    required this.password,
    this.name,
    required this.context,
  });

  @override
  List<Object?> get props => [email, password, name, context];
}

class LogoutEvent extends AuthEvent {}

class CheckAuthStatusEvent extends AuthEvent {}
