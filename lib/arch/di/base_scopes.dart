// coverage:ignore-file

/// Default scopes for app
/// Do not use ths predefined ids
class BaseScopes {
  /// Global scope for app level sigletons
  static const global = 'global';

  /// Scope for global interactors that will be disposed 
  /// once all holders are disposed
  static const weak = 'weak';

  /// Stub scope defining unique object scope
  static const unique = 'unique';
}
